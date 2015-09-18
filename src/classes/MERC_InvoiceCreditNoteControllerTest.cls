@isTest
private class MERC_InvoiceCreditNoteControllerTest {

	static List<Account> accs;
	static List<Meeting_MERC__c> mtgs;
	static List<Meeting_Participant_MERC__c> ps;
	static List<Invoice_MERC__c> invoices;
	static Id workspaceId;
	static String versionData = 'foo';
	static Blob versionDataBlob = Blob.valueOf(versionData);
	static ContentVersion c;
	static List<ContentVersion> cvList;
	static {
		workspaceId = [SELECT Id FROM ContentWorkspace WHERE Name = 'Mercury' Limit 1].Id; //we dont seem to be able to create this in a test
		system.assertNotEquals(workspaceId, null, 'The workspace \'Mercury\' does not exist or is not availble to the running user.');

		accs = MERC_TestFactory.insertAccounts(1);
 		mtgs = MERC_TestFactory.insertMeetings(1);
 		ps = MERC_TestFactory.insertParticipants(mtgs.get(0).Id, accs);
 		invoices = MERC_TestFactory.insertInvoices(ps);
 		//insert 3 line items for the invoice
 		MERC_TestFactory.insertInvoiceLineItems(invoices.get(0).Id, 3);

		cvList = new List<ContentVersion>();
		c                           = new ContentVersion();
		c.Title                     = 'foo';
		//c.FirstPublishLocationId    = workspaceId;
		c.PathOnClient              = 'foo';
		c.VersionData               = versionDataBlob;
		c.RecordTypeID			    = [SELECT Id FROM RecordType WHERE SObjectType='ContentVersion' AND DeveloperName='Invoice_MERC' LIMIT 1].Id;

		//add three cv records to the invoice
		cvList.add(c);
		cvList.add(c.clone());
		cvList.add(c.clone());
		insert cvList;

		//mimick the ui insertion process per: https://developer.salesforce.com/forums/ForumsMain?id=906F00000008yKTIAY
		List<ContentWorkspaceDoc> cwd     =  new List<ContentWorkspaceDoc>();
		List<ContentVersion> updateCvList = new List<ContentVersion>();
		for (ContentVersion cv : [SELECT Id, ContentDocumentId, Invoice_MERC__c FROM ContentVersion WHERE Id IN :cvList])
		{
			cwd.add(new ContentWorkspaceDoc(ContentDocumentId=cv.ContentDocumentId, ContentWorkspaceId=workspaceId));
			cv.Invoice_MERC__c = invoices.get(0).Id;
			updateCvList.add(cv);
		}
		insert cwd;
		update updateCvList;
	}

	@isTest
	static void test_should_not_allow_clone_of_unlocked_invoice() {
		ApexPages.StandardController sc             = new ApexPages.StandardController(invoices.get(0));
		MERC_InvoiceCreditNoteController controller = new MERC_InvoiceCreditNoteController(sc);

		//the default record type is Invoice so it should not be cloneable;
		System.assertEquals(1, ApexPages.getMessages().size());
		System.assert(ApexPages.getMessages().get(0).getSummary().contains('This invoice/credit note cannot be cloned.'));
	}

	@isTest
	static void test_should_not_allow_clone_of_unlocked_credit_notes() {
		invoices.get(0).RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Invoice_MERC__c' AND DeveloperName='Credit_Note_MERC' limit 1].Id;
		update invoices.get(0);

		ApexPages.StandardController sc             = new ApexPages.StandardController(invoices.get(0));
		MERC_InvoiceCreditNoteController controller = new MERC_InvoiceCreditNoteController(sc);

		//the default record type is Invoice so it should not be cloneable;
		System.assertEquals(1, ApexPages.getMessages().size());
		System.assert(ApexPages.getMessages().get(0).getSummary().contains('This invoice/credit note cannot be cloned.'));
	}

	@isTest
	static void test_should_instantiate_correctly_for_locked_invoice() {
		invoices.get(0).RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Invoice_MERC__c' AND DeveloperName='Invoice_Locked_MERC' limit 1].Id;
		update invoices.get(0);

		ApexPages.StandardController sc             = new ApexPages.StandardController(invoices.get(0));
		MERC_InvoiceCreditNoteController controller = new MERC_InvoiceCreditNoteController(sc);

		//the default record type is Invoice so it should not be cloneable;
		System.assertEquals(invoices.get(0).id, controller.invoice.id);
		System.assertEquals('Credit_Note_MERC', controller.newInvoiceRecType.DeveloperName);
	}

	@isTest
	static void test_should_instantiate_correctly_for_locked_credit_note() {
		invoices.get(0).RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Invoice_MERC__c' AND DeveloperName='Credit_Note_Locked_MERC' limit 1].Id;
		update invoices.get(0);

		ApexPages.StandardController sc             = new ApexPages.StandardController(invoices.get(0));
		MERC_InvoiceCreditNoteController controller = new MERC_InvoiceCreditNoteController(sc);

		//the default record type is Invoice so it should not be cloneable;
		System.assertEquals(invoices.get(0).id, controller.invoice.id);
		System.assertEquals('Invoice_MERC', controller.newInvoiceRecType.DeveloperName);
	}

	@isTest
	static void test_should_return_proper_values_for_getters() {
		invoices.get(0).RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Invoice_MERC__c' AND DeveloperName='Invoice_Locked_MERC' limit 1].Id;
		update invoices.get(0);

		ApexPages.StandardController sc             = new ApexPages.StandardController(invoices.get(0));
		MERC_InvoiceCreditNoteController controller = new MERC_InvoiceCreditNoteController(sc);

		System.assertEquals(3, controller.getLineItemCount());
		System.assertEquals(3, controller.getContentCount());
	}

	@isTest
	static void test_should_create_credit_note_from_locked_invoice_with_line_items_and_content() {
		invoices.get(0).RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Invoice_MERC__c' AND DeveloperName='Invoice_Locked_MERC' limit 1].Id;
		update invoices.get(0);

		ApexPages.StandardController sc             = new ApexPages.StandardController(invoices.get(0));
		MERC_InvoiceCreditNoteController controller = new MERC_InvoiceCreditNoteController(sc);

		PageReference ref = controller.createNewInvoice();
		System.assertNotEquals(ref, null);

		List<Invoice_MERC__c> cn = [SELECT Id
		                                  , (SELECT Id FROM Invoice_Line_Items__r)
		                                  , (SELECT Id FROM Content_CN__r)
		                              FROM Invoice_MERC__c
		                             WHERE RecordType.DeveloperName = 'Credit_Note_MERC'
		                               AND Credit_Note_Invoice_MERC__c =:invoices.get(0).id];
		System.assertEquals(1, cn.size());
		System.assertEquals(3, cn.get(0).Invoice_Line_Items__r.size());
		System.assertEquals(3, cn.get(0).Content_CN__r.size());
	}

	@isTest
	static void test_should_create_invoice_from_locked_credit_note_with_only_line_items() {
		invoices.get(0).RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Invoice_MERC__c' AND DeveloperName='Credit_Note_Locked_MERC' limit 1].Id;
		update invoices.get(0);

		ApexPages.StandardController sc             = new ApexPages.StandardController(invoices.get(0));
		MERC_InvoiceCreditNoteController controller = new MERC_InvoiceCreditNoteController(sc);

		PageReference ref = controller.createNewInvoice();
		System.assertNotEquals(ref, null);

		List<Invoice_MERC__c> cn = [SELECT Id
		                                  , (SELECT Id FROM Invoice_Line_Items__r)
		                                  , (SELECT Id FROM Content_CN__r)
		                              FROM Invoice_MERC__c
		                             WHERE RecordType.DeveloperName = 'Invoice_MERC'];
		System.assertEquals(1, cn.size());
		System.assertEquals(3, cn.get(0).Invoice_Line_Items__r.size());
		System.assertEquals(0, cn.get(0).Content_CN__r.size());
	}

	@isTest
	static void test_cloneInvoice_should_clone_invoice() {
		invoices.get(0).RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Invoice_MERC__c' AND DeveloperName='Invoice_Locked_MERC' limit 1].Id;
		update invoices.get(0);

		ApexPages.StandardController sc             = new ApexPages.StandardController(invoices.get(0));
		MERC_InvoiceCreditNoteController controller = new MERC_InvoiceCreditNoteController(sc);

		Invoice_MERC__c clonedInvoice = controller.cloneInvoice(invoices.get(0));
		System.assertEquals(invoices.get(0).Invoice_Date_MERC__c, clonedInvoice.Invoice_Date_MERC__c);
		System.assertEquals(invoices.get(0).Meeting_Participant_MERC__c, clonedInvoice.Meeting_Participant_MERC__c);
	}

	@isTest
	static void test_cloneInvoice_should_throw_MERC_Exception_on_failure() {
		invoices.get(0).RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Invoice_MERC__c' AND DeveloperName='Invoice_Locked_MERC' limit 1].Id;
		update invoices.get(0);

		ApexPages.StandardController sc             = new ApexPages.StandardController(invoices.get(0));
		MERC_InvoiceCreditNoteController controller = new MERC_InvoiceCreditNoteController(sc);

		Boolean failureCaught = false;
		try
		{
			Test.setReadOnlyApplicationMode(true);
			Invoice_MERC__c clonedInvoice = controller.cloneInvoice(invoices.get(0));
		}
		catch(MERC_Exception ex)
		{
			failureCaught = true;
		}
		System.assert(failureCaught, 'An expected exception was not thrown');
	}

	@isTest
	static void test_cloneLineItems_should_clone_allLineItems() {
		invoices.get(0).RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Invoice_MERC__c' AND DeveloperName='Invoice_Locked_MERC' limit 1].Id;
		update invoices.get(0);

		ApexPages.StandardController sc             = new ApexPages.StandardController(invoices.get(0));
		MERC_InvoiceCreditNoteController controller = new MERC_InvoiceCreditNoteController(sc);

		Invoice_MERC__c clonedInvoice = controller.cloneInvoice(invoices.get(0));
		controller.cloneLineItems(invoices.get(0), clonedInvoice);

		System.assertEquals(3, [SELECT COUNT() FROM Invoice_Line_Item_MERC__c WHERE Invoice_MERC__c = :clonedInvoice.Id]);
	}

	@isTest
	static void test_cloneLinesItems_should_throw_MERC_Exception_on_failure() {
		invoices.get(0).RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Invoice_MERC__c' AND DeveloperName='Invoice_Locked_MERC' limit 1].Id;
		update invoices.get(0);

		ApexPages.StandardController sc             = new ApexPages.StandardController(invoices.get(0));
		MERC_InvoiceCreditNoteController controller = new MERC_InvoiceCreditNoteController(sc);

		Boolean failureCaught = false;
		try
		{
			Invoice_MERC__c clonedInvoice = controller.cloneInvoice(invoices.get(0));
			Test.setReadOnlyApplicationMode(true);
			controller.cloneLineItems(invoices.get(0), clonedInvoice);
		}
		catch(MERC_Exception ex)
		{
			failureCaught = true;
		}
		System.assert(failureCaught, 'An expected exception was not thrown');
	}

	@isTest
	static void test_updateContentVersions_should_update_contentVersions() {
		invoices.get(0).RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Invoice_MERC__c' AND DeveloperName='Invoice_Locked_MERC' limit 1].Id;
		update invoices.get(0);

		ApexPages.StandardController sc             = new ApexPages.StandardController(invoices.get(0));
		MERC_InvoiceCreditNoteController controller = new MERC_InvoiceCreditNoteController(sc);

		Invoice_MERC__c clonedInvoice = controller.cloneInvoice(invoices.get(0));
		controller.updateContentVersions(invoices.get(0), clonedInvoice);

		System.assertEquals(3, [SELECT COUNT() FROM ContentVersion WHERE Credit_Note_MERC__c = :clonedInvoice.Id]);
	}

	@isTest
	static void test_updateContentVersions_should_throw_MERC_Exception_on_failure() {
		invoices.get(0).RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Invoice_MERC__c' AND DeveloperName='Invoice_Locked_MERC' limit 1].Id;
		update invoices.get(0);

		ApexPages.StandardController sc             = new ApexPages.StandardController(invoices.get(0));
		MERC_InvoiceCreditNoteController controller = new MERC_InvoiceCreditNoteController(sc);

		Boolean failureCaught = false;
		try
		{
			Invoice_MERC__c clonedInvoice = controller.cloneInvoice(invoices.get(0));
			Test.setReadOnlyApplicationMode(true);
			controller.updateContentVersions(invoices.get(0), clonedInvoice);
		}
		catch(MERC_Exception ex)
		{
			failureCaught = true;
		}
		System.assert(failureCaught, 'An expected exception was not thrown');
	}
}