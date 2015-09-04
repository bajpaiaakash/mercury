/*
    MERC_AccountToAccountRollupsTest
    @author : Kyle Thornton, Mavens Consulting
    @created : 13 Jul 2015
    @description : Unit tests for MERC_AccountToAccountRollups
    @modified by :
    @modified date :

*/
@isTest
private class MERC_AccountToAccountRollupsTest
{
	static List<Account> parentAccounts     = new List<Account>();
	static List<Account> designatedInvs     = new List<Account>();
	static List<Account> contractingParties = new List<Account>();
	static {
		parentAccounts = MERC_TestFactory.insertAccounts(200);
		Id diRecordTypeId = [Select ID FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Designated_Individual_GLBL' LIMIT 1].Id;
		Id cpRecordTypeId = [Select ID FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Contracting_Party_GLBL' LIMIT 1].Id;

		for (Account acct : parentAccounts) {
			designatedInvs.add(new Account(RecordTypeId = diRecordTypeId,
				                           LastName='Test',
				                           HCP_Designated_Individuals_MERC__c = acct.id));
			contractingParties.add(new Account(RecordTypeId = cpRecordTypeId,
				                               Name='Test',
				                               HCP_Contracting_Party_MERC__c=acct.id));
		}
		insert designatedInvs;
		insert contractingParties;
	}

	@isTest
	static void testRollupDIAccountsAndCPAccounts()
	{
		Map<Id, Account> pAccounts = new Map<Id, Account>(
			[SELECT Id,
					Designated_Individual_Counter_MERC__c,
					Contracting_Parties_Counter_MERC__c
			   FROM Account
			  WHERE Id IN :parentAccounts]
		);

		System.assertEquals(200, pAccounts.size());
		for (Account acct : pAccounts.values()) {
			System.assertEquals(0, acct.Designated_Individual_Counter_MERC__c);
			System.assertEquals(null, acct.Contracting_Parties_Counter_MERC__c);
		}

		Test.startTest();
		System.enqueueJob(new MERC_AccountToAccountRollups(pAccounts.keySet()));
		Test.stopTest();

		for (Account acct : [SELECT Id,
					Designated_Individual_Counter_MERC__c,
					Contracting_Parties_Counter_MERC__c
			   FROM Account
			  WHERE Id IN :parentAccounts])
		{
			System.assertEquals(1, acct.Designated_Individual_Counter_MERC__c);
			System.assertEquals(1, acct.Contracting_Parties_Counter_MERC__c);
		}

	}

	@isTest
	static void testRollupDIAccountsAndCPAccountsWhenErrorOccurs()
	{
		Test.setReadOnlyApplicationMode(true);
		Test.startTest();
		Boolean didFail = false;
		try {
			MERC_AccountToAccountRollups a2a = new MERC_AccountToAccountRollups(new Set<Id>{parentAccounts[0].id});
			a2a.execute(null);
		} catch (Exception ex) {
			didFail = true;
			System.assert(ex.getMessage().contains('INSERT_UPDATE_DELETE_NOT_ALLOWED_DURING_MAINTENANCE'));
		}
		Test.stopTest();

		System.assert(didFail);
	}
}