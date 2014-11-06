/**
* @author Sean Harrison
*
* This is a unit test class for MERC_NewContentController.cls
*/
@isTest
private class MERC_NewContentControllerTest {


	static User u;
	static Profile p;
	static List<Account> accounts;
	static Budget_MERC__c budget;
	static HCP_Contract_MERC__c contract;
	static List<Invoice_MERC__c> invoices;
	static List<Meeting_MERC__c> meetings;
	static List<Meeting_Participant_MERC__c> participants;
    static Map<String, List<String>> docTypesByRecType;

	static User runningUser = MERC_TestFactory.getRunningUser();
	static User testUser = MERC_TestFactory.getTestingUser();

   static
    {
    	MERC_TestFactory.insertMercuryCustomSettings();

    	docTypesByRecType = new Map<String, List<String>>();
    	for (Content_Library_Lookup_MERC__c cll : Content_Library_Lookup_MERC__c.getAll().values()) {
    		if (docTypesByRecType.containsKey(cll.Content_Record_Type_MERC__c)) {
    			docTypesByRecType.get(cll.Content_Record_Type_MERC__c).add(cll.Content_Document_Type_MERC__c);
    		} else {
    			docTypesByRecType.put(cll.Content_Record_Type_MERC__c, new List<String>{});
    		}
    	}

		System.runAs(runningUser) {
			accounts = MERC_TestFactory.insertHcpAccountsInCountry(1, 'GB');
			meetings = MERC_TestFactory.insertMeetings(1, 'GB');
			participants = MERC_TestFactory.insertParticipants(meetings[0].Id, accounts);
			invoices = MERC_TestFactory.insertInvoices(participants);
			budget = MERC_TestFactory.insertBudget(meetings[0].Id);
			contract = MERC_TestFactory.insertHCPContract(accounts[0].Id);
		}
	}


	@isTest
	static void userCancels() {
		PageReference ref = Page.MERC_NewMeetingContent;
		Test.setCurrentPage(ref);
		ApexPages.currentPage().getParameters().put('id', (String) meetings[0].id);

		Test.startTest();
		MERC_NewContentController controller = new MERC_NewContentController();
		PageReference returnRef = controller.cancel();
		Test.stopTest();

		System.assert(returnRef.getUrl().contains((String) meetings[0].id),
			'Expected a return to the object detail but got: '+returnRef.getUrl());
	}

	/*
	 * Loop through all expected account documents types and try the upload
	 */
	@isTest
	static void testUploadAccountContent() {
		System.runAs(testUser) {
			PageReference ref = Page.MERC_NewMeetingContent;
			ref.getParameters().put('id', accounts.get(0).Id);
			Test.setCurrentPage(ref);

			Test.startTest();

			for (String type : docTypesByRecType.get('Account_MERC')) {
				MERC_NewContentController controller = new MERC_NewContentController();
				populateFile(controller, type);
				PageReference returnRef = controller.upload();
				if (returnRef != null) System.debug(returnRef.getUrl());
				System.assertNotEquals(null,returnRef,'Expected a PageRef but got null: ' + ApexPages.getMessages());
			}
			Test.stopTest();
		}
	}

	/*
	 * Loop through all expected meeting documents types and try the upload
	 */
	@isTest
	static void testUploadMeetingContent() {
	// 	System.runAs(testUser) {
			PageReference ref = Page.MERC_NewMeetingContent;
			ref.getParameters().put('id', meetings.get(0).Id);
			Test.setCurrentPage(ref);

			Test.startTest();

			for (String type : docTypesByRecType.get('Meeting_MERC')) {
				MERC_NewContentController controller = new MERC_NewContentController();
				populateFile(controller, type);
				PageReference returnRef = controller.upload();
				if (returnRef != null) System.debug(returnRef.getUrl());
				System.assertNotEquals(null,returnRef,'Expected a PageRef but got null: ' + ApexPages.getMessages());
			}
			Test.stopTest();
	//	}
	}

	/*
	 * Loop through all expected Meeting_Participant_MERC documents types and try the upload
	 */
	@isTest
	static void testUploadMeetingParticipantContent() {
		System.runAs(testUser) {
			PageReference ref = Page.MERC_NewMeetingContent;
			ref.getParameters().put('id', participants.get(0).Id);
			Test.setCurrentPage(ref);

			Test.startTest();

			for (String type : docTypesByRecType.get('Meeting_Participant_MERC')) {
				MERC_NewContentController controller = new MERC_NewContentController();
				populateFile(controller, type);
				PageReference returnRef = controller.upload();
				if (returnRef != null) System.debug(returnRef.getUrl());
				System.assertNotEquals(null,returnRef,'Expected a PageRef but got null: ' + ApexPages.getMessages());
			}
			Test.stopTest();
		}
	}

	@isTest
	static void testUploadContractContent() {
		System.runAs(testUser) {
			PageReference ref = Page.MERC_NewMeetingContent;
			ref.getParameters().put('id', contract.Id);
			Test.setCurrentPage(ref);

			Test.startTest();

			for (String type : docTypesByRecType.get('HCP_Contract_MERC')) {
				MERC_NewContentController controller = new MERC_NewContentController();
				populateFile(controller, type);
				PageReference returnRef = controller.upload();
				if (returnRef != null) System.debug(returnRef.getUrl());
				System.assertNotEquals(null,returnRef,'Expected a PageRef but got null: ' + ApexPages.getMessages());
			}
			Test.stopTest();
		}
	}

	@isTest
	static void testUploadInvoiceContent() {
		System.runAs(testUser) {
			PageReference ref = Page.MERC_NewInvoiceContent;
			ref.getParameters().put('id', invoices.get(0).Id);
			Test.setCurrentPage(ref);

			Test.startTest();

			for (String type : docTypesByRecType.get('Invoice_MERC')) {
				MERC_NewContentController controller = new MERC_NewContentController();
				populateFile(controller, type);
				PageReference returnRef = controller.upload();
				if (returnRef != null) System.debug(returnRef.getUrl());
				System.assertNotEquals(null,returnRef,'Expected a PageRef but got null: ' + ApexPages.getMessages());
			}
			Test.stopTest();
		}
	}

	@isTest
	static void testUploadInvoiceContentAfterDelete() {

        String suffix  = [SELECT Library_String_MERC__c
                             FROM Content_Library_Lookup_MERC__c
                            WHERE Content_Record_Type_MERC__c='Invoice_MERC'
                              AND Content_Document_Type_MERC__c='Invoices'].Library_String_MERC__c;
        String libraryName = 'GB' + ' - ' + suffix;
		ContentVersion file = new ContentVersion();
		file.FirstPublishLocationId = [select Id from ContentWorkspace WHERE Name = :libraryName].Id;
		file.Invoice_MERC__c = invoices.get(0).Id;
        file.RecordTypeId = [Select Id From RecordType WHERE DeveloperName = 'Invoice_MERC' AND SobjectType = 'ContentVersion' LIMIT 1].Id;
        file.Title = Mercury_Settings_MERC__c.getOrgDefaults().Invoice_File_Prefix_MERC__c + String.valueOf(invoices.get(0).Id) + '.tif';
        file.Document_Type_MERC__c = 'Invoices';
		file.PathOnClient = Mercury_Settings_MERC__c.getOrgDefaults().Invoice_File_Prefix_MERC__c + String.valueOf(invoices.get(0).Id) + '.tif';
		file.VersionData = Blob.valueOf('For naught so vile that on the earth doth live but to the earth some special good doth give.');
		insert file;

		System.runAs(runningUser) {
			Test.startTest();
			PageReference ref = Page.MERC_NewInvoiceContent;
			ref.getParameters().put('id', invoices.get(0).Id);
			ref.getParameters().put('tif','1');
			Test.setCurrentPage(ref);
			for (String type : docTypesByRecType.get('Invoice_MERC')) {
				MERC_NewContentController controller = new MERC_NewContentController();
				populateFile(controller, type);
				PageReference returnRef = controller.upload();
				if (returnRef != null) System.debug(returnRef.getUrl());
				System.assertNotEquals(null,returnRef,'Expected a PageRef but got null: ' + ApexPages.getMessages());
			}
			Test.stopTest();
		}
	}

	@isTest
	static void testShouldErrorWhenUploadBudgetContent() {
		update new user(Id=UserInfo.getUserId(), Procurement_Library_MERC__c=null);
		System.runAs(testUser) {
			PageReference ref = Page.MERC_NewMeetingContent;
			ref.getParameters().put('id', budget.Id);
			Test.setCurrentPage(ref);

			Test.startTest();

			MERC_NewContentController controller = new MERC_NewContentController();
			populateFile(controller, 'sometype');
			PageReference returnRef = controller.upload();
			if (returnRef != null) System.debug(returnRef.getUrl());
			// System.assertNotEquals(null,returnRef,'Expected a PageRef but got null: ' + ApexPages.getMessages());
			System.assert(ApexPages.getMessages().get(0).getSummary().contains('not been granted access to a Procurement Library'),
				'Absent or unexpected error message: '+ApexPages.getMessages().get(0).getSummary());

			Test.stopTest();
		}
	}


	 //Simulate a problem with the User's access to Content
	@isTest
	static void catchWorkspaceException() {
		RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business_Account'];

		System.runAs(testUser) {
			Test.startTest();

			Account a = new Account();
			a.Name = 'Capulet';
			a.RecordTypeId = rt.Id;
			insert a;

			PageReference ref = Page.MERC_NewMeetingContent;
			Test.setCurrentPage(ref);
			ApexPages.currentPage().getParameters().put('id', (String) a.id);

			MERC_NewContentController controller = new MERC_NewContentController();
			populateFile(controller, 'sometype');
			controller.upload();

			System.assert(ApexPages.getMessages().get(0).getSummary().contains('Unable to determine the proper content library.'), ApexPages.getMessages());
			Test.stopTest();
		}
	}

	// Catch an exception when inserting the ContentVersion record in upload()
	@isTest
	static void catchUploadException() {
		PageReference ref = Page.MERC_NewMeetingContent;
		Test.setCurrentPage(ref);
		ApexPages.currentPage().getParameters().put('id', (String) meetings[0].id);

		Test.startTest();
		MERC_NewContentController controller = new MERC_NewContentController();
		controller.file.VersionData = Blob.valueOf('From forth the fatal loins of these two foes a pair of star-crossed lovers take their life,.');

		Boolean errThrown = false;
		PageReference returnRef = controller.upload();
		Test.stopTest();

		System.assertEquals(null, returnRef, 'Expected null PageRef but got: '+returnRef);
		List<ApexPages.Message> messages = ApexPages.getMessages();
		for (ApexPages.Message m : messages) {
			System.assertEquals(ApexPages.Severity.Error,m.getSeverity(),'Unexpected error thrown: '+m);
		}
	}

	@isTest
	static void exerciseReloadButton() {
		PageReference ref = Page.MERC_NewMeetingContent;
		ref.getParameters().put('id', (String) meetings[0].id);
		Test.setCurrentPage(ref);


		Test.startTest();
		MERC_NewContentController controller = new MERC_NewContentController();
		System.assertEquals(ref, controller.reloadPage());
		Test.stopTest();
	}

	@isTest
	static void shouldRenameFilesWhenTif() {
		System.runAs(testUser) {
			PageReference ref = Page.MERC_NewMeetingContent;
			ref.getParameters().put('id', (String) invoices[0].id);
			ref.getParameters().put('tif', '1');
			Test.setCurrentPage(ref);


			Test.startTest();
			MERC_NewContentController controller = new MERC_NewContentController();
			System.assert(controller.file.Title.endsWith('.tif'));
			Test.stopTest();
		}
	}

	@isTest
	static void shouldRenameFilesWhenPdf() {
		System.runAs(testUser) {
			PageReference ref = Page.MERC_NewMeetingContent;
			ref.getParameters().put('id', (String) invoices[0].id);
			ref.getParameters().put('pdf', '1');
			Test.setCurrentPage(ref);


			Test.startTest();
			MERC_NewContentController controller = new MERC_NewContentController();
			System.assert(controller.file.Title.endsWith('.pdf'));
			Test.stopTest();
		}
	}

	@isTest
	static void shouldErrorWhenUserCannotAccessLibrary() {
		Content_Library_Lookup_MERC__c lookup = [SELECT Id, Library_String_MERC__c
		                                         FROM Content_Library_Lookup_MERC__c
		                                         WHERE Content_Record_Type_MERC__c='Meeting_MERC'
		                                           AND Content_Document_Type_MERC__c='Invitations' limit 1];
        lookup.Library_String_MERC__c = 'badlibrary';
        update lookup;

		System.runAs(testUser) {
			PageReference ref = Page.MERC_NewMeetingContent;
			ref.getParameters().put('id', (String) meetings[0].id);
			Test.setCurrentPage(ref);


			Test.startTest();
			MERC_NewContentController controller = new MERC_NewContentController();
			populateFile(controller, 'Invitations');
			controller.upload();
			System.assert(ApexPages.getMessages().get(0).getSummary().contains(lookup.Library_String_MERC__c),'Absent or unexpected error message: '+ApexPages.getMessages().get(0).getSummary());
			Test.stopTest();
		}
	}

	@isTest
	static void shouldErrorWhenNoCountryOnMeeeting() {
		meetings.get(0).Event_Country_MERC__c = null;
		update meetings;

		System.runAs(testUser) {
			PageReference ref = Page.MERC_NewMeetingContent;
			ref.getParameters().put('id', (String) meetings[0].id);
			Test.setCurrentPage(ref);


			Test.startTest();
			MERC_NewContentController controller = new MERC_NewContentController();
			try {
				controller.getLibraryId('Meeting_MERC__c');
				system.assert(false, 'exception not thrown.');
			} catch (Exception ex) {
				system.assert(ex.getMessage().startsWith('Unable to determine the proper content library'), ex.getMessage());
			}

			Test.stopTest();
		}
	}

	@isTest
	static void shouldErrorWhenVersionDataIsNull() {
		System.runAs(testUser) {
			PageReference ref = Page.MERC_NewMeetingContent;
			ref.getParameters().put('id', meetings.get(0).Id);
			Test.setCurrentPage(ref);

			Test.startTest();

			for (String type : docTypesByRecType.get('Meeting_MERC')) {
				MERC_NewContentController controller = new MERC_NewContentController();
				populateFile(controller, type);
				controller.file.VersionData = null;
				PageReference returnRef = controller.upload();
				System.assertEquals(null,returnRef,'Expected a null but got pageref: ' + ApexPages.getMessages());
				System.assertEquals('Please select a document to upload.', ApexPages.getMessages().get(0).getSummary());
			}
			Test.stopTest();
		}
	}

	@isTest
	static void shouldErrorWhenVersionDataEmpty() {
		System.runAs(testUser) {
			PageReference ref = Page.MERC_NewMeetingContent;
			ref.getParameters().put('id', meetings.get(0).Id);
			Test.setCurrentPage(ref);

			Test.startTest();

			for (String type : docTypesByRecType.get('Meeting_MERC')) {
				MERC_NewContentController controller = new MERC_NewContentController();
				populateFile(controller, type);
				controller.file.VersionData = Blob.valueOf('');
				PageReference returnRef = controller.upload();
				System.assertEquals(null,returnRef,'Expected a null but got pageref: ' + ApexPages.getMessages());
				System.assertEquals('The document you have selected to upload contains no data.', ApexPages.getMessages().get(0).getSummary());
			}
			Test.stopTest();
		}
	}

	private static void populateFile(MERC_NewContentController controller, String type) {
		controller.file.Title = controller.getsObjectName();
		controller.file.PathOnClient = controller.getsObjectName();
		controller.file.VersionData = Blob.valueOf('For naught so vile that on the earth doth live but to the earth some special good doth give.');
		controller.file.Document_Type_MERC__c = type;
	}
}