@isTest
private class MERC_ParticipantFMVCalculatorTest {

	static User testUser;
	static
	{
		System.runAs(new User(Id=UserInfo.getUserId()))
		{
			testUser = MERC_TestFactory.insertTestUsers(1, null).get(0);
			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='Mercury_Customer_Meeting_Services_Edit' limit 1];
			insert new PermissionSetAssignment( PermissionSetId=ps.Id
				                              , AssigneeId=testUser.id);
			update new User( id=testUser.Id
				           , UserRoleId=[SELECT Id FROM UserRole WHERE Name='Global' limit 1].id);
		}
		MERC_TestFactory.loadFMVSettings();
	}

	static List<Meeting_MERC__c> meetings;
	static List<Account> accounts;
	static List<Meeting_Day_MERC__c> meetingDays;
	static List<Meeting_Participant_MERC__c> participants;
	static List<Meeting_Participant_MERC__c> participants2;

	static {
		accounts = MERC_TestFactory.insertHcpAccountsInCountry(5, 'GB'); //insert 5 accounts
		meetings = MERC_TestFactory.insertMeetings(2); //insert 2 meetings
		meetingDays = MERC_TestFactory.insertMeetingDays(meetings.get(0).Id, 3); //insert 3 days
		participants = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts); //insert 5 participants
		participants2 = MERC_TestFactory.insertParticipants(meetings.get(1).Id, accounts); //insert 5 participants

		List<Account> accts = [SELECT Id, Service_Provider_Tier_MERC__c, Academic_Qualifications_MERC__c
		                         FROM Account
		                        WHERE Id IN :accounts];
		for (Account a : accts)
 		{
 			//values in loaded custom setting data will map to min=60, max=100 for a tier 3 phd non-md
 			a.Service_Provider_Tier_MERC__c = 3;
 			a.Academic_Qualifications_MERC__c = 'PhD non-MD';
 		}
 		update accts;

		MERC_TestFactory.loadFMVSettings();
	}

	@isTest static void test_should_stamp_fmv_rates_on_participant_update() {
		System.runAs(testUser)
		{
			Test.startTest();
			update participants;
			Test.stopTest();

			List<Meeting_Participant_MERC__c> updatedParticipants = [SELECT Id, Minimum_Rate_MERC__c, Maximum_Rate_MERC__c
			                                                           FROM Meeting_Participant_MERC__c
			                                                          WHERE Id IN :participants];
            for (Meeting_Participant_MERC__c p : updatedParticipants)
            {
            	System.assertEquals(60, p.Minimum_Rate_MERC__c);
            	System.assertEquals(100, p.Maximum_Rate_MERC__c);
            }
		}
	}

	@isTest static void test_should_stamp_fmv_rates_on_participant_on_account_update() {
		System.runAs(testUser)
		{
			List<Account> accts = [SELECT Service_Provider_Tier_MERC__c, Calculate_Open_Meeting_Fees_MERC__c
			                         FROM Account
			                        WHERE Id IN :accounts];
			for (Account a : accts)
			{
				a.Service_Provider_Tier_MERC__c       = 2; //change the tier so that maps to min=90, max=140;
				a.Calculate_Open_Meeting_Fees_MERC__c = true;
			}
			Test.startTest();
			update accts;
			Test.stopTest();

			List<Meeting_Participant_MERC__c> updatedParticipants = [SELECT Id, Minimum_Rate_MERC__c, Maximum_Rate_MERC__c
			                                                           FROM Meeting_Participant_MERC__c
			                                                          WHERE Id IN :participants];
            for (Meeting_Participant_MERC__c p : updatedParticipants)
            {
            	System.assertEquals(90, p.Minimum_Rate_MERC__c);
            	System.assertEquals(140, p.Maximum_Rate_MERC__c);
            }
		}
	}
}