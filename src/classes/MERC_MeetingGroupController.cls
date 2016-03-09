/*
Name        :MERC_MeetingGroupController
Author      :Kyle Thornton (Mavens Consulting)
Date        :March 1, 2016
Description :This class is the controller for the Group Edit Page. The page
             allows users to add or remove meeting participants to a group.
             Only meeting participants without a group are displayed in the
             availableParticipants and can be added to the group.
             groupParticipants lists the existing members of the group and
             allows for removal of a member from the group.
 */
public with sharing class MERC_MeetingGroupController {

	public Meeting_Group_MERC__c meetingGroup { get; set; }
	public MERC_ParticipantListDataObject availableParticipants { get; set; }
	public MERC_ParticipantListDataObject groupParticipants { get; set; }
	public Boolean hasError { get; set; }

	public final String MISSING_GROUP_ID = 'Missing id parameter. Please pass a group record id in as the id parameter.';
	public final String INVALID_GROUP_ID = 'Invalid Group Id.';

	// initialize the meeting group controller
	public MERC_MeetingGroupController() {
		hasError = false;
		meetingGroup = new Meeting_Group_MERC__c();

		// get meeting id and query for the meeting
		String meetingGroupId = ApexPages.currentPage().getParameters().get('id');
		if (String.isNotBlank(meetingGroupId)) {
			try {
				meetingGroup =
			        [SELECT Id, Meeting_MERC__c, Name, Meeting_MERC__r.Name
			           FROM Meeting_Group_MERC__c
			          WHERE Id = :meetingGroupId
			          LIMIT 1];
			} catch (System.queryException ex) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, INVALID_GROUP_ID));
				hasError = true;
			}
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MISSING_GROUP_ID));
			hasError = true;
		}

		// if a meeting group was found
		if (meetingGroup != null) {
			// Set up where clauses to pass to MERC_ParticipantListDataObjects
			String availableWhereClause = 'Meeting_MERC__c = \'' + meetingGroup.Meeting_MERC__c + '\' '
			                            + 'AND Meeting_Group_MERC__c = null';

			String groupWhereClause = 'Meeting_MERC__c =\'' + meetingGroup.Meeting_MERC__c + '\' '
			 						+ 'AND Meeting_Group_MERC__c =\'' + meetingGroup.Id + '\'';

			//initialize MERC_ParticipantListDataObjcts for available participants and group participants. Pass in default page
			//size of 10 and a set of list size options
			availableParticipants = new MERC_ParticipantListDataObject(availableWhereClause, 10, new Set<Integer>{1,2,10,25,50});
			groupParticipants = new MERC_ParticipantListDataObject(groupWhereClause, 10, new Set<Integer>{10,25,50});
		}
	}

	// for all participants in the availableParticipants list that have been selected, assign them to the group
	public void addSelectedToGroup() {
		System.debug(availableParticipants.selectedParticipants);
		List<Meeting_Participant_MERC__c> participantsToAdd = new List<Meeting_Participant_MERC__c>();

		for (Meeting_Participant_MERC__c participant : availableParticipants.selectedParticipants) {
			participant.Meeting_Group_MERC__c = meetingGroup.id;
			participantsToAdd.add(participant);
		}

		update participantsToAdd;
		reinitializeLists();
	}

	// for all participants in the groupParticipants list that have been selected, remove them to the group
	public void removeSelectedFromGroup() {
		List<Meeting_Participant_MERC__c> participantsToRemove = new List<Meeting_Participant_MERC__c>();

		for (Meeting_Participant_MERC__c participant : groupParticipants.selectedParticipants) {
			participant.Meeting_Group_MERC__c = null;
			participantsToRemove.add(participant);
		}

		update participantsToRemove;
		reinitializeLists();
	}

	private void reinitializeLists() {
		availableParticipants.initializeParticipantList();
		groupParticipants.initializeParticipantList();
	}
}