/**
 * @author Kyle Thornton
 *
 * Unit tests for MERC_ParticipantStatusCalculator trigger handler
 */
@isTest
private class MERC_ParticipantStatusCalculatorTest {

	static User testUser;

	/*----- 50 participants plus 4 days gives us 200 TOV records for bulk test -----*/
	static Meeting_MERC__c meeting;
	static List<Account> accounts;
	static List<Meeting_Participant_MERC__c> participants;
	static List<Meeting_Day_MERC__c> meetingDays;

	static {
		testUser = MERC_TestFactory.getUserInRole('CEO');

		User employeeUser = MERC_TestFactory.getUserInRole('Lilly Employee');
		System.runAs(employeeUser){
			meeting = MERC_TestFactory.insertMeetings(1).get(0);
			accounts = MERC_TestFactory.insertAccounts(50);
			participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts);
			meetingDays = MERC_TestFactory.insertMeetingDays(meeting.Id, 4);
		}
	}

	@isTest static void test_should_set_status_to_attended_when_attended_all_days() {
		System.runAs(testUser)
		{
			List<Daily_Attendance_TOV_MERC__c> tovs = createTovs('Attended');

			Test.startTest();
			insert tovs;
			Test.stopTest();

			System.assertEquals(50, [SELECT COUNT() FROM Meeting_Participant_MERC__c WHERE Status_MERC__c='Attended']);
		}
	}

	@isTest static void test_should_set_status_to_attended_when_attended_any_days() {
		System.runAs(testUser)
		{
			List<Daily_Attendance_TOV_MERC__c> tovs = createTovs('Attended', 'No Show');

			Test.startTest();
			insert tovs;
			Test.stopTest();

			System.assertEquals(50, [SELECT COUNT() FROM Meeting_Participant_MERC__c WHERE Status_MERC__c='Attended']);
		}
	}

	@isTest static void test_should_set_status_to_no_show_when_attended_zero_days() {
		System.runAs(testUser)
		{
			List<Daily_Attendance_TOV_MERC__c> tovs = createTovs('No Show');

			Test.startTest();
			insert tovs;
			Test.stopTest();

			System.assertEquals(50, [SELECT COUNT() FROM Meeting_Participant_MERC__c WHERE Status_MERC__c='No Show']);
		}
	}

	@isTest static void test_should_set_status_to_attended_on_update() {
		System.runAs(testUser)
		{
			List<Daily_Attendance_TOV_MERC__c> tovs = createTovs('No Show');

			Test.startTest();
			/*----- first insert, we know this works from tests above -----*/
			insert tovs;
			for (Daily_Attendance_TOV_MERC__c tov : tovs)
			{
				tov.Status_MERC__c = 'Attended';
			}

			/*----- now update -----*/
			update tovs;
			Test.stopTest();

			System.assertEquals(50, [SELECT COUNT() FROM Meeting_Participant_MERC__c WHERE Status_MERC__c='Attended']);
		}
	}

	@isTest static void test_should_set_status_to_no_show_when_all_deleted() {
		System.runAs(testUser)
		{
			List<Daily_Attendance_TOV_MERC__c> tovs = createTovs('Attended');

			Test.startTest();
			/*----- first insert, we know this works from tests above -----*/
			insert tovs;
			/*----- now delete -----*/
			delete tovs;
			Test.stopTest();

			System.assertEquals(50, [SELECT COUNT() FROM Meeting_Participant_MERC__c WHERE Status_MERC__c='No Show']);
		}
	}

	@isTest static void test_should_set_status_on_undelete() {
		System.runAs(testUser)
		{
			List<Daily_Attendance_TOV_MERC__c> tovs = createTovs('Attended');

			Test.startTest();
			/*----- first insert, we know this works from tests above -----*/
			insert tovs;
			/*----- now delete, status goes to no show, we know this works from tests above -----*/
			delete tovs;

			/*----- finally undelete -----*/
			undelete tovs;
			Test.stopTest();

			System.assertEquals(50, [SELECT COUNT() FROM Meeting_Participant_MERC__c WHERE Status_MERC__c='Attended']);
		}
	}


	private static List<Daily_Attendance_TOV_MERC__c> createTovs(String status)
	{
		return createTovs(status, null);
	}

	private static List<Daily_Attendance_TOV_MERC__c> createTovs(String status, String secondStatus)
	{
		List<Daily_Attendance_TOV_MERC__c> tovs = new List<Daily_Attendance_TOV_MERC__c>();
		for (Meeting_Participant_MERC__c p : participants)
		{
			String participantStatus = status;
			for (Meeting_Day_MERC__c md : meetingDays)
			{
				tovs.add( new Daily_Attendance_TOV_MERC__c( Meeting_Day_MERC__c         = md.Id
									                      , Meeting_Participant_MERC__c = p.Id
									                      , Status_MERC__c              = participantStatus)
				);
				if (secondStatus != null)
					participantStatus = secondStatus;
			}
		}
		return tovs;
	}

}