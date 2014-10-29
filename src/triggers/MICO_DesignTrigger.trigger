trigger MICO_DesignTrigger on MICO_Design__c (before insert, before update, after update)
{


if (trigger.isAfter && trigger.isUpdate)
{
      
      //custom Design history
    Map<Id,MICO_Design__c> mapDesign = new Map<Id,MICO_Design__c>();
    Map<Id,MICO_Design__c> mapApproval = new Map<Id,MICO_Design__c>();
    

    for ( MICO_Design__c thisDesign : trigger.new) 
    {
      //check for Design records that have been submitted for approval
      if(
      /*((thisDesign.Overview__c!=trigger.oldMap.get(thisDesign.id).Overview__c) 
        ||(thisDesign.Data_Model__c!=trigger.oldMap.get(thisDesign.id).Data_Model__c)
        ||(thisDesign.Data_Model__c!=trigger.oldMap.get(thisDesign.id).Data_Model__c) 
        ||(thisDesign.Fields__c!=trigger.oldMap.get(thisDesign.id).Fields__c) 
        ||(thisDesign.Objects__c!=trigger.oldMap.get(thisDesign.id).Objects__c) 
        ||(thisDesign.Other_Components__c!=trigger.oldMap.get(thisDesign.id).Other_Components__c) 
        ||(thisDesign.Apex_Classes__c!=trigger.oldMap.get(thisDesign.id).Apex_Classes__c) 
        ||(thisDesign.Apex_Trigger__c!=trigger.oldMap.get(thisDesign.id).Apex_Trigger__c))*/
        (trigger.oldMap.get(thisDesign.id).Approval_Status__c == 'Open') 
        &&(trigger.newMap.get(thisDesign.id).Approval_Status__c == 'Pending Approval' ))
      {
            mapDesign.put(thisDesign.id , trigger.oldMap.get(thisDesign.id));
      }
      
      // check for Design records that have been Approved
      if((trigger.newMap.get(thisDesign.id).Approval_Status__c == 'Approved') && (trigger.oldMap.get(thisDesign.id).Approval_Status__c == 'Pending Approval'))
      {
            mapApproval.put(thisDesign.id , trigger.oldMap.get(thisDesign.id));
      }
    } 
    
    MICO_DesignTriggerClass.createNewDesignHistoryRecord(mapDesign);
    MICO_DesignTriggerClass.updateApprovalDate(mapApproval, System.now());
}
}