/** 
* @author Sean Harrison, Joseph Ferraro 
* 
* This is a unit test class for MERC_DeleteNotifyService.cls which is intended 
* as a delete trigger on MERC_Meeting, MERC_MeetingParticipant, MERC_MeetingProducts, MERC_TeamMember
*/

@isTest
private class MERC_DeleteNotifyServiceTest {
	
	/*
		It's important that we don't run any inserts via the TestFactory in a static block because it trips a Salesforce issue:
		http://www.joe-ferraro.com/2014/04/apex-unit-testing-test-data-and-test-setmock/
	*/

	// just delete some meetings, this wont make the callout
	@isTest 
	static void testMeetingDelete() {
		List<Meeting_MERC__c> meetings = MERC_TestFactory.insertMeetings(5);

		Test.startTest();
		delete meetings;
		Test.stopTest();
		system.assertEquals(0, [SELECT count() FROM Meeting_MERC__c]);
	}
	
	// delete a batch of meetings and their participants. again we're just ensuring the deletes complete. the notifcation service is tested below
	@isTest 
	static void testCascadeDelete() {
		List<Account> accounts = MERC_TestFactory.insertAccounts(2);
		List<Meeting_MERC__c> meetings = MERC_TestFactory.insertMeetings(5);
		List<Meeting_Participant_MERC__c> participants = MERC_TestFactory.insertBulkParticipants(meetings, accounts);

		Test.startTest();
		delete meetings;
		Test.stopTest();

		List<Meeting_Participant_MERC__c> shouldBeEmpty = new List<Meeting_Participant_MERC__c>([
			SELECT Id FROM Meeting_Participant_MERC__c WHERE Id in :participants
			]);
		System.assert(shouldBeEmpty.isEmpty(),' '+ shouldBeEmpty.size() +'Participants still exist?');
	}

	// skip the trigger and just hit the execute() method
	@isTest
	static void testCalloutExplicitly() {
		Account a = new Account(name='foo');
		insert a;
		List<Sobject> sobjects = new List<Sobject>{a};
		Test.startTest();
		String sobjectTypeAPIName = MERC_Util.getSobjectAPIName(sobjects.get(0));
		String serializedSobjects = Json.serialize(sobjects); 
		String sessionId = UserInfo.getSessionId();
		String body = 'Thou art a soul in bliss; but I am bound upon a wheel of fire...';
		MERC_DeleteNotifyMock mock = new MERC_DeleteNotifyMock(200, 'OK', body, null);
		Test.setMock(HttpCalloutMock.class, mock);
		MERC_DeleteNotifyService.sendDeletesToRTI(sobjectTypeAPIName, serializedSobjects, sessionId);
		Test.stopTest();		
	}
}