/*
 @ author : Vijay Garg, Tata Consultancy Services
 @ Dated  : 19 Jan 2016
 @ Descrition : This will check before update vaidation on Meeting as per US-40195. As per the User Story, user should not be
                 able to set the field 'Participant ToV Final' as 'yes' if daily attendance has not been managed for applicable 
                 Meeting Participants.
*/

public with sharing class MERC_MeetingTOVFinalValidation implements GLBL_TriggerHandler.HandlerInterface {

    List<Sobject> sobjects;
    
    public MERC_MeetingTOVFinalValidation(Schema.SobjectType sObjectType) {
    }
    
    public Boolean isActive() {
        return MERC_TriggerHandlerStateManager.isActive(MERC_MeetingTOVFinalValidation.class);
    }
    
    public void handle() { //Trigger should be run in case of before update only.
        if (Trigger.isBefore) {
            if (Trigger.isUpdate) {
                this.sobjects = Trigger.new;
                execute();
            }
        }
    }
    
    public void execute(){
        List<ID> meetingIds = new List<ID>();
        List<Meeting_MERC__c> meetings= this.sobjects;
        
        for(Meeting_MERC__c meeting: meetings){
            meetingIds.add(meeting.id);
        }
        
        //Fetching all Meeting Details like meeting record type, number of meeting days and Meeting Participant detail on meeting. 
        Map<ID, Meeting_MERC__c> meetingsDetail = new Map<ID, Meeting_MERC__c>([Select ID, Recordtype.DeveloperName, 
                                                                                    (Select ID From Meeting_Days__r),
                                                                                    (Select ID, Status_MERC__c
                                                                                     From Meeting_Participants_del__r 
                                                                                     Where Status_MERC__c in ('Approved', 'Invited', 'Interested in Meeting', 'Pending Approval', 'Accepted', 'Attended', 'No Show')
                                                                                         AND Account_MERC__r.RecordType.DeveloperName = 'HCP_GLBL' 
                                                                                         AND RecordType.DeveloperName not in ('Merc_Individual_Sponsorship', 'Merc_Consulting')) Meeting_Participants_del__r 
                                                                                 From Meeting_MERC__c
                                                                                 Where id in :meetingIds
                                                                                     AND Recordtype.DeveloperName not in ('Ad_Hoc_Consulting', 'Meeting_Program')]);
        
        //Fetch details of Daily Attendance Tov For applicable Meeting Participants on Meeting
        Map<ID, Meeting_Participant_MERC__c> meetingParticipantDailyAttendanceCount = new Map<ID, Meeting_Participant_MERC__c>([ Select ID, 
                                                      (Select ID 
                                                      From Daily_Attendance_TOV_MERC__r     
                                                      Where Status_MERC__c in ('Attended', 'No Show')) Daily_Attendance_TOV_MERC__r
                                          FROM Meeting_Participant_MERC__c
                                          Where Meeting_MERC__c in :meetingsDetail.keySet()
                                          AND Status_MERC__c in ('Accepted', 'Attended', 'No Show')
                                          AND Account_MERC__r.RecordType.DeveloperName = 'HCP_GLBL' 
                                          AND RecordType.DeveloperName in ('Merc_Service_Provider', 'Merc_Delegate')]);
                                                                                 
        Integer numberOfMeetingDays;
        
        for ( ID meetingId: meetingsDetail.keySet() ) {
            numberOfMeetingDays = meetingsDetail.get(meetingId).Meeting_Days__r.size();
            
            Meeting_MERC__c newMeeting = (Meeting_MERC__c)Trigger.newMap.get(meetingId);
            String oldParticipantToVFinal = ((Meeting_MERC__c)Trigger.oldMap.get(meetingId)).Participant_ToV_Final_MERC__c;
            
            List<Meeting_Participant_MERC__c> meetingParticipantDetails = meetingsDetail.get(meetingId).Meeting_Participants_del__r;
            
            for ( Meeting_Participant_MERC__c meetingParticipantDetail :meetingParticipantDetails  ) {
                //Need to Compare if value for Participant ToV Final has changed so that logic does not fire when triggered from Meeting Participant
                if ( newMeeting.Participant_ToV_Final_MERC__c.tolowercase() == 'yes' && oldParticipantToVFinal != newMeeting.Participant_ToV_Final_MERC__c ) {
                    if ( meetingParticipantDetail.status_MERC__c == 'Approved' || meetingParticipantDetail.status_MERC__c == 'Invited' || meetingParticipantDetail.status_MERC__c == 'Interested in Meeting' || meetingParticipantDetail.status_MERC__c == 'Pending Approval') {
                        newMeeting.addError('Participant ToV Final can only be set to \"yes\" after daily attendance for MPs has been managed');
                        break;
                    } else if ( meetingParticipantDetail.status_MERC__c == 'Accepted' || meetingParticipantDetail.status_MERC__c == 'Attended' || meetingParticipantDetail.status_MERC__c == 'No Show') {
                        if ( numberOfMeetingDays == 0 ) {
                            //Meeting days are not set up on Meeting and Meeting Participant exists on Meeting for which daily attendance should be managed    
                            newMeeting.addError('Participant ToV Final can only be set to \"yes\" after daily attendance for MPs has been managed');
                            break;
                        } else if ( numberOfMeetingDays > 0 ) {
                        //Daily attendance should be managed for applicable Meeting Participants for all meeting days
                        
                            Integer DailyAttendanceCount; //To check the number of manage daily attendance for each meeting participant
                            DailyAttendanceCount = meetingParticipantDailyAttendanceCount.get(meetingParticipantDetail.id).Daily_Attendance_TOV_MERC__r.size();
                            
                            if ( DailyAttendanceCount < numberOfMeetingDays ) {
                                newMeeting.addError('Participant ToV Final can only be set to \"yes\" after daily attendance for MPs has been managed');
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}