@isTest
private class MERC_RegistrationResponsesControllerTest {

	static Account                              account;
	static Meeting_MERC__c                      meeting;
	static Meeting_Participant_MERC__c          participant;
	static List<Registration_Question_MERC__c>  questions;
	static List<Answer_MERC__c>                 answers;
	static List<Response_MERC__c>               responses;
	static MERC_RegistrationResponsesController controller;
	static Meeting_Group_MERC__c                meetingGroup;
	static {
		MERC_TestFactory.loadTimeZoneFieldMapSettings();
		account = 	  MERC_TestFactory.insertAccounts(1)[0];
		meeting =     MERC_TestFactory.insertMeetings(1)[0];
		participant = MERC_TestFactory.insertParticipants(meeting.id, new List<Account>{account})[0];
	}

	/**************** Scenario: load page *******************/
	@isTest
	static void testControllerWrapsQuestionsCorrectly() {
		Test.startTest();
		givenTheMeetingHasQuestions(null);
		givenThePageHasBeenOpenedForTheParticipant();
		expectTheControllerToContainQuestionsWithWrappedAnswers();
		expectThePageTitleToBePopulated();
		expectThePageSubTitleToBePopulated();
		Test.stopTest();
	}

	@isTest
	static void testControllerWrapsQuestionsCorrectlyForGroupQuestions() {
		Test.startTest();
		givenTheMeetingHasQuestions(null);
		givenTheMeetingHasAGroup();
		givenTheGroupHasQuestions();
		givenTheParticipantIsADelgateAndPartOfTheGroup(); //so service provider questions won't appear
		givenThePageHasBeenOpenedForTheParticipant();
		expectTheControllerToContainQuestionsWithWrappedAnswers();
		Test.stopTest();
	}

	private static void givenTheMeetingHasQuestions(List<String> answerTypes) {
		//this method takes a list of strings and passes it to the test factory.
		//if null defaults list to 'Text', 'Select One', 'Select Multiple' to create three questions
		if (answerTypes == null) {
			answerTypes = defaultAnswerTypes();
		}
		questions = MERC_TestFactory.insertQuestions(answerTypes, meeting.Id, true);
	}

	private static void givenTheParticipantIsADelgateAndPartOfTheGroup() {
		RecordType delegateRt = [SELECT Id FROM RecordType WHERE SObjectType='Meeting_Participant_MERC__c' and DeveloperName='MERC_Delegate' limit 1];
		participant.RecordTypeId = delegateRt.Id;
		participant.Meeting_Group_MERC__c = meetingGroup.id;
		update participant;
	}

	private static void givenTheMeetingHasAGroup() {
		meetingGroup = new Meeting_Group_MERC__c(Name='test', Meeting_MERC__c=meeting.id);
		insert meetingGroup;
	}

	private static void givenTheGroupHasQuestions() {
		List<Meeting_Group_Question_MERC__c> groupQuestions = new List<Meeting_Group_Question_MERC__c>();
		for (Registration_Question_MERC__c question : questions) {
			groupQuestions.add(new Meeting_Group_Question_MERC__c(Meeting_Group_Name_MERC__c=meetingGroup.Id, Registration_Question_MERC__c=question.id));
		}
		insert groupQuestions;
	}

	private static List<String> defaultAnswerTypes() {
		return new List<String>{
			Label.Registration_Questions_Text,
			Label.Registration_Questions_Select_One,
			Label.Registration_Questions_Select_Many};
	}

	private static void givenThePageHasBeenOpenedForTheParticipant() {
		PageReference pageRef = Page.MERC_RegistrationResponses;
		pageRef.getParameters().put('id', participant.Id);

		Test.setCurrentPage(pageRef);

		controller = new MERC_RegistrationResponsesController();
	}

	private static void expectTheControllerToContainQuestionsWithWrappedAnswers() {
		System.debug('default answer types size: ' + defaultAnswerTypes().size());
		System.assertEquals(defaultAnswerTypes().size(), controller.questions.size());
		for (MERC_RegistrationResponsesController.Question question : controller.questions) {
			if (question.detail.Answer_Type_MERC__c == Label.Registration_Questions_Text) {
				System.assert(question.answers.isEmpty());
			} else {
				System.assert(!question.answers.isEmpty());
			}
		}
	}

	private static void expectThePageTitleToBePopulated() {
		System.assertEquals(Schema.SObjectType.Meeting_MERC__c.fields.Name.getLabel() + ': ' + meeting.Name,
		                     controller.getPageTitle());
	}

	private static void expectThePageSubTitleToBePopulated() {
		Account thisAccount = [SELECT Name FROM Account WHERE Id = :account.id];
		Meeting_Participant_MERC__c thisParticipant = [SELECT Name FROM Meeting_Participant_MERC__c WHERE Id = :participant.id];
		System.assertEquals(Label.Registration_Questions_Responses_For + ' ' + thisAccount.Name + ' (' + thisParticipant.Name + ')',
		                     controller.getPageSubTitle());
	}

	/**************** Scenario: load page with no Id *******************/
	@isTest
	static void testControllerThrowsErrorWithNoIdPresent() {
		givenThePageIsAccessWithNoIdQueryParameter();
		expectANoIdErrorToBeThrown();
	}

	private static void givenThePageIsAccessWithNoIdQueryParameter() {
		PageReference pageRef = Page.MERC_RegistrationResponses;
		Test.setCurrentPage(pageRef);
		controller = new MERC_RegistrationResponsesController();
	}

	private static void expectANoIdErrorToBeThrown() {
		System.assertEquals(1, ApexPages.getMessages().size());
		System.assertEquals(Label.Registration_Questions_No_Participant_Id, ApexPages.getMessages()[0].getSummary());
		System.assert(controller.initializationError);
		System.assert(controller.questions.isEmpty());
	}

	/**************** Scenario: load page with bad Id *******************/
	@isTest
	static void testControllerThrowsErrorWithBadIdPresent() {
		givenThePageIsAccessWithBadIdQueryParameter();
		expectABadIdErrorToBeThrown();
	}

	private static void givenThePageIsAccessWithBadIdQueryParameter() {
		PageReference pageRef = Page.MERC_RegistrationResponses;
		pageRef.getParameters().put('id', 'badid');
		Test.setCurrentPage(pageRef);
		controller = new MERC_RegistrationResponsesController();
	}

	private static void expectABadIdErrorToBeThrown() {
		System.assertEquals(1, ApexPages.getMessages().size());
		System.assertEquals(Label.Registration_Questions_Invalid_Participant, ApexPages.getMessages()[0].getSummary());
		System.assert(controller.initializationError);
		System.assert(controller.questions.isEmpty());
	}

	/**************** Scenario: call cancelForm*******************/
	@isTest
	static void testCancelForm() {
		givenThePageHasBeenOpenedForTheParticipant();
		PageReference pageRef = controller.cancelForm();
		System.assertEquals('/'+participant.id, pageRef.getUrl());
	}

	/**************** Scenario: save the form with answers*******************/
	@isTest
	static void testUserAnswersQuestions() {
		givenTheMeetingHasQuestions(null);
		givenThePageHasBeenOpenedForTheParticipant();
		givenTheUserHasProvidedAnswersToDefaultQuestions();
		givenTheUserClicksSave();
		expectAnswersToDefaultQuestionsToBeSaved();
	}

	private static void givenTheUserHasProvidedAnswersToDefaultQuestions() {
		//assumes defaultAnswerTypes method was used
		//first qustion will be text
		controller.questions[0].textAnswer = 'foo';

		//second question bee be a select one
		controller.questions[1].selectedAnswerId = controller.questions[1].answers[1].detail.id;

		//third question will be a select many
		controller.questions[2].answers[0].selected = true;
		controller.questions[2].answers[1].selected = true;
	}

	private static void givenTheUserClicksSave() {
		controller.saveResponses();
	}

	private static void expectAnswersToDefaultQuestionsToBeSaved() {
		List<Response_MERC__c> theResponses = [SELECT Id
		                                         FROM Response_MERC__c
											    WHERE Meeting_Participant_MERC__c = :participant.id];
		System.assertEquals(4, theResponses.size());

	}

	/**************** Scenario: save the form with answers when answers already provided *******************/
	@isTest
	static void testUserAnswersQuestionsASecondTime() {
		givenTheMeetingHasQuestions(null);
		givenThePageHasBeenOpenedForTheParticipant();
		givenTheUserHasProvidedAnswersToDefaultQuestions();
		givenTheUserClicksSave();

		Map<Id, Response_MERC__c> initialResponses = new Map<Id, Response_MERC__c>(
			[SELECT Id FROM Response_MERC__c WHERE Meeting_Participant_MERC__c = :participant.id]
		);
		//reopen the page and save again.
		givenThePageHasBeenOpenedForTheParticipant();
		givenTheUserHasProvidedAnswersToDefaultQuestions();
		givenTheUserClicksSave();

		expectInitialResponsesToBeDeleatedAndReplacedWithNewResponses(initialResponses.keySet());
	}

	private static void expectInitialResponsesToBeDeleatedAndReplacedWithNewResponses(Set<Id> initialIds) {
		for (Response_MERC__c response : [SELECT Id FROM Response_MERC__c WHERE Meeting_Participant_MERC__c = :participant.id]) {
			System.assert(!initialIds.contains(response.id));
		}
	}

	/**************** Scenario: save the form with out providing answers *******************/
	@isTest
	static void testUserDoesNotProvideAnswerToSingleOrMultipleQuestions() {
		givenTheMeetingHasQuestions(null);
		givenThePageHasBeenOpenedForTheParticipant();
		givenTheUserClicksSave();
		expectTwoErrorsCreatedForUnansweredQuestions();
	}

	private static void expectTwoErrorsCreatedForUnansweredQuestions() {
		System.assertEquals(2, ApexPages.getMessages().size());
		for (ApexPages.Message message : ApexPages.getMessages()) {
			System.assert(message.getSummary().startsWith(Label.Registration_Questions_Answer_Required));
		}
	}

	/**************** Scenario: save the form when dml is disabled *******************/
	@isTest
	static void testUserSavesFormAndEncountersInsertDMLException() {
		givenTheMeetingHasQuestions(null);
		givenThePageHasBeenOpenedForTheParticipant();
		givenTheUserHasProvidedAnswersToDefaultQuestions();
		givenTheUserWillEncounterAnErrorOnSave();
		givenTheUserClicksSave();
		expectErrorInsertingQuestions();
	}

	private static void givenTheUserWillEncounterAnErrorOnSave() {
		Test.setReadOnlyApplicationMode(true);
	}

	private static void expectErrorInsertingQuestions() {
		System.assertEquals(1, ApexPages.getMessages().size());
		System.assertEquals(Label.Registration_Questions_Error_Inserting_Responses, ApexPages.getMessages()[0].getSummary());
	}

	/**************** Scenario: save the form a second time when dml is disabled *******************/
	@isTest
	static void testUserSavesFormAndEncountersDeleteDMLException() {
		givenTheMeetingHasQuestions(null);
		givenThePageHasBeenOpenedForTheParticipant();
		givenTheUserHasProvidedAnswersToDefaultQuestions();
		givenTheUserClicksSave();

		//reopen the page and save again.
		givenThePageHasBeenOpenedForTheParticipant();
		givenTheUserHasProvidedAnswersToDefaultQuestions();
		givenTheUserWillEncounterAnErrorOnSave();
		givenTheUserClicksSave();
		expectErrorDeletingQuestions();
	}


	private static void expectErrorDeletingQuestions() {
		System.assertEquals(1, ApexPages.getMessages().size());
		System.assertEquals(Label.Registration_Questions_Error_Deleting_Responses, ApexPages.getMessages()[0].getSummary());
	}

	/***************** Scenario: Questions have answers and return options, test "getAnswerOptions" ******************/
	@isTest
	static void testQuestionReturnsSelectOptions() {
		givenTheMeetingHasQuestions(null);
		givenThePageHasBeenOpenedForTheParticipant();
		expectSingleAnswerToProduceSelectOptions();
	}

	private static void expectSingleAnswerToProduceSelectOptions() {
		List<SelectOption> options = controller.questions[1].getAnswerOptions();
		System.assertEquals(2, options.size());
		System.assert(options[1].getLabel().startsWith('Answer 2'), options[1].getLabel());
	}

	/***************** Scenario: User wants to clear all responses ***********************/
	@isTest
	static void testClearResponsesDeletesAllResponses() {
		givenTheMeetingHasQuestions(null);
		givenThePageHasBeenOpenedForTheParticipant();
		givenTheUserHasProvidedAnswersToDefaultQuestions();
		givenTheUserClicksSave();

		givenThePageHasBeenOpenedForTheParticipant();
		givenTheUserClicksClearRepsonsesButton();
		expectConfirmationMessageToReturnProperValue();
		expectResponsesToBeDeleted();
		expectMessageToShowResponsesCleared();
	}

	private static void givenTheUserClicksClearRepsonsesButton() {
		controller.clearResponses();
	}

	private static void expectConfirmationMessageToReturnProperValue() {
		Account thisAccount = [SELECT Name FROM Account WHERE Id = :account.id];
		Meeting_Participant_MERC__c thisParticipant = [SELECT Name FROM Meeting_Participant_MERC__c WHERE Id = :participant.id];
		System.assertEquals(Label.Registration_Questions_Confirm_Delete + ' ' + thisAccount.Name + ' (' + thisParticipant.Name + ')',
		                    controller.getClearResponseMessage());
	}

	private static void expectResponsesToBeDeleted() {
		System.assertEquals(0, [SELECT Id FROM Response_MERC__c].size());
	}

	private static void expectMessageToShowResponsesCleared() {
		System.assertEquals(1, ApexPages.getMessages().size());
		System.assertEquals(Label.Registration_Questions_Cleared_Responses,
		                    ApexPages.getMessages()[0].getSummary());
	}

	/****************** Scenario: Error when trying to clear records **************/
	@isTest
	static void testClearResponsesWithDMLError() {
		givenTheMeetingHasQuestions(null);
		givenThePageHasBeenOpenedForTheParticipant();
		givenTheUserHasProvidedAnswersToDefaultQuestions();
		givenTheUserClicksSave();

		givenThePageHasBeenOpenedForTheParticipant();
		givenTheUserWillEncounterAnErrorOnSave();
		givenTheUserClicksClearRepsonsesButton();
		expectErrorDeletingQuestions();
	}
}