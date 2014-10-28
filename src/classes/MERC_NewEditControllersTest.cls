/**
 * @author Kyle Thornton
 *
 * This test class simply aims to gain coverage for any new edit contorllers that only extend the
 * GLBL_BaseEditController and add no functionality. the tests here simple instantiate each controller
 */
@isTest
private class MERC_NewEditControllersTest {

	static User runningUser = MERC_TestFactory.getRunningUser();
	static User testUser = MERC_TestFactory.getTestingUser();

	@isTest static void test_instantiate_meeting_product_controller () {
		System.runAs(testUser) {
			Meeting_Products_MERC__c meetingProduct =  new Meeting_Products_MERC__c();
			ApexPages.StandardController stdController = new ApexPages.StandardController(meetingProduct);
			MERC_MeetingProductNewEditController controller = new MERC_MeetingProductNewEditController(stdController);
		}
	}

	@isTest static void test_instantiate_budget_line_item_controller () {
		System.runAs(testUser) {
			Budget_Line_Item_MERC__c bli = new Budget_Line_Item_MERC__c();
			ApexPages.StandardController stdController = new ApexPages.StandardController(bli);
			MERC_BudgetLineItemNewEditController controller = new MERC_BudgetLineItemNewEditController(stdController);
		}
	}

	@isTest static void test_instantiate_invoice_controller () {
		System.runAs(testUser) {
			Invoice_MERC__c invoice = new Invoice_MERC__c();
			ApexPages.StandardController stdController = new ApexPages.StandardController(invoice);
			MERC_InvoiceNewEditController controller = new MERC_InvoiceNewEditController(stdController);
		}
	}

	@isTest static void test_instantiate_participant_agenda_controller () {
		System.runAs(testUser) {
			Participant_Agenda_MERC__c pAgenda = new Participant_Agenda_MERC__c();
			ApexPages.StandardController stdController = new ApexPages.StandardController(pAgenda);
			MERC_ParticipantAgendaNewEditController controller = new MERC_ParticipantAgendaNewEditController(stdController);
		}
	}

}