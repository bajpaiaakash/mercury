@isTest
private class MERC_HcpCapYearlyCalculationJobTest {

	static User runningUser = MERC_TestFactory.getRunningUser();
	static User testUser = MERC_TestFactory.getTestingUser();
	static List<Account> accounts;
	static Meeting_MERC__c meeting;
	static List<Meeting_Participant_MERC__c> participants;

	static {
		System.runAs(runningUser) {
			accounts = MERC_TestFactory.insertAccounts(200);
			meeting = MERC_TestFactory.insertMeetings(1).get(0);
			participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts);

			update new Meeting_MERC__c(
						Id                                   =meeting.Id,
						Meeting_Status_MERC__c               ='Registered',
						City_of_Meeting_MERC__c              ='London',
						Number_of_Expected_Employees_MERC__c =10,
						Number_of_Expected_Non_HCP_MERC__c   =10,
						Number_of_Expected_Speakers_MERC__c  =10,
						Interaction_Type_MERC__c             ='Virtual',
						Planned_Budget_MERC__c               =10000
			);
		}
	}

	@isTest static void test_batch_job() {

		for (Meeting_Participant_MERC__c participant : participants) {
			participant.Final_Fee_MERC__c           = 100;
			participant.Include_CAP_Roll_Up_MERC__c = true;
			//participant.Proposed_Final_Fee_MERC__c = 0;
		}
		update participants;

		for (Account a : accounts) {
			a.Allocated_CAP_MERC__c = null;
		}
		update accounts;

		//System.assertEquals(1,[SELECT COUNT() FROM Account WHERE Allocated_CAP_MERC__c=null]);

		System.runAs(testUser) {
			Test.startTest();
	       	MERC_HcpCapYearlyCalculationJob m = new MERC_HcpCapYearlyCalculationJob();
	       	Database.executeBatch(m);
	       	Test.stopTest();
	    }

       	System.debug([select Allocated_CAP_MERC__c from account]);
       	System.assertEquals(200,[SELECT COUNT() FROM Account WHERE Allocated_CAP_MERC__c=100.0], [select Allocated_CAP_MERC__c from account]);
	}
}