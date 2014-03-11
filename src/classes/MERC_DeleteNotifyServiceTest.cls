/** 
* @author Sean Harrison 
* 
* This is a unit test class for MERC_DeleteNotifyService.cls which is intended 
* as a delete trigger on MERC_Meeting, MERC_MeetingParticipant, MERC_MeetingProducts, MERC_TeamMember
*/

@isTest
private class MERC_DeleteNotifyServiceTest {
	
	static List<Account> accounts;
	static List<Meeting_MERC__c> meetings;
	static List<Meeting_Participant_MERC__c> participants;

	static {
		accounts = MERC_TestFactory.insertAccounts(2);
		meetings = MERC_TestFactory.insertMeetings(200);
	}

	// just delete some meetings
	@isTest 
	static void testMeetingDelete() {
		String body = 'Once more unto the breach, dear friends! Once more!';
		MERC_DeleteNotifyMock mock = new MERC_DeleteNotifyMock(200, 'OK', body, null);

		Test.setMock(HttpCalloutMock.class, mock);
		Test.startTest();

		delete meetings;

		Test.stopTest();
	}
	
	// delete a batch of meetings and their participants
	@isTest 
	static void testCascadeDelete() {
		participants = MERC_TestFactory.insertBulkParticipants(meetings, accounts);

		String body = 'Now is the winter of our discontent made glorious summer...';
		MERC_DeleteNotifyMock mock = new MERC_DeleteNotifyMock(200, 'OK', body, null);

		Test.setMock(HttpCalloutMock.class, mock);
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
		List<SObject> sobjects = new List<SObject>();
		for (Meeting_MERC__c m : meetings) {
			sobjects.add((Sobject) m);
		}

		String body = 'Thou art a soul in bliss; but I am bound upon a wheel of fire...';
		MERC_DeleteNotifyMock mock = new MERC_DeleteNotifyMock(200, 'OK', body, null);

		Test.setMock(HttpCalloutMock.class, mock);
		Test.startTest();
		
		String sobjectTypeAPIName = MERC_Util.getSobjectAPIName(sobjects.get(0));
		String serializedSobjects = Json.serialize(sobjects); 
		String sessionId = UserInfo.getSessionId();
		MERC_DeleteNotifyService.execute(sobjectTypeAPIName, serializedSobjects, sessionId);

		Test.stopTest();		
	}
}