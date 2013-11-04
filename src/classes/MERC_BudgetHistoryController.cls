public with sharing class MERC_BudgetHistoryController {

	private final sObject mysObject;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public MERC_BudgetHistoryController(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
    }

}