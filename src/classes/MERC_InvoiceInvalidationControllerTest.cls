/**
 * @author Kyle Thornton
 *
 * Unit test for MERC_InvoiceInvalidationController
 */
 @isTest
private class MERC_InvoiceInvalidationControllerTest {

	static User testUser = MERC_TestFactory.getRunningUser();

	@isTest static void test_method_one() {
		Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1).get(0);
		List<Account> accounts = MERC_TestFactory.insertAccounts(1);
		List<Meeting_Participant_MERC__c> participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts);
		Invoice_MERC__c invoice = MERC_TestFactory.insertInvoices(participants).get(0);

		System.runAs(testUser) {
			ApexPages.StandardController stdController = new ApexPages.StandardController(invoice);
			MERC_InvoiceInvalidationController controller = new MERC_InvoiceInvalidationController(stdController);

			Test.startTest();
			PageReference ref = controller.redirect();
			Test.stopTest();

			System.assertNotEquals(null, ref);
			System.assertEquals(invoice.id, ref.getParameters().get('id'));
		}
	}

}