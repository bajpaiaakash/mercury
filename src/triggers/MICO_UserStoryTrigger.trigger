/****************************************************************************************************************************************** 
* Class Name   : UserStoryTrigger
* Description  : Creates AC/CC History & Updates Burndown Chart   
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/

trigger MICO_UserStoryTrigger on MICO_User_Story__c (before update, after update) 
        {
           
           Map<Id,String> mapStoryAC = new Map<Id,String>();
           Map<Id,String> mapStoryCC = new Map<Id,String>();
           
           for ( MICO_User_Story__c thisUS : trigger.new)
            {
               if(thisUS.Acceptance_Criteria__c!=trigger.oldMap.get(thisUS.id).Acceptance_Criteria__c)
               {
                   mapStoryAC.put(thisUS.id , trigger.oldMap.get(thisUS.id).Acceptance_Criteria__c);
               }
               if(thisUS.Compliance_Criteria__c!=trigger.oldMap.get(thisUS.id).Compliance_Criteria__c)
               {
                   mapStoryCC.put(thisUS.id , trigger.oldMap.get(thisUS.id).Compliance_Criteria__c);
               }
            }
            UserStoryTriggerClass.createNewACHistoryRecord(mapStoryAC,mapStoryCC);
            
            
    //autoburndown
    if(trigger.isAfter && trigger.isUpdate){
        Set<Id> affectedSprints = new Set<Id>();
        for(MICO_User_Story__c us:trigger.new){
            affectedSprints.add(us.Allocated_Sprint__c);
        }
        for(Id sprint:affectedSprints){
            automateBurnDown.updateSprintBurndown(sprint);
        }
    }
        
           
                    
}