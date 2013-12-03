/**
 * @author Joseph Ferraro
 *
 * Controller for VF page that searches CST and enables user to add Accounts to Meeting as Participants
 */

public with sharing class MERC_AddMeetingParticipantsController {
	
	public GLBL_CustomerSearchToolService.SearchRequest searchRequest { get; set; }
    public List<GLBL_CustomerSearchToolService.SearchResult> searchResults { get; set; }

	public MERC_AddMeetingParticipantsController(ApexPages.StandardSetController controller) {
		
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
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT ID FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :ApexPages.currentPage().getParameters().get('id')]));
            }
            return setCon;
        }
        set;
    }

    public List<Meeting_Participant_MERC__c> getMeetingParticipants() {
        return (List<Meeting_Participant_MERC__c>) setCon.getRecords();
    }

    public PageReference doSearch() {
    	this.searchResults = GLBL_CustomerSearchToolService.doSearch(this.searchRequest);
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