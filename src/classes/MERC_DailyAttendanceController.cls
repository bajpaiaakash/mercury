/**
 * @author Joseph Ferraro
 *
 * controller for Meeting Daily Attendance UI
 * -when the page loads, any missing daily attendance tov records for the participants are inserted with a blank "status" value
 * -we're also reloading MP status when their status updates to show real-time TOV numbers. if this isn't necessary,
 *  we could save some processing time
 */
public with sharing class MERC_DailyAttendanceController {

    public String selectedMeetingDayId { get; set; }
    public Boolean refreshParticipants { get; set; }
    public Boolean hasError { get; private set; }
    public static Integer pageSize = 100;
    public List<ParticipantWrapper> participants = new List<ParticipantWrapper>();

    public MERC_DailyAttendanceController(ApexPages.StandardSetController c) {
        this.refreshParticipants = false;
        this.hasError = false;
        validate();
    }

    private Integer pageNumber;

    //make sure every meeting participant has a tov record for every meeting day
    public PageReference upsertMissingTovRecords() {
        try {
            List<Daily_Attendance_TOV_MERC__c> tovsToUpsert = new List<Daily_Attendance_TOV_MERC__c>();

            for (Meeting_Day_MERC__c day : [SELECT ID, (SELECT ID, Meeting_Participant_MERC__c FROM Daily_Attendance_TOV__r) FROM Meeting_Day_MERC__c WHERE Meeting_MERC__c = :meeting.Id]) {
                Set<Id> participantIdsWithTovsForThisDay = new Set<Id>();
                for (Daily_Attendance_TOV_MERC__c tov : day.Daily_Attendance_TOV__r) {
                    participantIdsWithTovsForThisDay.add(tov.Meeting_Participant_MERC__c);
                }
                for (Id participantId : participantIds) {
                    if (!participantIdsWithTovsForThisDay.contains(participantId)) {
                        Daily_Attendance_TOV_MERC__c tovRecord = new Daily_Attendance_TOV_MERC__c();
                        tovRecord.Meeting_Participant_MERC__c = participantId;
                        tovRecord.Meeting_Day_MERC__c = day.Id;
                        tovRecord.External_ID_MERC__c = participantId+'_'+day.Id;
                        tovRecord.CurrencyIsoCode = meeting.CurrencyIsoCode;
                        tovsToUpsert.add(tovRecord);
                    }
                    if (tovsToUpsert.size() >=100) break; //where there are a lot of meeting days to create this will ensure that the page doesn't hit any limits
                }
            }
            if (tovsToUpsert.size() > 0) {
                Integer attempts = 3;
                while (attempts > 0) {
                    try {
                        attempts--;
                        upsert tovsToUpsert External_ID_MERC__c;
                        attempts = 0;
                        PageReference p = Page.MERC_DailyAttendance;
                        p.getParameters().put('id', meeting.Id);
                        p.setRedirect(true);
                        return p;
                    } catch (Exception dmlEx) {
                        if (!dmlEx.getMessage().contains('UNABLE_TO_LOCK_ROW') || attempts == 0) {
                            attempts = 0;  // exit on any other exception
                            throw dmlEx;  // throw exception after MAX_ATTEMPTS
                        }
                    }
                }
            }
            return null;
        } catch (Exception e) {
            this.hasError = true;
            ApexPages.addMessages(e); //doesn't show ugly error text
            return null;
        }
    }

    public Integer nonQualifiedParticipantSize {
        get {
            //Id employeeRecordTypeId = [SELECT ID FROM RecordType WHERE SobjectType = 'Account' and DeveloperName = 'Employee_GLBL'].ID;
            // on query AND Account_MERC__r.RecordTypeId != :employeeRecordTypeId 
            List<String> excludedStatuses = new List<String>{ 'Pending Approval', 'Declined', 'Interested in Meeting', 'Cancelled', 'Rejected', 'Invited' };
            Integer result = [SELECT Name 
                                FROM Meeting_Participant_MERC__c
                               WHERE Meeting_MERC__c = :meeting.Id 
                                 AND Status_MERC__c IN :excludedStatuses].size();
            return result;
        }
        private set;
    }

    Set<Id> participantIds {
        get {
            if (participantIds == null) {
                participantIds = new Set<Id>();
                //Id employeeRecordTypeId = [SELECT ID FROM RecordType WHERE SobjectType = 'Account' and DeveloperName = 'Employee_GLBL'].ID;
                // on query Account_MERC__r.RecordTypeId != :employeeRecordTypeId AND
                List<String> excludedStatuses = new List<String>{ 'Pending Approval', 'Declined', 'Interested in Meeting', 'Cancelled', 'Rejected', 'Invited' };
                for (Meeting_Participant_MERC__c p : [SELECT ID FROM
                                                                    Meeting_Participant_MERC__c
                                                                        WHERE
                                                                            Meeting_MERC__c = :meeting.Id AND
                                                                            Status_MERC__c NOT IN :excludedStatuses
                                                    ]) {
                    participantIds.add(p.Id);
                }
            }
            return participantIds;
        }
        private set;
    }

    void validate() {
        if (meetingDays.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please add Meeting Days to this Meeting.'));
            this.hasError = true;
        }
        if (!this.hasError) {
            this.selectedMeetingDayId = meetingDays.get(0).Id;
            getParticipants();
        }
        if (participants.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Only those Meeting Participants that are allocated to attend (with a status of Approved, Accepted, Attended or No Show) will appear in this list. Please ensure Meeting Participants have been added to the Meeting and all Meeting Participants have the correct Status.'));
            this.hasError = true;
        }
        if (!this.hasError) {
            this.hasError = false;
        }
    }

    public Meeting_MERC__c meeting {
        get {
            if (meeting == null) {
                meeting = [Select Id, Name, CurrencyIsoCode From Meeting_MERC__c Where Id = :ApexPages.currentPage().getParameters().get('id')];
            }
            return meeting;
        }
        private set;
    }

    public List<Meeting_Day_MERC__c> meetingDays {
        get {
            if (meetingDays == null) {
                meetingDays = [Select Id, Name, Date_MERC__c From Meeting_Day_MERC__c Where Meeting_MERC__c = :meeting.Id order by Date_MERC__c];
            }
            return meetingDays;
        }
        private set;
    }

    public PageReference changeDay() {
        this.pageNumber = null;
        this.refreshParticipants = true;
        return null;
    }

    public PageReference setSelectedToNoShow() {
        try {
            this.pageNumber = tovs.getPageNumber();
            List<Daily_Attendance_TOV_MERC__c> tovsToUpsert = new List<Daily_Attendance_TOV_MERC__c>();
            for (ParticipantWrapper p : participants) {
                if (p.selected) {
                    p.selected = false;
                    p.tov.Status_MERC__c = 'No Show';
                    p.tov.External_ID_MERC__c = p.tov.Meeting_Participant_MERC__c+'_'+selectedMeetingDayId;
                    tovsToUpsert.add(p.tov);
                }
            }
            upsert tovsToUpsert External_ID_MERC__c;
            this.refreshParticipants = true;
        } catch(Exception e) {
            ApexPages.addMessages(e); //doesn't show ugly error text
        }
        return null;
    }

    public PageReference setSelectedToAttended() {
        try {
            this.pageNumber = tovs.getPageNumber();
            List<Daily_Attendance_TOV_MERC__c> tovsToUpsert = new List<Daily_Attendance_TOV_MERC__c>();
            for (ParticipantWrapper p : participants) {
                if (p.selected) {
                    p.selected = false;
                    p.tov.Status_MERC__c = 'Attended';
                    p.tov.External_ID_MERC__c = p.tov.Meeting_Participant_MERC__c+'_'+selectedMeetingDayId;
                    tovsToUpsert.add(p.tov);
                }
            }
            upsert tovsToUpsert External_ID_MERC__c;
            this.refreshParticipants = true;
        } catch(Exception e) {
            ApexPages.addMessages(e); //doesn't show ugly error text
        }
        return null;
    }

    public PageReference saveAll() {
        try {
            this.pageNumber = tovs.getPageNumber();
            List<Daily_Attendance_TOV_MERC__c> tovsToSave = new List<Daily_Attendance_TOV_MERC__c>();
            for (ParticipantWrapper p : participants) {
                tovsToSave.add(p.tov);
            }
            upsert tovsToSave;
        } catch(Exception e) {
            ApexPages.addMessages(e); //doesn't show ugly error text
        }
        this.refreshParticipants = true;
        return null;
    }

    public PageReference updateTov() {
        try {
            String tovRecordId = ApexPages.currentPage().getParameters().get('tovRecordId');
            system.debug('>>>>> UPDATING TOV');
            system.debug('>>>>> '+tovRecordId);
            system.debug('>>>>> '+participants);
            for (ParticipantWrapper p : participants) {
                if (p.tov.Id == tovRecordId) {
                    p.tov.External_ID_MERC__c = p.tov.Meeting_Participant_MERC__c+'_'+selectedMeetingDayId;
                    upsert p.tov External_ID_MERC__c;
                    break;
                }
            }
            this.refreshParticipants = true;
        } catch(Exception e) {
            ApexPages.addMessages(e); //doesn't show ugly error text
        }
        return null;
    }

    public List<SelectOption> getMeetingDayOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for (Meeting_Day_MERC__c m : meetingDays) {
            if (m.Date_MERC__c != null) {
                Datetime myDatetime = Datetime.newInstance(m.Date_MERC__c, Time.newInstance(12, 0, 0, 0));
                String sFormattedDate = myDatetime.format('MMMM d,  yyyy');
                options.add(new SelectOption((String)m.Id, m.Name + ' (' + sFormattedDate + ')'));
            } else {
                options.add(new SelectOption((String)m.Id, m.Name));
            }
        }
        return options;
    }

    /*public List<ParticipantWrapper> participant {
        get {
            if (participants == null || refreshParticipants) {
                participants = new List<ParticipantWrapper>();
                for (Daily_Attendance_TOV_MERC__c tovRecord : [SELECT
                                                                    Id, Name,
                                                                    Meeting_Day_MERC__c,
                                                                    Meeting_Participant_MERC__c,
                                                                    Est_Food_Bev_ToV_MERC__c,
                                                                    Est_Grnd_Transp_MERC__c,
                                                                    Est_Grp_Grnd_Transp_MERC__c,
                                                                    Est_Indv_Transfer_MERC__c,
                                                                    Est_Reg_Amt_ToV_MERC__c,
                                                                    Est_Hotel_ToV_MERC__c,
                                                                    Status_MERC__c, External_ID_MERC__c,
                                                                    Meeting_Participant_Record_Type_MERC__c,
                                                                    Meeting_Participant_Account_Name_MERC__c,
                                                                    Confirm_ToV_Reporting_Change_MERC__c
                                                                        FROM Daily_Attendance_TOV_MERC__c
                                                                        WHERE Meeting_Day_MERC__c = :this.selectedMeetingDayId
                                                                        AND Meeting_Participant_MERC__r.Status_MERC__c != 'Approved'
                                                                        ORDER BY Meeting_Participant_Account_Name_MERC__c])
                {
                    if(tovRecord.Confirm_ToV_Reporting_Change_MERC__c) {
                        tovRecord.Confirm_ToV_Reporting_Change_MERC__c = false;
                    }
                    participants.add(new ParticipantWrapper(tovRecord));
                }
            }
            if (this.refreshParticipants)
                this.refreshParticipants = false;

            return participants;
        }
        set;
    }*/

    public ApexPages.StandardSetController tovs {
        get {
            if (tovs == null || refreshParticipants) {
                refreshParticipants = false;

                String soqlQuery = 'SELECT Id, ' +
                                          'Name, ' +
                                          'Meeting_Day_MERC__c, ' +
                                          'Meeting_Participant_MERC__c, ' +
                                          'Est_Food_Bev_ToV_MERC__c, ' +
                                          'Est_Grnd_Transp_MERC__c, ' +
                                          'Est_Grp_Grnd_Transp_MERC__c, ' +
                                          'Est_Indv_Transfer_MERC__c, ' +
                                          'Est_Reg_Amt_ToV_MERC__c, ' +
                                          'Est_Hotel_ToV_MERC__c, ' +
                                          'Status_MERC__c,  External_ID_MERC__c,' +
                                          'Meeting_Participant_Record_Type_MERC__c, ' +
                                          'Meeting_Participant_Account_Name_MERC__c, ' +
                                          'Confirm_ToV_Reporting_Change_MERC__c '  +
                                     'FROM Daily_Attendance_TOV_MERC__c ' +
                                    'WHERE Meeting_Day_MERC__c = :selectedMeetingDayId ' +
                                      'AND Meeting_Participant_MERC__r.Status_MERC__c != \'Approved\' ' +
                                 'ORDER BY Meeting_Participant_Account_Name_MERC__c';
                tovs = new ApexPages.StandardSetController(Database.getQueryLocator(soqlQuery));
               // sets the number of records in each page set
                tovs.setPageSize(pageSize);

                // If page number is set then update the page number in the meeting tasks
                if (pageNumber != null) {
                    tovs.setPageNumber(pageNumber);
                }
            }
            return tovs;
        }
        set;
    }

    /*
        - return a list of wrapped meeting Daily attendance records
        - deepClone the records from the standard set controller to avoid "modified rows exist in the records collection!" error.
    */
    public List<ParticipantWrapper> getParticipants() {
        participants = new List<ParticipantWrapper>();
        for (Daily_Attendance_TOV_MERC__c tovRecord : (List<Daily_Attendance_TOV_MERC__c>)tovs.getRecords().deepClone(true, true, true)) {
            participants.add(new ParticipantWrapper(tovRecord));
        }
        return participants;
    }

    public class ParticipantWrapper {
        public Boolean selected { get; set; }
        public Daily_Attendance_TOV_MERC__c tov { get; set; }
        public ParticipantWrapper(Daily_Attendance_TOV_MERC__c tov) {
            this.tov = tov;
            this.selected = false;
        }
    }
}