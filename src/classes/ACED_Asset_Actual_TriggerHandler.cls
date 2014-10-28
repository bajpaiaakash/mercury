/* Class Name  : ACED_DataFactory
* Description  : Class to update eInteraction values on Asset Brand Indication upon creating or updating Asset Actuals
* Created By   : Goutham
* Created Date : 
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

public with sharing class ACED_Asset_Actual_TriggerHandler {
    
    Public static void UpdateAssetIndicationWithInteractionValues(List<ACED_Asset_Actual__c> lAssetActuals){
    
    //Creating Map of Asset IDs and Sum of corresponding Asset actuals value Sum
    Map<ID,Decimal> mAssetToSum = New Map<ID,Decimal>();
    //Creating a list of Asset IDs
    List<ID> lAssets = New List<ID>();
    //Creating a lsit of asse indications
    List<ACED_Asset_Indication__c> lAssetInd = New List<ACED_Asset_Indication__c>();
    

    //Aggregate query to get the sum of value on related Asset actuals of an asset
                    for(AggregateResult oAssetAggregates : [SELECT Sum(Value__c) MonthlySum,Asset__c AssetIDs 
                                                           FROM ACED_Asset_Actual__c
                                                           WHERE Id in :lAssetActuals group by Asset__c]){
                                                           
                    mAssetToSum.put((Id)oAssetAggregates.get('AssetIDs'),(Decimal)oAssetAggregates.get('MonthlySum'));  
                    lAssets.add((Id)oAssetAggregates.get('AssetIDs'));
                                                                               
                    }
                    
     //Looping over all Asset Indications and updating eInteraction values                
                    for(ACED_Asset_Indication__c AssetIndUpdate: [SELECT Effort__c ,Asset__c,Asset__r.Total_Effort__c 
                                                           FROM ACED_Asset_Indication__c
                                                           WHERE Asset__c in :lAssets ]){
                    If(mAssetToSum.containskey(AssetIndUpdate.Asset__c)){ 
                    If(AssetIndUpdate.Asset__r.Total_Effort__c!=NULL && AssetIndUpdate.Asset__r.Total_Effort__c!=0){                                      
                    AssetIndUpdate.Actual_eInteraction__c=AssetIndUpdate.Effort__c * ((mAssetToSum.get(AssetIndUpdate.Asset__c))/100);
                    AssetIndUpdate.Effort_eInteraction__c=(AssetIndUpdate.Effort__c/(AssetIndUpdate.Asset__r.Total_Effort__c)) * (mAssetToSum.get(AssetIndUpdate.Asset__c));
                    lAssetInd.add(AssetIndUpdate); 
                    }                                     
                    }
                    }
                    Update(lAssetInd);
                    
    
    
    }
}