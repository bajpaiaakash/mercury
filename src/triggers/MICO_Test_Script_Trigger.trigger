trigger MICO_Test_Script_Trigger on MICO_Test_Templates__c (after update, before insert) {
    
if (trigger.isAfter && trigger.isUpdate){
      
      //Create/Update custom Test Script History records
      Map<Id,MICO_Test_Templates__c> mapTestScript = new Map<Id,MICO_Test_Templates__c>();
      Map<Id,MICO_Test_Templates__c> mapApproval = new Map<Id,MICO_Test_Templates__c>();
      Map<Id,MICO_Test_Templates__c> mapRejection = new Map<Id,MICO_Test_Templates__c>();
      Set < Id > affectedSprints = new Set < Id > ();
            
      
    for (MICO_Test_Templates__c thisTestScript : trigger.new){
        //check for Test Script records that have been submitted for approval
          if ((trigger.oldMap.get(thisTestScript.id).Approval_Status__c != 'Pending Approval' && thisTestScript.Approval_Status__c == 'Pending Approval')) {
              mapTestScript.put(thisTestScript.id , trigger.newMap.get(thisTestScript.id));
          }
        
        // check for Test Script records that have been Approved
        if((trigger.newMap.get(thisTestScript.id).Approval_Status__c == 'Approved')
          &&(trigger.oldMap.get(thisTestScript.id).Approval_Status__c == 'Pending Approval')){
                mapApproval.put(thisTestScript.id , trigger.newMap.get(thisTestScript.id));
        }
        
        // check for Test Script records that have been Rejected
        if((trigger.newMap.get(thisTestScript.id).Approval_Status__c == 'Rejected' || trigger.newMap.get(thisTestScript.id).Approval_Status__c == 'Open'  ) 
          &&(trigger.oldMap.get(thisTestScript.id).Approval_Status__c == 'Pending Approval')){
                mapRejection.put(thisTestScript.id , trigger.newMap.get(thisTestScript.id));
        }
        
        MICO_User_Story__c userStory = [select Allocated_Sprint__c from MICO_User_Story__c where id =: thisTestScript.User_Story__c limit 1];
        
        affectedSprints.add(userStory.Allocated_Sprint__c);
        } 
      
      MICO_Test_ScriptTriggerClass.createNewTestScriptHistoryRecord(mapTestScript);
      MICO_Test_ScriptTriggerClass.updateApprovalDate(mapApproval, System.now());
      MICO_Test_ScriptTriggerClass.updateRejectionStatus(mapRejection);
      
     
      for (Id sprint: affectedSprints) {
            automateBurnDown.updateTestScriptSprintBurndown(sprint);
        }
     
}
}