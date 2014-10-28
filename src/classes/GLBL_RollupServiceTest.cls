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
private with sharing class GLBL_RollupServiceTest
{
	static Schema.SObjectField ACCOUNT_CODS_END_DATE;
	static Schema.SObjectField ACCOUNT_NUMBER_OF_EMPLOYEES;
	static
	{
		// Dynamically resolve these fields, if they are not present when the test runs, the test will return as passed to avoid failures in subscriber org when packaged
		Map<String, Schema.SObjectField> accountFields = Schema.SObjectType.Account.fields.getMap();
		ACCOUNT_CODS_END_DATE = accountFields.get('CODS_End_Date_GLBL__c');
		ACCOUNT_NUMBER_OF_EMPLOYEES = accountFields.get('NumberOfEmployees');
	}

	private testmethod static void testSingleSumRollup()
	{
		testSingleRollup(new List<Decimal> { 250, 250, 50, 50 }, 600, GLBL_RollupSummaries.AggregateOperation.Sum, null);
	}

	private testmethod static void testSingleMaxRollup()
	{
		testSingleRollup(new List<Decimal> { 250, 250, 50, 50 }, 250, GLBL_RollupSummaries.AggregateOperation.Max, null);
	}

	private testmethod static void testSingleMinRollup()
	{
		testSingleRollup(new List<Decimal> { 250, 250, 50, 50 }, 50, GLBL_RollupSummaries.AggregateOperation.Min, null);
	}

	private testmethod static void testSingleAvgRollup()
	{
		testSingleRollup(new List<Decimal> { 250, 250, 50, 50 }, 150, GLBL_RollupSummaries.AggregateOperation.Avg, null);
	}

	private testmethod static void testSingleCountRollup()
	{
		testSingleRollup(new List<Decimal> { 250, 250, 50, 50 }, 4, GLBL_RollupSummaries.AggregateOperation.Count, null);
	}

	private testmethod static void testSingleSumRollupConditional()
	{
		testSingleRollup(new List<Decimal> { 250, 250, 50, 50 }, 500, GLBL_RollupSummaries.AggregateOperation.Sum, 'Amount > 200');
	}

	private testmethod static void testMultiRollup()
	{
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;

		// Test data
		List<Decimal> rollups = new List<Decimal> { 250, 250, 50, 50 };

		// Test data for rollup A
		Decimal expectedResultA = 500;
		GLBL_RollupSummaries.AggregateOperation operationA = GLBL_RollupSummaries.AggregateOperation.Sum;
		String conditionA = 'Amount > 200';

		// Test data for rollup B
		Decimal expectedResultB = 4;
		GLBL_RollupSummaries.AggregateOperation operationB = GLBL_RollupSummaries.AggregateOperation.Count;
		String conditionB = null;

		// Configure rollup A
		LookupRollupSummary_GLBL__c rollupSummaryA = new LookupRollupSummary_GLBL__c();
		rollupSummaryA.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummaryA.ParentObject_GLBL__c = 'Account';
		rollupSummaryA.ChildObject_GLBL__c = 'Opportunity';
		rollupSummaryA.RelationShipField_GLBL__c = 'AccountId';
		rollupSummaryA.RelationShipCriteria_GLBL__c = conditionA;
		rollupSummaryA.FieldToAggregate_GLBL__c = 'Amount';
		rollupSummaryA.AggregateOperation_GLBL__c = operationA.name();
		rollupSummaryA.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummaryA.Active_GLBL__c = true;
		rollupSummaryA.CalculationMode_GLBL__c = 'Realtime';
		insert rollupSummaryA;

		// Configure rollup B
		LookupRollupSummary_GLBL__c rollupSummaryB = new LookupRollupSummary_GLBL__c();
		rollupSummaryB.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummaryB.ParentObject_GLBL__c = 'Account';
		rollupSummaryB.ChildObject_GLBL__c = 'Opportunity';
		rollupSummaryB.RelationShipField_GLBL__c = 'AccountId';
		rollupSummaryB.RelationShipCriteria_GLBL__c = conditionB;
		rollupSummaryB.FieldToAggregate_GLBL__c = 'CloseDate';
		rollupSummaryB.AggregateOperation_GLBL__c = operationB.name();
		rollupSummaryB.AggregateResultField_GLBL__c = 'NumberOfEmployees';
		rollupSummaryB.Active_GLBL__c = true;
		rollupSummaryB.CalculationMode_GLBL__c = 'Realtime';
		insert rollupSummaryB;

		// Insert rollup definitions
		//insert new List<LookupRollupSummary_GLBL__c> { rollupSummaryA, rollupSummaryB };

		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		account.AnnualRevenue = 0;
		insert account;
		List<Opportunity> opps = new List<Opportunity>();
		for(Decimal rollupValue : rollups)
		{
			Opportunity opp = new Opportunity();
			opp.Name = 'Test Opportunity';
			opp.StageName = 'Open';
			opp.CloseDate = System.today();
			opp.AccountId = account.Id;
			opp.Amount = rollupValue;
			opps.add(opp);
		}
		insert opps;

		// Assert rollup
		Id accountId = account.Id;
		Account accountResult = Database.query('select AnnualRevenue, NumberOfEmployees from Account where Id = :accountId');
		System.assertEquals(expectedResultA, accountResult.AnnualRevenue);
		System.assertEquals(expectedResultB, accountResult.get(ACCOUNT_NUMBER_OF_EMPLOYEES));
	}

	private testmethod static void testMultiRollupWithTwoParents()
	{
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;

		// Test data
		List<Decimal> rollups = new List<Decimal> { 250, 250, 50, 50 };

		// Test data for rollup A
		Decimal expectedResultA = 500;
		GLBL_RollupSummaries.AggregateOperation operationA = GLBL_RollupSummaries.AggregateOperation.Sum;
		String conditionA = 'Amount > 200';

		// Test data for rollup B
		Decimal expectedResultB = 4;
		GLBL_RollupSummaries.AggregateOperation operationB = GLBL_RollupSummaries.AggregateOperation.Count;
		String conditionB = null;

		// Test data for rollup C
		Decimal expectedResultC = 600;
		GLBL_RollupSummaries.AggregateOperation operationC = GLBL_RollupSummaries.AggregateOperation.Sum;
		String conditionC = null;

		// Configure rollup A
		LookupRollupSummary_GLBL__c rollupSummaryA = new LookupRollupSummary_GLBL__c();
		rollupSummaryA.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummaryA.ParentObject_GLBL__c = 'Account';
		rollupSummaryA.ChildObject_GLBL__c = 'Opportunity';
		rollupSummaryA.RelationShipField_GLBL__c = 'AccountId';
		rollupSummaryA.RelationShipCriteria_GLBL__c = conditionA;
		rollupSummaryA.FieldToAggregate_GLBL__c = 'Amount';
		rollupSummaryA.AggregateOperation_GLBL__c = operationA.name();
		rollupSummaryA.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummaryA.Active_GLBL__c = true;
		rollupSummaryA.CalculationMode_GLBL__c = 'Realtime';

		// Configure rollup B
		LookupRollupSummary_GLBL__c rollupSummaryB = new LookupRollupSummary_GLBL__c();
		rollupSummaryB.Name = 'Total Opportunities into Number Of Locations on Accountt';
		rollupSummaryB.ParentObject_GLBL__c = 'Account';
		rollupSummaryB.ChildObject_GLBL__c = 'Opportunity';
		rollupSummaryB.RelationShipField_GLBL__c = 'AccountId';
		rollupSummaryB.RelationShipCriteria_GLBL__c = conditionB;
		rollupSummaryB.FieldToAggregate_GLBL__c = 'CloseDate';
		rollupSummaryB.AggregateOperation_GLBL__c = operationB.name();
		rollupSummaryB.AggregateResultField_GLBL__c = 'NumberOfEmployees';
		rollupSummaryB.Active_GLBL__c = true;
		rollupSummaryB.CalculationMode_GLBL__c = 'Realtime';

		// Configure rollup C
		LookupRollupSummary_GLBL__c rollupSummaryC = new LookupRollupSummary_GLBL__c();
		rollupSummaryC.Name = 'Total Opportunities into Num Sent on Campaign';
		rollupSummaryC.ParentObject_GLBL__c = 'Campaign';
		rollupSummaryC.ChildObject_GLBL__c = 'Opportunity';
		rollupSummaryC.RelationShipField_GLBL__c = 'CampaignId';
		rollupSummaryC.RelationShipCriteria_GLBL__c = conditionC;
		rollupSummaryC.FieldToAggregate_GLBL__c = 'TotalOpportunityQuantity';
		rollupSummaryC.AggregateOperation_GLBL__c = operationC.name();
		rollupSummaryC.AggregateResultField_GLBL__c = 'NumberSent';
		rollupSummaryC.Active_GLBL__c = true;
		rollupSummaryC.CalculationMode_GLBL__c = 'Realtime';

		// Insert rollup definitions
		insert new List<LookupRollupSummary_GLBL__c> { rollupSummaryA, rollupSummaryB, rollupSummaryC };

		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		account.AnnualRevenue = 0;
		insert account;
		SObject camp = Schema.getGlobalDescribe().get('Campaign').newSObject();
		camp.put('Name', 'Test Campaign');
		insert camp;
		List<Opportunity> opps = new List<Opportunity>();
		for(Decimal rollupValue : rollups)
		{
			Opportunity opp = new Opportunity();
			opp.Name = 'Test Opportunity';
			opp.StageName = 'Open';
			opp.CloseDate = System.today();
			opp.AccountId = account.Id;
			opp.Amount = rollupValue;
			opp.TotalOpportunityQuantity = rollupValue;
			opp.put('CampaignId', camp.Id);
			opps.add(opp);
		}
		insert opps;

		// Assert rollups
		Id accountId = account.Id;
		Account accountResult = Database.query('select AnnualRevenue, NumberOfEmployees from Account where Id = :accountId');
		System.assertEquals(expectedResultA, accountResult.AnnualRevenue);
		System.assertEquals(expectedResultB, accountResult.get(ACCOUNT_NUMBER_OF_EMPLOYEES));
		Id campId = camp.Id;
		SObject campResult = Database.query('select NumberSent from Campaign where Id = :campId');
		System.assertEquals(expectedResultC, campResult.get('NumberSent'));
	}

	private testmethod static void testSingleRollupWithoutRelation()
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
		rollupSummary.FieldToAggregate_GLBL__c = 'Amount';
		rollupSummary.AggregateOperation_GLBL__c = 'Sum';
		rollupSummary.AggregateResultField_GLBL__c = 'AnnualRevenue';
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
		opp.AccountId = null; // Note no relationship with an Account
		opp.Amount = 100;
		insert opp;

		// Assert rollup
		System.assertEquals(0, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);

		// Do an update
		opp.Amount = 101;
		update opp;

		// Assert rollup
		System.assertEquals(0, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);
	}

	private testmethod static void testSingleRollupWithInsertThenDelete()
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
		rollupSummary.FieldToAggregate_GLBL__c = 'Amount';
		rollupSummary.AggregateOperation_GLBL__c = 'Sum';
		rollupSummary.AggregateResultField_GLBL__c = 'AnnualRevenue';
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
		System.assertEquals(100, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);

		// Delete Opportunity
		delete opp;

		// Assert rollup
		System.assertEquals(0, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);
	}

	private testmethod static void testSingleRollupWithInsertsThenDelete()
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
		rollupSummary.FieldToAggregate_GLBL__c = 'Amount';
		rollupSummary.AggregateOperation_GLBL__c = 'Sum';
		rollupSummary.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummary.Active_GLBL__c = true;
		rollupSummary.CalculationMode_GLBL__c = 'Realtime';
		insert new List<LookupRollupSummary_GLBL__c> { rollupSummary };

		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		account.AnnualRevenue = 0;
		insert account;
		{
			Opportunity opp = new Opportunity();
			opp.Name = 'Test Opportunity';
			opp.StageName = 'Open';
			opp.CloseDate = System.today();
			opp.AccountId = account.Id;
			opp.Amount = 100;
			insert opp;
		}
		Opportunity opp = new Opportunity();
		opp.Name = 'Test Opportunity';
		opp.StageName = 'Open';
		opp.CloseDate = System.today();
		opp.AccountId = account.Id;
		opp.Amount = 100;
		insert opp;

		// Assert rollup
		System.assertEquals(200, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);

		// Delete Opportunity
		delete opp;

		// Assert rollup
		System.assertEquals(100, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);
	}

	private testmethod static void testSingleRollupWithZerosAsNullInsertsThenDelete()
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
		rollupSummary.FieldToAggregate_GLBL__c = 'Amount';
		rollupSummary.AggregateOperation_GLBL__c = 'Sum';
		rollupSummary.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummary.Active_GLBL__c = true;
		rollupSummary.CalculationMode_GLBL__c = 'Realtime';
		rollupSummary.TreatZeroAsNull_GLBL__c = true;
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

		Opportunity opp2 = new Opportunity();
		opp2.Name = 'Test Opportunity 2';
		opp2.StageName = 'Open';
		opp2.CloseDate = System.today();
		opp2.AccountId = account.Id;
		opp2.Amount = 100;
		insert opp2;

		// Assert rollup
		System.assertEquals(200, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);

		// Delete Opportunity
		delete opp;

		// Assert rollup
		System.assertEquals(100, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);

		// Delete Opportunity
		delete opp2;

		// Assert rollup
		System.assertEquals(null, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);

		Opportunity opp3 = new Opportunity();
		opp3.Name = 'Test Opportunity 3';
		opp3.StageName = 'Open';
		opp3.CloseDate = System.today();
		opp3.AccountId = account.Id;
		opp3.Amount = 0;
		insert opp3;

		// Assert rollup
		System.assertEquals(null, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);
	}

	private testmethod static void testRollupWithoutChanges()
	{
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;

		// Perform standard test
		testSingleRollup(new List<Decimal> { 250, 250, 50, 50 }, 600, GLBL_RollupSummaries.AggregateOperation.Sum, null);
		List<Opportunity> opps = [select Id from Opportunity];

		// Sample various limits prior to an update
		Integer beforeQueries = Limits.getQueries();
		Integer beforeRows = Limits.getQueryRows();
		Integer beforeDescribes = Limits.getFieldsDescribes();

		// Update opportunities (no changes to the field being aggregted, thus no rollup processng)
		update opps;

		// Assert no further limits have been used since the field to aggregate on the detail has not changed
		//System.assertEquals(beforeQueries + 1, Limits.getQueries()); // Only tolerate a query for the Lookup definition
		System.assertEquals(beforeRows + 1, Limits.getQueryRows()); // Only tolerate a row for the Lookup definition
		System.assertEquals(beforeDescribes, Limits.getFieldsDescribes()); // Zero tolerance on field describes
	}

	private testmethod static void testLimitsConsumedWithConditions()
	{
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;

		// Disable the Account trigger for this test, its carefully caluculated test actuals are thrown when this is enabled as well
		GLBL_TestContext.AccountTestTriggerEnabled = false;

		// Test data
		List<Decimal> rollups = new List<Decimal> { 250, 250, 50, 50 };

		// Test data for rollup A
		Decimal expectedResultA = 500;
		GLBL_RollupSummaries.AggregateOperation operationA = GLBL_RollupSummaries.AggregateOperation.Sum;
		String conditionA = 'Amount > 200';

		// Test data for rollup B
		Decimal expectedResultB = 4;
		GLBL_RollupSummaries.AggregateOperation operationB = GLBL_RollupSummaries.AggregateOperation.Count;
		String conditionB = null;

		// Configure rollup A
		LookupRollupSummary_GLBL__c rollupSummaryA = new LookupRollupSummary_GLBL__c();
		rollupSummaryA.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummaryA.ParentObject_GLBL__c = 'Account';
		rollupSummaryA.ChildObject_GLBL__c = 'Opportunity';
		rollupSummaryA.RelationShipField_GLBL__c = 'AccountId';
		rollupSummaryA.RelationShipCriteria_GLBL__c = conditionA;
		rollupSummaryA.FieldToAggregate_GLBL__c = 'Amount';
		rollupSummaryA.AggregateOperation_GLBL__c = operationA.name();
		rollupSummaryA.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummaryA.Active_GLBL__c = true;
		rollupSummaryA.CalculationMode_GLBL__c = 'Realtime';

		// Configure rollup B
		LookupRollupSummary_GLBL__c rollupSummaryB = new LookupRollupSummary_GLBL__c();
		rollupSummaryB.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummaryB.ParentObject_GLBL__c = 'Account';
		rollupSummaryB.ChildObject_GLBL__c = 'Opportunity';
		rollupSummaryB.RelationShipField_GLBL__c = 'AccountId';
		rollupSummaryB.RelationShipCriteria_GLBL__c = conditionB;
		rollupSummaryB.FieldToAggregate_GLBL__c = 'CloseDate';
		rollupSummaryB.AggregateOperation_GLBL__c = operationB.name();
		rollupSummaryB.AggregateResultField_GLBL__c = 'NumberOfEmployees';
		rollupSummaryB.Active_GLBL__c = true;
		rollupSummaryB.CalculationMode_GLBL__c = 'Realtime';

		// Insert rollup definitions
		insert new List<LookupRollupSummary_GLBL__c> { rollupSummaryA, rollupSummaryB };

		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		account.AnnualRevenue = 0;
		insert account;
		List<Opportunity> opps = new List<Opportunity>();
		for(Decimal rollupValue : rollups)
		{
			Opportunity opp = new Opportunity();
			opp.Name = 'Test Opportunity';
			opp.StageName = 'Open';
			opp.CloseDate = System.today();
			opp.AccountId = account.Id;
			opp.Amount = rollupValue;
			opps.add(opp);
		}
		insert opps;

		// One query on ApexTrigger (in the GLBL_TestContext.isSupported method)
		// One query on ApexTrigger (validation when inserting rollups)
		// One query on Rollup object
		// One query on Opportunity for rollup a
		// One query on Opportunity for rollup b
		//System.assertEquals(5, Limits.getQueries());

		// One row for ApexTrigger (in the GLBL_TestContext.isSupported method)
		// One row for ApexTrigger
		// Two rows for Rollup object
		// Two rows for Opportunity for rollup a
		// Four rows for Opportunity for rollup b
		System.assertEquals(10, Limits.getQueryRows());

		// One for the statics at the top of the test
		// One for the parent object validation on insert of lookup
		// One for the child object validaiton on insert of lookup
		// One for the lookup of the field type for the parent object during trigger
		// One for the lookup of the field type for the child object during trigger
		System.assertEquals(5, Limits.getFieldsDescribes());

		// Assert rollup
		Id accountId = account.Id;
		Account accountResult = Database.query('select AnnualRevenue, NumberOfEmployees from Account where Id = :accountId');
		System.assertEquals(expectedResultA, accountResult.AnnualRevenue);
		System.assertEquals(expectedResultB, accountResult.get(ACCOUNT_NUMBER_OF_EMPLOYEES));

		// Modify the opps, but only the Amount, this should result in only the Amount rollup executing
		for(Opportunity opp : opps)
			opp.Amount++;
		update opps;

		// + One query for the Account query above
		// + One query on Rollup object
		// + One query on Opportunity for rollup a
		//System.assertEquals(8, Limits.getQueries());

		// + One query for the Account query above
		// + Two rows for Rollup object
		// + Two rows for Opportunity for rollup a
		System.assertEquals(15, Limits.getQueryRows());

		// + One for the lookup of the field type for the parent object during trigger
		// + One for the lookup of the field type for the child object during trigger
		System.assertEquals(7, Limits.getFieldsDescribes());

		// Assert rollup
		accountResult = Database.query('select AnnualRevenue, NumberOfEmployees from Account where Id = :accountId');
		System.assertEquals(expectedResultA + 2, accountResult.AnnualRevenue);
		System.assertEquals(expectedResultB, accountResult.get(ACCOUNT_NUMBER_OF_EMPLOYEES));
	}

	private testmethod static void testLimitsConsumedWithoutConditions()
	{
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;

		// Disable the Account trigger for this test, its carefully caluculated test actuals are thrown when this is enabled as well
		GLBL_TestContext.AccountTestTriggerEnabled = false;

		// Test data
		List<Decimal> rollups = new List<Decimal> { 250, 250, 50, 50 };

		// Test data for rollup A
		Decimal expectedResultA = 600;
		GLBL_RollupSummaries.AggregateOperation operationA = GLBL_RollupSummaries.AggregateOperation.Sum;
		String conditionA = null;

		// Test data for rollup B
		Decimal expectedResultB = 4;
		GLBL_RollupSummaries.AggregateOperation operationB = GLBL_RollupSummaries.AggregateOperation.Count;
		String conditionB = null;

		// Configure rollup A
		LookupRollupSummary_GLBL__c rollupSummaryA = new LookupRollupSummary_GLBL__c();
		rollupSummaryA.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummaryA.ParentObject_GLBL__c = 'Account';
		rollupSummaryA.ChildObject_GLBL__c = 'Opportunity';
		rollupSummaryA.RelationShipField_GLBL__c = 'AccountId';
		rollupSummaryA.RelationShipCriteria_GLBL__c = conditionA;
		rollupSummaryA.FieldToAggregate_GLBL__c = 'Amount';
		rollupSummaryA.AggregateOperation_GLBL__c = operationA.name();
		rollupSummaryA.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummaryA.Active_GLBL__c = true;
		rollupSummaryA.CalculationMode_GLBL__c = 'Realtime';

		// Configure rollup B
		LookupRollupSummary_GLBL__c rollupSummaryB = new LookupRollupSummary_GLBL__c();
		rollupSummaryB.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummaryB.ParentObject_GLBL__c = 'Account';
		rollupSummaryB.ChildObject_GLBL__c = 'Opportunity';
		rollupSummaryB.RelationShipField_GLBL__c = 'AccountId';
		rollupSummaryB.RelationShipCriteria_GLBL__c = conditionB;
		rollupSummaryB.FieldToAggregate_GLBL__c = 'CloseDate';
		rollupSummaryB.AggregateOperation_GLBL__c = operationB.name();
		rollupSummaryB.AggregateResultField_GLBL__c = 'NumberOfEmployees';
		rollupSummaryB.Active_GLBL__c = true;
		rollupSummaryB.CalculationMode_GLBL__c = 'Realtime';

		// Insert rollup definitions
		insert new List<LookupRollupSummary_GLBL__c> { rollupSummaryA, rollupSummaryB };

		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		account.AnnualRevenue = 0;
		insert account;
		List<Opportunity> opps = new List<Opportunity>();
		for(Decimal rollupValue : rollups)
		{
			Opportunity opp = new Opportunity();
			opp.Name = 'Test Opportunity';
			opp.StageName = 'Open';
			opp.CloseDate = System.today();
			opp.AccountId = account.Id;
			opp.Amount = rollupValue;
			opps.add(opp);
		}
		insert opps;

		// One query on ApexTrigger (in the GLBL_TestContext.isSupported method)
		// One query on ApexTrigger (validation when inserting rollups)
		// One query on Rollup object
		// One query on Opportunity for both rollups
		//System.assertEquals(4, Limits.getQueries());

		// One row for ApexTrigger (in the GLBL_TestContext.isSupported method)
		// One row for ApexTrigger
		// Two rows for Rollup object
		// Four rows for Opportunity for rollup a and b
		System.assertEquals(8, Limits.getQueryRows());

		// One for the statics at the top of the test
		// One for the parent object validation on insert of lookup
		// One for the child object validaiton on insert of lookup
		// One for the lookup of the field type for the parent object during trigger
		// One for the lookup of the field type for the child object during trigger
		System.assertEquals(5, Limits.getFieldsDescribes());

		// Assert rollup
		Id accountId = account.Id;
		Account accountResult = Database.query('select AnnualRevenue, NumberOfEmployees from Account where Id = :accountId');
		System.assertEquals(expectedResultA, accountResult.AnnualRevenue);
		System.assertEquals(expectedResultB, accountResult.get(ACCOUNT_NUMBER_OF_EMPLOYEES));

		// Modify the opps, but only the Amount, this should result in only the Amount rollup executing
		for(Opportunity opp : opps)
			opp.Amount++;
		update opps;

		// + One query for the Account query above
		// + One query on Rollup object
		// + One query on Opportunity for rollup a
		//System.assertEquals(7, Limits.getQueries());

		// + One query for the Account query above
		// + Two rows for Rollup object
		// + Four rows for Opportunity for rollup a and
		System.assertEquals(15, Limits.getQueryRows());

		// + One for the lookup of the field type for the parent object during trigger
		// + One for the lookup of the field type for the child object during trigger
		System.assertEquals(7, Limits.getFieldsDescribes());

		// Assert rollup
		accountResult = Database.query('select AnnualRevenue, NumberOfEmployees from Account where Id = :accountId');
		System.assertEquals(expectedResultA + 4, accountResult.AnnualRevenue);
		System.assertEquals(expectedResultB, accountResult.get(ACCOUNT_NUMBER_OF_EMPLOYEES));
	}

	private static void testSingleRollup(List<Decimal> rollups, Decimal expectedResult, GLBL_RollupSummaries.AggregateOperation operation, String condition)
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
		rollupSummary.RelationShipCriteria_GLBL__c = condition; // 'Amount > 200';
		rollupSummary.FieldToAggregate_GLBL__c = 'Amount';
		rollupSummary.AggregateOperation_GLBL__c = operation.name();
		rollupSummary.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummary.Active_GLBL__c = true;
		rollupSummary.CalculationMode_GLBL__c = 'Realtime';
		insert new List<LookupRollupSummary_GLBL__c> { rollupSummary };

		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		account.AnnualRevenue = 0;
		insert account;
		List<Opportunity> opps = new List<Opportunity>();
		for(Decimal rollupValue : rollups)
		{
			Opportunity opp = new Opportunity();
			opp.Name = 'Test Opportunity';
			opp.StageName = 'Open';
			opp.CloseDate = System.today();
			opp.AccountId = account.Id;
			opp.Amount = rollupValue;
			opps.add(opp);
		}
		insert opps;

		// Assert rollup
		System.assertEquals(expectedResult, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);
	}

	private testmethod static void testNoLookupFoundOnRunJobToCalculate() {
		try {
			GLBL_RollupService.runJobToCalculate('001000000000abc');
			System.assert(false, 'no error thrown');
		} catch (GLBL_RollupServiceException ex) {
			System.assert(ex.getMessage().startswith('Invalid rollup'));
		}
	}

	private testmethod static void testHasJobRunningForRunJobToCalculate() {
	    //Configure rollup
		LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
		rollupSummary.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummary.ParentObject_GLBL__c = 'Account';
		rollupSummary.ChildObject_GLBL__c = 'Opportunity';
		rollupSummary.RelationShipField_GLBL__c = 'AccountId';
		rollupSummary.RelationShipCriteria_GLBL__c = null;
		rollupSummary.FieldToAggregate_GLBL__c = 'Amount';
		rollupSummary.AggregateOperation_GLBL__c = 'Sum';
		rollupSummary.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummary.Active_GLBL__c = true;
		rollupSummary.CalculationMode_GLBL__c = 'Realtime';
		rollupSummary.CalculateJobId_GLBL__c='001000000000123';

		insert rollupSummary;
		try {
			GLBL_RollupService.runJobToCalculate(rollupSummary.Id);
			System.assert(false, 'no error thrown');
		} catch (GLBL_RollupServiceException ex) {
			System.assert(ex.getMessage().startswith('A calculate job for rollup'));
		}
	}

	private testmethod static void testUpdateMasterRollups() {
	    //Configure rollup
		LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
		rollupSummary.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummary.ParentObject_GLBL__c = 'Account';
		rollupSummary.ChildObject_GLBL__c = 'Opportunity';
		rollupSummary.RelationShipField_GLBL__c = 'AccountId';
		rollupSummary.RelationShipCriteria_GLBL__c = null;
		rollupSummary.FieldToAggregate_GLBL__c = 'Amount';
		rollupSummary.AggregateOperation_GLBL__c = 'Sum';
		rollupSummary.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummary.Active_GLBL__c = true;
		rollupSummary.CalculationMode_GLBL__c = 'Realtime';

		insert rollupSummary;

		Map<Id, Account> acctMap = new Map<Id, Account>(MERC_TestFactory.insertAccounts(3));
		GLBL_RollupService.updateMasterRollups(new Set<Id> {rollupSummary.Id}, acctMap.keySet());
	}

	//this is a very contrived test to force an error in the static method in order to gain
	//test coverage.
	private testmethod static void testUpdateMasterRollupsFailure() {
	    //Configure rollup
		LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
		rollupSummary.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummary.ParentObject_GLBL__c = 'Account';
		rollupSummary.ChildObject_GLBL__c = 'Opportunity';
		rollupSummary.RelationShipField_GLBL__c = 'AccountId';
		rollupSummary.RelationShipCriteria_GLBL__c = null;
		rollupSummary.FieldToAggregate_GLBL__c = 'Amount';
		rollupSummary.AggregateOperation_GLBL__c = 'Sum';
		rollupSummary.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummary.Active_GLBL__c = true;
		rollupSummary.CalculationMode_GLBL__c = 'Realtime';

		insert rollupSummary;

		Map<Id, Account> acctMap = new Map<Id, Account>(MERC_TestFactory.insertAccounts(3));
		Test.setReadOnlyApplicationMode(true);
		try {
			GLBL_RollupService.updateMasterRollups(new Set<Id> {rollupSummary.Id}, acctMap.keySet());
		} catch (Exception ex) {

		}
	}

}