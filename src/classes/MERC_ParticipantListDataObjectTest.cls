/*
	MERC_ParticipantListDataObjectTest
	Author : Kyle Thornton (Mavens Consulting)
	Date : March 8, 2016
	Description: Test classes for MERC_ParticipantListDataObject
 */
@isTest
private class MERC_ParticipantListDataObjectTest
{
	static List<Account> accounts;
	static Meeting_MERC__c meeting;
	static List<Meeting_Participant_MERC__c> participants;
	static MERC_ParticipantListDataObject dataObject;
	static String whereClause;
	static final Integer DATA_SIZE = 11; // default for set controller is 10, add one to make it easy to see it's working
	static List<MERC_ParticipantListDataObject.SelectableParticipant> selectableParticipants;
	static User lillyUser = MERC_TestFactory.getRunningUser();

	static {
		System.runAs(lillyUser) {
			accounts = MERC_TestFactory.insertAccounts(DATA_SIZE);
			meeting = MERC_TestFactory.insertMeetings(1)[0];
			participants = MERC_TestFactory.insertParticipants(meeting.id, accounts);
		}
	}

	@isTest
	static void itShouldInitializeTheDataObjectCorrectly()
	{
		System.runAs(lillyUser) {
			givenTheDataObjectIsInstantiated();
			thenTheDataObjectIsInitializedProperly();
		}
	}

	@isTest
	static void itShouldSetTheQueryStringAndInitializeTheParticipantList() {
		System.runAs(lillyUser) {
			String fakeQuery = 'SELECT fakeSoql FROM NoObject';
			givenTheDataObjectIsInstantiated();
			givenTheSelectableParticipantsListIsPopulatedAndSetControllerInstantiated();
			Test.startTest();
			whenQueryParticipantsIsCalledWithString(fakeQuery);
			Test.stopTest();
			thenQueryStringShouldBeSetTo(fakeQuery);
			thenTheSelectableParticipantsListIsEmpty();
		}
	}

	@isTest
	static void itShouldReturnAListOfWrappedParticipants() {
		System.runAs(lillyUser) {
			givenTheDataObjectIsInstantiated();
			Test.startTest();
			whenGetRecordsIsCalled();
			Test.stopTest();
			thenTheCorrectNumberOfSelectableRecordsAreReturned(5);
		}
	}

	@isTest
	static void itShouldReturnAListOfTheSelectedParticipants() {
		System.runAs(lillyUser) {
			givenTheDataObjectIsInstantiated();
			Test.startTest();
			whenGetRecordsIsCalled();
			whenSomeRecordsAreSelected();
			Test.stopTest();
			thenTheSelectedParticipantsReturnsSelected();
		}
	}

	private static void givenTheDataObjectIsInstantiated() {
		whereClause = 'Meeting_MERC__c = \'' + meeting.id + '\'';
		dataObject = new MERC_ParticipantListDataObject(whereClause, 5, null);
		dataObject.queryParticipants('SELECT Id FROM Meeting_Participant_MERC__c WHERE ' + dataObject.baseWhereClause);
	}

	private static void givenTheSelectableParticipantsListIsPopulatedAndSetControllerInstantiated() {
		for (Meeting_Participant_MERC__c participant : participants) {
			dataObject.selectableParticipants.add(new MERC_ParticipantListDataObject.SelectableParticipant(participant));
		}
		//call the set controller to instantiate it.
		ApexPages.StandardSetController setController = dataObject.setController;
	}

	private static void whenQueryParticipantsIsCalledWithString(String queryString) {
		dataObject.queryParticipants(queryString);
	}

	private static void whenGetRecordsIsCalled() {
		selectableParticipants = dataObject.getRecords();
	}

	private static void whenSomeRecordsAreSelected() {
		selectableParticipants[0].selected = true;
		selectableParticipants[1].selected = true;
		selectableParticipants[2].selected = true;
	}

	private static void thenTheDataObjectIsInitializedProperly() {
		System.assertEquals(0, dataObject.selectableParticipants.size());
		System.assertEquals(whereClause, dataObject.baseWhereClause, 'The baseWhereClause was not passed in correctly');
		System.assertEquals(4, dataObject.pageSizeOptions.size(), 'Page size options not initialized properly. Should have 3 base values (10/25/50) and 11');
		System.assertEquals(5, dataObject.pageSize, 'The expected page size was not set');
	}

	private static void thenQueryStringShouldBeSetTo(String queryString) {
		System.assertEquals(queryString, dataObject.participantQueryString);
	}

	private static void thenTheSelectableParticipantsListIsEmpty() {
		System.assert(dataObject.selectableParticipants.isEmpty());
	}

	private static void thenTheCorrectNumberOfSelectableRecordsAreReturned(Integer count) {
		System.assertEquals(count, selectableParticipants.size());
	}

	private static void thenTheSelectedParticipantsReturnsSelected() {
		System.assertEquals(3, dataObject.selectedParticipants.size());
	}
}