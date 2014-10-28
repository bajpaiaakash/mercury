public class UserStoryTriggerClass {
    /**
     * Creates custom AC history on user stories, as we can't do history tracking on rich text fields.
     */
    public static void createNewACHistoryRecord(Map < Id, String > mapStoryACHistory, Map < Id, String > mapStoryCCHistory) {
        List < MICO_AC_History__c > lstACHistoryRecords = new List < MICO_AC_History__c > ();
        for (Id UserStoryId: mapStoryACHistory.keySet()) {
            MICO_AC_History__c newACHistoryRecord = new MICO_AC_History__c();
            newACHistoryRecord.Acceptance_Criteria__c = mapStoryACHistory.get(UserStoryId);
            newACHistoryRecord.User_Story__c = UserStoryId;
            newACHistoryRecord.Type__c = 'Acceptance Criteria';
            lstACHistoryRecords.add(newACHistoryRecord);
        }
        for (Id UserStoryId: mapStoryCCHistory.keySet()) {
            MICO_AC_History__c newCCHistoryRecord = new MICO_AC_History__c();
            newCCHistoryRecord.Acceptance_Criteria__c = mapStoryCCHistory.get(UserStoryId);
            newCCHistoryRecord.User_Story__c = UserStoryId;
            newCCHistoryRecord.Type__c = 'Compliance Criteria';
            lstACHistoryRecords.add(newCCHistoryRecord);
        }
        if (!lstACHistoryRecords.isEmpty()) {
            insert lstACHistoryRecords;
        }
    }
    public static void createNewApprovalHistoryRecord(Map < Id, MICO_User_Story__c > mapStoryFields) {
        //List<MICO_User_Story_Approval_History__c> rec=[Select name from MICO_User_Story_Approval_History__c Limit 1];
        List < MICO_User_Story_Approval_History__c > listUSHistoryRecords = new List < MICO_User_Story_Approval_History__c > ();
        //if(rec.isEmpty()){
        for (MICO_User_Story__c userStoryObj: mapStoryFields.values()) {
            MICO_User_Story_Approval_History__c newRecord = new MICO_User_Story_Approval_History__c();
            newRecord.So_that__c = userStoryObj.So_that__c;
            newRecord.I_Want_To__c = userStoryObj.I_Want_To__c;
            newRecord.As_A_text__c = userStoryObj.As_A_text__c;
            newRecord.Approval_Status__c = userStoryObj.Approval_Status__c;
            newRecord.System_Owner__c = userStoryObj.System_Owner__c;
            newRecord.User_Story__c = userStoryObj.id;
            newRecord.Business_Quality__c = userStoryObj.Compliance_Owner__c;
            newRecord.System_Custodian__c = userStoryObj.System_Custodian__c;
            newRecord.Computer_Systems_Quality__c = userStoryObj.Computer_Systems_Quality__c;
            listUSHistoryRecords.add(newRecord);
        }
        insert listUSHistoryRecords;
    }

    /**
     * User stories should have their stakeholder fields populated. If they are left blank,
     * bring through the stakeholders from the associated MICO_App__c record
     */
    public static void populateAppStakeholders(List < MICO_User_Story__c > userStories) {
        List < MICO_User_Story__c > userStoriesWithMissingStakeholders = new List < MICO_User_Story__c > ();
        List < Id > appIds = new List < Id > ();
        // find out which stories have missing stakeholders
        for (MICO_User_Story__c story: userStories) {
            if (story.System_Custodian__c == null || story.System_Owner__c == null || story.Compliance_Owner__c == null || story.Computer_Systems_Quality__c == null) {
                userStoriesWithMissingStakeholders.add(story);
                appIds.add(story.App__c);
            }
        }
        // get the app records that contain this missing info
        Map < Id, MICO_App__c > appMap = new Map < Id, MICO_App__c > ([SELECT Id, System_Custodian__c, System_Owner__c, Business_Quality__c, Computer_Systems_Quality__c
            FROM MICO_App__c
            WHERE Id in : appIds
        ]);
        // now assign those values to the user story records
        for (MICO_User_Story__c story: userStoriesWithMissingStakeholders) {
            if (appMap.get(story.App__c) != null) {
                if (story.System_Custodian__c == null) {
                    story.System_Custodian__c = appMap.get(story.App__c).System_Custodian__c;
                }
                if (story.System_Owner__c == null) {
                    story.System_Owner__c = appMap.get(story.App__c).System_Owner__c;
                }
                if (story.Compliance_Owner__c == null) {
                    story.Compliance_Owner__c = appMap.get(story.App__c).Business_Quality__c;
                }
                if (story.Computer_Systems_Quality__c == null) {
                    story.Computer_Systems_Quality__c = appMap.get(story.App__c).Computer_Systems_Quality__c;
                }
            }
        }
    }
}