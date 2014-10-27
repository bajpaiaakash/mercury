public class ACED_Delivery_Actuals_TriggerHandler{

    public static void DelDeliveryActualLinesOnDelivery(List<ACED_Delivery_Actuals__c> lDeliveryActuals){
        
        system.debug('#####'+lDeliveryActuals);
        list<ACED_Delivery_Actual_Line__c> lDeliveryActialLinesToBeDeleted = new list<ACED_Delivery_Actual_Line__c>();
        
        for(ACED_Delivery_Actual_Line__c oDeliveryActualLine : [SELECT ID,Delivery_Actuals__c from ACED_Delivery_Actual_Line__c where Delivery_Actuals__c  in :lDeliveryActuals]){
            lDeliveryActialLinesToBeDeleted.add(oDeliveryActualLine);
        }   
        Database.DeleteResult [] lDeleteResults = Database.Delete(lDeliveryActialLinesToBeDeleted,false); 
                 
                 for(Integer i=0;i<lDeleteResults.size();i++){
                     if (!lDeleteResults.get(i).isSuccess()){
                        // DML operation failed
                        lDeliveryActialLinesToBeDeleted[i].adderror(label.ACED_ErrorMessage);//failed record from the list
                        }
                  }
       // delete lDeliveryActialLinesToBeDeleted;
    }
    
    Public static void UpsertAggregatedAssetActuals(List<ACED_Delivery_Actuals__c> lDeliveryActuals){
        List<ACED_Asset_Actual__c> lAssetActuals = new List<ACED_Asset_Actual__c>();
        for(AggregateResult oDeliveryAggregates : [Select Sum(Value__c) MonthlySum,Month__c Month,Delivery__r.Activity__r.Assets__c AssetIds,Delivery__r.Activity__r.program__r.Year__c year from ACED_Delivery_Actuals__c where Id in :lDeliveryActuals group by Delivery__r.Activity__r.program__r.Year__c,Delivery__r.Activity__r.Assets__c,Month__c]){
            if(oDeliveryAggregates.get('AssetIds')!=null){
                ACED_Asset_Actual__c oAssetActuals = new ACED_Asset_Actual__c();
                oAssetActuals.Asset__c = (Id)oDeliveryAggregates.get('AssetIds');
                oAssetActuals.Asset_Attribute_Upsert__c = (String)oDeliveryAggregates.get('AssetIds')+'-'+(String)oDeliveryAggregates.get('year')+'-'+(String)oDeliveryAggregates.get('Month');
                oAssetActuals.Value__c = (Decimal)oDeliveryAggregates.get('MonthlySum');
                oAssetActuals.Year__c = (String)oDeliveryAggregates.get('year');
                oAssetActuals.Month__c = (String)oDeliveryAggregates.get('Month');
                lAssetActuals.add(oAssetActuals);
            }
        }
        
        if(!lAssetActuals.isempty()){
        		 Schema.SObjectField fUpsertfield = ACED_Asset_Actual__c.Asset_Attribute_Upsert__c;    
                   
                 Database.UpsertResult [] lUpsertResults = Database.upsert(lAssetActuals,fUpsertfield ,false); 
                 
                 for(Integer i=0;i<lUpsertResults .size();i++){
                     if (!lUpsertResults .get(i).isSuccess()){
                        // DML operation failed
                        lAssetActuals.get(i).adderror(label.ACED_ErrorMessage);//failed record from the list
                        }
                  }
         }
                 
 }
    
}