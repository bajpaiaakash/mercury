@isTest
private class GLBL_RollupServiceExceptionTest {

	static List<LookupRollupSummary_GLBL__c> rollups;
	static {
		MERC_TestFactory.loadDeclarativeRollupSummaries();
		rollups = [SELECT Id, Name FROM LookupRollupSummary_GLBL__c];
	}

	@isTest 
	static void test_method_one() {
		System.assertEquals('Lookup Rollup Summary  \'' + rollups.get(0).Name + '\' is invalid, your org configuration may have changed.'
			               , GLBL_RollupServiceException.invalidRollup(rollups.get(0)).getMessage());

		System.assertEquals('Invalid rollup ' + rollups.get(0).Id + ' not found.'
			               , GLBL_RollupServiceException.rollupNotFound(rollups.get(0).Id).getMessage());

		System.assertEquals('A calculate job for rollup \'name\' is already executing. If you suspect it is not aleady running try clearing the Calculate Job Id field and try again.'
			               , GLBL_RollupServiceException.jobAlreadyRunning('name').getMessage());

		System.assertEquals('A previous Declarative Rollup Summary scheduled job \'name\' is still running, this scheduled execution will not occur.'
			               , GLBL_RollupServiceException.jobsExecuting('name').getMessage());
	}
}