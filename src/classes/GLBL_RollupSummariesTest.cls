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

@IsTest
private with sharing class GLBL_RollupSummariesTest 
{
	// TODO: Write a test to validate the criteria fields validation
	// ...		


	// TODO: Write a test to validate the criteria fields are specified when criteria is specified
	// ...		
	
	private testmethod static void testInsertActiveValidation()
	{
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;
		
		LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
		rollupSummary.Name = 'Max Birthday for Contacts related to an Account';
		rollupSummary.ParentObject_GLBL__c = 'Account';
		rollupSummary.ChildObject_GLBL__c = 'Contact';
		rollupSummary.RelationShipField_GLBL__c = 'AccountId';
		rollupSummary.RelationShipCriteria_GLBL__c = null;
		rollupSummary.FieldToAggregate_GLBL__c = 'LastCURequestDate';
		rollupSummary.AggregateOperation_GLBL__c = 'Count';
		rollupSummary.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummary.Active_GLBL__c = true;
		rollupSummary.CalculationMode_GLBL__c = 'Realtime';
		GLBL_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary_GLBL__c[] { rollupSummary } );		
		GLBL_SObjectDomain.triggerHandler(GLBL_RollupSummaries.class);		
		System.assertEquals(1, GLBL_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Apex Trigger ' + GLBL_RollupSummaries.makeTriggerName(rollupSummary) + ' has not been deployed. Click Manage Child Trigger and try again.', GLBL_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary_GLBL__c.Active_GLBL__c, ((GLBL_SObjectDomain.FieldError)GLBL_SObjectDomain.Errors.getAll()[0]).field);
	}
	
	private testmethod static void testInsertParentObjectValidation()
	{
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;
		
		LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject_GLBL__c = 'AccountX';
		rollupSummary.ChildObject_GLBL__c = 'Opportunity';
		rollupSummary.RelationShipField_GLBL__c = 'AccountId';
		rollupSummary.RelationShipCriteria_GLBL__c = null;
		rollupSummary.FieldToAggregate_GLBL__c = 'Amount';
		rollupSummary.AggregateOperation_GLBL__c = 'Sum';
		rollupSummary.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummary.Active_GLBL__c = true;
		rollupSummary.CalculationMode_GLBL__c = 'Realtime';
		GLBL_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary_GLBL__c[] { rollupSummary } );		
		GLBL_SObjectDomain.triggerHandler(GLBL_RollupSummaries.class);		
		System.assertEquals(1, GLBL_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Object does not exist.', GLBL_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary_GLBL__c.ParentObject_GLBL__c, ((GLBL_SObjectDomain.FieldError)GLBL_SObjectDomain.Errors.getAll()[0]).field);
	}
	
	private testmethod static void testInsertChildObjectValidation()
	{
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;
		
		LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject_GLBL__c = 'Account';
		rollupSummary.ChildObject_GLBL__c = 'OpportunityX';
		rollupSummary.RelationShipField_GLBL__c = 'AccountId';
		rollupSummary.RelationShipCriteria_GLBL__c = null;
		rollupSummary.FieldToAggregate_GLBL__c = 'Amount';
		rollupSummary.AggregateOperation_GLBL__c = 'Sum';
		rollupSummary.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummary.Active_GLBL__c = true;
		rollupSummary.CalculationMode_GLBL__c = 'Realtime';
		GLBL_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary_GLBL__c[] { rollupSummary } );		
		GLBL_SObjectDomain.triggerHandler(GLBL_RollupSummaries.class);		
		System.assertEquals(2, GLBL_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Object does not exist.', GLBL_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary_GLBL__c.ChildObject_GLBL__c, ((GLBL_SObjectDomain.FieldError)GLBL_SObjectDomain.Errors.getAll()[0]).field);
		System.assertEquals('Apex Trigger ' + GLBL_RollupSummaries.makeTriggerName(rollupSummary) + ' has not been deployed. Click Manage Child Trigger and try again.', GLBL_SObjectDomain.Errors.getAll()[1].message);
		System.assertEquals(LookupRollupSummary_GLBL__c.Active_GLBL__c, ((GLBL_SObjectDomain.FieldError)GLBL_SObjectDomain.Errors.getAll()[1]).field);
	}
	
	private testmethod static void testInsertRelationshipFieldValidation()
	{
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;
		
		LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject_GLBL__c = 'Account';
		rollupSummary.ChildObject_GLBL__c = 'Opportunity';
		rollupSummary.RelationShipField_GLBL__c = 'AccountIdX';
		rollupSummary.RelationShipCriteria_GLBL__c = null;
		rollupSummary.FieldToAggregate_GLBL__c = 'Amount';
		rollupSummary.AggregateOperation_GLBL__c = 'Sum';
		rollupSummary.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummary.Active_GLBL__c = true;
		rollupSummary.CalculationMode_GLBL__c = 'Realtime';
		GLBL_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary_GLBL__c[] { rollupSummary } );		
		GLBL_SObjectDomain.triggerHandler(GLBL_RollupSummaries.class);		
		System.assertEquals(1, GLBL_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Field does not exist.', GLBL_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary_GLBL__c.RelationShipField_GLBL__c, ((GLBL_SObjectDomain.FieldError)GLBL_SObjectDomain.Errors.getAll()[0]).field);
	}		
	
	private testmethod static void testInsertFieldToAggregateValidation()
	{
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;
		
		LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject_GLBL__c = 'Account';
		rollupSummary.ChildObject_GLBL__c = 'Opportunity';
		rollupSummary.RelationShipField_GLBL__c = 'AccountId';
		rollupSummary.RelationShipCriteria_GLBL__c = null;
		rollupSummary.FieldToAggregate_GLBL__c = 'AmountX';
		rollupSummary.AggregateOperation_GLBL__c = 'Sum';
		rollupSummary.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummary.Active_GLBL__c = true;
		rollupSummary.CalculationMode_GLBL__c = 'Realtime';
		GLBL_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary_GLBL__c[] { rollupSummary } );		
		GLBL_SObjectDomain.triggerHandler(GLBL_RollupSummaries.class);		
		System.assertEquals(1, GLBL_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Field does not exist.', GLBL_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary_GLBL__c.FieldToAggregate_GLBL__c, ((GLBL_SObjectDomain.FieldError)GLBL_SObjectDomain.Errors.getAll()[0]).field);
	}		
	
	private testmethod static void testInsertAggregateResultFieldValidation()
	{
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;
		
		LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject_GLBL__c = 'Account';
		rollupSummary.ChildObject_GLBL__c = 'Opportunity';
		rollupSummary.RelationShipField_GLBL__c = 'AccountId';
		rollupSummary.RelationShipCriteria_GLBL__c = null;
		rollupSummary.FieldToAggregate_GLBL__c = 'Amount';
		rollupSummary.AggregateOperation_GLBL__c = 'Sum';
		rollupSummary.AggregateResultField_GLBL__c = 'AnnualRevenueX';
		rollupSummary.Active_GLBL__c = true;
		rollupSummary.CalculationMode_GLBL__c = 'Realtime';
		GLBL_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary_GLBL__c[] { rollupSummary } );		
		GLBL_SObjectDomain.triggerHandler(GLBL_RollupSummaries.class);		
		System.assertEquals(1, GLBL_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Field does not exist.', GLBL_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary_GLBL__c.AggregateResultField_GLBL__c, ((GLBL_SObjectDomain.FieldError)GLBL_SObjectDomain.Errors.getAll()[0]).field);
	}	
	
	private testmethod static void testInsertBadFieldTypesStringNotValid()
	{
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;
		
		LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject_GLBL__c = 'Account';
		rollupSummary.ChildObject_GLBL__c = 'Opportunity';
		rollupSummary.RelationShipField_GLBL__c = 'AccountId';
		rollupSummary.RelationShipCriteria_GLBL__c = null;
		rollupSummary.FieldToAggregate_GLBL__c = 'Name';
		rollupSummary.AggregateOperation_GLBL__c = 'Sum';
		rollupSummary.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummary.Active_GLBL__c = true;
		rollupSummary.CalculationMode_GLBL__c = 'Realtime';
		GLBL_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary_GLBL__c[] { rollupSummary } );		
		GLBL_SObjectDomain.triggerHandler(GLBL_RollupSummaries.class);		
		System.assertEquals(1, GLBL_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Only Date/DateTime/Time/Numeric fields are allowed', GLBL_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(rollupSummary, ((GLBL_SObjectDomain.ObjectError)GLBL_SObjectDomain.Errors.getAll()[0]).record);
	}	

	private testmethod static void testInsertBadFieldTypeSumNotValid()
	{
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;
		
		LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject_GLBL__c = 'Account';
		rollupSummary.ChildObject_GLBL__c = 'Opportunity';
		rollupSummary.RelationShipField_GLBL__c = 'AccountId';
		rollupSummary.RelationShipCriteria_GLBL__c = null;
		rollupSummary.FieldToAggregate_GLBL__c = 'CloseDate';
		rollupSummary.AggregateOperation_GLBL__c = 'Sum';
		rollupSummary.AggregateResultField_GLBL__c = 'CODS_End_Date_GLBL__c';
		rollupSummary.Active_GLBL__c = true;
		rollupSummary.CalculationMode_GLBL__c = 'Realtime';
		GLBL_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary_GLBL__c[] { rollupSummary } );		
		GLBL_SObjectDomain.triggerHandler(GLBL_RollupSummaries.class);		
		System.assertEquals(1, GLBL_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Sum/Avg doesnt looks like valid for dates ! Still want, then implement the IRollerCoaster yourself and change this class as required.', GLBL_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(rollupSummary, ((GLBL_SObjectDomain.ObjectError)GLBL_SObjectDomain.Errors.getAll()[0]).record);
	}	
	
	private testmethod static void testTriggerAndTestClassNaming()
	{	
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;
		
		System.assertEquals('GLBL_ContactTrigger', GLBL_RollupSummaries.makeTriggerName(new LookupRollupSummary_GLBL__c(ChildObject_GLBL__c = 'Contact')));		
		System.assertEquals('GLBL_ContactTest', GLBL_RollupSummaries.makeTriggerTestName(new LookupRollupSummary_GLBL__c(ChildObject_GLBL__c = 'Contact')));		
		System.assertEquals('GLBL_pse_AssignmentTrigger', GLBL_RollupSummaries.makeTriggerName(new LookupRollupSummary_GLBL__c(ChildObject_GLBL__c = 'pse__Assignment__c')));		
		System.assertEquals('GLBL_pse_AssignmentTest', GLBL_RollupSummaries.makeTriggerTestName(new LookupRollupSummary_GLBL__c(ChildObject_GLBL__c = 'pse__Assignment__c')));		
		System.assertEquals('GLBL_MyCustomObjectTrigger', GLBL_RollupSummaries.makeTriggerName(new LookupRollupSummary_GLBL__c(ChildObject_GLBL__c = 'MyCustomObject__c')));		
		System.assertEquals('GLBL_MyCustomObjectTest', GLBL_RollupSummaries.makeTriggerTestName(new LookupRollupSummary_GLBL__c(ChildObject_GLBL__c = 'MyCustomObject__c')));		
	}
	
	private testmethod static void testRelationshipCriteriaFieldsValidationSingle()
	{
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;
		
		LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject_GLBL__c = 'Account';
		rollupSummary.ChildObject_GLBL__c = 'Opportunity';
		rollupSummary.RelationShipField_GLBL__c = 'AccountId';
		rollupSummary.RelationShipCriteria_GLBL__c = 'Stage = \'Won\'';
		rollupSummary.RelationShipCriteriaFields_GLBL__c = 'Stage';
		rollupSummary.FieldToAggregate_GLBL__c = 'Amount';
		rollupSummary.AggregateOperation_GLBL__c = 'Sum';
		rollupSummary.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummary.Active_GLBL__c = true;
		rollupSummary.CalculationMode_GLBL__c = 'Realtime';
		GLBL_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary_GLBL__c[] { rollupSummary } );		
		GLBL_SObjectDomain.triggerHandler(GLBL_RollupSummaries.class);		
		System.assertEquals(1, GLBL_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Field Stage does not exist on the child object.', GLBL_SObjectDomain.Errors.getAll()[0].message);		
	}	

	private testmethod static void testRelationshipCriteriaFieldsValidationMulti()
	{
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;
		
		LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject_GLBL__c = 'Account';
		rollupSummary.ChildObject_GLBL__c = 'Opportunity';
		rollupSummary.RelationShipField_GLBL__c = 'AccountId';
		rollupSummary.RelationShipCriteria_GLBL__c = 'Stage = \'Won\'';
		rollupSummary.RelationShipCriteriaFields_GLBL__c = 'Stage\r\nAnother';
		rollupSummary.FieldToAggregate_GLBL__c = 'Amount';
		rollupSummary.AggregateOperation_GLBL__c = 'Sum';
		rollupSummary.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummary.Active_GLBL__c = true;
		rollupSummary.CalculationMode_GLBL__c = 'Realtime';
		GLBL_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary_GLBL__c[] { rollupSummary } );		
		GLBL_SObjectDomain.triggerHandler(GLBL_RollupSummaries.class);		
		System.assertEquals(1, GLBL_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Fields Stage,Another do not exist on the child object.', GLBL_SObjectDomain.Errors.getAll()[0].message);		
	}	
}