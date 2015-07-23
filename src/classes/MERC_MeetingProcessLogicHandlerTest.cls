/*
 * Author: Kyle Thornton - Mavens Consulting
 * Created Date: 22 Jul 2015
 * Description : This is the test class for the MERC_MeetingProcessLogicHandler.
 *               After this functionality has made it to production it will be possible
 *               to load up the Meeting Process Logic Records using Test.loadData and a
 *               static resource since record type Ids will remain consisent. At this
 *               point however there is no way to identify the record type needed for
 *               each record and we can't load it using Test.loaddata since the Record
 *               type Ids won't be the same from environment to environment.
*/
@isTest
private class MERC_MeetingProcessLogicHandlerTest {

	static List<Meeting_MERC__c> meetings;
	static List<Account> accounts;
	static List<Meeting_Participant_MERC__c> participants;
	static List<Travel_Itinerary_MERC__c> proposals;

	static {
		meetings     = Merc_TestFactory.insertMeetings(1);
		accounts     = Merc_TestFactory.insertAccounts(200);
		participants = Merc_TestFactory.insertParticipants(meetings[0].Id, accounts, 'Approved');
	}

	/**** SCENARIO : Process being created should spawn new task ****/
	@isTest
	static void newProcessShouldCreateNewTask() {
		givenAProcessLogicRecordForPreMeetingInformation();

		Test.startTest();
		whenPreMeetingInformationProcessCreatedFor(participants);
		Test.stopTest();

		expectTasksToBeCreatedForProcessesFor(participants);
	}

	/**** SCENARIO: participant updated to invited should spawn the registration process ****/
	@isTest
	static void invitedParticipantsShouldGetRegProcessCreated() {
		givenAProcessLogicRecordForInvitedMercuryParticipant();
		givenTheMeetingHasInitiateDelegateManagement('Yes');

		Test.startTest();
		whenTheParticipantsStatusBecomes('Invited');

		Test.stopTest();

		expectProcessToBeCreatedFor(participants, 'Registration');
	}

	/**** SCENARIO: invited participants accep ****/
	@isTest
	static void acceptedParticipantsShouldHaveRegProcessClosedPreMeeetingStarted() {
		//once lookup rollup summaries are gone this might be possible to remove.
		MERC_TriggerHandlerStateManager.deactivateAll();
		MERC_TriggerHandlerStateManager.activate(MERC_MeetingProcessLogicHandler.class);

		givenTheMeetingHasInitiateDelegateManagement('Yes');
		givenTheParticipantsHaveBeenInvited();
		givenAProcessLogicRecordForAcceptedMercuryParticipant();
		givenAProcessLogicRecordForPreMeetingInformation();

		Test.startTest();
		whenTheParticipantsStatusBecomes('Accepted');
		Test.stopTest();

		expectProcessToBeCompletedFor(participants, 'Registration');
		expectProcessToBeCreatedFor(participants, 'Pre-Meeting Information');
	}

	/***** SCENARIO : Travel Proposal moving to Ready For Proposal kicks off process *****/
	@isTest
	private static void travelProposalReadyForProposalKicksOffProcess() {
		//once lookup rollup summaries are gone this might be possible to remove.
		MERC_TriggerHandlerStateManager.deactivateAll();
		MERC_TriggerHandlerStateManager.activate(MERC_MeetingProcessLogicHandler.class);

		givenTheMeetingHasInitiateDelegateManagement('Yes');
		givenAProcessLogicRecordForTravelProposalReady();

		givenTravelProposalsAreInDraft(participants);
		Test.startTest();
		whenTravelProposalsAreReadyForProposal();
		Test.stopTest();

		expectProcessToBeCreatedFor(participants, 'Travel Proposal');
	}

	/**************************************************
	**************** TEST SETUP METHODS ***************
	***************************************************/
	private static void givenAProcessLogicRecordForPreMeetingInformation() {
		//create a rule that spawns task when process is created
		Id mpTypeId = Schema.SObjectType.Meeting_Process_Logic_MERC__c.getRecordTypeInfosByName().get('Meeting Process').getRecordTypeId();
		insert new Meeting_Process_Logic_MERC__c(Description_MERC__c = 'New Pre-Meeting Information Process Created',
												 RecordTypeId = mpTypeId,
												 Process_MERC__c = 'Pre-Meeting Information',
												 Create_New_Task_MERC__c = true,
												 New_Task_Name_MERC__c = 'Send Pre-Meeting Information',
												 New_Task_Status_MERC__c = 'Incomplete',
			                                     New_Task_Due_Date_Days_MERC__c = 7,
			                                     New_Due_Date_Direction_MERC__c = 'Before',
			                                     New_Task_Due_Date_Relative_to_MERC__c = 'Meeting_Start_Date_MERC__c');
        //clear the cached rules
		MERC_MeetingProcessLogicHandler.meetingProcessLogicRecordsByType = null;
	}

	private static void givenAProcessLogicRecordForInvitedMercuryParticipant() {
		//create a rule that initates the reg process when the (Mercury) participants are invited.
		Id mpTypeId = Schema.SObjectType.Meeting_Process_Logic_MERC__c.getRecordTypeInfosByName().get('Meeting Participant').getRecordTypeId();
		insert new Meeting_Process_Logic_MERC__c(Description_MERC__c = 'Mercury Meeting Participant is Invited',
												 RecordTypeId = mpTypeId,
												 Initiate_Delegate_Management_MERC__c = 'Yes',
			                                     Meeting_Participant_Status_MERC__c = 'Invited',
			                                     Veeva_Meeting_Participant_MERC__c = false,
			                                     Process_MERC__c = 'Registration',
			                                     Create_New_Process_MERC__c = true,
			                                     New_Process_MERC__c = 'Registration');
		//clear the cached rules
		MERC_MeetingProcessLogicHandler.meetingProcessLogicRecordsByType = null;
	}

	private static void givenAProcessLogicRecordForAcceptedMercuryParticipant() {
		//create a rule that initates the reg process when the (Mercury) participants are invited.
		Id mpTypeId = Schema.SObjectType.Meeting_Process_Logic_MERC__c.getRecordTypeInfosByName().get('Meeting Participant').getRecordTypeId();
		insert new Meeting_Process_Logic_MERC__c(Description_MERC__c = 'Mercury Meeting Participant is Invited',
												 RecordTypeId = mpTypeId,
												 Initiate_Delegate_Management_MERC__c = 'Yes',
			                                     Meeting_Participant_Status_MERC__c = 'Accepted',
			                                     Veeva_Meeting_Participant_MERC__c = false,
			                                     Process_MERC__c = 'Registration',
			                                     Create_New_Process_MERC__c = true,
			                                     New_Process_MERC__c = 'Pre-Meeting Information',
			                                     Update_Existing_Task_MERC__c = true,
			                                     Update_Task_Status_From_MERC__c = 'Incomplete',
			                                     Update_Task_Status_To_MERC__c = 'Completed - Task Not Needed',
			                                     Update_Task_Completed_Date_To_MERC__c = 'Today');
		//clear the cached rules
		MERC_MeetingProcessLogicHandler.meetingProcessLogicRecordsByType = null;
	}

	private static void givenTheMeetingHasInitiateDelegateManagement(String status) {
		meetings[0].Initiate_Delegate_Management_MERC__c = status;
		update meetings[0];
	}

	private static void givenAProcessLogicRecordForTravelProposalReady() {
		//create a rule that initates the travel process when the travel propoasl is ready for propsal
		Id mpTypeId = Schema.SObjectType.Meeting_Process_Logic_MERC__c.getRecordTypeInfosByName().get('Travel Proposal').getRecordTypeId();
		insert new Meeting_Process_Logic_MERC__c(Description_MERC__c = 'First Travel Proposal Ready for Proposal',
												 RecordTypeId = mpTypeId,
												 First_Travel_Proposal_MERC__c = 'TRUE',
			                                     Travel_Proposal_Status_MERC__c = 'Ready for Proposal',
			                                     Process_MERC__c = 'Travel Proposal',
			                                     Create_New_Process_MERC__c = true,
			                                     New_Process_MERC__c = 'Travel Proposal');
		//clear the cached rules
		MERC_MeetingProcessLogicHandler.meetingProcessLogicRecordsByType = null;
	}

	private static void givenTravelProposalsAreInDraft(List<Meeting_Participant_MERC__c> mps) {
		Id proposalRtId = Schema.SObjectType.Travel_Itinerary_MERC__c.getRecordTypeInfosByName().get('Travel Proposal').getRecordTypeId();
		proposals = new List<Travel_Itinerary_MERC__c>();
		for (Meeting_Participant_MERC__c mp : mps) {
			proposals.add( new Travel_Itinerary_MERC__c(RecordTypeId = proposalRtId,
				                                        Meeting_Participant_MERC__c = mp.Id,
				                                        Status_MERC__c = 'Draft',
				                                        Account_MERC__c = mp.Account_MERC__c,
				                                        Proposal_Counter_MERC__c = 1));
		}
		insert proposals;
	}

	private static void givenTheParticipantsHaveBeenInvited() {
		//In this scenario the participants would have already had a Registration process created
		//with a task to send invitation that has been marked complete
		//and a Reminder 1 task that has been generated. Set up the data to represent that here.
		List<Meeting_Process_MERC__c> processes = new List<Meeting_Process_MERC__c>();
		for (Meeting_Participant_MERC__c participant : participants) {
			participant.Status_MERC__c = 'Invited';
			processes.add(new Meeting_Process_MERC__c(Name = 'Participant - Registration',
													  Meeting_Participant_MERC__c = participant.id,
				                                      Process_Type_MERC__c = 'Registration'));
		}

		update participants;
		insert processes;

		List<Meeting_Tasks_MERC__c> tasks = new List<Meeting_Tasks_MERC__c>();
		for (Meeting_Process_MERC__c process : processes) {
			tasks.add(new Meeting_Tasks_MERC__c(Name='Send Registration',
				                                Task_Status_MERC__c = 'Completed - Continue Follow Up',
				                                Meeting_Process_MERC__c = process.id,
				                                Due_Date_MERC__c = Date.today().addDays(7),
				                                Completed_Date_MERC__c = Date.today()));
			tasks.add(new Meeting_Tasks_MERC__c(Name='Reminder 1',
				                                Task_Status_MERC__c = 'Incomplete',
				                                Meeting_Process_MERC__c = process.id,
				                                Due_Date_MERC__c = Date.today().addDays(7)));
		}
		insert tasks;
	}

	/**************************************************
	************** TEST HELPER METHODS ****************
	**************************************************/

	private static void whenPreMeetingInformationProcessCreatedFor(List<Meeting_Participant_MERC__c> mps) {
		List<Meeting_Process_MERC__c> processes = new List<Meeting_Process_MERC__c>();

		for (Meeting_Participant_MERC__c participant : mps) {
			processes.add(new Meeting_Process_MERC__c(Name='Send Pre-Meeting Info',
				                                      Process_Type_MERC__c = 'Pre-Meeting Information',
				                                      Meeting_Participant_MERC__c = participant.id));
		}

		insert processes;
	}

	private static void whenTheParticipantsStatusBecomes(String status) {
		for (Meeting_Participant_MERC__c participant : participants) {
			participant.Status_MERC__c = status;
			//this box would be checked via
			participant.Evaluate_Meeting_Process_Logic_MERC__c = true;
		}
		update participants;
	}

	private static void whenTravelProposalsAreReadyForProposal() {
		for (Travel_Itinerary_MERC__c proposal : proposals) {
			proposal.Status_MERC__c = 'Ready for Proposal';
		}
		update proposals;
	}

	/**************************************************
	************ TEST VALIDATION METHODS **************
	**************************************************/
	private static void expectTasksToBeCreatedForProcessesFor(List<Meeting_Participant_MERC__c> mps) {
		System.assertEquals(mps.size(), [SELECT Id
	                                       FROM Meeting_Tasks_MERC__c
	                                      WHERE Meeting_Process_MERC__r.Meeting_Participant_MERC__c IN : mps].size());
	                                        //AND Name = 'Send Pre-Meeting Information'
	                                        //AND Task_Status_MERC__c = 'Incomplete'].size());
	}

	private static void expectProcessToBeCreatedFor(List<Meeting_Participant_MERC__c> mps, String processType) {
		List<Meeting_Process_MERC__c> processes = [SELECT Process_Type_MERC__c
		                                             FROM Meeting_Process_MERC__c
		                                            WHERE Meeting_Participant_MERC__c IN :mps
		                                              AND Process_Type_MERC__c = :processType];

		System.assertEquals(mps.size(), processes.size(), processType + ' Processes not created correctly');
	}

	private static void expectProcessToBeCompletedFor(List<Meeting_Participant_MERC__c> mps, String processType) {
		List<Meeting_Process_MERC__c> processes = [SELECT Id
		                                             FROM Meeting_Process_MERC__c
		                                            WHERE Meeting_Participant_MERC__c IN :mps
		                                              AND Process_Status_MERC__c = 'Completed'
		                                              AND Process_Type_MERC__c = :processType];
		System.assertEquals(mps.size(), processes.size(), processType + ' processes not completed');
	}
}