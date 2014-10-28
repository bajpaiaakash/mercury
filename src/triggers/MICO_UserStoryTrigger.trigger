trigger MICO_UserStoryTrigger on MICO_User_Story__c(before insert, before update, after update) {
    if (trigger.isBefore && trigger.isInsert) {
        UserStoryTriggerClass.populateAppStakeholders(trigger.new);
    }
    if (trigger.isAfter && trigger.isUpdate) {
        //custom AC history
        Map < Id, String > mapStoryAC = new Map < Id, String > ();
        Map < Id, String > mapStoryCC = new Map < Id, String > ();
        Map < Id, MICO_User_Story__c > mapStoryInsertFields = new Map < Id, MICO_User_Story__c > ();
        Map < Id, MICO_User_Story__c > mapStoryUpdateFields = new Map < Id, MICO_User_Story__c > ();
        Map < Id, MICO_User_Story__c > mapTimeStampFields = new Map < Id, MICO_User_Story__c > ();
        for (MICO_User_Story__c thisUS: trigger.new) {
            if (thisUS.Acceptance_Criteria__c != trigger.oldMap.get(thisUS.id).Acceptance_Criteria__c) {
                mapStoryAC.put(thisUS.id, trigger.oldMap.get(thisUS.id).Acceptance_Criteria__c);
            }
            if (thisUS.Compliance_Criteria__c != trigger.oldMap.get(thisUS.id).Compliance_Criteria__c) {
                mapStoryCC.put(thisUS.id, trigger.oldMap.get(thisUS.id).Compliance_Criteria__c);
            }
            if ((trigger.oldMap.get(thisUS.id).Approval_Status__c != 'Pending Approval' && thisUS.Approval_Status__c == 'Pending Approval')) {
                mapStoryInsertFields.put(thisUS.id, thisUS);
            }
            if ((thisUS.Approval_Status__c != trigger.oldMap.get(thisUS.id).Approval_Status__c && trigger.oldMap.get(thisUS.id).Approval_Status__c == 'Pending Approval' && (thisUS.Approval_Status__c == 'Approved' || thisUS.Approval_Status__c == 'Rejected'))) {
                mapStoryUpdateFields.put(thisUS.id, thisUS);
            }
        }
        if (!mapStoryInsertFields.isEmpty()) {
            UserStoryTriggerClass.createNewApprovalHistoryRecord(mapStoryInsertFields);
        }
        UserStoryTriggerClass.createNewACHistoryRecord(mapStoryAC, mapStoryCC);
        //autoburndown
        Set < Id > affectedSprints = new Set < Id > ();
        for (MICO_User_Story__c us: trigger.new) {
            affectedSprints.add(us.Allocated_Sprint__c);
        }
        for (Id sprint: affectedSprints) {
            automateBurnDown.updateSprintBurndown(sprint);
        }
    }
}