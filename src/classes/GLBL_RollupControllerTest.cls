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
private with sharing class GLBL_RollupControllerTest
{
	private testmethod static void testDeployedStatus()
	{
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;

    	// Metadata API web Service mock implementation for tests
        Test.setMock(WebServiceMock.class, new GLBL_RollupControllerWebServiceMockImpl());

		// Test data
		LookupRollupSummary_GLBL__c rollupSummaryA = new LookupRollupSummary_GLBL__c();
		rollupSummaryA.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummaryA.ParentObject_GLBL__c = 'Account';
		rollupSummaryA.ChildObject_GLBL__c = 'Opportunity';
		rollupSummaryA.RelationShipField_GLBL__c = 'AccountId';
		rollupSummaryA.RelationShipCriteria_GLBL__c = null;
		rollupSummaryA.FieldToAggregate_GLBL__c = 'Amount';
		rollupSummaryA.AggregateOperation_GLBL__c = 'Sum';
		rollupSummaryA.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummaryA.Active_GLBL__c = true;
		rollupSummaryA.CalculationMode_GLBL__c = 'Realtime';
		LookupRollupSummary_GLBL__c rollupSummaryB = new LookupRollupSummary_GLBL__c();
		rollupSummaryB.Name = 'Total Opportunities into Number Of Locations on Accountt';
		rollupSummaryB.ParentObject_GLBL__c = 'Account';
		rollupSummaryB.ChildObject_GLBL__c = 'Opportunity';
		rollupSummaryB.RelationShipField_GLBL__c = 'AccountId';
		rollupSummaryB.RelationShipCriteria_GLBL__c = null;
		rollupSummaryB.FieldToAggregate_GLBL__c = 'CloseDate';
		rollupSummaryB.AggregateOperation_GLBL__c = 'Count';
		rollupSummaryB.AggregateResultField_GLBL__c = 'NumberOfEmployees';
		rollupSummaryB.Active_GLBL__c = true;
		rollupSummaryB.CalculationMode_GLBL__c = 'Realtime';
		insert new List<LookupRollupSummary_GLBL__c> { rollupSummaryA, rollupSummaryB };

		// Assert initial state of controller when the trigger for the child object is deployed
		GLBL_RollupController controller = new GLBL_RollupController(new ApexPages.StandardController( rollupSummaryA ));
		System.assertEquals(true, controller.Deployed);
		System.assertEquals('GLBL_RollupServiceTestTrigger', controller.RollupTriggerName);
		System.assertEquals('GLBL_RollupSummariesTest', controller.RollupTriggerTestName);
		System.assertEquals('GLBL_RollupServiceTestTrigger', controller.RollupTrigger.Name);
		System.assertEquals('GLBL_RollupSummariesTest', controller.RollupTriggerTest.Name);
		System.assertEquals(controller.RollupTrigger.Body, controller.getTriggerCode());
		System.assertEquals(controller.RollupTriggerTest.Body, controller.getTriggerTestCode());
		System.assertEquals(
			    '<?xml version="1.0" encoding="UTF-8"?>' +
				'<Package xmlns="http://soap.sforce.com/2006/04/metadata">' +
	    			'<version>28.0</version>' +
				'</Package>',
			controller.getPackageXml());
		System.assertEquals(
			    '<?xml version="1.0" encoding="UTF-8"?>' +
				'<Package xmlns="http://soap.sforce.com/2006/04/metadata">' +
	    			'<types>' +
	        			'<members>'+controller.RollupTriggerName+'</members>' +
	        			'<name>ApexTrigger</name>' +
	    			'</types>' +
	    			'<types>' +
	        			'<members>'+controller.RollupTriggerTestName+'</members>' +
	        			'<name>ApexClass</name>' +
	    			'</types>' +
	    			'<version>28.0</version>' +
				'</Package>',
				controller.getDestructiveChangesXml());
		System.assertEquals(
		    '<?xml version="1.0" encoding="UTF-8"?>' +
			'<ApexTrigger xmlns="http://soap.sforce.com/2006/04/metadata">' +
			    '<apiVersion>28.0</apiVersion>' +
			    '<status>Active</status>' +
			'</ApexTrigger>',
			controller.getTriggerCodeMetadata());
		System.assertEquals(
		    '<?xml version="1.0" encoding="UTF-8"?>' +
			'<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">' +
			    '<apiVersion>28.0</apiVersion>' +
			    '<status>Active</status>' +
			'</ApexClass>',
			controller.getTriggerTestCodeMetadata());

		// Open test context, permits callouts following DML
		Test.startTest();

		// Undeploy (no need to emulate the zip contents prepared by the client as mock service does not bother with this)
		controller.deployZip();

		// Check deployment (mock service impl emulates a positive response)
		controller.checkAsyncRequest();

		Test.stopTest();

		// Assert Active_GLBL__c is false on lookups referencing this child object
		List<LookupRollupSummary_GLBL__c> lookups = [select Active_GLBL__c from LookupRollupSummary_GLBL__c];
		System.assertEquals(false, lookups[0].Active_GLBL__c);
		System.assertEquals(false, lookups[1].Active_GLBL__c);
	}

	private testmethod static void testNotDeployedStatus()
	{
		// Test supported?
		if(!GLBL_TestContext.isSupported())
			return;

    	// Metadata API web Service mock implementation for tests
        Test.setMock(WebServiceMock.class, new GLBL_RollupControllerWebServiceMockImpl());

		// Test data
		LookupRollupSummary_GLBL__c rollupSummary = new LookupRollupSummary_GLBL__c();
		rollupSummary.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummary.ParentObject_GLBL__c = 'Account';
		rollupSummary.ChildObject_GLBL__c = 'Contact';
		rollupSummary.RelationShipField_GLBL__c = 'AccountId';
		rollupSummary.RelationShipCriteria_GLBL__c = null;
		rollupSummary.FieldToAggregate_GLBL__c = 'LastCURequestDate';
		rollupSummary.AggregateOperation_GLBL__c = 'Count';
		rollupSummary.AggregateResultField_GLBL__c = 'AnnualRevenue';
		rollupSummary.Active_GLBL__c = false;
		rollupSummary.CalculationMode_GLBL__c = 'Realtime';
		insert rollupSummary;

		// Assert initial state of controller when the trigger for the child object is deployed
		GLBL_RollupController controller = new GLBL_RollupController(new ApexPages.StandardController( rollupSummary ));
		System.assertEquals(false, controller.Deployed);
		System.assertEquals('GLBL_ContactTrigger', controller.RollupTriggerName);
		System.assertEquals('GLBL_ContactTest', controller.RollupTriggerTestName);
		System.assertEquals(null, controller.RollupTrigger);
		System.assertEquals(null, controller.RollupTriggerTest);
		//System.assertEquals(
		//		'/**\n' +
		//		' * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)\n' +
		//		' **/\n' +
		//		'trigger ' + controller.RollupTriggerName + ' on ' + rollupSummary.ChildObject_GLBL__c + '\n' +
		//		'    (before delete, before insert, before update, after delete, after insert, after undelete, after update)\n'+
		//		'{\n'+
		//		'    dlrs.RollupService.triggerHandler();\n'+
		//		'}\n', controller.getTriggerCode());
		//System.assertEquals(
		//	 	'/**\n' +
		//		' * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)\n' +
		//		' **/\n' +
		//		'@IsTest\n' +
		//	    'private class ' + controller.RollupTriggerTestName + '\n' +
		//		'{\n' +
		//		'    private static testmethod void testTrigger()\n' +
		//		'    {\n' +
		//		'        // Code to cover the one line trigger, the method called has been tested separately by the packaged tests.\n' +
		//		'        try { insert new ' + rollupSummary.ChildObject_GLBL__c + '(); } catch(Exception e) { }\n' +
		//		'    }\n' +
		//		'}', controller.getTriggerTestCode());
		System.assertEquals(
			    '<?xml version="1.0" encoding="UTF-8"?>' +
				'<Package xmlns="http://soap.sforce.com/2006/04/metadata">' +
	    			'<types>' +
	        			'<members>'+controller.RollupTriggerName+'</members>' +
	        			'<name>ApexTrigger</name>' +
	    			'</types>' +
	    			'<types>' +
	        			'<members>'+controller.RollupTriggerTestName+'</members>' +
	        			'<name>ApexClass</name>' +
	    			'</types>' +
	    			'<version>28.0</version>' +
				'</Package>',
			controller.getPackageXml());
		System.assertEquals(
		    '<?xml version="1.0" encoding="UTF-8"?>' +
			'<ApexTrigger xmlns="http://soap.sforce.com/2006/04/metadata">' +
			    '<apiVersion>28.0</apiVersion>' +
			    '<status>Active</status>' +
			'</ApexTrigger>',
			controller.getTriggerCodeMetadata());
		System.assertEquals(
		    '<?xml version="1.0" encoding="UTF-8"?>' +
			'<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">' +
			    '<apiVersion>28.0</apiVersion>' +
			    '<status>Active</status>' +
			'</ApexClass>',
			controller.getTriggerTestCodeMetadata());
	}
}