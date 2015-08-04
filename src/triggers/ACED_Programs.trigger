/*****************************************************************************************
    Name    : ACED_Programs
    Desc    : This is the trigger to update Indication Details field  Program record upon adding Brand Indications
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description     
---------------------------------------------------------------------------
Goutham              09/25/2014          Created
---------------------------------------------------------------------------
History Log:
******************************************************************************************/
trigger ACED_Programs on ACED_Programs__c (before Update) {
    
    If(Trigger.IsBefore && Trigger.IsUpdate){
        //Calling the trigger method for before update of program to update Indication Details field  Program record upon adding Brand Indications
        ACED_Programs_TriggerHandler.updateIndicationDetails(trigger.new);            
    }
          
}