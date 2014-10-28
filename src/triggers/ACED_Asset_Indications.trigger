/*****************************************************************************************
    Name           : ACED_Asset_Indications
    Description    : This is the trigger on asset indication object to update asset indications for stand alone assets
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description     
---------------------------------------------------------------------------
Anil SHivaraj         11/09/2014          Created
---------------------------------------------------------------------------
History Log:

******************************************************************************************/

trigger ACED_Asset_Indications on ACED_Asset_Indication__c (after insert,after update) {

    //Calling the trigger method for after update and after insert  of Asset indications record
    ACED_AssetIndications_TriggerHandler.UpdateAssetIndicationsForStandAloneAssets(trigger.new);
    
}