@isTest
private class MERC_LockedRecordHandlerTest {
	
	static List<Meeting_MERC__c> meetings;
	static List<Account> accounts;
	static List<Meeting_Day_MERC__c> meetingDays;
	static List<Meeting_Participant_MERC__c> participants;

	static {
		accounts = MERC_TestFactory.insertAccounts(5); //insert 5 accounts
		meetings = MERC_TestFactory.insertMeetings(2); //insert 2 meetings
		meetingDays = MERC_TestFactory.insertMeetingDays(meetings.get(0).Id, 3); //insert 3 days
		participants = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts, 'Accepted'); //insert 5 participants
	}

	@isTest static void test_should_prevent_meeting_and_participant_update() {
		Meeting_MERC__c meeting = meetings.get(0);
		meeting.Lock_Meeting_MERC__c = true;
		update meeting;

		meeting.Name = 'a different name';
		try {
			update meeting;
		} catch(System.DmlException e) {
			system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, Operation Failed:  The record is locked due to the meeting being closed.  Please contact Customer Meeting Services for Assistance'));
		}

		Meeting_Participant_MERC__c participant = participants.get(0);
		participant.Status_MERC__c = 'a different status';
		try {
			update participant;
		} catch(System.DmlException e) {
			system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, Operation Failed:  The record is locked due to the meeting being closed.  Please contact Customer Meeting Services for Assistance'));
		}

	}
}