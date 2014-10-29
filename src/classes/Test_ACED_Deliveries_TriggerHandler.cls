/* Class Name  : Test_ACED_Deliveries_TriggerHandler
* Description  : Test Class for ACED_Deliveries_TriggerHandler
* Created By   : Goutham
* Created Date : 9/19/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

@isTest(SeeAllData=false)

//test class for ACED_Deliveries_TriggerHandler
public class Test_ACED_Deliveries_TriggerHandler{
    
    //test method for ACED_Deliveries_TriggerHandler
    static testMethod void insertNewDelivery() {
    
    //Declaring the user with Digital dashboard owner Permission set
    User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
            
    System.runAs(runAsUser) {
    
        Test.startTest();
        
               //Inserting a list of 100 Delivery indication actuals records which inturn will insert 100 deliveries and fires the trigger on delivery object
               List<ACED_Delivery_Indication_Actuals__c> ldelActs = ACED_DataFactory.createDeliveryIndicationActualswithActuals(100);
               
               
               
        Test.stopTest();
        
    }
}
}