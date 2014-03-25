/** 
* @author Sean Harrison 
* 
* This is a unit test class for MERC_NewContentController.cls
*/
@isTest
private class MERC_NewContentControllerTest {

	static List<Account> accounts;
	static Budget_MERC__c budget;
	static HCP_Contract_MERC__c contract;
	static List<Invoice_MERC__c> invoices;
	static List<Meeting_MERC__c> meetings;
	static List<Meeting_Participant_MERC__c> participants;

	static {
		accounts = MERC_TestFactory.insertAccounts(1);
		meetings = MERC_TestFactory.insertMeetings(1);
		participants = MERC_TestFactory.insertParticipants(meetings[0].Id, accounts);
		invoices = MERC_TestFactory.insertInvoices(participants);
		budget = MERC_TestFactory.insertBudget(meetings[0].Id);
		contract = MERC_TestFactory.insertHCPContract(accounts[0].Id);
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
	 * Loop through all expected content types and try the upload
	 */
	@isTest 
	static void testUploadAllContentTypes() {

		List<String> ids = new List<String>();
		ids.add(accounts[0].Id);
		ids.add(meetings[0].Id);
		ids.add(participants[0].Id);
		ids.add(invoices[0].Id);
		ids.add(budget.Id);
		ids.add(contract.Id);

		PageReference ref = Page.MERC_NewMeetingContent;
		Test.setCurrentPage(ref);
		Test.startTest();

		for (String id : ids) {
			ApexPages.currentPage().getParameters().put('id', id);

			MERC_NewContentController controller = new MERC_NewContentController();
			PageReference returnRef = controller.upload();

			System.assertEquals(null, returnRef, 'Expected null PageRef but got: '+returnRef);
			List<ApexPages.Message> messages = ApexPages.getMessages();
			for (ApexPages.Message m : messages) {
				System.assert(m.getDetail().contains('Please select a document'));			
			}

			controller.file.Title = controller.getsObjectName();
			controller.file.PathOnClient = controller.getsObjectName();
			controller.file.VersionData = Blob.valueOf('For naught so vile that on the earth doth live but to the earth some special good doth give.');
			returnRef = controller.upload();
			if (returnRef != null) System.debug(returnRef.getUrl());
			System.assertNotEquals(null,returnRef,'Expected a PageRef but got null');			
		}
	}

	// Simulate a problem with the User's access to Content
	@isTest
	static void catchWorkspaceException() {
        Profile p = [SELECT id FROM profile WHERE name='Standard User'];
		User u = new User(alias = 'Romeo', lastname='Montegue', email='romeo@montegue.com',
			profileid = p.Id, username='romeo@montegue.com.MERC_NewContentControllerTest',
			emailencodingkey='UTF-8', languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago');
		RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business_Account'];

		System.runAs(u) {
			Account a = new Account();
			a.Name = 'Capulet';
			a.RecordTypeId = rt.Id;
			insert a;

			PageReference ref = Page.MERC_NewMeetingContent;
			Test.setCurrentPage(ref);
			ApexPages.currentPage().getParameters().put('id', (String) a.id);

			Test.startTest();
			Boolean errThrown = false;
			try {
				MERC_NewContentController controller = new MERC_NewContentController();
			} catch (Exception e) {
				System.assert(e.getMessage().contains('Insufficient access'),'Unexpected error thrown: '+e);
				errThrown = true;
			}
			System.assert(errThrown,'Expected error but none thrown!');
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
}