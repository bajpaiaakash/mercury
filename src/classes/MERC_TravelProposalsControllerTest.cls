@isTest
private class MERC_TravelProposalsControllerTest
{
	static Account                              account;
	static Meeting_MERC__c                      meeting;
	static Meeting_Participant_MERC__c          participant;
	static MERC_TravelProposalsController       controller;

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
}