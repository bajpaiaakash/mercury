/**
 * @author Joseph Ferraro & Kyle Thornton
 *
 * Exercises the appropriate coverage for the GLBL_BaseEditController controller via the Account page
 * Note: this does not test the callouts, those are tested in GLBL_DescribeLayoutTest
 */

@isTest
private class GLBL_BaseEditControllerTest {

	@isTest static void testAccountEditPage() {
		List<Account> accounts = MERC_TestFactory.insertAccounts(1);
		ApexPages.StandardController acctController = new ApexPages.StandardController(accounts.get(0));
		GLBL_BaseEditController controller = new GLBL_BaseEditController(acctController, Account.SobjectType);
	}

}