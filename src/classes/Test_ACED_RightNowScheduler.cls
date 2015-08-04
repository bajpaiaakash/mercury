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
private class Test_ACED_RightNowScheduler {

    static testMethod void myUnitTest() {
        User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
        System.runAs(runAsUser) {
        // Set mock callout class 
            
            ACED_Integration_Console__c oIntConsole =  new ACED_Integration_Console__c(Web_UserName__c='tets@tet.com',RightNow_Admin_Email__c='uet@yryr.com',WebTrends_Admin_Email__c='777@77.com',Web_Password__c='8888',WebTrends_Service_URL__c='yryryr@uerur.com');
            oIntConsole.RN_UserName__c = 'tetete';
            oIntConsole.RN_Password__c = '12334';
            oIntConsole.Metrics__c= 'Test Metrics';
            insert oIntConsole;
            
            ACED_RightNow_Country__c oRightNow = new ACED_RightNow_Country__c();
            oRightNow.RightNow_Service_URL__c = 'http://api.salesforce.com/foo/bar';
            oRightNow.Report_ID__c = '13252';
            oRightNow.Integration_Console__c = oIntConsole.Id;
            Insert oRightNow;
            
            ACED_Channel__c oChannel = ACED_DataFactory.createChannels(1)[0];
            ACED_Channel_Attribute__c oChannelAttributes = new ACED_Channel_Attribute__c();
            oChannelAttributes.Attribute_Name__c ='Opened';
            oChannelAttributes.actual__c = true;
            oChannelAttributes.channel__c = oChannel.id;
            Insert oChannelAttributes;
            
            oChannel.Actual_Attribute__c = 'Opened';
            Update oChannel;
            
            ACED_Activity__c oActivity =  ACED_DataFactory.createActivities(1)[0];      
            oActivity.channel__c = oChannel.id;
            update oActivity;
            
            ACED_Deliveries__c oDeliveries= New ACED_Deliveries__c();
            oDeliveries.Activity__c= oActivity.ID;
            oDeliveries.Start_Date__c=System.today();
            oDeliveries.End_Date__c=System.today()+45;
            oDeliveries.PIM_Segment__c='Traditionalist';
            insert  oDeliveries;
            
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new Test_ACED_RightNowMockResp());
                ACED_RightNowScheduler.InvokeRightNow();
            Test.stopTest();
            
            String CRON_EXP = '0 0 0 1 1 ? 2025';  
            String jobId = System.schedule('testScheduledApex', CRON_EXP, new ACED_RightNowScheduler() ); 
            
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
            
            //Assert job is now running for first time
            System.assertEquals(0, ct.TimesTriggered);
        }    
      
    }
}