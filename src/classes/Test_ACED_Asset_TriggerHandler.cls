/* Class Name  : Test_ACED_Asset_TriggerHandler 
* Description  : Test Class for ACED_Asset_TriggerHandler
* Created By   : Goutham
* Created Date : 10/1/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/
@isTest(SeeAllData=false)

//test class for ACED_Asset_TriggerHandler
public class Test_ACED_Asset_TriggerHandler {

    //test method for ACED_Asset_TriggerHandler
    static testMethod void insertAssets() {
    
        //Declaring the user with Digital dashboard owner Permission set
        User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
            
    System.runAs(runAsUser) {
    
        //declaring list of asset Ids
        List<ID> lAssetIDs = New List<ID>();
        
        //declaring list of assets
        List<ACED_Asset__c> lAssets = New List<ACED_Asset__c>();
        
        Test.startTest();
            
            //Inserting a list of Asset Brandindications which inturn will insert corresponding assets
            list<ACED_Asset_Indication__c> lAssetInds = ACED_DataFactory.createAssetIndications(100);
            
            //looping over asset indications and adding asset ids to a list
            for(ACED_Asset_Indication__c AssetInd:lAssetInds){
                lAssetIDs.add(AssetInd.Asset__c);
            }
            
            //adding assets to list of assets
            lAssets = [SELECT id, Recordtype.DeveloperName from ACED_Asset__c where ID in:lAssetIDs];
            
            //updating the assets to run after and before update triggers
            Update lAssets; 
            
            //System assert to check whether recordtypeID of assets inserted is NonProgram(Standalone)asset
            system.assertequals(String.valueof(lAssets[10].Recordtype.DeveloperName),'Non_Program_Asset'); 
            
        Test.stopTest();
        
        
        
        }
      }   
}