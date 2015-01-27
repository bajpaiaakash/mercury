@isTest
private class MERC_MergeHistoryStampTriggerHandlerTest {

	@isTest 
	private static void TestRelatedRecordsNoUpdate() {
		MERC_TestFactory.insertMercuryCustomSettings();

		String fakeId = Account.SObjectType.getDescribe().getKeyPrefix() + '000000000001AAA';

		Account acc = new Account(Name = 'Test Account');
		insert acc;

		Address_GLBL__c address = new Address_GLBL__c();
		address.Account_GLBL__c = acc.Id;
		address.Prior_Parent_Id_GLBL__c = fakeId;
		insert address;

		Test.startTest();

		Merge_History_GLBL__c mergeHistory = new Merge_History_GLBL__c();
		mergeHistory.Merge_Date_GLBL__c = Date.today();
		mergeHistory.Original_Account_ID_GLBL__c = fakeId;
		mergeHistory.Winning_Id_GLBL__c = acc.Id;
		insert mergeHistory;

		Test.stopTest();

		Merge_History_GLBL__c updatedHistory = [SELECT Merge_Marked_Complete_MERC__c, Id FROM Merge_History_GLBL__c WHERE Id = :mergeHistory.Id];

		System.assertEquals(false, updatedHistory.Merge_Marked_Complete_MERC__c);

	}

	@isTest 
	private static void TestRelatedRecordsNultipleObjectNoUpdate() {
		MERC_TestFactory.insertMercuryCustomSettings();

		String fakeId = Account.SObjectType.getDescribe().getKeyPrefix() + '000000000001AAA';

		Account acc = new Account(Name = 'Test Account');
		insert acc;

		Address_GLBL__c address = new Address_GLBL__c();
		address.Account_GLBL__c = acc.Id;
		address.Prior_Parent_Id_GLBL__c = fakeId;
		insert address;

		Payee_MERC__c payee = new Payee_MERC__c();
		payee.Prior_Parent_Id_GLBL__c = fakeId;
		payee.Account_MERC__c = acc.Id;
		insert payee;

		Test.startTest();

		Merge_History_GLBL__c mergeHistory = new Merge_History_GLBL__c();
		mergeHistory.Merge_Date_GLBL__c = Date.today();
		mergeHistory.Original_Account_ID_GLBL__c = fakeId;
		mergeHistory.Winning_Id_GLBL__c = acc.Id;
		insert mergeHistory;

		Test.stopTest();

		Merge_History_GLBL__c updatedHistory = [SELECT Merge_Marked_Complete_MERC__c, Id FROM Merge_History_GLBL__c WHERE Id = :mergeHistory.Id];

		System.assertEquals(false, updatedHistory.Merge_Marked_Complete_MERC__c);

	}

	@isTest 
	private static void TestNoRelatedRecordsNoUpdate() {
		MERC_TestFactory.insertMercuryCustomSettings();

		String fakeId = Account.SObjectType.getDescribe().getKeyPrefix() + '000000000001AAA';

		Account acc = new Account(Name = 'Test Account');
		insert acc;

		Test.startTest();

		Merge_History_GLBL__c mergeHistory = new Merge_History_GLBL__c();
		mergeHistory.Merge_Date_GLBL__c = Date.today();
		mergeHistory.Original_Account_ID_GLBL__c = fakeId;
		mergeHistory.Winning_Id_GLBL__c = acc.Id;
		insert mergeHistory;

		Test.stopTest();

		Merge_History_GLBL__c updatedHistory = [SELECT Merge_Marked_Complete_MERC__c, Id FROM Merge_History_GLBL__c WHERE Id = :mergeHistory.Id];

		System.assertEquals(true, updatedHistory.Merge_Marked_Complete_MERC__c);

	}
	

}