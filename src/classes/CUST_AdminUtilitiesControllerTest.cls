/**
* CUST_AdminUtilitiesControllerTest
* Created By: Sean Harrison, Mavens
* Description: Tests the CUST_AdminUtilitiesController.
*/

@isTest
private class CUST_AdminUtilitiesControllerTest {

	// Initialize CUST_AdminUtilitiesController.
	@isTest static void test_initialize_controller() {

		// Fill in necessary Mercury Settings.
		Mercury_Settings_MERC__c settings = new Mercury_Settings_MERC__c();
		settings.CST_Expire_Cron_Name_CUST__c = 'CST Set Access To Expired TEST';
		settings.CST_Expire_Cron_Sched_CUST__c = '0 0 13 1 * ?';
		settings.CST_Notify_Cron_Name_CUST__c = 'CST Set Access To Will Expire TEST';
		settings.CST_Notify_Cron_Sched_CUST__c =  '0 0 13 15 * ?';
		settings.CST_Review_Cron_Name_CUST__c = 'CST Set Access To Under Review TEST';
		settings.CST_Review_Cron_Sched_CUST__c = '0 0 * * * ?';
		insert settings;

		CUST_AdminUtilitiesController controller = new CUST_AdminUtilitiesController();
		controller.initJobs();
		System.assertEquals(CUST_AdminUtilitiesController.STATUS_SUCCESS, controller.result);
		System.assertEquals('SUCCESS!  Click <a href="/08e?setupid=ScheduledJobs">here to view scheduled jobs</a>.', controller.message);
		controller.stopJobs();
		System.assertEquals(CUST_AdminUtilitiesController.STATUS_SUCCESS, controller.result);
		System.assertEquals('Active Jobs Deleted', controller.message);
	}
}