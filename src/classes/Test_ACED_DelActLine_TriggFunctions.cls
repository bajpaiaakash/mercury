/* Class Name  : Test_ACED_DelActLine_TriggFunctions
* Description  : Test Class for ACED_Delivery_Actual_Line_TriggFunctions
* Created By   : Goutham
* Created Date : 9/22/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

@isTest(SeeAllData=false)

//test class for ACED_Delivery_Actual_Line_TriggFunctions
public class Test_ACED_DelActLine_TriggFunctions{

//test method for ACED_Delivery_Actual_Line_TriggFunctions
    static testMethod void insertNewDeliveryActualLines() {
    
     //Declaring the user with Digital dashboard owner Permission set
     User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
            
    System.runAs(runAsUser) {
    
        Test.startTest();
        
           //Inserting a list of Delivery actual lines which inturn will insert delivery actuals and the trigger functions will update delivery actuals with primary attributes
           List<ACED_Delivery_Actual_Line__c> lDelActLines = ACED_DataFactory.createDeliveryActualLines(100);
           
           //Querying for value field on delivery actual
           ACED_Delivery_Actual_Line__c DelActLine = [SELECT id,Delivery_Actuals__r.Value__c from ACED_Delivery_Actual_Line__c where id =:lDelActLines[0].id];
                      
            //System assert to check whether delivery actuals are updated with primary attributes
            system.assertequals(lDelActLines[0].Value__c,DelActLine.Delivery_Actuals__r.Value__c);
            
        Test.stopTest();
    }
}
}