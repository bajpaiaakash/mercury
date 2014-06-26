/**
 * @author Kyle Thornton
 *
 * Unit test for GLBL_RollupCalculateJob exercises code
 */

@isTest
private class GLBL_RollupCalculateJobTest {

	static Id lookupId;
	static {
		MERC_TestFactory.loadDeclarativeRollupSummaries();
		lookupId = [SELECT Id FROM LookupRollupSummary_GLBL__c limit 1].Id;
	}

	@isTest static void test_method_one() {
		Test.startTest();
		GLBL_RollupCalculateJob b = new GLBL_RollupCalculateJob(lookupid);
		Database.executeBatch(b);
		Test.stopTest();
	}
}