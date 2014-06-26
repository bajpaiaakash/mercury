@isTest
private class CUST_AdminUtilitiesControllerTest {

	@isTest static void test_initialize_controller() {
		CUST_AdminUtilitiesController controller = new CUST_AdminUtilitiesController();
		controller.initJobs();
		System.assertEquals(CUST_AdminUtilitiesController.STATUS_SUCCESS, controller.result);
		System.assertEquals('SUCCESS!  Click <a href="/08e?setupid=ScheduledJobs">here to view scheduled jobs</a>.', controller.message);
		controller.stopJobs();
		System.assertEquals(CUST_AdminUtilitiesController.STATUS_SUCCESS, controller.result);
		System.assertEquals('Active Jobs Deleted', controller.message);
	}
}