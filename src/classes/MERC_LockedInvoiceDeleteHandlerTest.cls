/**
 * @author Kyle Thornton
 *
 * Test methods for the MERC_LockedInvoiceDeleteHandler
 */

@isTest
private class MERC_LockedInvoiceDeleteHandlerTest
{

	static Meeting_MERC__c meeting;
	static List<Account> accounts;
	static List<Meeting_Participant_MERC__c> participants;
	static List<Invoice_MERC__c> invoices;
	static User runningUser = MERC_TestFactory.getRunningUser();
	static User testUser = MERC_TestFactory.getTestingUser();

	static {
		System.runAs(runningUser) {
			meeting = MERC_TestFactory.insertMeetings(1).get(0);
			accounts = MERC_TestFactory.insertAccounts(200);
			participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts);
			invoices = MERC_TestFactory.insertInvoices(participants);
		}
	}

	@isTest 
	static void test_should_be_able_to_delete_invoices()
	{
		System.runAs(testUser)
		{
			System.assertEquals(200, [SELECT COUNT() FROM Invoice_MERC__c WHERE Id IN :invoices]);
			Test.startTest();
			delete invoices;
			Test.stopTest();
			System.assertEquals(0, [SELECT COUNT() FROM Invoice_MERC__c WHERE Id IN :invoices]);
		}
	}

	@isTest 
	static void test_should_not_be_able_to_delete_locked_invoices()
	{
		Id lockedInvoiceRecTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Invoice_MERC__c' AND DeveloperName='Invoice_Locked_MERC' limit 1].Id;
		for (Invoice_MERC__c invoice : invoices)
		{
			invoice.RecordTypeId = lockedInvoiceRecTypeId;
		}
		update invoices;

		System.runAs(testUser)
		{
			System.assertEquals(200, [SELECT COUNT() FROM Invoice_MERC__c WHERE Id IN :invoices]);
			Test.startTest();
			try
			{
				delete invoices;
				System.assert(false, 'A DML Exception should have been thrown.');
			}
			catch(System.DMLException ex)
			{
				System.assertEquals(200, ex.getNumDml());
				for (Integer i=0; i<200; i++) {
					System.assertEquals(ex.getDmlMessage(i), Label.Error_Can_t_Delete_Locked_Invoice);
				}
			}
			Test.stopTest();
			System.assertEquals(200, [SELECT COUNT() FROM Invoice_MERC__c WHERE Id IN :invoices]);
		}
	}

	@isTest 
	static void test_should_be_able_to_delete_credit_notes()
	{
		Id lockedInvoiceRecTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Invoice_MERC__c' AND DeveloperName='Credit_Note_MERC' limit 1].Id;
		for (Invoice_MERC__c invoice : invoices)
		{
			invoice.RecordTypeId = lockedInvoiceRecTypeId;
		}
		update invoices;

		System.runAs(testUser)
		{
			System.assertEquals(200, [SELECT COUNT() FROM Invoice_MERC__c WHERE Id IN :invoices]);
			Test.startTest();
			delete invoices;
			Test.stopTest();
			System.assertEquals(0, [SELECT COUNT() FROM Invoice_MERC__c WHERE Id IN :invoices]);
		}
	}

	@isTest 
	static void test_should_not_be_able_to_delete_locked_credit_notes()
	{
		Id lockedInvoiceRecTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Invoice_MERC__c' AND DeveloperName='Credit_Note_Locked_MERC' limit 1].Id;
		for (Invoice_MERC__c invoice : invoices)
		{
			invoice.RecordTypeId = lockedInvoiceRecTypeId;
		}
		update invoices;

		System.runAs(testUser)
		{
			System.assertEquals(200, [SELECT COUNT() FROM Invoice_MERC__c WHERE Id IN :invoices]);
			Test.startTest();
			try
			{
				delete invoices;
				System.assert(false, 'A DML Exception should have been thrown.');
			}
			catch(System.DMLException ex)
			{
				System.assertEquals(200, ex.getNumDml());
				for (Integer i=0; i<200; i++) {
					System.assertEquals(ex.getDmlMessage(i), Label.Error_Can_t_Delete_Locked_Invoice);
				}
			}
			Test.stopTest();
			System.assertEquals(200, [SELECT COUNT() FROM Invoice_MERC__c WHERE Id IN :invoices]);
		}
	}
}