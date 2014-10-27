/*****************************************************************************************
    Name           : ACED_Activities
    Description    : This is the trigger on activity object to update channel value on Activity record and Rollup Actual costs and eInteractions values to the Asset
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description     
---------------------------------------------------------------------------
Goutham              01/09/2014          Created
---------------------------------------------------------------------------
History Log:
Venugopal            12/09/2014          IsAfter logic was added to rollup Actual costs and eInteractions to Assets 
******************************************************************************************/

//Trigger on activity object before inserting, updating as well as after inserting, updating, deleting and undeleting the activity records.
trigger ACED_Activities on ACED_Activity__c (before Insert, before Update,after insert,after update, after Delete, after undelete) {

    //Calling the trigger functionality for isAfter functionality
    If(Trigger.IsAfter ){
    
        //Calling the trigger method for After delete of Activity record
        if(Trigger.Isdelete)
            ACED_Activities_TriggerHandler.UpdateActualCostonAsset(trigger.oldmap,trigger.oldmap);

        //Calling the trigger method for After update, After insert and after undelete of Activity record            
        else {
            if(ACED_Asset_TriggerHandler.bRecursiveCheck)
                ACED_Activities_TriggerHandler.UpdateActualCostonAsset(trigger.oldmap,trigger.newmap);
            
        }    
    }
    
    //Calling the trigger functionality for isBefore functionality    
    If(Trigger.IsBefore){
        //Calling the trigger method for Before update and Before insert  of Activity record
        ACED_Activities_TriggerHandler.updateActivity(trigger.new);
    }   
}