/*****************************************************************************************
    Name           : ACED_Deliveries
    Description    : This is the trigger on Delivery object to update asset indications for stand alone assets. 
                     This trigger also inserts delivery indications from grandparent program record and update einteraction values
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description     
---------------------------------------------------------------------------
Anil SHivaraj         11/09/2014          Created
---------------------------------------------------------------------------
History Log:

******************************************************************************************/
trigger ACED_Deliveries on ACED_Deliveries__c (after insert, after update, after delete, after undelete,before update,before insert) {

    if(Trigger.isAfter){
        If(Trigger.isInsert){
        
            //Calling the trigger method for  after insert  of Deliveries record to copy Brand Indications from Grandparent Program Indications and insert them as delivery indications
            ACED_Deliveries_TriggerHandler.InsertDeliveryIndications(Trigger.New);
                  
        }
        If(Trigger.isUpdate){
            
            //Calling the trigger method for after update of Deliveries record to upsert delivery indication actuals
            ACED_Deliveries_TriggerHandler.UpsertDeliveryIndicationActuals(Trigger.New);
             
        }        
    }
    
    if(Trigger.isBefore){
    
      //Calling the trigger method for before updating and inserting of Deliveries record to calculate planned einteraction values
      ACED_Deliveries_TriggerHandler.CalculatePlannedInteractions(Trigger.New);
      
    }
}