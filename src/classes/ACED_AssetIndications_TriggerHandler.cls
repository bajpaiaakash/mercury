public with sharing class ACED_AssetIndications_TriggerHandler {
	Public Static void UpdateAssetIndicationsForStandAloneAssets(List<ACED_Asset_Indication__c> lAssetIndications){
		Map<Id,Map<Id,ACED_Asset_Indication__c>> mAssetIndications = new Map<Id,Map<Id,ACED_Asset_Indication__c>>();
		Map<Id,Map<Id,ACED_Delivery_Indication__c>> mDeliveryIndications = new Map<Id,Map<Id,ACED_Delivery_Indication__c>>();
		Map<Id,Id> mAssetToDelivery = new Map<Id,Id>();
				
		for(ACED_Asset_Indication__c oAssetIndi : lAssetIndications){
			if(mAssetIndications.containskey(oAssetIndi.asset__c)){
				mAssetIndications.get(oAssetIndi.asset__c).Put(oAssetIndi.Brand_Indication__c,oAssetIndi);
			}
			else{
				mAssetIndications.put(oAssetIndi.asset__c,new Map<Id,ACED_Asset_Indication__c> {oAssetIndi.Brand_Indication__c=>null});
			}
			
		}
		
		for(ACED_Deliveries__c oDelivery : [Select Id,StandAlone_Asset__c,(Select id,Brand_Indication__c from Delivery_Indications__r) from ACED_Deliveries__c where StandAlone_Asset__c IN : mAssetIndications.keyset()]){
			mDeliveryIndications.put(oDelivery.StandAlone_Asset__c,new Map<Id,ACED_Delivery_Indication__c>());
			mAssetToDelivery.put(oDelivery.StandAlone_Asset__c,oDelivery.Id);
			if(oDelivery.Delivery_Indications__r.size()>0){
				for(ACED_Delivery_Indication__c oDeliveryIndications : oDelivery.Delivery_Indications__r){
					if(mDeliveryIndications.containskey(oDelivery.StandAlone_Asset__c) && mDeliveryIndications.containskey(oDelivery.StandAlone_Asset__c)!=null)
						mDeliveryIndications.get(oDelivery.StandAlone_Asset__c).put(oDeliveryIndications.Brand_Indication__c,oDeliveryIndications);
				}
			}
		}	
		
		List<ACED_Delivery_Indication__c> lDeliveryIndications = new List<ACED_Delivery_Indication__c>();
		for(ACED_Asset_Indication__c oAssetIndication : [Select id,Asset__c,effort__c,Brand_Indication__c from ACED_Asset_Indication__c where asset__c in : mAssetIndications.keyset()] ){
			if(mDeliveryIndications.containskey(oAssetIndication.Asset__c)){ 
				ACED_Delivery_Indication__c oDeliveryIndications;
				if(mDeliveryIndications.get(oAssetIndication.Asset__c).containsKey(oAssetIndication.Brand_Indication__c))
					oDeliveryIndications = mDeliveryIndications.get(oAssetIndication.Asset__c).get(oAssetIndication.Brand_Indication__c);
				else{ 
					oDeliveryIndications = new ACED_Delivery_Indication__c();				
					oDeliveryIndications.Brand_Indication__c = oAssetIndication.Brand_Indication__c;
				}
				oDeliveryIndications.Effort__c = oAssetIndication.effort__c;
				oDeliveryIndications.Delivery__c = mAssetToDelivery.get(oAssetIndication.asset__c);
				lDeliveryIndications.add(oDeliveryIndications);
			}
		}
		
		system.debug('#####'+lDeliveryIndications);
		
		//Upsert lDeliveryIndications;
		if(!lDeliveryIndications.isempty()){
	             //Upsert lDeliveryIndications;
	             Database.UpsertResult[] lUpsertResults = Database.upsert(lDeliveryIndications,false);             
	             for(Integer i=0;i<lUpsertResults .size();i++){
	                 if (!lUpsertResults .get(i).isSuccess()){
	                    // DML operation failed
	                    lDeliveryIndications.get(i).adderror(label.ACED_ErrorMessage);//failed record from the list
	                    }
	             }
             }
		
		
	}
}