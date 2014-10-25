/**
 * @author Kyle Thornton
 *
 * Description: The unit tests for MERC_MVIMeetingTimeZoneHandler. Tests that dates are adjusted for
 * the mvi user but for nobody else.
 */
@isTest
private class MERC_MVIMeetingTimeZoneHandlerTest
{

	static User runningUser = MERC_TestFactory.getRunningUser();
	static User testUser = MERC_TestFactory.getTestingUser();
	static List<Meeting_MERC__c> meetings;
	static
	{
		MERC_TestFactory.loadTimeZoneFieldMapSettings();
		System.runAs(runningUser)
		{
			meetings = MERC_TestFactory.insertMeetings(200);
		}
	}


	@isTest static void test_should_set_dates_per_timezone_when_MVI_updates()
	{
		User mviUser = [SELECT Id FROM user WHERE username LIKE 'mercuryintegration.veeva@%' limit 1];
		System.runAs(mviUser)
		{
			for (Meeting_MERC__c meeting : meetings)
			{
				meeting.Date_of_Event_MERC__c = Date.today().addDays(1);
				meeting.Start_Time_of_Meeting_MERC__c = DateTime.newInstance(meeting.Date_of_Event_MERC__c, Time.newInstance(2, 0, 0, 0)); //2am will convert to prior day gmt
				meeting.End_Date_of_Event_MERC__c = Date.today().addDays(3);
				meeting.End_Time_of_Meeting_MERC__c = DateTime.newInstance(meeting.End_Date_of_Event_MERC__c, Time.newInstance(2, 0, 0, 0));
				meeting.Meeting_Time_Zone_MERC__c = 'Moscow Standard Time (Europe/Moscow)'; // GMT + 4
				meeting.Confirm_Meeting_Date_Change_MERC__c = true;
			}
			Test.startTest();
			update meetings;
			Test.stopTest();
		}

		meetings = [SELECT Date_of_Event_MERC__c, Start_Time_of_Meeting_MERC__c, End_Date_of_Event_MERC__c, End_Time_of_Meeting_MERC__c FROM Meeting_MERC__c];
		System.assertEquals(200, meetings.size());
		for (Meeting_MERC__c meeting : meetings)
		{
			System.assertEquals(Date.today().addDays(1), meeting.Date_of_Event_MERC__c);
			System.assertEquals(Datetime.newInstance(Date.today(), Time.newInstance(22,0,0,0)), meeting.Start_Time_of_Meeting_MERC__c);
			System.assertEquals(Date.today().addDays(3), meeting.End_Date_of_Event_MERC__c);
			System.assertEquals(Datetime.newInstance(Date.today().addDays(2), Time.newInstance(22,0,0,0)), meeting.End_Time_of_Meeting_MERC__c);
		}
	}

	@isTest static void test_should_not_set_dates_when_non_MVI_updates()
	{

		System.runAs(testUser)
		{
			for (Meeting_MERC__c meeting : meetings)
			{
				meeting.Date_of_Event_MERC__c = Date.today().addDays(1);
				meeting.Start_Time_of_Meeting_MERC__c = DateTime.newInstance(meeting.Date_of_Event_MERC__c, Time.newInstance(2, 0, 0, 0)); //2am will convert to prior day gmt
				meeting.End_Date_of_Event_MERC__c = Date.today().addDays(3);
				meeting.End_Time_of_Meeting_MERC__c = DateTime.newInstance(meeting.End_Date_of_Event_MERC__c, Time.newInstance(2, 0, 0, 0));
				meeting.Meeting_Time_Zone_MERC__c = 'Moscow Standard Time (Europe/Moscow)'; // GMT + 4
				meeting.Confirm_Meeting_Date_Change_MERC__c = true;
			}
			Test.startTest();
			update meetings;
			Test.stopTest();
		}

		meetings = [SELECT Date_of_Event_MERC__c, Start_Time_of_Meeting_MERC__c, End_Date_of_Event_MERC__c, End_Time_of_Meeting_MERC__c FROM Meeting_MERC__c];
		System.assertEquals(200, meetings.size());
		for (Meeting_MERC__c meeting : meetings)
		{
			System.assertEquals(Date.today().addDays(1), meeting.Date_of_Event_MERC__c);
			System.assertEquals(Datetime.newInstance(Date.today().addDays(1), Time.newInstance(2,0,0,0)), meeting.Start_Time_of_Meeting_MERC__c);
			System.assertEquals(Date.today().addDays(3), meeting.End_Date_of_Event_MERC__c);
			System.assertEquals(Datetime.newInstance(Date.today().addDays(3), Time.newInstance(2,0,0,0)), meeting.End_Time_of_Meeting_MERC__c);
		}
	}
}