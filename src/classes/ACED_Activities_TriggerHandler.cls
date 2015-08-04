/*****************************************************************************************
    Name    : ACED_Activities_TriggerHandler
    Desc    : Trigger handler class to update channel value on Activity record and Rollup Actual costs and eInteractions values to the Asset
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description     
---------------------------------------------------------------------------
Goutham              01/09/2014          Created
---------------------------------------------------------------------------
History Log:
Venugopal            12/09/2014          Added method 'UpdateActualCostonAsset' to rollup Actual costs and eInteractions to Assets on Activities update event.
Saba Fatima          15/09/2014          As the field 'StandAlone_Asset_Program' has been renamed to 'StandAlone_Asset_Program_TF',updated the same at one occurence in this class.
******************************************************************************************/

Public class ACED_Activities_TriggerHandler{
    //Method to update channel value upon selecting asset on activity record
    Public static void updateActivity(list<ACED_Activity__c> lActivities) {
        //Map to store selected asset ID and corresponding channel ID
        Map<Id, Id> mAssetIdToChannelId = New Map<Id, Id>(); 
        //List of selected assets on Activity       
        list<ACED_Asset__c> assetlist = New list<ACED_Asset__c>();
        //List of IDs of selected assets on Activity 
        Set<Id> sAssetIds = New Set<Id>();

        //Looping over all activities being updated/inserted and adding assets selected on the activity records to a list      
        for (ACED_Activity__c a : lActivities){
            if(a.Assets__c!=NULL)
                sAssetIds.add(a.Assets__c);
        }
                
        //Looping over all assets in the list and mapping corresponding channel IDs on asset             
        for (ACED_Asset__c Asset : [SELECT Id, Channel__c from ACED_Asset__c where Id IN  :sAssetIds  ] ){
            if(asset.Channel__c!= NULL ){
                mAssetIdToChannelId.put(Asset.Id, Asset.Channel__c);
            }
        }
        //Looping over all activities being updated/inserted and assigning channel on asset to activity      
        for (ACED_Activity__c a : lActivities ){
            if(a.assets__c!=NULL && mAssetIdToChannelId.containsKey(a.assets__c) && mAssetIdToChannelId.get(a.assets__c)!=null){
                a.Channel__c= mAssetIdToChannelId.get(a.assets__c);
            }
        }
        
    
    }
    
       Public static void UpdateActualCostonAsset(Map<Id,ACED_Activity__c> mNewActivityMap,Map<Id,ACED_Activity__c> mOldActivityMap){
    
        Set<Id> sAssetIds=new Set<Id>();
        List<ACED_Asset__c> lAggegateAssetUpdate = new List<ACED_Asset__c>();

        //looping overall activities being udpated to see if there are any Assets associated and storing in the sAssetsIds set
        if(mNewActivityMap != null && mNewActivityMap.size()>0){
        
            for(ACED_Activity__c oActivity : mNewActivityMap.values()){  
                if(oActivity .Assets__c!=null){
                    sAssetIds.add(oActivity.Assets__c);
                }
                if(mNewActivityMap.get(oActivity.Id).Assets__c == null && mNewActivityMap.get(oActivity.Id).Assets__c!= mOldActivityMap.get(oActivity.Id).Assets__c)
                    sAssetIds.add(mOldActivityMap.get(oActivity.Id).Assets__c);
            }
            //Map to store Activity's Parent asset ID, name , actual cost and eInteractions
            Map<Id, ACED_Asset__c> mAssetCurrentCost= new Map<Id, ACED_Asset__c>([SELECT ID, Name, Activity_Actual_Cost__c, Recordtype.DeveloperName from ACED_Asset__c where ID IN: sAssetIds]); 
            
            //aggregate query to fetch the sum of ActualCost and eInteractions on the activities grouped by List of Assets 
            List<AggregateResult> lAggregateResult = [SELECT Assets__c, SUM(Actual_Costs__c) SumActualCost, SUM(Actual_eInt__c) SumofeIntforAsset  FROM ACED_Activity__c where Assets__c IN: sAssetIds GROUP BY Assets__c];
            System.debug('# List of Aggregate Assets'+lAggregateResult);
            
            //Condition to check if the aggregate query returns empty list any records then process the Asset
            if(lAggregateResult.size() == 0){
                for(Id sAsset : sAssetIds){
                    if(mAssetCurrentCost.containskey(sAsset) && mAssetCurrentCost.get(sAsset).Activity_Actual_Cost__c != 0){
                        ACED_Asset__c oAsset = new ACED_Asset__c (id = sAsset);
                        oAsset.Activity_Actual_Cost__c = 0;
                        oAsset.No_Activities__c = false;
                        lAggegateAssetUpdate.add(oAsset );
                    }
                }
            }
            else{
                
                //Condition to check if the aggregate query returns the records in the list, then populate the fields on Asset iterating through each
                for(AggregateResult ar : lAggregateResult){
                    if(mAssetCurrentCost.containskey((string)ar.get('Assets__c'))){
                        ACED_Asset__c oAsset = new ACED_Asset__c (id = (ID)ar.get('Assets__c'));
                        oAsset.No_Activities__c = false;
                        if(mAssetCurrentCost.get((string)ar.get('Assets__c')).Activity_Actual_Cost__c  != (decimal)ar.get('SumActualCost'))
                            oAsset.Activity_Actual_Cost__c = (decimal)ar.get('SumActualCost');
                        if(mAssetCurrentCost.get((string)ar.get('Assets__c')).Activity_Actual_Cost__c  != (decimal)ar.get('SumActualCost') ||mAssetCurrentCost.get((string)ar.get('Assets__c')).recordtype.developername!= 'Delivery_Asset')
                            lAggegateAssetUpdate.add(oAsset);               
                     }
                 
                }
            }
                 update lAggegateAssetUpdate;
                
       }
    }
    
  
}