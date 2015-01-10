@isTest
private class MERC_HcpCapYearlyCalculationScheduleTest {

	static {
		List<Account> accounts = MERC_TestFactory.insertAccounts(200);
		Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1).get(0);
		List<Meeting_Participant_MERC__c> participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts);
	}

	@isTest static void test_method_one() {
		Test.startTest();

		MERC_HcpCapYearlyCalculationScheduler m = new MERC_HcpCapYearlyCalculationScheduler();
		String sch = '0 0 8 1 1 ? *';
		String jobID = system.schedule('Yearly CAP Calculation Job', sch, m);

   		Test.stopTest();
	}

}