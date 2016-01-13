/**
 * @author Kyle Thornton
 * Unit test class for CUST_Scheduler
 */

@isTest
private class CUST_SchedulerTest {

	static {
		Mercury_Settings_MERC__c settings = new Mercury_Settings_MERC__c();
		settings.CST_Expire_Cron_Name_CUST__c = 'CST Set Access To Expired TEST';
		settings.CST_Expire_Cron_Sched_CUST__c = '0 0 13 1 * ?';
		settings.CST_Notify_Cron_Name_CUST__c = 'CST Set Access To Will Expire TEST';
		settings.CST_Notify_Cron_Sched_CUST__c =  '0 0 13 15 * ?';
		settings.CST_Review_Cron_Name_CUST__c = 'CST Set Access To Under Review TEST';
		settings.CST_Review_Cron_Sched_CUST__c = '0 0 * * * ?';
		insert settings;
	}

	// Testing that you can properly schedule and abort the CUST_Scheduler
	@isTest static void test_scheduling_Scheduler() {
		CUST_Scheduler scheduler = new CUST_Scheduler();
		System.assertEquals(0, scheduler.checkActiveJobs().size());
		scheduler.cronAll();
		System.assertNotEquals(0, scheduler.checkActiveJobs().size());
		scheduler.abortAll();
		System.assertEquals(0, scheduler.checkActiveJobs().size());

	}
}