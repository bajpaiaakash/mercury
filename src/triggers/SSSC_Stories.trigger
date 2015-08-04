trigger SSSC_Stories on SSSC_SafeStart_Story__c (after insert) {
  
  if(trigger.isAfter){
    if(trigger.isInsert){
      SSSC_Stories_TriggerHandler.newFeed(trigger.new,'Insert');
    } 
    
  }

}