public class UserStoryTriggerClass{ 

       public static void createNewACHistoryRecord(Map<Id,String> mapStoryACHistory, Map<Id,String> mapStoryCCHistory)
        {
         List<MICO_AC_History__c> lstACHistoryRecords = new List<MICO_AC_History__c>();
        
         for(Id UserStoryId : mapStoryACHistory.keySet())
           {
               MICO_AC_History__c newACHistoryRecord = new MICO_AC_History__c();
               newACHistoryRecord.Acceptance_Criteria__c = mapStoryACHistory.get(UserStoryId);
               newACHistoryRecord.User_Story__c          = UserStoryId;
               newACHistoryRecord.Type__c                = 'Acceptance Criteria';
               lstACHistoryRecords.add(newACHistoryRecord);
            }
          for(Id UserStoryId : mapStoryCCHistory.keySet())
           {
               MICO_AC_History__c newCCHistoryRecord = new MICO_AC_History__c();
               newCCHistoryRecord.Acceptance_Criteria__c = mapStoryCCHistory.get(UserStoryId);
               newCCHistoryRecord.User_Story__c          = UserStoryId;
               newCCHistoryRecord.Type__c                = 'Compliance Criteria';
               lstACHistoryRecords.add(newCCHistoryRecord);
            }
            if (!lstACHistoryRecords.isEmpty())
            {
              insert lstACHistoryRecords;
            }
        }
            
        
        

}