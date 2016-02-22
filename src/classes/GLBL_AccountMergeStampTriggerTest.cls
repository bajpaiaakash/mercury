/**
 * GLBL_AccountMergeStampTriggerTest
 * Created By: Kyle Thornton, Mavens Consulting
 * Description: This test the GLBL_AccountMergeStampTrigger trigger handler which is responsible for stamping the Global Id of the losing account onto the children that are being reparented to the winning account. 
 */

@isTest
private class GLBL_AccountMergeStampTriggerTest {

	static List<Account> accounts; 
	static List<Meeting_MERC__c> meetings; 

	static Account winningAccount;
	static Account losingAccount;

	static
	{
		MERC_TestFactory.insertMercuryCustomSettings();

		accounts = MERC_TestFactory.insertAccounts(6);
		meetings = MERC_TestFactory.insertMeetings(2);
		winningAccount = accounts[0];
		accounts[1].Cust_Id_GLBL__c = 'GLOBALID';
		losingAccount = accounts[1];
		accounts[2].HCP_Designated_Individuals_MERC__c = winningAccount.Id;
		accounts[3].HCP_Designated_Individuals_MERC__c = losingAccount.Id;
		accounts[4].HCP_Contracting_Party_MERC__c = winningAccount.Id;
		accounts[5].HCP_Contracting_Party_MERC__c = losingAccount.Id;

		update accounts;

		List<Address_GLBL__c> addresses = new List<Address_GLBL__c>{
			new Address_GLBL__c(Account_GLBL__c = winningAccount.Id),
			new Address_GLBL__c(Account_GLBL__c = losingAccount.Id)
		};
		insert addresses;

		List<Payee_MERC__c> payees = new List<Payee_MERC__c>{
			new Payee_MERC__c(Account_MERC__c=winningAccount.Id),
			new Payee_MERC__c(Account_MERC__c=losingAccount.Id)
		};
		insert payees;

		List<Meeting_Participant_MERC__c> participants = new List<Meeting_Participant_MERC__c>{
			new Meeting_Participant_MERC__c(Account_MERC__c=winningAccount.Id, Meeting_MERC__c=meetings[0].Id),
			new Meeting_Participant_MERC__c(Account_MERC__c=losingAccount.Id,  Meeting_MERC__c=meetings[1].Id)
		};
		insert participants;

		List<HCP_Contract_MERC__c> contracts = new List<HCP_Contract_MERC__c>{
			new HCP_Contract_MERC__c(Account_MERC__c=winningAccount.Id,
				                     Payee_MERC__c  =payees[0].Id,
				                     Meeting_Name_MERC__c=meetings[0].Id,
				                     Meeting_Participant_MERC__c=participants[0].Id),
			new HCP_Contract_MERC__c(Account_MERC__c=losingAccount.Id,
				                     Payee_MERC__c  =payees[1].Id,
				                     Meeting_Name_MERC__c=meetings[1].Id,
				                     Meeting_Participant_MERC__c=participants[1].Id)
		};
		insert contracts;

		List<Case> cases = new List<Case>{
			new Case(AccountId=winningAccount.Id),
			new Case(AccountId=losingAccount.Id)
		};
		insert cases;

		List<Preferences_and_Consent_GLBL__c> prefs = new List<Preferences_and_Consent_GLBL__c> {
			new Preferences_and_Consent_GLBL__c(Account_GLBL__c=winningAccount.Id,Cmnctn_Chnl_Cd_Cap_GLBL__c='989',Preference_Type_MERC__c='Meals Allergy Preferences'),
			new Preferences_and_Consent_GLBL__c(Account_GLBL__c=losingAccount.Id,Cmnctn_Chnl_Cd_Cap_GLBL__c='YYZ',Preference_Type_MERC__c='High/Low Verbal')
		};
		insert prefs;
	}

	@isTest static void test_merge_stamps_child_records() {
		Test.startTest();
		System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Id =:winningAccount.Id], 'Winning account not visible');
		System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Id =:losingAccount.Id], 'Losing account not visible');
		System.assert(MERC_TriggerHandlerStateManager.isActive(GLBL_AccountMergeStampTrigger.class),'Trigger not active.');

		merge winningAccount losingAccount;
		Test.stopTest();

		System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Id =:losingAccount.Id], 'Account was not deleted');
		System.assertEquals(4, [SELECT COUNT() FROM Account WHERE HCP_Designated_Individuals_MERC__c=:winningAccount.Id OR HCP_Contracting_Party_MERC__c=:winningAccount.Id], 'Children were not moved over correctly');
		System.assertEquals(2, [SELECT COUNT() FROM Account WHERE Prior_Parent_Id_GLBL__c='GLOBALID'], 'losing account child accounts not stamped correctly');

		System.assertEquals(2, [SELECT COUNT() FROM Address_GLBL__c WHERE Account_GLBL__c=:winningAccount.Id], 'child address not moved over correctly');
		System.assertEquals(1, [SELECT COUNT() FROM Address_GLBL__c WHERE Account_GLBL__c=:winningAccount.Id AND Prior_Parent_Id_GLBL__c='GLOBALID'], 'losing address not stamped correctly');

		System.assertEquals(2, [SELECT COUNT() FROM Payee_MERC__c WHERE Account_MERC__c=:winningAccount.Id], 'child payee not moved over correctly');
		System.assertEquals(1, [SELECT COUNT() FROM Payee_MERC__c WHERE Account_MERC__c=:winningAccount.Id AND Prior_Parent_Id_GLBL__c='GLOBALID'], 'losing payee not stamped correctly');

		System.assertEquals(2, [SELECT COUNT() FROM Meeting_Participant_MERC__c WHERE Account_MERC__c=:winningAccount.Id], 'child participant not moved over correctly');
		System.assertEquals(1, [SELECT COUNT() FROM Meeting_Participant_MERC__c WHERE Account_MERC__c=:winningAccount.Id AND Prior_Parent_Id_GLBL__c='GLOBALID'], 'losing participant not stamped correctly');

		System.assertEquals(2, [SELECT COUNT() FROM HCP_Contract_MERC__c WHERE Account_MERC__c=:winningAccount.Id], 'child contract not moved over correctly');
		System.assertEquals(1, [SELECT COUNT() FROM HCP_Contract_MERC__c WHERE Account_MERC__c=:winningAccount.Id AND Prior_Parent_Id_GLBL__c='GLOBALID'], 'losing contract not stamped correctly');

		System.assertEquals(2, [SELECT COUNT() FROM Case WHERE AccountId=:winningAccount.Id], 'child case not moved over correctly');
		System.assertEquals(1, [SELECT COUNT() FROM Case WHERE AccountId=:winningAccount.Id AND Prior_Parent_Id_GLBL__c='GLOBALID'], 'losing case not stamped correctly');
	}

}