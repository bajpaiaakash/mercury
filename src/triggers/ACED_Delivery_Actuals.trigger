/*****************************************************************************************
    Name           : ACED_Channel
    Description    : This is the trigger on Delivery actuals object to upsert aggregated asset actuals.
                      This trigger also deletes delivery actual lines upon deletion of corresponding delivery actuals 
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description     
---------------------------------------------------------------------------
Goutham Ramireddy    05/09/2014          Created
---------------------------------------------------------------------------
History Log:

******************************************************************************************/

trigger ACED_Delivery_Actuals on ACED_Delivery_Actuals__c (Before delete,after insert,after update) {
    if(Trigger.IsAfter){
        if(Trigger.isInsert|| Trigger.isUpdate){
            //Calling the method for after updating or inserting  of delivery actual to Upsert Aggregated Asset Actuals
            ACED_Delivery_Actuals_TriggerHandler.UpsertAggregatedAssetActuals(trigger.new); 
        }      
    }
    if(Trigger.IsBefore && Trigger.isdelete){
        //Calling the method to delete delivery actual lines upon deletion of corresponding delivery actuals
        ACED_Delivery_Actuals_TriggerHandler.DelDeliveryActualLinesOnDelivery(trigger.old); 
        
        //Calling the method to update aggregate asset actuals upon deleting corresponding of corresponding delivery actuals
        ACED_Delivery_Actuals_TriggerHandler.DeleteAssetActualsonAsset(trigger.old); 
        
        //Method is called to delete related delivery indication actuals when delivery actual is deleted
        ACED_Delivery_Actuals_TriggerHandler.DeleteDeliveryIndicationActual(trigger.old); 
    }       
}