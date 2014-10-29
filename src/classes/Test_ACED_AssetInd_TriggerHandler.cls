/* Class Name  : Test_ACED_AssetIndications_TriggerHandler 
* Description  : Test Class for ACED_AssetIndications_TriggerHandler
* Created By   : Goutham
* Created Date : 10/1/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/
@isTest(SeeAllData=false)

//test class for ACED_AssetIndications_TriggerHandler
public class Test_ACED_AssetInd_TriggerHandler {

    //test method for ACED_AssetIndications_TriggerHandler
    static testMethod void insertAssetInd() {
    
        //Declaring the user with Digital dashboard owner Permission set
        User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
            
    System.runAs(runAsUser) {
        
        Test.startTest();
            
            //Inserting a list of Asset Brandindications which fires trigger on asset brand indications
            list<ACED_Asset_Indication__c> lAssetInds = ACED_DataFactory.createAssetIndications(100);
            
            //System assert to check whether recordtypeof assets inserted
            //system.assertequals(lAssetInds[0].Brand_Indication__c,NULL); 
            
        Test.stopTest();
        
        
        
        }
      }   
}