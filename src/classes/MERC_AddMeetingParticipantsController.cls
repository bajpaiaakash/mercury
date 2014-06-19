/**
 * @author Joseph Ferraro and Sean Harrison
 *
 * Controller for VF page that searches CST and enables user to add Accounts to Meeting as Participants
 */

public with sharing class MERC_AddMeetingParticipantsController {

    public GLBL_CustomerSearchToolService cstService = new GLBL_CustomerSearchToolService();
	public GLBL_CustomerSearchToolService.SearchRequest searchRequest { get; set; }
    public Boolean hasError { get; private set; }
    private String oldParticipantRecordTypeId { get; set; }
    public Meeting_Participant_MERC__c meetingParticipant { get; set; }

	public MERC_AddMeetingParticipantsController(ApexPages.StandardSetController controller) {
        this.searchRequest = new GLBL_CustomerSearchToolService.SearchRequest();
        meetingParticipant = new Meeting_Participant_MERC__c();
	}

    //if cst token is expired, it will grab a new one
    public void ensureCstToken() {
        this.cstService.refreshToken();
    }

	public Meeting_MERC__c meeting {
		get {
			if (meeting == null) {
				meeting = [Select Id, Name From Meeting_MERC__c Where Id = :ApexPages.currentPage().getParameters().get('id')];
			}
			return meeting;
		}
		private set;
	}

	public ApexPages.StandardSetController setCon {
        get {
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
            	[SELECT ID, Account_MERC__c, Services_Rendered_MERC__c, Account_MERC__r.Name, Status_MERC__c FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :ApexPages.currentPage().getParameters().get('id')]));
            return setCon;
        }
        set;
    }

    public Integer getMpCount() {
        return [SELECT count() FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meeting.Id];
    }

    public Integer getSrCount() {
        if (this.searchResults == null)
            return 0;
        return searchResults.size();
    }

    public List<Meeting_Participant_MERC__c> getMeetingParticipants() {
        return (List<Meeting_Participant_MERC__c>) setCon.getRecords();
    }

    public List<SelectOption> recordTypeOptions {
        get {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--Select--'));
            for (RecordType rt : [SELECT ID, Name From RecordType WHERE SobjectType = 'Meeting_Participant_MERC__c']) {
                options.add(new SelectOption(rt.Id, rt.Name));
            }
            return options;
        }
    }

    public Set<String> meetingParticipantAccountIds {
    	get {
			if (meetingParticipantAccountIds == null) {
                meetingParticipantAccountIds = new Set<String>();
                for (Meeting_Participant_MERC__c mp : [SELECT ID, Account_MERC__c FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :this.Meeting.Id AND Account_MERC__c != null]) {
                    meetingParticipantAccountIds.add(mp.Account_MERC__c);
                }
            }
    		return meetingParticipantAccountIds;
    	}
    	set;
    }

    /* the following set up the select options based on CST settings */

    public List<SelectOption> specialtyPriorityRanks {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Only Specialty Ranks', false);
        }
    }

    public List<SelectOption> affiliationPriorityRanks {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Search only Priority Ranks', false);
        }
    }

    public List<SelectOption> affiliationRoleTypes {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Relationship Role', false);
        }
    }

    public List<SelectOption> accountClassifications {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Classification', false);
        }
    }

    public List<SelectOption> accountStatusTypes {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Status', false);
        }
    }

    public List<SelectOption> professionalDesignations {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Professional Designation', false);
        }
    }

    public List<SelectOption> specialties {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Specialty', false);
        }
    }

    public List<SelectOption> alternateIdTypes {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Alternate Id Type', false);
        }
    }

    /**
     * For countries to appear in the user select list, util methods are called to check the following:
     *     - User is a member of a territory
     *     - That territory and its children have a custom ISO country fields
     *     - The value of the ISO country fields are each contained in the availble picklist values of
     *           CST_User_Settings_CUST__c.Country_Code_CUST__c
     */
    public List<SelectOption> countries {
    	get {
           return MERC_Util.getCountryPicklistValuesForCurrentUser(true);
    	}
    }

    public List<SelectOption> dummy {
    	get {
    		List<SelectOption> options = new List<SelectOption>();
    		options.add(new SelectOption('',''));
    		return options;
    	}
    }

    public List<GLBL_CustomerSearchToolService.SearchResult> searchResults {
        get {
            if (searchResults != null) {
                for (GLBL_CustomerSearchToolService.SearchResult result : searchResults) {
                    result.selectable = !meetingParticipantAccountIds.contains(result.sfid);
                }
            }
            return searchResults;
        }
        private set {
            searchResults = value;
        }
    }

    //performs the search against the CST
    public PageReference doSearch() {
        p('Entering doSearch!!!!!!');
    	system.debug('>>>>>> '+this.searchRequest);
        this.searchResults = this.cstService.doSearch(this.searchRequest);
        // if error, returns null & cstService.error will be available
        if (this.searchResults==null && this.cstService.error != null) {
            this.hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, this.cstService.error.Error+': '+this.cstService.error.Message));
        }
        this.searchRequest = new GLBL_CustomerSearchToolService.SearchRequest();
    	return null;
    }

    static void p(String m) {
        System.debug('\n\n\nYYZ - '+m+'\n\n\n\n');
    }


    //returns a list of required fields to be used in the UI
    public List<Schema.FieldSetMember> requiredFields {
        get {
            // new page or record type changed so reset the meeting participant
            if (String.isBlank(meetingParticipant.RecordTypeId) || meetingParticipant.RecordTypeId != oldParticipantRecordTypeId) {
                oldParticipantRecordTypeId = meetingParticipant.RecordTypeId;
                meetingParticipant = new Meeting_Participant_MERC__c(RecordTypeId=meetingParticipant.RecordTypeId);
            }

            List<Schema.FieldSetMember> requiredFields = new List<Schema.FieldSetMember>();

            // get the developer name for the record type that has been selected
            List<RecordType> recType = [SELECT Id
                                             , DeveloperName
                                          FROM RecordType
                                         WHERE Id=:meetingParticipant.RecordTypeId
                                           AND SobjectType = 'Meeting_Participant_MERC__c'];
            System.debug('\n\n\nrecType: ' + recType + '\n\n\n');

            if (!recType.isEmpty()) {
                // find the custom setting that is configured for the record type by developer name
                List<Add_Participant_Rec_Type_Req_Fields_MERC__c> reqFields = [SELECT Id
                                                                                    , Meeting_Participant_Field_Set_MERC__c
                                                                                FROM Add_Participant_Rec_Type_Req_Fields_MERC__c
                                                                                WHERE Record_Type_Developer_Name_MERC__c =: recType.get(0).DeveloperName];

                System.debug('\n\n\nrecFields: ' + reqFields + '\n\n\n');

                // if we have a custom setting, find the configured field set and return those fields.
                if (!reqFields.isEmpty()) {
                    for (Schema.FieldSetMember fsm : Schema.SObjectType.Meeting_Participant_MERC__c.fieldSets.getMap().get(reqFields.get(0).Meeting_Participant_Field_Set_MERC__c).getFields()) {
                        requiredFields.add(fsm);
                    }
                }
            }
            return requiredFields;
        }
        set;
    }

    public PageReference addToMeetingAndRedirect(){
        Id participantId = addAcctToMeeting();
        System.debug('Participant Id: ' + participantId);
        if(participantId != null){
            PageReference page = new PageReference('/' + participantId + '/e');
            return page;
        } else{
            return null;
        }
    }

    public PageReference addToMeeting() {
    	addAcctToMeeting();
	    return null;
    }

    public Id addAcctToMeeting(){
        try {
            String accountId = MERC_Util.getUrlParam('aid');
            if (String.isBlank(meetingParticipant.RecordTypeId))
            {
                throw new MERC_Exception('A Record Type is required to add an account to the meeting.');
            }
            meetingParticipant.Account_MERC__c = accountId;
            meetingParticipant.Meeting_MERC__c = meeting.Id;
            //meetingParticipant.RecordTypeId = newParticipantRecordTypeId;
            System.debug(meetingParticipant);
            insert meetingParticipant;
            this.meetingParticipantAccountIds.add(accountId);
        } catch(Exception e) {
            System.debug(e);
            //this.newParticipantRecordTypeId = null;
            this.hasError = true;
            ApexPages.addMessages(e);
            return null;
        }

        Id meetingParticipantId = meetingParticipant.Id;

        //this.newParticipantRecordTypeId = null;
        this.meetingParticipant = new Meeting_Participant_MERC__c();
        this.hasError = false;
        return meetingParticipantId;
    }

    public PageReference removeFromMeeting() {
    	try {
    		String meetingParticipantId = MERC_Util.getUrlParam('pid');
            Meeting_Participant_MERC__c mp = [SELECT Id, Account_MERC__c, Status_MERC__c FROM Meeting_Participant_MERC__c WHERE ID = :meetingParticipantId];
            mp.Status_MERC__c = 'Cancelled';
            update mp;
            //String accountId = mp.Account_MERC__c;
            //delete mp;
            //this.meetingParticipantAccountIds.remove(accountId);
    	} catch(Exception e) {
			this.hasError = true;
			ApexPages.addMessages(e);
            return null;
    	}
    	this.hasError = false;
    	return null;
    }

	//public List<MeetingParticipantWrapper> participants {
	//	get {
	//		for (Meeting_Participant_MERC__c p : );
	//	}
	//}

	//public class MeetingParticipantWrapper {
	//	public Boolean selected { get; set; }
	//	public Meeting_Participant_MERC__c participant { get; set; }
	//	public MeetingParticipantWrapper(Meeting_Participant_MERC__c p) {
	//		this.participant = p;
	//	}
	//}

	public List<GLBL_CustomerSearchToolService.SearchResult> results {
		get {
			return null;
		}
	}
}