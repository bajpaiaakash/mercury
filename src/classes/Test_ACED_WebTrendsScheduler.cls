/* Class Name  : Test_ACED_WebTrendsScheduler
* Description  : Test Class for ACED_WebTrendsScheduler
* Created By   : Deloitte Consulting
* Created Date :
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

@isTest(seealldata=false)
private class Test_ACED_WebTrendsScheduler {
    
    //Test method to test non program assets
    static testMethod void myUnitTest() {
        User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
        System.runAs(runAsUser) {
            
            //Inserting integration console record
            ACED_Integration_Console__c oIntConsole =  new ACED_Integration_Console__c(Metrics__c='ga:newUsers,ga:users,ga:sessions',Web_UserName__c='tets@tet.com',RightNow_Admin_Email__c='uet@yryr.com',WebTrends_Admin_Email__c='777@77.com',Web_Password__c='8888',WebTrends_Service_URL__c='yryryr@uerur.com');
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

    //Test method to test program assets    
    static testMethod void myUnitTest1() {
        User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
        System.runAs(runAsUser) {
                        
            //Inserting integration console record
            ACED_Integration_Console__c oIntConsole =  new ACED_Integration_Console__c(Metrics__c='ga:newUsers',Web_UserName__c='tets@tet.com',WebTrends_Admin_Email__c='777@77.com',Web_Password__c='8888',WebTrends_Service_URL__c='yryryr@uerur.com');            
            insert oIntConsole;
            
            ACED_Asset__c ast = ACED_DataFactory.createProgramAssets(1)[0];
            ast.profileid__c = '12345678';
            Update ast;
            
             List<ACED_Activity__c> lActivities=ACED_DataFactory.createActivities(1);
             List<ACED_Activity__c>  lAct = [Select Program__r.Year__c,Assets__c from ACED_Activity__c where id=:lActivities[0].ID];
             lAct[0].Assets__c = ast.ID;
             update lAct;
             List<ACED_Providers__c> lProviders=ACED_DataFactory.createProviders(1); 
             
            //Inserting the delivery and assigning it to activity above. Inserting Delivery independently rather than from utility to insert delivery indication which is being inserted from trigger
            ACED_Deliveries__c Del= New ACED_Deliveries__c();
            Del.Activity__c=lAct[0].ID;
            Del.Provider__c=lProviders[0].ID;
            Del.Start_Date__c=System.today();
            Del.End_Date__c= date.newInstance(system.Today().year(), 12, 31);
            Del.PIM_Segment__c='Traditionalist';
            Insert Del;
            
            
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
}