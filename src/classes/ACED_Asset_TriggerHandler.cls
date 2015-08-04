public with sharing class ACED_Asset_TriggerHandler {
    
       
    Public static boolean bRecursiveCheck = true; 
    Public static String Non_Program_AssetRecodtypeId = ACED_Utility.mRecordType(ACED_Utility.oAssetName).get('Non_Program_Asset');
    Public static String Program_AssetRecodtypeId = ACED_Utility.mRecordType(ACED_Utility.oAssetName).get('Program_Asset');
        
    Public static void UpdateStandAloneCheckboxOnInsert(List<ACED_Asset__c> lAsset){
        for(ACED_Asset__c oAsset : lAsset){
            oAsset.No_Activities__c = true;
            oAsset.RecordtypeId = Non_Program_AssetRecodtypeId;
        }
    }
    
    Public static void CheckIfStandAloneAsset(List<ACED_Asset__c> lAsset){
        Set<Id> sAssetWithActivity = new Set<Id>();
        List<ACED_Asset__c> lAssetWithoutActivity = new List<ACED_Asset__c>();
        for(ACED_Activity__c oActivity : [Select id,Assets__c from ACED_Activity__c where Assets__c in: lAsset and Program__r.StandAlone_Asset_Program_TF__c = :false]){
            sAssetWithActivity.add(oActivity.Assets__c);
        }
        
        for(ACED_Asset__c oAsset : lAsset){
            if(!sAssetWithActivity.contains(oAsset.id)){
                if(oAsset.status__c == ACED_Utility.sAssetLiveStatus){
                    lAssetWithoutActivity.add(oAsset);
                }   
                oAsset.No_Activities__c = true;
                oAsset.RecordtypeId = Non_Program_AssetRecodtypeId;
            }
            else{
                oAsset.No_Activities__c = false;
                oAsset.RecordtypeId = Program_AssetRecodtypeId;
            }   
        }
            system.debug('$$$$$'+lAssetWithoutActivity);
            createStandAloneAsset(lAssetWithoutActivity);
    }
    
    Public static void createStandAloneAsset(List<ACED_Asset__c> lAsset){
            bRecursiveCheck = false;
            List<ACED_Asset__c> lAssetsVar = new List<ACED_Asset__c>();
            List<ACED_Deliveries__c> lDeliveries = new List<ACED_Deliveries__c>();
            List<ACED_Activity__c> lActivityInsert = new List<ACED_Activity__c>();
            List<ACED_Programs__c> lPrograms = new List<ACED_Programs__c>();
            Set<String> sProgramUpsertIds = new Set<String>();
            for(ACED_Asset__c oAsset : lAsset){
                if(oAsset.status__c == ACED_Utility.sAssetLiveStatus){
                    //Create Programs                                           
                    ACED_Programs__c oPrograms = new ACED_Programs__c();
                        oPrograms.StandAlone_Asset_Program_TF__c = true;
                        oPrograms.Name = oAsset.HUB__c+'- Program';
                        oPrograms.HUB__c = oAsset.HUB__c;
                        oPrograms.Affiliate__c = oAsset.Affiliate__c;
                        oPrograms.StandAlone_Asset_Upsert_TF__c = oAsset.HUB__c +'-'+system.Today().year();
                        oPrograms.Year__c = String.valueOf(system.Today().year());
                        
                        //This condition is added so that mulitple programs dont get added for upsert with same value and we would get duplicate id specified error
                        if(!sProgramUpsertIds.contains(oAsset.HUB__c +'-'+system.Today().year()))
                            lPrograms.add(oPrograms);
                        sProgramUpsertIds.add(oAsset.HUB__c +'-'+system.Today().year());
                    
                    //Create Activity
                    ACED_Activity__c oActivity = new ACED_Activity__c();
                        oActivity.Activity_Name__c  = oAsset.Name+' - Asset Only Performance -'+oAsset.HUB__c+'-'+system.Today().year();
                        oActivity.Assets__c = oAsset.id;
                        ACED_Programs__c oProg = new ACED_Programs__c();
                        oProg.StandAlone_Asset_Upsert_TF__c = oAsset.HUB__c +'-'+system.Today().year();
                        oActivity.Program__r = oProg;
                        oActivity.StandAlone_Asset_Upsert__c = oAsset.Id+'-'+oAsset.HUB__c +'-'+system.Today().year();
                        oActivity.Planned_Start_Date__c = date.newInstance(system.Today().year(), 1, 1);
                        oActivity.Planned_End_Date__c = date.newInstance(system.Today().year(), 12, 31);
                        lActivityInsert.add(oActivity);
                    
                    //Create Delivery
                    ACED_Deliveries__c oDelivery = new ACED_Deliveries__c();
                        ACED_Activity__c oActivityUpsrt= new ACED_Activity__c();
                        oActivityUpsrt.StandAlone_Asset_Upsert__c = oAsset.Id+'-'+oAsset.HUB__c +'-'+system.Today().year();
                        oDelivery.StandAlone_Asset__c = oAsset.Id;
                        oDelivery.start_date__c = system.today();
                        oDelivery.end_date__c = date.newInstance(system.Today().year(), 12, 31);
                        oDelivery.Activity__r = oActivityUpsrt;
                        oDelivery.Status__c = 'Started';
                        oDelivery.StandAlone_Upsert_Attribute__c = oAsset.Id+'-'+oAsset.HUB__c +'-'+system.Today().year();
                        lDeliveries.add(oDelivery);
                }
            }
            
                Upsert lPrograms StandAlone_Asset_Upsert_TF__c;
                Upsert lActivityInsert StandAlone_Asset_Upsert__c;
                Upsert lDeliveries StandAlone_Upsert_Attribute__c; 
    
    }
    
    Public static void validateActiveChildAssets(List<ACED_Asset__c> lAsset){
        Set<Id> sRegionalAssetIds = new Set<Id>();
        Map<Id,Decimal> mRelatedAssetCount = new Map<Id,Decimal>();
        //store all regional assets to the set whose status being changed to 'Retired'
        for(ACED_Asset__c oAsset : lAsset){
            if(oAsset.Is_Regional_Asset__c && oAsset.Status__c ==ACED_Utility.RetiredStatus){
                sRegionalAssetIds.add(oAsset.Id);
            }
        }
        //
        for(Aggregateresult oRelatedAsset : [Select Count(id) Nr,Regional_Asset__c from ACED_Asset__c where Regional_Asset__c in : sRegionalAssetIds AND Status__c Not IN : ACED_Utility.retiredStatuses group by Regional_Asset__c]){
            mRelatedAssetCount.put((id)oRelatedAsset.get('Regional_Asset__c'),(Decimal)oRelatedAsset.get('Nr'));
        }
            
        for(ACED_Asset__c oAsset : lAsset){
            if(mRelatedAssetCount.containskey(oAsset.Id) && mRelatedAssetCount.get(oAsset.Id)!=null && mRelatedAssetCount.get(oAsset.Id)>0 ){
                oAsset.addError(Label.ACED_Retire_Asset_Error_Msg);
            }
        }
        
    }
    
    Public Static Void AssetIndicationsDeleteUpdateOnStandAlone(Map<Id,ACED_Asset__c> mNewAssetIndications,Map<Id,ACED_Asset__c> mOldAssetIndications){
        Set<Id> sDeleteAssetIds = new Set<Id>();
        List<ACED_Asset_Indication__c> lDeleteAssetIndication = new List<ACED_Asset_Indication__c>();
        Set<Id> sUpdateAssetIndicationIds = new Set<Id>();
        List<ACED_Asset_Indication__c> lUpdateAssetIndication = new List<ACED_Asset_Indication__c>();
        
        for(ACED_Asset__c oAsset : mNewAssetIndications.Values()){
            If(oAsset.Asset_Indications__c >0 && oAsset.No_Activities__c==false)
                sDeleteAssetIds.add(oAsset.Id);
            If(mNewAssetIndications.get(oAsset.Id).Status__c == 'Live' && mNewAssetIndications.get(oAsset.Id).Status__c != mOldAssetIndications.get(oAsset.Id).Status__c)   
                sUpdateAssetIndicationIds.add(oAsset.Id);
        }
                
        for(ACED_Asset_Indication__c oAssetIndication : [Select Id,Asset__c from ACED_Asset_Indication__c where Asset__c In : sDeleteAssetIds or Asset__c In : sUpdateAssetIndicationIds]){
            if(sDeleteAssetIds.contains(oAssetIndication.Asset__c))
                lDeleteAssetIndication.add(oAssetIndication);
            else if(sUpdateAssetIndicationIds.contains(oAssetIndication.Asset__c))  
                lUpdateAssetIndication.add(oAssetIndication);
        }
        if(lDeleteAssetIndication.size()>0)
            Delete lDeleteAssetIndication;
        if(lUpdateAssetIndication.size()>0)
            Update lUpdateAssetIndication;
        
    } 
}