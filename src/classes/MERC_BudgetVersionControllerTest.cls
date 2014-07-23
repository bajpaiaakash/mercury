/**
 * @author Joseph Ferraro
 *
 * Asserts functionality of the MERC_BudgetVersionController controller
 */

@isTest
private class MERC_BudgetVersionControllerTest {

	static User testUser = MERC_TestFactory.getRunningUser();
	static List<Meeting_MERC__c> mtgs;
	static Budget_MERC__c b;
	static Budget_MERC__c b2;
	static List<Budget_Line_Item_MERC__c> budgetLines;
	static List<Budget_Line_Item_MERC__c> budget2Lines;

	static {
		MERC_TestFactory.insertMercuryCustomSettings();
		mtgs = MERC_TestFactory.insertMeetings(1);
		b = MERC_TestFactory.insertBudget(mtgs.get(0).Id);
		budgetLines = MERC_TestFactory.insertBudgetLineItems(b.Id, 5);
	}

	@isTest static void test_should_activate_budget() {
		System.runAs(testUser) {
			PageReference activatePage = Page.MERC_ActivateBudget;
			activatePage.getParameters().put('id', b.Id);
			Test.setCurrentPage(activatePage);

			ApexPages.StandardController stdController = new ApexPages.StandardController(b);
			MERC_BudgetVersionController controller = new MERC_BudgetVersionController(stdController);
			controller.activate();

			System.assertEquals('Active', [Select Status_MERC__c From Budget_MERC__c WHERE ID = :b.Id].Status_MERC__c);
		}
	}

	@isTest static void test_should_activate_and_create_new_version_of_budget() {
		b.Status_MERC__c = 'Approved';
		update b;
		b2 = MERC_TestFactory.insertBudget(mtgs.get(0).Id);
		b2.Previous_Budget_Revision_MERC__c = b.Id;
		update b2;
		budget2Lines = MERC_TestFactory.insertBudgetLineItems(b.Id, 5);


		System.runAs(testUser) {
			PageReference activatePage = Page.MERC_ActivateBudget;
			activatePage.getParameters().put('id', b2.Id);
			Test.setCurrentPage(activatePage);

			ApexPages.StandardController stdController = new ApexPages.StandardController(b2);
			MERC_BudgetVersionController controller = new MERC_BudgetVersionController(stdController);
			controller.activate();

			System.assertEquals('Active', [Select Status_MERC__c From Budget_MERC__c WHERE ID = :b2.Id].Status_MERC__c);

			PageReference versionPage = Page.MERC_NewBudgetVersion;
			versionPage.getParameters().put('id', b2.Id);
			Test.setCurrentPage(versionPage);

			controller = new MERC_BudgetVersionController(stdController);
			controller.newVersion();

			System.assertEquals('Active', [Select Status_MERC__c From Budget_MERC__c WHERE ID = :b2.Id].Status_MERC__c);
			List<Budget_MERC__c> b3 = [Select Id, Master_Budget_MERC__c From Budget_MERC__c WHERE Master_Budget_MERC__c = :b2.Id];
			System.assertEquals(1, b3.size()) ;
			System.assertEquals('Archived', [Select Status_MERC__c From Budget_MERC__c WHERE ID = :b.Id].Status_MERC__c);

			stdController = new ApexPages.StandardController(b3.get(0));
			controller = new MERC_BudgetVersionController(stdController);
			controller.activate();
			controller.newVersion();
			System.assertEquals(2, [Select count() From Budget_MERC__c WHERE Master_Budget_MERC__c = :b2.Id]);
		}
	}

	@isTest static void test_should_finalize_budget() {
		System.runAs(testUser) {
			PageReference activatePage = Page.MERC_ActivateBudget;
			activatePage.getParameters().put('id', b.Id);
			Test.setCurrentPage(activatePage);

			ApexPages.StandardController stdController = new ApexPages.StandardController(b);
			MERC_BudgetVersionController controller = new MERC_BudgetVersionController(stdController);
			controller.finalize();

			System.assertEquals('Final', [Select Status_MERC__c From Budget_MERC__c WHERE ID = :b.Id].Status_MERC__c);

			Test.setReadOnlyApplicationMode(true);
			System.assertEquals(null, controller.finalize());
			System.assert(!ApexPages.getMessages().isEmpty());

		}
	}

}