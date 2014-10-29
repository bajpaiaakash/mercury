@isTest(SeeAllData=false)
public class Test_ACED_Delivery_Actuals_TriggerHndlr{

    static testMethod void createDeliveryActuals() {
    
      User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
            
    System.runAs(runAsUser) {
       Test.startTest();
       List<ACED_Delivery_Actuals__c> ldelActs = ACED_DataFactory.createDeliveryActuals(100);
           
       Delete ldelActs; 
       
       //Assert deletion successful
       system.assert([Select id from ACED_Delivery_Actuals__c where id in : ldelActs].size()==0);
       
       Test.stopTest();
   
    }
  
}
    
}