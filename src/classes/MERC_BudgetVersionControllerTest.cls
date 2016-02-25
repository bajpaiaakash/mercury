/**
 * @author Joseph Ferraro
 *
 * Asserts functionality of the MERC_BudgetVersionController controller
 */

@isTest
private class MERC_BudgetVersionControllerTest {
    
    static List<Meeting_MERC__c> mtgs;
    static Budget_MERC__c b;
    static List<Budget_Line_Item_MERC__c> budgetLines;
    
    static {
        MERC_TestFactory.insertMercuryCustomSettings();
        mtgs = MERC_TestFactory.insertMeetings(1);
        b = MERC_TestFactory.insertBudget(mtgs.get(0).Id,true);
        budgetLines = MERC_TestFactory.insertBudgetLineItems(b.Id, 5);
    }

    @isTest static void test_should_activate_budget() {
        PageReference activatePage = Page.MERC_ActivateBudget;
        activatePage.getParameters().put('id', b.Id);
        Test.setCurrentPage(activatePage);
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(b);
        MERC_BudgetVersionController controller = new MERC_BudgetVersionController(stdController);
        controller.activate();
        Test.stopTest();
        System.assertEquals('Active', [Select Status_MERC__c From Budget_MERC__c WHERE ID = :b.Id].Status_MERC__c);
    }

    @isTest static void test_should_activate_and_create_new_version_of_budget() {
        PageReference activatePage = Page.MERC_ActivateBudget;
        Test.startTest();
        activatePage.getParameters().put('id', b.Id);
        Test.setCurrentPage(activatePage);
        ApexPages.StandardController stdController = new ApexPages.StandardController(b);
        MERC_BudgetVersionController controller = new MERC_BudgetVersionController(stdController);
        controller.activate();
        System.assertEquals('Active', [Select Status_MERC__c From Budget_MERC__c WHERE ID = :b.Id].Status_MERC__c);
        PageReference versionPage = Page.MERC_NewBudgetVersion;
        versionPage.getParameters().put('id', b.Id);
        Test.setCurrentPage(versionPage);
        controller = new MERC_BudgetVersionController(stdController);
        controller.newVersion();
        Test.stopTest();
        System.assertEquals('Active', [Select Status_MERC__c From Budget_MERC__c WHERE ID = :b.Id].Status_MERC__c);
        System.assertEquals(1, [Select count() From Budget_MERC__c WHERE Master_Budget_MERC__c = :b.Id]);
    }
    @isTest static void test_should_Finalize_budget() {
        PageReference finalizePage = Page.MERC_FinalizeBudgetConfirm;
        finalizePage.getParameters().put('id', b.Id);
        Test.setCurrentPage(finalizePage);
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(b);
        MERC_BudgetVersionController controller = new MERC_BudgetVersionController(stdController);
        controller.finalize();
        Test.stopTest();
        System.assertEquals('Final', [Select Status_MERC__c From Budget_MERC__c WHERE ID = :b.Id].Status_MERC__c);
    
    }

    @isTest static void test_should_fail_to_finalize_budged() {
        Test.startTest();
        Budget_MERC__c budgetNoLines = MERC_TestFactory.insertStandAloneBudget();
        PageReference finalizePage = Page.MERC_FinalizeBudgetConfirm;
        ApexPages.StandardController stdController = new ApexPages.StandardController(budgetNoLines);
        MERC_BudgetVersionController controller = new MERC_BudgetVersionController(stdController);
        controller.finalize();
        Test.stopTest();
        System.assertNotEquals('Final', [Select Status_MERC__c From Budget_MERC__c WHERE ID = :budgetNoLines.Id].Status_MERC__c);    

    }
}