/**
 * Copyright (c) 2013, Andrew Fawcett
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Andrew Fawcett, nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * Tests the RollupService methods, note the LREngine is test independently via TestLREngine
 **/
@IsTest
private with sharing class GLBL_RollupServiceTest3 
{		
	static Schema.SObjectField ACCOUNT_SLA_EXPIRATION_DATE;
	static Schema.SObjectField ACCOUNT_NUMBER_OF_LOCATIONS;		
	static
	{
		// Dynamically resolve these fields, if they are not present when the test runs, the test will return as passed to avoid failures in subscriber org when packaged
		Map<String, Schema.SObjectField> accountFields = Schema.SObjectType.Account.fields.getMap();
		ACCOUNT_SLA_EXPIRATION_DATE = accountFields.get('CODS_End_Date_GLBL__c');
		ACCOUNT_NUMBER_OF_LOCATIONS = accountFields.get('NumberOfEmployees');
	}
	
	//private testmethod static void testCalculateJob()
	//{		
	//	// Test supported?
	//	if(!GLBL_TestContext.isSupported())
	//		return;
		
	//	// Insert parents
	//	Schema.SObjectType parentType = Schema.getGlobalDescribe().get('LookupParent_GLBL__c');
	//	SObject parentA = parentType.newSObject();
	//	parentA.put('Name', 'ParentA');
	//	SObject parentB = parentType.newSObject();
	//	parentB.put('Name', 'ParentB');
	//	SObject parentC = parentType.newSObject();
	//	parentC.put('Name', 'ParentC');
	//	List<SObject> parents = new List<SObject> { parentA, parentB, parentC };
	//	insert parents;
		
	//	// Insert children
	//	Schema.SObjectType childType = Schema.getGlobalDescribe().get('LookupChild_GLBL__c');
	//	List<SObject> children = new List<SObject>();
	//	for(SObject parent : parents)		
	//	{
	//		String name = (String) parent.get('Name');
	//		SObject child1 = childType.newSObject();
	//		child1.put('LookupParent_GLBL__c', parent.Id);
	//		child1.put('Amount_GLBL__c', 20);
	//		children.add(child1);				
	//		SObject child2 = childType.newSObject();
	//		child2.put('LookupParent_GLBL__c', parent.Id);
	//		child2.put('Amount_GLBL__c', 20);
	//		children.add(child2);				
	//		if(name.equals('ParentA') || name.equals('ParentB'))
	//		{
	//			SObject child3 = childType.newSObject();
	//			child3.put('LookupParent_GLBL__c', parent.Id);
	//			child3.put('Amount_GLBL__c', 2);
	//			children.add(child3);				
	//		}
	//	}
	//	insert children;

	//	// Create rollup AFTER the data exists		
	//	LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
	//	rollupSummary.Name = 'Test Rollup';
	//	rollupSummary.ParentObject_GLBL__c = 'LookupParent_GLBL__c';
	//	rollupSummary.ChildObject_GLBL__c = 'LookupChild_GLBL__c';
	//	rollupSummary.RelationShipField_GLBL__c = 'LookupParent_GLBL__c';
	//	rollupSummary.FieldToAggregate_GLBL__c = 'Amount_GLBL__c';
	//	rollupSummary.AggregateOperation_GLBL__c = GLBL_RollupSummaries.AggregateOperation.Sum.name();
	//	rollupSummary.AggregateResultField_GLBL__c = 'Total_GLBL__c';
	//	rollupSummary.Active_GLBL__c = true;
	//	rollupSummary.CalculationMode_GLBL__c = 'Scheduled';	
	//	insert rollupSummary;
		
	//	// Run rollup calculate job
	//	Test.startTest();		
	//	Id jobId = GLBL_RollupService.runJobToCalculate(rollupSummary.Id);
	//	rollupSummary = [select Id, CalculateJobId_GLBL__c from LookupRollupSummary_GLBL__c where Id  = :rollupSummary.Id];
	//	System.assertEquals(jobId, rollupSummary.CalculateJobId_GLBL__c); // Assert job id captured
	//	try { 
	//		// Assert not possible to start another
	//		GLBL_RollupService.runJobToCalculate(rollupSummary.Id);
	//		System.assert(false, 'Expected an exception');
	//	} catch (Exception e) {
	//		System.assert(e.getMessage().equals('A calculate job for rollup \'Test Rollup\' is already executing. If you suspect it is not aleady running try clearing the Calculate Job Id field and try again.'));
	//	}			 
	//	Test.stopTest();
	//	// Assert job id cleared
	//	rollupSummary = [select Id, CalculateJobId_GLBL__c from LookupRollupSummary_GLBL__c where Id  = :rollupSummary.Id];
	//	System.assertEquals(null, rollupSummary.CalculateJobId_GLBL__c);  

	//	// This should not generate any schedule items		
	//	System.assertEquals(0, [select id from LookupRollupSummaryScheduleItems_GLBL__c].size());
		
	//	// Assert rollups 
	//	Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query('select id, Total_GLBL__c from LookupParent_GLBL__c'));
	//	System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get('Total_GLBL__c'));
	//	System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get('Total_GLBL__c'));
	//	System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get('Total_GLBL__c'));		
		
	//	// Assert scheduled items and log records
	//	List<LookupRollupSummaryLog_GLBL__c> logs = [select id, ParentId_GLBL__c, ParentObject_GLBL__c, ErrorMessage_GLBL__c from LookupRollupSummaryLog_GLBL__c];
	//	System.assertEquals(parentC.Id, logs[0].ParentId_GLBL__c);
	//	System.assertEquals('LookupParent_GLBL__c', logs[0].ParentObject_GLBL__c);
	//	System.assertEquals(1, logs.size());
	//	System.assertEquals('The answer is not 42! : FIELD_CUSTOM_VALIDATION_EXCEPTION (Total_GLBL__c)', logs[0].ErrorMessage_GLBL__c);		
	//}

	private testmethod static void testCalculateJobNotActive()
	{		
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;
		
		// Insert parents
		Schema.SObjectType parentType = Schema.getGlobalDescribe().get('LookupParent_GLBL__c');
		SObject parentA = parentType.newSObject();
		parentA.put('Name', 'ParentA');
		SObject parentB = parentType.newSObject();
		parentB.put('Name', 'ParentB');
		SObject parentC = parentType.newSObject();
		parentC.put('Name', 'ParentC');
		List<SObject> parents = new List<SObject> { parentA, parentB, parentC };
		insert parents;
		
		// Insert children
		Schema.SObjectType childType = Schema.getGlobalDescribe().get('LookupChild_GLBL__c');
		List<SObject> children = new List<SObject>();
		for(SObject parent : parents)		
		{
			String name = (String) parent.get('Name');
			SObject child1 = childType.newSObject();
			child1.put('LookupParent_GLBL__c', parent.Id);
			child1.put('Amount_GLBL__c', 20);
			children.add(child1);				
			SObject child2 = childType.newSObject();
			child2.put('LookupParent_GLBL__c', parent.Id);
			child2.put('Amount_GLBL__c', 20);
			children.add(child2);				
			if(name.equals('ParentA') || name.equals('ParentB'))
			{
				SObject child3 = childType.newSObject();
				child3.put('LookupParent_GLBL__c', parent.Id);
				child3.put('Amount_GLBL__c', 2);
				children.add(child3);				
			}
		}
		insert children;

		// Create rollup AFTER the data exists		
		LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
		rollupSummary.Name = 'Test Rollup';
		rollupSummary.ParentObject_GLBL__c = 'LookupParent_GLBL__c';
		rollupSummary.ChildObject_GLBL__c = 'LookupChild_GLBL__c';
		rollupSummary.RelationShipField_GLBL__c = 'LookupParent_GLBL__c';
		rollupSummary.FieldToAggregate_GLBL__c = 'Amount_GLBL__c';
		rollupSummary.AggregateOperation_GLBL__c = GLBL_RollupSummaries.AggregateOperation.Sum.name();
		rollupSummary.AggregateResultField_GLBL__c = 'Total_GLBL__c';
		rollupSummary.Active_GLBL__c = false;
		rollupSummary.CalculationMode_GLBL__c = 'Scheduled';	
		insert rollupSummary;
		
		// Run rollup calculate job
		Test.startTest();		
		try { 
			// Assert not possible to start another
			GLBL_RollupService.runJobToCalculate(rollupSummary.Id);
			System.assert(false, 'Expected an exception');
		} catch (Exception e) {
			System.assert(e.getMessage().equals('The rollup must be Active before you can run a Calculate job.'));
		}			 
		Test.stopTest();
	}
	
	private testmethod static void testDeveloperAPI()
	{		
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;
		
		// Create rollup		
		LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
		rollupSummary.Name = 'Test Rollup';
		rollupSummary.ParentObject_GLBL__c = 'LookupParent_GLBL__c';
		rollupSummary.ChildObject_GLBL__c = 'LookupChild_GLBL__c';
		rollupSummary.RelationShipField_GLBL__c = 'LookupParent_GLBL__c';
		rollupSummary.FieldToAggregate_GLBL__c = 'Amount_GLBL__c';
		rollupSummary.AggregateOperation_GLBL__c = GLBL_RollupSummaries.AggregateOperation.Sum.name();
		rollupSummary.AggregateResultField_GLBL__c = 'Total_GLBL__c';
		rollupSummary.Active_GLBL__c = true;
		rollupSummary.CalculationMode_GLBL__c = GLBL_RollupSummaries.CalculationMode.Developer.name();	
		insert rollupSummary;
		
		// Insert parents
		Schema.SObjectType parentType = Schema.getGlobalDescribe().get('LookupParent_GLBL__c');
		SObject parentA = parentType.newSObject();
		parentA.put('Name', 'ParentA');
		SObject parentB = parentType.newSObject();
		parentB.put('Name', 'ParentB');
		SObject parentC = parentType.newSObject();
		parentC.put('Name', 'ParentC');
		List<SObject> parents = new List<SObject> { parentA, parentB, parentC };
		insert parents;
		
		// Insert children
		Schema.SObjectType childType = Schema.getGlobalDescribe().get('LookupChild_GLBL__c');
		List<SObject> children = new List<SObject>();
		for(SObject parent : parents)		
		{
			String name = (String) parent.get('Name');
			SObject child1 = childType.newSObject();
			child1.put('LookupParent_GLBL__c', parent.Id);
			child1.put('Amount_GLBL__c', 20);
			children.add(child1);				
			SObject child2 = childType.newSObject();
			child2.put('LookupParent_GLBL__c', parent.Id);
			child2.put('Amount_GLBL__c', 20);
			children.add(child2);				
			if(name.equals('ParentA') || name.equals('ParentB'))
			{
				SObject child3 = childType.newSObject();
				child3.put('LookupParent_GLBL__c', parent.Id);
				child3.put('Amount_GLBL__c', 2);
				children.add(child3);				
			}
		}
		insert children;
		
		// Assert nothing has changed on db 
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query('select id, Total_GLBL__c from LookupParent_GLBL__c'));
		System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get('Total_GLBL__c'));
		System.assertEquals(null, (Decimal) assertParents.get(parentB.id).get('Total_GLBL__c'));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get('Total_GLBL__c'));		
				
		// Call developer API
		List<SObject> masterRecords = GLBL_RollupService.rollup(children);

		// Assert nothing has changed on db 
		assertParents = new Map<Id, SObject>(Database.query('select id, Total_GLBL__c from LookupParent_GLBL__c'));
		System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get('Total_GLBL__c'));
		System.assertEquals(null, (Decimal) assertParents.get(parentB.id).get('Total_GLBL__c'));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get('Total_GLBL__c'));		
		
		// Assert rollups produced
		assertParents = new Map<Id, SObject>(masterRecords);
		System.assertEquals(3, masterRecords.size()); 
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get('Total_GLBL__c'));
		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get('Total_GLBL__c'));
		System.assertEquals(40, (Decimal) assertParents.get(parentC.id).get('Total_GLBL__c'));		
	}	
	
	
	/**
	 * https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/23
	 */
	private testmethod static void testDateRollupDeleteChild()
	{
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;
		
		// Configure rollup
		LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
		rollupSummary.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummary.ParentObject_GLBL__c = 'Account';
		rollupSummary.ChildObject_GLBL__c = 'Opportunity';
		rollupSummary.RelationShipField_GLBL__c = 'AccountId';
		rollupSummary.RelationShipCriteria_GLBL__c = null;
		rollupSummary.FieldToAggregate_GLBL__c = 'CloseDate';
		rollupSummary.AggregateOperation_GLBL__c = 'Max';
		rollupSummary.AggregateResultField_GLBL__c = 'CODS_End_Date_GLBL__c';
		rollupSummary.Active_GLBL__c = true;
		rollupSummary.CalculationMode_GLBL__c = 'Realtime';
		insert new List<LookupRollupSummary_GLBL__c> { rollupSummary };
		
		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		account.AnnualRevenue = 0;
		insert account;
		Opportunity opp = new Opportunity(); 
		opp.Name = 'Test Opportunity';
		opp.StageName = 'Open';
		opp.CloseDate = System.today();
		opp.AccountId = account.Id;
		opp.Amount = 100;
		insert opp;
		
		// Assert rollup
		Id accountId = account.Id;
		System.assertEquals(System.today(), Database.query('select CODS_End_Date_GLBL__c from Account where Id = :accountId')[0].get(ACCOUNT_SLA_EXPIRATION_DATE));
		
		// Delete Opportunity
		delete opp;
		
		// Assert rollup
		System.assertEquals(null, Database.query('select CODS_End_Date_GLBL__c from Account where Id = :accountId')[0].get(ACCOUNT_SLA_EXPIRATION_DATE));								 	
	}
	
	/**
	 * https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/23
	 */
	private testmethod static void testDateRollupInsertConditionalChild()
	{
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;
		
		// Configure rollup
		LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
		rollupSummary.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummary.ParentObject_GLBL__c = 'Account';
		rollupSummary.ChildObject_GLBL__c = 'Opportunity';
		rollupSummary.RelationShipField_GLBL__c = 'AccountId';
		rollupSummary.RelationShipCriteria_GLBL__c = 'CloseDate < TODAY';
		rollupSummary.FieldToAggregate_GLBL__c = 'CloseDate';
		rollupSummary.AggregateOperation_GLBL__c = 'Max';
		rollupSummary.AggregateResultField_GLBL__c = 'CODS_End_Date_GLBL__c';
		rollupSummary.Active_GLBL__c = true;
		rollupSummary.CalculationMode_GLBL__c = 'Realtime';
		insert new List<LookupRollupSummary_GLBL__c> { rollupSummary };
		
		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		account.AnnualRevenue = 0;
		insert account;
		Opportunity opp = new Opportunity(); 
		opp.Name = 'Test Opportunity';
		opp.StageName = 'Open';
		opp.CloseDate = System.today();
		opp.AccountId = account.Id;
		opp.Amount = 100;
		insert opp;
		
		// Assert rollup
		Id accountId = account.Id;
		System.assertEquals(null, Database.query('select CODS_End_Date_GLBL__c from Account where Id = :accountId')[0].get(ACCOUNT_SLA_EXPIRATION_DATE));
		
		// Delete Opportunity
		delete opp;
		
		// Assert rollup
		System.assertEquals(null, Database.query('select CODS_End_Date_GLBL__c from Account where Id = :accountId')[0].get(ACCOUNT_SLA_EXPIRATION_DATE));								 	
	}
	
	//private testmethod static void testRollupWithInAccessibleParent()
	//{
	//	// Test supported?
	//	if(!GLBL_TestContext.isSupported())
	//		return;
		
	//	// Configure rollup
	//	LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
	//	rollupSummary.Name = 'Test Rollup';
	//	rollupSummary.ParentObject_GLBL__c = 'LookupParent_GLBL__c';
	//	rollupSummary.ChildObject_GLBL__c = 'LookupChild_GLBL__c';
	//	rollupSummary.RelationShipField_GLBL__c = 'LookupParent_GLBL__c';
	//	rollupSummary.FieldToAggregate_GLBL__c = 'Amount_GLBL__c';
	//	rollupSummary.AggregateOperation_GLBL__c = GLBL_RollupSummaries.AggregateOperation.Sum.name();
	//	rollupSummary.AggregateResultField_GLBL__c = 'Total_GLBL__c';
	//	rollupSummary.Active_GLBL__c = true;
	//	rollupSummary.CalculationMode_GLBL__c = 'Realtime';	
	//	insert rollupSummary;
				
	//	// Insert parents
	//	Schema.SObjectType parentType = Schema.getGlobalDescribe().get('LookupParent_GLBL__c');
	//	SObject parentA = parentType.newSObject();
	//	parentA.put('Name', 'ParentA');
	//	insert parentA;
		
	//	// Insert children
	//	Schema.SObjectType childType = Schema.getGlobalDescribe().get('LookupChild_GLBL__c');
	//	SObject child1 = childType.newSObject();
	//	child1.put('LookupParent_GLBL__c', parentA.Id);
	//	insert child1;
		
	//	// Assert rollup		
	//	Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query('select id, Total_GLBL__c from LookupParent_GLBL__c'));
	//	System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get('Total_GLBL__c'));
					
	//	// Create test user
	//	User testUser = null;
	//	System.runAs ( new User(Id = UserInfo.getUserId()) ) {
 //			testUser = createUser();
	//	}
		
	//	//// Test data insert children as new user (who cannot see the parent)
	//	//System.runAs(testUser)
	//	//{
	//	//	// Ensure this user can read it (the Sharing setting for LookupParent_GLBL__c is Public Read Only)
	//	//	assertParents = new Map<Id, SObject>(Database.query('select id, Total_GLBL__c from LookupParent_GLBL__c'));
	//	//	System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get('Total_GLBL__c'));
			
	//	//	// Attempt to indirectly via rollup trigger to update parent record
	//	//	child1.put('Amount_GLBL__c', 42);
	//	//	update child1;
	//	//}
		
	//	//// Assert rollup
	//	//assertParents = new Map<Id, SObject>(Database.query('select id, Total_GLBL__c from LookupParent_GLBL__c'));
	//	//System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get('Total_GLBL__c'));
	//}
	
	/**
	 * Create test user
	 **/
	private static User createUser()
	{
		// Can only proceed with test if we have a suitable profile
		List<Profile> testProfiles = [Select Id From Profile where Name='Standard User' limit 1];
		if(testProfiles.size()!=1)
			return null; 		

		// Can only proceed with test if we can successfully insert a test user 
		String testUsername = System.now().format('yyyyMMddhhmmss') + '@testorg.com';
		User testUser = new User(Alias = 'test1', Email='testuser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = testProfiles[0].Id, TimeZoneSidKey='America/Los_Angeles', UserName=testUsername);
		try {
			insert testUser;
			
			// Assign permission sets
			Set<String> psNames = new Set<String> { 'LookupRollupSummariesFull', 'LookupRollupSummariesTest' };
			List<PermissionSet> ps = [select Id from PermissionSet where Name in :psNames];
			insert new List<PermissionSetAssignment> {
				new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps[0].Id),
				new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps[1].Id) };
		} catch (Exception e) {
			return null;
		}		
		return testUser;
	}	
}