@isTest
private class MERC_PrimaryMeetingOwnerHandlerTest {

	static User testUser = MERC_TestFactory.insertTestUsers(1, 'Mercury Integration RTI - Platform').get(0);

	@isTest static void test_should_create_team_member_for_meeting_when_source_is_Mercury() {

		List<Meeting_MERC__c> mtgs = new List<Meeting_MERC__c>();
		for (Integer i = 0; i < 200; i++) {
			Meeting_MERC__c m           = new Meeting_MERC__c();
			m.Date_of_Event_MERC__c     = Date.today().addDays(2);
			m.End_Date_of_Event_MERC__c = Date.today().addDays(2);
			m.Name                      = 'Event Name'+i;
			m.Meeting_Time_Zone_MERC__c = 'Greenwich Mean Time (Europe/London)';
			m.Source_MERC__c            = 'Mercury';
			mtgs.add(m);
		}

		System.runAs(testUser)
		{
			Test.startTest();
			insert mtgs;
			Test.stopTest();
		}
		//there should be 200 team member records for the testUser
		System.assertEquals(200, [SELECT COUNT()
			                        FROM Team_Member_MERC__c
			                       WHERE User_MERC__c = :testUser.Id
			                         AND Role_MERC__c = 'Primary Meeting Owner']);
	}

	@isTest static void test_should_not_create_team_members_when_source_is_not_mercury() {
		List<Meeting_MERC__c> mtgs = new List<Meeting_MERC__c>();
		for (Integer i = 0; i < 200; i++) {
			Meeting_MERC__c m           = new Meeting_MERC__c();
			m.Date_of_Event_MERC__c     = Date.today().addDays(2);
			m.End_Date_of_Event_MERC__c = Date.today().addDays(2);
			m.Name                      = 'Event Name'+i;
			m.Meeting_Time_Zone_MERC__c = 'Greenwich Mean Time (Europe/London)';
			m.Source_MERC__c            = 'Veeva';
			mtgs.add(m);
		}

		System.runAs(testUser)
		{
			Test.startTest();
			insert mtgs;
			Test.stopTest();
		}

		//there should be no team members at all
		System.assertEquals(0, [SELECT COUNT() FROM Team_Member_MERC__c]);
	}

}