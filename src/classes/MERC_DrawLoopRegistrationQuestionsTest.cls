/*
	MERC_DrawLoopRegistrationQuestionsTest
	Author : Kyle Thornton (Mavens Consulting)
	Date : March 12, 2016
	Description: Test classes for MERC_DrawLoopRegistrationQuestions
 */
@isTest
private class MERC_DrawLoopRegistrationQuestionsTest
{
	static MERC_DrawLoopRegistrationQuestions theClass;
	static User lillyUser = MERC_TestFactory.getRunningUser();
	static Account account;
	static Meeting_MERC__C meeting;
	static Meeting_Participant_MERC__c participant;
	static List<Registration_Question_MERC__c> questions;

	static {
		MERC_TriggerHandlerStateManager.deactivateAll();
	}
	@isTest
	static void itShouldReturnTheSetOfObjects()
	{
		System.runAs(lillyUser) {
			givenAnInstantiatedClass();
			Test.startTest();
			thenGetGlobalDescribeShouldReturnSetOfObjectNames();
			Test.stopTest();
		}
	}

	@isTest
	static void itShouldReturnAListOfLoopDataObjects() {
		System.runAs(lillyUser) {
			givenAnInstantiatedClass();
			Test.startTest();
			thenDescribeObjectseShouldReturnListOfLoopDataObjects();
			Test.stopTest();
		}
	}

	@isTest
	static void itShouldReturnChildRelationships() {
		System.runAs(lillyUser) {
			givenAnInstantiatedClass();
			Test.startTest();
			thenGetChildRelationShipsShouldReturnSetOfChildren();
			Test.stopTest();
		}
	}

	@isTest
	static void itShouldReturnCorrectResultsForConsulant() {
		System.runAs(lillyUser) {
			givenAnInstantiatedClass();
			Test.startTest();
			givenAMeetingParticipantThatShouldHaveQuestions('Consulting', 'HCP');
			thenQueryShouldReturnData();
			Test.stopTest();
		}
	}

	@isTest
	static void itShouldReturnCorrectResultsForDelegateHCP() {
		System.runAs(lillyUser) {
			givenAnInstantiatedClass();
			Test.startTest();
			givenAMeetingParticipantThatShouldHaveQuestions('Delegate', 'HCP');
			thenQueryShouldReturnData();
			Test.stopTest();
		}
	}

	@isTest
	static void itShouldReturnCorrectResultsForDelegateEmployee() {
		System.runAs(lillyUser) {
			givenAnInstantiatedClass();
			Test.startTest();
			givenAMeetingParticipantThatShouldHaveQuestions('Delegate', 'Employee');
			thenQueryShouldReturnData();
			Test.stopTest();
		}
	}

	@isTest
	static void itShouldReturnCorrectResultsForDelegateNonHCP() {
		System.runAs(lillyUser) {
			givenAnInstantiatedClass();
			Test.startTest();
			givenAMeetingParticipantThatShouldHaveQuestions('Delegate', 'Non-HCP');
			thenQueryShouldReturnData();
			Test.stopTest();
		}
	}

	@isTest
	static void itShouldReturnCorrectResultsForServiceProvider() {
		System.runAs(lillyUser) {
			givenAnInstantiatedClass();
			Test.startTest();
			givenAMeetingParticipantThatShouldHaveQuestions('Service Provider', 'HCP');
			thenQueryShouldReturnData();
			Test.stopTest();
		}
	}

	@isTest
	static void itShouldReturnCorrectResultsForIndividualSponsorship() {
		System.runAs(lillyUser) {
			givenAnInstantiatedClass();
			Test.startTest();
			givenAMeetingParticipantThatShouldHaveQuestions('Individual Sponsorship', 'HCP');
			thenQueryShouldReturnData();
			Test.stopTest();
		}
	}

	private static void givenAnInstantiatedClass() {
		theClass = new MERC_DrawLoopRegistrationQuestions();
	}

	private static void givenAMeetingParticipantThatShouldHaveQuestions(String recordType, String participantType) {
		account = MERC_TestFactory.insertAccounts(1)[0];
		meeting = MERC_TestFactory.insertMeetings(1)[0];
		participant = MERC_TestFactory.insertParticipants(meeting.id, new List<Account>{account})[0];

		Map<String,Schema.RecordTypeInfo> rtInfo = Schema.SObjectType.Meeting_Participant_MERC__c.getRecordTypeInfosByName();
		participant.RecordTypeId = rtInfo.get(recordType).getRecordTypeId();
		participant.Participant_Typ_MERC__c = participantType;
		update participant;

		questions = MERC_TestFactory.insertQuestions(new List<String>{'Select One', 'Select Many', 'Text'}, meeting.Id, true);
		questions[0].Consulting_MERC__c = true;
		update questions[0];

		Meeting_Group_MERC__c meetingGroup = new Meeting_Group_MERC__c(Name='test group', Meeting_MERC__c=meeting.id);
		insert meetingGroup;

		participant.Meeting_Group_MERC__c = meetingGroup.id;
		update participant;

		List<Meeting_Group_Question_MERC__c> groupQuestions = new List<Meeting_Group_Question_MERC__c>();
		groupQuestions.add(new Meeting_Group_Question_MERC__c(Meeting_Group_Name_MERC__c = meetingGroup.Id,
			                                                  Registration_Question_MERC__c=questions[1].Id));
		groupQuestions.add(new Meeting_Group_Question_MERC__c(Meeting_Group_Name_MERC__c = meetingGroup.Id,
			                                                  Registration_Question_MERC__c=questions[2].Id));
		insert groupQuestions;
	}

	private static void thenGetGlobalDescribeShouldReturnSetOfObjectNames() {
		System.assert(theClass.getGlobalDescribe().contains('Registration_Question_MERC__c'));
		System.assert(theClass.getGlobalDescribe().contains('Answer_MERC__c'));
	}

	private static void thenDescribeObjectseShouldReturnListOfLoopDataObjects() {
		List<Loop.ExternalData.DataObject> theList = theClass.describeObjects(new List<String>{'Registration_Question_MERC__c', 'Answer_MERC__c'});
		System.assertEquals(2, theList.size());
		System.assertEquals('Registration_Question_MERC__c', theList[0].name);
		System.assertEquals('Answer_MERC__c', theList[1].name);
	}

	private static void thenGetChildRelationShipsShouldReturnSetOfChildren() {
		System.assertEquals(1, theClass.getChildRelationships('Registration_Question_MERC__c').size());
		System.assert(theClass.getChildRelationships('Registration_Question_MERC__c').contains('Answer_MERC__c'));
	}

	private static void thenQueryShouldReturnData() {

		Loop.ExternalData.QueryRequestInfo info = new Loop.ExternalData.QueryRequestInfo();
		info.RecordId = participant.Id;
		//info.Relationships = new List<String>{'Registration_Question_MERC__c','Answer_MERC__c'};

		Loop.ExternalData.QueryResultSet result = theClass.query(info);
	}
}