/*****************************************************************************************
    Name           : PANG_Requests
    Description    : This trigger is to copy Molecules from Study and insert them as Request Molecules
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description     
---------------------------------------------------------------------------
  Goutham         18/03/2015          Created
---------------------------------------------------------------------------
History Log:

******************************************************************************************/
trigger PANG_Requests on PANG_Request__c(after insert, before Insert) {

    if (Trigger.isAfter) {
        If(Trigger.isInsert) {
            //Calling the trigger method for  after insert  of Requests record to copy Molecules from parent Study and insert them as Request Molecules
            PANG_Request_TriggerHandler.insertRequestMoleculesFromStudy(Trigger.New);
        }
    }
    
    if (Trigger.isBefore) {
        If(Trigger.isInsert) {
            //Calling the trigger method for  before insert  of Requests record to copy Region field from parent Study 
            PANG_Request_TriggerHandler.UpdateRequestRegion(Trigger.New);
        }
    }
}