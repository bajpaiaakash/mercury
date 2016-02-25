/**
 * @author Kyle Thornton
 *
 * Unit test for MERC_InvoiceInvalidationController
 */
 @isTest
private class MERC_InvoiceInvalidationControllerTest {

    static User runningUser = MERC_TestFactory.getRunningUser();
    static User testUser = MERC_TestFactory.getTestingUser();

    @isTest static void test_redirect() {
        Meeting_MERC__c meeting;
        List<Account> accounts;
        List<Meeting_Participant_MERC__c> participants;
        Invoice_MERC__c invoice;

        System.runAs(runningUser) {
            meeting = MERC_TestFactory.insertMeetings(1).get(0);
            MERC_TriggerHandlerStateManager.deactivateAll();
            accounts = MERC_TestFactory.insertAccounts(1);
            participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts);
            invoice = MERC_TestFactory.insertInvoices(participants).get(0);
        }

        System.runAs(testUser) {
            
            ApexPages.StandardController stdController = new ApexPages.StandardController(invoice);
            Test.startTest();
            MERC_InvoiceInvalidationController controller = new MERC_InvoiceInvalidationController(stdController);

            
            PageReference ref = controller.redirect();
            Test.stopTest();

            System.assertNotEquals(null, ref);
            System.assertEquals(invoice.id, ref.getParameters().get('id'));
        }
    }

}