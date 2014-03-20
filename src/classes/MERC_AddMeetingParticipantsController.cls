/**
 * @author Joseph Ferraro
 *
 * Controller for VF page that searches CST and enables user to add Accounts to Meeting as Participants
 */

public with sharing class MERC_AddMeetingParticipantsController {
    
    public GLBL_CustomerSearchToolService cstService = new GLBL_CustomerSearchToolService();
	public GLBL_CustomerSearchToolService.SearchRequest searchRequest { get; set; }
    public Boolean hasError { get; private set; }
    public String newParticipantRecordTypeId { get; set; }

	public MERC_AddMeetingParticipantsController(ApexPages.StandardSetController controller) {
        this.searchRequest = new GLBL_CustomerSearchToolService.SearchRequest();
	}

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
            	[SELECT ID, Account_MERC__c, Services_Rendered_MERC__c, Account_MERC__r.Name FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :ApexPages.currentPage().getParameters().get('id')]));
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

    public List<SelectOption> specialtyPriorityRanks {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Specialty_priority_rank_CUST__c', true);
        }
    }

    public List<SelectOption> affiliationPriorityRanks {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Affiliation_Priority_Rank_Nbr_CUST__c', true);
        }
    }

    public List<SelectOption> affiliationRoleTypes {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Affiliation_Role_Types_CUST__c', true);
        }
    }

    public List<SelectOption> accountClassifications {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Account_Clsfctn_Cd_CUST__c', true);
        }
    }

    public List<SelectOption> accountStatusTypes {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Account_Status_Types_CUST__c', true);
        }
    }

    public List<SelectOption> professionalDesignations {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Account_Bnft_Dsgn_Cd_CUST__c', true);
        }
    }

    public List<SelectOption> specialties {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Specialty_Spclty_Cd_CUST__c', true);
        }
    }

    public List<SelectOption> alternateIdTypes {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Altid_Altrnt_Id_Typ_Cd_CUST__c', true);
        }
    }

    public List<SelectOption> countries {
    	get {
    		Schema.DescribeFieldResult fieldResult = CST_User_Settings_CUST__c.Country_Code_CUST__c.getDescribe();
    		return MERC_Util.getPicklistValues(fieldResult, true);
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


    public PageReference doSearch() {
    	system.debug('>>>>>> '+this.searchRequest);
        this.searchResults = this.cstService.doSearch(this.searchRequest);
        this.searchRequest = new GLBL_CustomerSearchToolService.SearchRequest();
    	return null;
    }

    public PageReference addToMeeting() {
    	try {
    		String accountId = MERC_Util.getUrlParam('aid');
	    	Meeting_Participant_MERC__c m = new Meeting_Participant_MERC__c();
	    	m.Account_MERC__c = accountId;
	    	m.Meeting_MERC__c = meeting.Id;
            m.RecordTypeId = newParticipantRecordTypeId;
	    	insert m;
            this.meetingParticipantAccountIds.add(accountId);
	    } catch(Exception e) {
			this.newParticipantRecordTypeId = null;
            this.hasError = true;
			ApexPages.addMessages(e);
            return null;
	    }

        this.newParticipantRecordTypeId = null;
        this.hasError = false;
	    return null;
    }

    public PageReference removeFromMeeting() {
    	try {
    		String meetingParticipantId = MERC_Util.getUrlParam('pid');
            Meeting_Participant_MERC__c mp = [SELECT Id, Account_MERC__c FROM Meeting_Participant_MERC__c WHERE ID = :meetingParticipantId];
            String accountId = mp.Account_MERC__c;
            delete mp;
            this.meetingParticipantAccountIds.remove(accountId);
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