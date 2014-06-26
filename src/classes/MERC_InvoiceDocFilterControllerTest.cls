/**
 * @author Kyle Thornton
 *
 * Unit test for MERC_InvoiceDocFilterController
 */
@isTest
private class MERC_InvoiceDocFilterControllerTest {


	@isTest static void test_redirect() {
		List<Account> accs = MERC_TestFactory.insertAccounts(1);
 		List<Meeting_MERC__c> mtgs = MERC_TestFactory.insertMeetings(1);
 		List<Meeting_Participant_MERC__c> ps = MERC_TestFactory.insertParticipants(mtgs.get(0).Id, accs);
 		List<Invoice_MERC__c> invoices = MERC_TestFactory.insertInvoices(ps);

		ContentVersion c = new ContentVersion();
		c.Title = 'foo';
		c.FirstPublishLocationId = [SELECT Id FROM ContentWorkspace WHERE Name = 'Mercury' Limit 1].Id;
		c.PathOnClient = 'foo.pdf';
		c.VersionData = Blob.valueOf('foo');
		c.Invoice_MERC__c = invoices.get(0).Id;
		c.Document_Type_MERC__c = 'Invoices';

		insert c;
		System.debug([select FileType from ContentVersion where id=:c.id]);

		Test.startTest();
		PageReference ref = Page.MERC_InvoiceDocFilter;
		ref.getParameters().put('eid', invoices.get(0).Id);
		ref.getParameters().put('type', 'PDF');
		ref.getParameters().put('loopurl','/loopurl');
		Test.setCurrentPage(ref);

		MERC_InvoiceDocFilterController controller = new MERC_InvoiceDocFilterController();
		PageReference returnRef = controller.redirect();
		System.assert(returnRef.getUrl().contains('/loopurl'));

		System.assertEquals(0, [SELECT COUNT() FROM ContentDocument]);
		Test.stopTest();
	}

	@isTest static void test_redirect_fail() {
		List<Account> accs = MERC_TestFactory.insertAccounts(1);
 		List<Meeting_MERC__c> mtgs = MERC_TestFactory.insertMeetings(1);
 		List<Meeting_Participant_MERC__c> ps = MERC_TestFactory.insertParticipants(mtgs.get(0).Id, accs);
 		List<Invoice_MERC__c> invoices = MERC_TestFactory.insertInvoices(ps);

		ContentVersion c = new ContentVersion();
		c.Title = 'foo';
		c.FirstPublishLocationId = [SELECT Id FROM ContentWorkspace WHERE Name = 'Mercury' Limit 1].Id;
		c.PathOnClient = 'foo.pdf';
		c.VersionData = Blob.valueOf('foo');
		c.Invoice_MERC__c = invoices.get(0).Id;
		c.Document_Type_MERC__c = 'Invoices';

		insert c;
		System.debug([select FileType from ContentVersion where id=:c.id]);

		Test.startTest();
		PageReference ref = Page.MERC_InvoiceDocFilter;
		ref.getParameters().put('eid', invoices.get(0).Id);
		ref.getParameters().put('type', 'PDF');
		ref.getParameters().put('loopurl','/loopurl');
		Test.setCurrentPage(ref);

		Test.setReadOnlyApplicationMode(true);
		MERC_InvoiceDocFilterController controller = new MERC_InvoiceDocFilterController();
		PageReference returnRef = controller.redirect();
		System.assert(returnRef.getUrl().contains('/loopurl'));

		System.assertEquals(1, [SELECT COUNT() FROM ContentDocument]);
		Test.stopTest();
	}
}