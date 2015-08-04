@isTest (SeeAllData = false)
public class Test_ACED_Activities_TriggerHandler {

    static testMethod void insertNewActvity() {
    
    //Declaring the User
    User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
    
    System.runAs(runAsUser) {        
        Test.startTest();
        List<ACED_Activity__c> lActivitiesWithOutAssets = ACED_DataFactory.createActivitiesWithOutAssets(100); 
        List<ACED_Cost__c> lCost = new List<ACED_Cost__c> ();
        List<ACED_Asset__c> lAssets = ACED_DataFactory.createAssets(1);
        for(ACED_Activity__c oActivity : lActivitiesWithOutAssets){
        	ACED_Cost__c oCost  = new ACED_Cost__c(Assets_Activity__c=oActivity.Id,Cost__c=100);
        	oActivity.Assets__c = lAssets[0].Id;
        	lCost.add(oCost);
        }
        Insert lCost;
        ACED_Asset_TriggerHandler.bRecursiveCheck  =true;
        Update lActivitiesWithOutAssets;
        //assert all activities are not deleted from the program after update operation
        system.assert(lActivitiesWithOutAssets.size()>0);

        Delete lActivitiesWithOutAssets.remove(0);  
       
        Test.stopTest();
        
        
        } 
    }

}