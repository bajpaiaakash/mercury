/*****************************************************************************************
    Name           : ACED_Asset_Actual
    Description    : This is the trigger on asset actual object to update asset indications with eInteraction values upon creating or updating asset actuals.
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description     
---------------------------------------------------------------------------
Anil SHivaraj         17/09/2014          Created
---------------------------------------------------------------------------
History Log:

******************************************************************************************/

trigger ACED_Asset_Actual on ACED_Asset_Actual__c (after insert, after update) {
    
    //Calling the trigger method for after update and after insert  of Asset actual record         
    ACED_Asset_Actual_TriggerHandler.UpdateAssetIndicationWithInteractionValues(Trigger.new);        
        
}