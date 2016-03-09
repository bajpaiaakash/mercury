/*
Name        :MERC_MeetingGroupControllerTest
Author      :Kyle Thornton (Mavens Consulting)
Date        :March 7, 2016
Description :Unit tests for MERC_MeetingGroupController
 */
@isTest
private class MERC_MeetingGroupControllerTest
{
	// declare varaibles needed for tests
	static final Integer NUM_ACCOUNTS = 10;
	static List<Account> accounts;
	static Meeting_MERC__c meeting;
	static List<Meeting_Participant_MERC__c> participants;
	static Meeting_Group_MERC__c meetingGroup;
	static MERC_MeetingGroupController controller;
	static String errorMessage;
	static User lillyUser;
	static {
		lillyUser = MERC_TestFactory.getRunningUser();
		System.runAs(lillyUser) {
			accounts     = MERC_TestFactory.insertAccounts(NUM_ACCOUNTS);
			meeting      = MERC_TestFactory.insertMeetings(1)[0];
			participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts);
		 	meetingGroup = new Meeting_Group_MERC__c(Name='Test Group', Meeting_MERC__c=meeting.id);
		 	insert meetingGroup;
		}
	}


	// Execute Tests
	@isTest
	static void itShouldInitializeWith_NUM_ACCOUNTS_Participants()
	{
		System.runAs(lillyUser) {
			givenThePageIsOpenedWithAGroupId();
			Test.startTest();
			givenTheParticipantQueriesHaveRun();
			Test.stopTest();
			thenTheAvailableParticipantsListShouldBeSize(10);
			thenTheGroupParticipantsListShouldBeSize(0);
		}
	}

	@isTest
	static void itShouldInitializeWithZeroParticipantsWhenNoGroupIsGiven() {
		System.runAs(lillyUser) {
			givenThePageIsOpenedWithoutAGroupId();
			thenTheErrorMessageShouldBe(controller.MISSING_GROUP_ID);
		}
	}

	@isTest
	static void itShouldHandleABadGroupId() {
		System.runAs(lillyUser) {
			givenThePageIsOpenedWithoutABadGroupId();
			thenTheErrorMessageShouldBe(controller.INVALID_GROUP_ID);
		}
	}

	@isTest
	static void itShouldAddParticipantsToTheGroup()
	{
		System.runAs(lillyUser) {
			givenThePageIsOpenedWithAGroupId();
			givenTheParticipantQueriesHaveRun();
			givenThreeAvailableParticpantsHaveBeenChecked();
			Test.startTest();
			whenAddSelectedToGroupIsCalled();
			Test.stopTest();
			thenTheAvailableParticipantsListShouldBeSize(7);
			thenTheGroupParticipantsListShouldBeSize(3);
		}
	}

	@isTest
	static void itShouldRemoveParticipantsToTheGroup()
	{
		System.runAs(lillyUser) {
			givenTheParticpantsAreAllPartOfTheGroup();
			givenThePageIsOpenedWithAGroupId();
			givenTheParticipantQueriesHaveRun();
			givenThreeGroupParticpantsHaveBeenChecked();
			Test.startTest();
			whenRemoveSelectedFromGroupIsCalled();
			Test.stopTest();
			thenTheAvailableParticipantsListShouldBeSize(3);
			thenTheGroupParticipantsListShouldBeSize(7);
		}
	}


	/**************************************************************
	***********************  HELPER METHODS ***********************
	*
	* Methods for reuse when running unit tests
	*/

	private static void givenThePageIsOpenedWithAGroupId() {
		PageReference pageRef = Page.MERC_MeetingGroup;
		pageRef.getParameters().put('id', meetingGroup.id);
		Test.setCurrentPage(pageRef);

		controller = new MERC_MeetingGroupController();
	}

	private static void givenTheParticipantQueriesHaveRun() {
		// in practice this is handled in the merc_participantlistcontroller
		// but to simplify things we will just set these here
		controller.availableParticipants.queryParticipants('SELECT Id FROM Meeting_Participant_MERC__c WHERE ' + controller.availableParticipants.baseWhereClause);
		controller.groupParticipants.queryParticipants('SELECT Id FROM Meeting_Participant_MERC__c WHERE ' + controller.groupParticipants.baseWhereClause);
	}

	private static void givenThePageIsOpenedWithoutAGroupId() {
		PageReference pageRef = Page.MERC_MeetingGroup;
		Test.setCurrentPage(pageRef);

		controller = new MERC_MeetingGroupController();
	}

	private static void givenThePageIsOpenedWithoutABadGroupId() {
		PageReference pageRef = Page.MERC_MeetingGroup;
		pageRef.getParameters().put('id', '000000000000000');
		Test.setCurrentPage(pageRef);

		controller = new MERC_MeetingGroupController();
	}

	private static void givenThreeAvailableParticpantsHaveBeenChecked() {
		List<MERC_ParticipantListDataObject.SelectableParticipant> selectableParticipants = controller.availableParticipants.getRecords();
		for (Integer i=0; i<3; i++) {
			selectableParticipants[i].selected = true;
		}
	}

	private static void givenThreeGroupParticpantsHaveBeenChecked() {
		List<MERC_ParticipantListDataObject.SelectableParticipant> selectableParticipants = controller.groupParticipants.getRecords();
		for (Integer i=0; i<3; i++) {
			selectableParticipants[i].selected = true;
		}
	}

	private static void givenTheParticpantsAreAllPartOfTheGroup()
 	{
 		for (Meeting_Participant_MERC__c participant : participants) {
 			participant.Meeting_Group_MERC__c = meetingGroup.id;
 		}
 		update participants;
 	}

	private static void whenAddSelectedToGroupIsCalled() {
		controller.addSelectedToGroup();
	}

	private static void whenRemoveSelectedFromGroupIsCalled() {
		controller.removeSelectedFromGroup();
	}

	private static void thenTheAvailableParticipantsListShouldBeSize(Integer participantCount) {
		System.assertEquals(participantCount, controller.availableParticipants.getRecords().size());
	}

	private static void thenTheGroupParticipantsListShouldBeSize(Integer participantCount) {
		System.assertEquals(participantCount, controller.groupParticipants.getRecords().size());
	}

	private static void thenTheErrorMessageShouldBe(String message) {
		System.assertEquals(message, ApexPages.getMessages()[0].getSummary());
		System.assert(controller.hasError);
	}
}