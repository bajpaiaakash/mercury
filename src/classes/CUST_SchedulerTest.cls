/**
 * @author Kyle Thornton
 *
 * Unit test class for CUST_Scheduler
 */

@isTest
private class CUST_SchedulerTest {

	static {
		MERC_TestFactory.insertMercuryCustomSettings();
	}

	@isTest static void test_method_one() {
		CUST_Scheduler scheduler = new CUST_Scheduler();
		System.assertEquals(0, scheduler.checkActiveJobs().size());
		scheduler.cronAll();
		System.assertNotEquals(0, scheduler.checkActiveJobs().size());
		scheduler.abortAll();
		System.assertEquals(0, scheduler.checkActiveJobs().size());

	}
}