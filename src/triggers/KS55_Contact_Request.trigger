trigger KS55_Contact_Request on KS55_Contact_Request__c (before insert, before update) {

  if(trigger.isBefore){
    if(trigger.isInsert || trigger.isUpdate){
      KS55_Contact_Request_TriggerHandler.assignApprovalSettings(trigger.new);
    } 
  }

}