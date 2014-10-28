@isTest
private class MERC_ParticipantFMVCalculatorTest {

    static User runningUser = MERC_TestFactory.getRunningUser();
    static User testUser = MERC_TestFactory.getTestingUser();
	static List<Meeting_MERC__c> meetings;
	static List<Account> accounts;
	static List<Meeting_Day_MERC__c> meetingDays;
	static List<Meeting_Participant_MERC__c> participants;
	static List<Meeting_Participant_MERC__c> participants2;

	static {
		MERC_TestFactory.loadFMVSettings();

		System.runAs(runningUser)
		{
	        MERC_TriggerHandlerStateManager.deactivateAll();
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
	        MERC_TriggerHandlerStateManager.activateAll();
		}

		MERC_TestFactory.loadFMVSettings();
	}

	@isTest static void test_should_stamp_fmv_rates_on_participant_update() {
		System.runAs(testUser)
		{
			Test.startTest();
			update participants;

			List<Meeting_Participant_MERC__c> updatedParticipants = [SELECT Id, Minimum_Rate_MERC__c, Maximum_Rate_MERC__c
			                                                           FROM Meeting_Participant_MERC__c
			                                                          WHERE Id IN :participants];
            for (Meeting_Participant_MERC__c p : updatedParticipants)
            {
            	System.assertEquals(60, p.Minimum_Rate_MERC__c);
            	System.assertEquals(100, p.Maximum_Rate_MERC__c);
            }
			Test.stopTest();
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

			List<Meeting_Participant_MERC__c> updatedParticipants = [SELECT Id, Minimum_Rate_MERC__c, Maximum_Rate_MERC__c
			                                                           FROM Meeting_Participant_MERC__c
			                                                          WHERE Id IN :participants];
            for (Meeting_Participant_MERC__c p : updatedParticipants)
            {
            	System.assertEquals(90, p.Minimum_Rate_MERC__c);
            	System.assertEquals(140, p.Maximum_Rate_MERC__c);
            }
			Test.stopTest();
		}
	}
}