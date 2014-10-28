/*
 * @author Kyle Thornton
 *
 * This class is the extension controller for the MERC_BudgetLineItemNewEdit.page. Its only purpose
 * is to pass the Participant Agenda SObject type to the glbl base edit controller since it is not
 * possible, due to salesforce limitations, to extract the sobject type from the standard controller
 * and also use add fields.
 */
public with sharing class MERC_BudgetLineItemNewEditController extends GLBL_BaseEditController {
	public MERC_BudgetLineItemNewEditController(ApexPages.StandardController stdController) {
		super(stdController, Budget_Line_Item_MERC__c.SObjectType);
	}
}