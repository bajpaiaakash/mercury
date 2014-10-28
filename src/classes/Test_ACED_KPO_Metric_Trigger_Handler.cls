/* Class Name  : Test_ACED_KPO_Metric_Trigger_Handler
* Description  : Test Class for ACED_KPO_Metric_Trigger_Handler
* Created By   : Goutham
* Created Date : 9/30/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

@isTest(SeeAllData=false)

//test class for ACED_KPO_Metric_Trigger_Handler
private class Test_ACED_KPO_Metric_Trigger_Handler{
    
    //test method for ACED_KPO_Metric_Trigger_Handler
    static testMethod void insert_UpdateKPOMetric(){
        
        //Declaring the user with Digital dashboard owner Permission set
        User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
                             
        Test.startTest();
            
        System.runAs(runAsUser) {
        
        //Inserting a list of KPO Metrics 
        List<ACED_KPO_Metric__c> lKPOMetrics  = ACED_DataFactory.creatKPOMetrics(100); 
        //List<ACED_Program_Mot__c> insertedrecs=[select id from ACED_Program_Mot__c];
        
        //Checking whether all records are inserted
        system.assertequals(lKPOMetrics.size(),100);
                
        }
        
        Test.stopTest();
        
      }
}