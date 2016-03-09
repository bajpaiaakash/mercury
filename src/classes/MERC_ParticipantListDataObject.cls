/*
	MERC_ParticipantListDataObject
	Author : Kyle Thornton (Mavens Consulting)
	Date : March 2, 2016
	Description: This class is used to pass data between the MERC_ParticipantList component and
	             the controller for a page which is using the aforementioned component.

	             The main controller can initialize an instance of this object and pass it
	             in as an attribute of the dataObject attribute of the component.
 */
public with sharing class MERC_ParticipantListDataObject {
	public List<SelectableParticipant> selectableParticipants { get; set; }
	public String baseWhereClause;
	public String participantQueryString;
	public String selectedParticipantId { get; set; }
	public final Integer defaultPageSize { get; private set; }
	public Integer pageSize {
		get;
		set {
			pageSize = Integer.valueOf(value);
			if (setController != null) {
				setController.setPageSize(pageSize);
			}
		}
	}
	public List<Integer> pageSizeOptions { get; set; }

	// initialize the data object. Must pass in a where clause, a value for default page size and a set of page size options;
	public MERC_ParticipantListDataObject(String whereClause, Integer defaultPageSize, Set<Integer> pageSizeSet) {
		initializeParticipantList();
		this.selectedParticipantId = '';
		this.baseWhereClause = whereClause;
		this.defaultPageSize = defaultPageSize != null ? defaultPageSize : 10;
		this.pageSize = defaultPageSize;

		// default list to 10/25/50 if no options passed
		if (pageSizeSet == null || pageSizeSet.size() == 0) {
			pageSizeSet = new Set<Integer>{10,25,50};
		}

		//ensure the default value appears in the options
		pageSizeSet.add(defaultPageSize);

		//convert set to list and sort it
		this.pageSizeOptions = new List<Integer>();
		this.pageSizeOptions.addAll(pageSizeSet);
		this.pageSizeOptions.sort();
	}

	// initialzie the result list and reset the setController
	public void initializeParticipantList() {
		selectableParticipants = new List<SelectableParticipant>();
		setController = null;
	}

	// take in a query string and initialize the lists for a new query
	public void queryParticipants(String query) {
		participantQueryString = query;
		initializeParticipantList();
	}

	public List<SelectableParticipant> getRecords() {
		selectableParticipants = new List<SelectableParticipant>();

		for (Meeting_Participant_MERC__c participant : (List<Meeting_Participant_MERC__c>) setController.getRecords()) {
			// wrap the passed in meeting participant and add the selectable participant to the list
			selectableParticipants.add(new SelectableParticipant(participant));
		}

		return selectableParticipants;
	}

	// Return selected participants as a list of meeting participants
	// Allows caller to simply iterate through the list and perform
	// the necessary actions against the selected participants
	public List<Meeting_Participant_MERC__c> selectedParticipants {
		get {
			List<Meeting_Participant_MERC__c> participants = new List<Meeting_Participant_MERC__c>();
			for (SelectableParticipant participant : selectableParticipants) {
				if (participant.selected) {
					participants.add(participant.detail);
				}
			}
			return participants;
		}
	}

	// Wrapper class for the participant
	// Sets detail to the passed in participant and appends a selected boolean
	public class SelectableParticipant {
		public Meeting_Participant_MERC__c detail { get; private set; }
		public Boolean selected { get; set; }

		public SelectableParticipant(Meeting_Participant_MERC__c participant) {
			this.detail = participant;
			selected = false;
		}
	}

	// create a set controller out of the particpants based on the query string that was set
	public ApexPages.StandardSetController setController {
		get {
			if (setController == null) {
				List<Meeting_Participant_MERC__c> participants = new List<Meeting_Participant_MERC__c>();
				if (String.isNotBlank(participantQueryString)) {
					participants = Database.query(participantQueryString);
				}
				setController = new ApexPages.StandardSetController(participants);
				if (pageSize != null) {
					setController.setPageSize(pageSize);
				}
			}
			return setController;
		}
		set;
	}
}