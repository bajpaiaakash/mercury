/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seealldata=false)
private class Test_ACED_WebTrendsScheduler {

    static testMethod void myUnitTest() {
        
        
		ACED_Integration_Console__c oIntConsole =  new ACED_Integration_Console__c(Web_UserName__c='tets@tet.com',RightNow_Admin_Email__c='uet@yryr.com',WebTrends_Admin_Email__c='777@77.com',Web_Password__c='8888',WebTrends_Service_URL__c='yryryr@uerur.com');
		oIntConsole.RN_UserName__c = 'tetete';
		oIntConsole.RN_Password__c = '12334';
		insert oIntConsole;
		
		ACED_Asset__c ast = ACED_DataFactory.createAssets(1)[0];
		ast.profileid__c = '12345678';
		Update Ast;
		Test.startTest();
			StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
			mock.setStaticResource('ACED_WebTrendsRepsonse');
			mock.setStatusCode(200); // Or other appropriate HTTP status code
			mock.setHeader('Content-Type', 'application/json'); // Or other appropriate MIME type like application/xml
			Test.setMock(HttpCalloutMock.class, mock);
	    	ACED_WebTrendsScheduler.InvokeWebTrends();
	    Test.stopTest();	
	    	
	        String CRON_EXP = '0 0 0 1 1 ? 2025';  
	        String jobId = System.schedule('testScheduledApex', CRON_EXP, new ACED_WebTrendsScheduler() );
			CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
	
	        System.assertEquals(CRON_EXP, ct.CronExpression); 
	        System.assertEquals(0, ct.TimesTriggered);
        
    }
}