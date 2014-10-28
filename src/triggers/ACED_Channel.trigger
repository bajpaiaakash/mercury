/*****************************************************************************************
    Name           : ACED_Channel
    Description    : This is the trigger on Channel object to update actual and potential attributes 
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description     
---------------------------------------------------------------------------
Anil Shivaraj         27/09/2014          Created
---------------------------------------------------------------------------
History Log:

******************************************************************************************/

trigger ACED_Channel on ACED_Channel__c (before update) {
    //Calling the method for before update of channel to update actual and potential attributes
    ACED_Channel_TriggerHandler.UpdateChannelActualNPotentialAttributes(trigger.new);
}