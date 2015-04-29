@isTest
private class MERC_TravelProposalsControllerTest
{
	static Account                              account;
	static Meeting_MERC__c                      meeting;
	static Meeting_Participant_MERC__c          participant;
	static MERC_TravelProposalsController       controller;
	static PageReference                        currentPageRef;

	static {
		MERC_TestFactory.loadTravelProposalSegmentTypeSettings();
		account = 	  MERC_TestFactory.insertAccounts(1)[0];
		meeting =     MERC_TestFactory.insertMeetings(1)[0];
		participant = MERC_TestFactory.insertParticipants(meeting.id, new List<Account>{account})[0];
	}

	/****************** Scenario : Page accessed without an Id **********************/
	@isTest
	static void itShouldErrorWhenNoIdParameterIsProvided()
	{
		givenThePageIsLoaded(null);
		expectOneErrorMessage();
		expectErrorMessageToBe(Label.Travel_Proposals_No_Participant_Id);
		expectAnInitializationError();
	}

	/****************** Scenario : Page accessed with a bad Id **********************/
	@isTest
	static void itShouldErrorWhenBadIdIsProvided() {
		givenThePageIsLoaded('001000000000000'); //with a bad id
		expectOneErrorMessage();
		expectErrorMessageToBe(Label.Travel_Proposals_Cannot_Find_Participant);
		expectAnInitializationError();
	}

	/***************** Scenario : Page is accessed with no Itineraries **************/
	@isTest
	static void itShouldLoadPageProperly() {
		givenThePageIsLoaded();
		expectNoErrors();
		expectPageTitleToBeSet();
		expectPageSubTitleToBeSet();
	}

	/******************  Scenario : User Creates a Proposal    **********************/
	@isTest
	static void itShouldCreateProposalAndSegment() {
		givenThePageIsLoaded();
		givenTheUserClicksNewProposal();
		expectProposalCountToBe(1);
		expectProposalXToHaveYSegments(0,1);
	}

	/********  Scenario : User Creates a Proposal, saves, creates segment saves & exits *******/
	@isTest
	static void itShouldBeAbleToAddSegmentsAndSaveItineraries() {
		givenThePageIsLoaded();
		givenTheUserClicksNewProposal();
		givenTheUserTogglesTheProposalXSegmentYTypeToAir(0,0);
		givenTheUserCompletesProposalXSegmentYInformation(0,0);
		givenTheUserClicksSave(); //exercising save only
		givenTheUserAddsAnotherSegmentToProposal(0);
		expectProposalXToHaveYSegments(0,2);
		givenTheUserTogglesTheProposalXSegmentYTypeToAir(0,1);
		givenTheUserCompletesProposalXSegmentYInformation(0,1);
		givenTheUserClicksSaveAndExit(); //exercising Save And Exit
		expectUserToBeReturnedToMeetingParticipant();
		expectTheParticipantToHaveXProposalsWithYSegments(1,2);
	}

	/*********************************************************************************
	                     HELPER METHODS
	*********************************************************************************/

	/******************************* Actions *********************************/
	private static void givenThePageIsLoaded() {
		givenThePageIsLoaded(participant.Id);
	}

	private static void givenThePageIsLoaded(String participantId) {
		PageReference proposalPage = Page.MERC_TravelProposals;
		proposalPage.getParameters().put('id', participantId);
		Test.setCurrentPage(proposalPage);

		controller = new MERC_TravelProposalsController();
	}

	private static void givenTheUserClicksNewProposal() {
		controller.addProposal();
	}

	private static void givenTheUserCompletesProposalXSegmentYInformation(Integer proposalIndex, Integer segmentIndex) {
		controller.proposals[proposalIndex].segments[segmentIndex].detail.Segment_Begin_Timezone_MERC__c = 'Central European Time (Europe/Berlin)';
		controller.proposals[proposalIndex].segments[segmentIndex].detail.Segment_End_Timezone_MERC__c = 'Central European Time (Europe/Berlin)';
		controller.proposals[proposalIndex].segments[segmentIndex].detail.Sgmnt_Bgin_TS_MERC__c = meeting.Date_of_Event_MERC__c.addDays(-1);
		controller.proposals[proposalIndex].segments[segmentIndex].detail.Sgmnt_End_TS_MERC__c = meeting.Date_of_Event_MERC__c.addDays(-1);
		controller.proposals[proposalIndex].segments[segmentIndex].detail.Travel_Detail_Typ_MERC__c = 'Outbound Leg';
		controller.proposals[proposalIndex].segments[segmentIndex].detail.Flght_Nmbr_MERC__c = '445';
		controller.proposals[proposalIndex].segments[segmentIndex].detail.Dprtr_Trmnl_Nm_MERC__c = 'Departure';
		controller.proposals[proposalIndex].segments[segmentIndex].detail.Arrvl_Trmnl_Nm_MERC__c = 'Arrival';
	}

	private static void givenTheUserClicksSave() {
		controller.save();
	}

	private static void givenTheUserAddsAnotherSegmentToProposal(Integer proposalIndex) {
		controller.proposals[proposalIndex].addSegment();
	}

	private static void givenTheUserClicksSaveAndExit() {
		currentPageRef = null; //null this out to make sure that we are setting it. Avoid any possible false positives
		currentPageRef = controller.saveProposalsAndReturn();
	}

	private static void givenTheUserTogglesTheProposalXSegmentYTypeToAir(Integer proposalIndex, Integer segmentIndex) {
		controller.proposals[proposalIndex].segments[segmentIndex].segmentType = 'Air_MERC';
		controller.doNothing(); //simulate the post back to the server from the page onchange actionsupport
	}

	/******************************* Expectations *********************************/
	private static void expectOneErrorMessage() {
		System.assertEquals(1, ApexPages.getMessages().size());
	}

	private static void expectErrorMessageToBe(String error) {
		System.assertEquals(error, ApexPages.getMessages().get(0).getSummary());
	}

	private static void expectAnInitializationError() {
		System.assert(controller.initializationError);
	}

	private static void expectNoErrors() {
		System.assertEquals(0, ApexPages.getMessages().size());
		System.assertEquals(false, controller.initializationError);
	}

	private static void expectProposalCountToBe(Integer count) {
		System.assertEquals(count, controller.proposals.size());
	}

	private static void expectPageTitleToBeSet() {
		System.assertEquals(Schema.SObjectType.Meeting_MERC__c.fields.Name.getLabel() + ': ' + meeting.Name,
		                    controller.getPageTitle());
	}

	private static void expectPageSubTitleToBeSet() {
		Meeting_Participant_MERC__c thisParticipant =  [select id, name, account_merc__r.name from Meeting_Participant_MERC__c where id=:participant.id];
		System.assertEquals(Label.Travel_Proposals_Page_subtitle_prefix + thisParticipant.Name + ' (' + thisParticipant.Account_MERC__r.Name + ')',
		                     controller.getPageSubTitle());
	}

	private static void expectProposalXToHaveYSegments(Integer proposalIndex, Integer segmentCount) {
		System.assertEquals(segmentCount, controller.proposals[proposalIndex].segments.size());
	}

	private static void expectUserToBeReturnedToMeetingParticipant() {
		System.assertEquals('/'+participant.id, currentPageRef.getUrl());
	}

	private static void expectTheParticipantToHaveXProposalsWithYSegments(Integer proposalCount, Integer segmentCount) {
		List<Travel_Itinerary_MERC__c> itineraries = [SELECT Id,
		                                                     (SELECT Id FROM Travel_Itineraries__r)
														FROM Travel_Itinerary_MERC__c
													   WHERE Meeting_Participant_MERC__c=:participant.id
													     AND RecordTypeId=:MERC_TravelProposalsController.proposalRecordTypeId];

		System.assertEquals(proposalCount, itineraries.size());
		System.assertEquals(segmentCount, itineraries[0].Travel_Itineraries__r.size());
	}
}