/**
 * @author Kyle Thornton
 *
 * Unit tests for the GLBL_RollupCalculateController class
 */
@isTest
private class GLBL_RollupCalculateControllerTest {

	@isTest static void test_should_runCalculateJob() {
		MERC_TestFactory.loadDeclarativeRollupSummaries();
		LookupRollupSummary_GLBL__c lookup = [SELECT Id FROM LookupRollupSummary_GLBL__c limit 1];

		Test.startTest();
		ApexPages.StandardController stdController = new ApexPages.StandardController(lookup);
		GLBL_RollupCalculateController controller = new GLBL_RollupCalculateController(stdController);

		controller.runCalculateJob();
		Test.stopTest();

		System.assertEquals('Calculate job started for this lookup.', ApexPages.getMessages().get(2).getSummary());
	}

	@isTest static void test_should_catch_error_on_runCalculateJob() {
		MERC_TestFactory.loadDeclarativeRollupSummaries();
		LookupRollupSummary_GLBL__c lookup = [SELECT Id, Active_GLBL__c FROM LookupRollupSummary_GLBL__c limit 1];
		lookup.Active_GLBL__c = false;
		update lookup;

		Test.startTest();
		ApexPages.StandardController stdController = new ApexPages.StandardController(lookup);
		GLBL_RollupCalculateController controller = new GLBL_RollupCalculateController(stdController);
		System.assertEquals(null, controller.runCalculateJob());
		Test.stopTest();

		System.assertEquals('The rollup must be Active before you can run a Calculate job.', ApexPages.getMessages().get(2).getSummary());
	}
}