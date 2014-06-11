/**
* @author Sean Harrison
* @TODO: we cannot create workspaces/libraries or add users to libraries via Apex, so we need to query for existing users in these tests
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
    static User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    static Map<String, List<String>> docTypesByRecType;

    static User testUser;
    static
    {
    	MERC_TestFactory.insertMercuryCustomSettings();

    	System.runAs(new User(Id=UserInfo.getUserId()))
    	{
    		testUser = MERC_TestFactory.insertTestUsers(1, null).get(0);
    		testUser.userRoleId = [SELECT Id FROM UserRole Where Name = 'Global' LIMIT 1].Id;
    		update testUser;
    		PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='Mercury_Customer_Meeting_Services_Edit' limit 1];
    		insert new PermissionSetAssignment( PermissionSetId=ps.Id
    			                              , AssigneeId=testUser.id);
    		update new User( id=testUser.Id
    			           , UserRoleId=[SELECT Id FROM UserRole WHERE Name='Global' limit 1].id);
    	}

    	docTypesByRecType = new Map<String, List<String>>();
    	for (Content_Library_Lookup_MERC__c cll : Content_Library_Lookup_MERC__c.getAll().values()) {
    		if (docTypesByRecType.containsKey(cll.Content_Record_Type_MERC__c)) {
    			docTypesByRecType.get(cll.Content_Record_Type_MERC__c).add(cll.Content_Document_Type_MERC__c);
    		} else {
    			docTypesByRecType.put(cll.Content_Record_Type_MERC__c, new List<String>{});
    		}
    	}
    }

	static {
		System.runAs(thisUser) {
			accounts = MERC_TestFactory.insertHcpAccountsInCountry(1, 'DE');
			meetings = MERC_TestFactory.insertMeetings(1, 'DE');
			participants = MERC_TestFactory.insertParticipants(meetings[0].Id, accounts);
			invoices = MERC_TestFactory.insertInvoices(participants);
			budget = MERC_TestFactory.insertBudget(meetings[0].Id);
			contract = MERC_TestFactory.insertHCPContract(accounts[0].Id);
		}
	}

	@isTest static void test_running_user_should_have_Global_role() {
		String userRoleId = [SELECT UserRoleId FROM User WHERE Id=:UserInfo.getUserId()].UserRoleId;
		System.assertEquals('Global', [SELECT Name FROM UserRole WHERE Id=:userRoleId].Name, 'The user running the tests does not have the global role and therefore some tests might fail in this class.');
	}

	// exercise cancel method.
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
		System.runAs(thisUser) {
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
		System.runAs(thisUser) {
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
		}
	}

	/*
	 * Loop through all expected Meeting_Participant_MERC documents types and try the upload
	 */
	@isTest
	static void testUploadMeetingParticipantContent() {
		System.runAs(thisUser) {
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
		System.runAs(thisUser) {
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
		System.runAs(thisUser) {
			PageReference ref = Page.MERC_NewMeetingContent;
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
	static void testUploadBudgetContent() {
		update new user(Id=UserInfo.getUserId(), Procurement_Library_MERC__c=null);
		System.runAs(thisUser) {
			PageReference ref = Page.MERC_NewMeetingContent;
			ref.getParameters().put('id', budget.Id);
			Test.setCurrentPage(ref);

			Test.startTest();

			MERC_NewContentController controller = new MERC_NewContentController();
			populateFile(controller, 'sometype');
			PageReference returnRef = controller.upload();
			if (returnRef != null) System.debug(returnRef.getUrl());
			//System.assertNotEquals(null,returnRef,'Expected a PageRef but got null: ' + ApexPages.getMessages());
			System.assert(ApexPages.getMessages().get(0).getSummary().contains('You have not been granted access to a Procurement Library to upload document against a Budget. This document will be uploaded to: DE - Regional. Please contact a system administrator for assistance with Library access.'));

			Test.stopTest();
		}
	}

	private static void populateFile(MERC_NewContentController controller, String type) {
		controller.file.Title = controller.getsObjectName();
		controller.file.PathOnClient = controller.getsObjectName();
		controller.file.VersionData = Blob.valueOf('For naught so vile that on the earth doth live but to the earth some special good doth give.');
		controller.file.Document_Type_MERC__c = type;
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
}