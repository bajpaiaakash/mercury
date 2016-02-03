/* MERC_InvoiceDocFilterControllerTest
 * Created by: Rick Locke
 * Created date: Nov 17, 2015
 * Description: Tests the MERC_InvoiceDocFilterController.
 */
@isTest
private class MERC_InvoiceDocFilterControllerTest {
	
	@isTest static void test_redirectSuccess() {
		Id invoiceId = createContent();
		PageReference pageRef = Page.MERC_NewInvoiceContent;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('eId', invoiceId);
		ApexPages.currentPage().getParameters().put('type', 'PDF');
		ApexPages.currentPage().getParameters().put('loopURL', 'http://www.lilly.com');
		MERC_InvoiceDocFilterController controller = new MERC_InvoiceDocFilterController();
		controller.redirect();
		Integer size = [SELECT Id, ContentDocumentId From ContentVersion WHERE Invoice_MERC__c = :invoiceId AND FileType = 'PDF' AND Document_Type_MERC__c = 'Invoices'].size();
		//delete succeeds, no records should be found.
		System.assertEquals(0, size);
	}
	
	@isTest static void test_redirectFailure() {
		Id invoiceId = createContent();
		PageReference pageRef = Page.MERC_NewInvoiceContent;
		Test.setCurrentPage(pageRef);
		//no parameters set to trigger failure
		MERC_InvoiceDocFilterController controller = new MERC_InvoiceDocFilterController();
		controller.redirect();
		Integer size = [SELECT Id, ContentDocumentId From ContentVersion WHERE Invoice_MERC__c = :invoiceId AND FileType = 'PDF' AND Document_Type_MERC__c = 'Invoices'].size();
		//delete fails, 1 record should be found.
		System.assertEquals(1, size);
	}

	@isTest static void test_deleteOldInvoiceContentSuccess() {
		Id invoiceId = createContent();
		PageReference pageRef = Page.MERC_NewInvoiceContent;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('Id', invoiceId);
		ApexPages.currentPage().getParameters().put('pdf', '1');
		MERC_InvoiceDocFilterController controller = new MERC_InvoiceDocFilterController();
		controller.deleteOldInvoiceContent();
		Integer size = [SELECT Id, ContentDocumentId From ContentVersion WHERE Invoice_MERC__c = :invoiceId AND FileType = 'PDF' AND Document_Type_MERC__c = 'Invoices'].size();
		//delete succeeds, no records should be found.
		System.assertEquals(0, size);
	}

	@isTest static void test_deleteOldInvoiceContentFailure() {
		Id invoiceId = createContent();
		PageReference pageRef = Page.MERC_NewInvoiceContent;
		Test.setCurrentPage(pageRef);
		//no parameters set to trigger failure
		MERC_InvoiceDocFilterController controller = new MERC_InvoiceDocFilterController();
		controller.deleteOldInvoiceContent();
		Integer size = [SELECT Id, ContentDocumentId From ContentVersion WHERE Invoice_MERC__c = :invoiceId AND FileType = 'PDF' AND Document_Type_MERC__c = 'Invoices'].size();
		//delete fails, 1 record should be found.
		System.assertEquals(1, size);
	}

	private static id createContent() {
		Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1)[0];
		List<Account> accounts = MERC_TestFactory.insertAccounts(1);
		List<Meeting_Participant_MERC__c> participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts);
		Invoice_MERC__c invoice = MERC_TestFactory.insertInvoices(participants)[0];

        Blob pdfBlob = Blob.toPdf('<html><body><p>test</p></body></html>');
		
		RecordType ContentRT = [SELECT Id FROM RecordType WHERE SObjectType = 'ContentVersion' AND Name = 'Invoice_MERC'];
		ContentVersion cv = new ContentVersion( 
			Document_Type_MERC__c = 'Invoices',
			Invoice_MERC__c = invoice.Id,
			PathOnClient = '/doc.pdf', 
			RecordTypeId = ContentRT.Id, 
			Title ='pdf', 
			VersionData = pdfBlob);
 		insert cv;

		return invoice.Id;
	}
}