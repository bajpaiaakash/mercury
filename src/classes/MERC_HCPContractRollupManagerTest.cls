/**
 * @author Kyle Thornton
 *
 * unit tests for the MERC_HCPContractRollupManager. These tests only ensure coverage. other unit
 * tests in the org test actual functionalty
 */
@isTest
private class MERC_HCPContractRollupManagerTest {

	static User testUser = MERC_TestFactory.getRunningUser();
	static Account acct = MERC_TestFactory.insertAccounts(1).get(0);

	@isTest static void test_method_one() {
		System.runAs(testUser) {
			HCP_Contract_MERC__c contract = MERC_TestFactory.insertHCPContract(acct.id);
			update contract;
			delete contract;
			undelete contract;
		}
	}
}