/**
 * @author Joseph Ferraro
 *
 * Controller for VF page that searches CST and enables user to add Accounts to Meeting as Participants
 */

public with sharing class MERC_AddMeetingParticipantsController {
	
	public GLBL_CustomerSearchToolService.SearchRequest searchRequest { get; set; }
    public List<GLBL_CustomerSearchToolService.SearchResult> searchResults { get; set; }
    public Boolean hasError { get; private set; }

	public MERC_AddMeetingParticipantsController(ApexPages.StandardSetController controller) {
		this.searchRequest = new GLBL_CustomerSearchToolService.SearchRequest();
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

    public List<Meeting_Participant_MERC__c> getMeetingParticipants() {
        return (List<Meeting_Participant_MERC__c>) setCon.getRecords();
    }

    public Set<String> meetingParticipantAccountIds {
    	get {
			meetingParticipantAccountIds = new Set<String>();
			for (Meeting_Participant_MERC__c mp : [SELECT ID, Account_MERC__c FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :this.Meeting.Id AND Account_MERC__c != null]) {
				meetingParticipantAccountIds.add(mp.Account_MERC__c);
			}
    		return meetingParticipantAccountIds;
    	}
    	set;
    }

    public PageReference doSearch() {
    	this.searchResults = GLBL_CustomerSearchToolService.doSearch(this.searchRequest);
    	for (GLBL_CustomerSearchToolService.SearchResult result : this.searchResults) {
    		system.debug('..... '+result);
    		result.selectable = !meetingParticipantAccountIds.contains(result.sfid);
    	}
    	this.searchRequest = new GLBL_CustomerSearchToolService.SearchRequest();
    	return null;
    }

    public PageReference addToMeeting() {
    	try {
    		String accountId = MERC_Util.getUrlParam('aid');
	    	Meeting_Participant_MERC__c m = new Meeting_Participant_MERC__c();
	    	m.Account_MERC__c = accountId;
	    	m.Meeting_MERC__c = meeting.Id;
	    	insert m;
	    } catch(Exception e) {
			this.hasError = true;
			ApexPages.addMessages(e);
	    }
	    this.hasError = false;
	    return null;
    }

    public PageReference removeFromMeeting() {
    	try {
    		String meetingParticipantId = MERC_Util.getUrlParam('pid');
    		delete [SELECT ID From Meeting_Participant_MERC__c WHERE Id = :meetingParticipantId];
    	} catch(Exception e) {
			this.hasError = true;
			ApexPages.addMessages(e);
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