/*****************************************************************************************
    Name           : ACED_Asset
    Description    : This is the trigger on Asset object to update Standalone checkbox to true upon inserting Assets. 
                     This trigger also deletes asset indications upon associating Non program asset to an activity
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description     
---------------------------------------------------------------------------
Anil SHivaraj         09/09/2014          Created
---------------------------------------------------------------------------
History Log:

******************************************************************************************/

trigger ACED_Asset on ACED_Asset__c (before insert, before update,after update,after insert) {
    
    If(Trigger.IsBefore){    
       if(Trigger.IsInsert){
            //Calling the method for before insert  of Asset record to check standalone checkbox to true 
            ACED_Asset_TriggerHandler.UpdateStandAloneCheckboxOnInsert(trigger.new);
        }
        else{
            ACED_Asset_TriggerHandler.CheckIfStandAloneAsset(trigger.new);
            ACED_Asset_TriggerHandler.validateActiveChildAssets(Trigger.New);
        }
    }
    If(Trigger.Isafter){
        if(Trigger.IsUpdate)
            //Calling the method for after update of Asset record to delete asset indications upon associating Non program asset to an activity 
            ACED_Asset_TriggerHandler.AssetIndicationsDeleteUpdateOnStandAlone(trigger.newMap,trigger.Oldmap);
        If(Trigger.IsInsert)
            ACED_Asset_TriggerHandler.createStandAloneAsset(trigger.new);
    }   
                   
        
}