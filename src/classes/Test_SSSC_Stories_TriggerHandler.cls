@isTest (SeeAllData = false)
public class Test_SSSC_Stories_TriggerHandler {

    Static testMethod void testNewStory() {  
    User runAsUser = SSSC_Utility.createTestUser('SSSC_App_Admin');
    List<SSSC_SafeStart_Story__c> lStoryInsert = new List<SSSC_SafeStart_Story__c>();
    System.runAs(runAsUser) {        
      Test.startTest();
        lStoryInsert = SSSC_Utility.createSafeStory(100);
          insert lStoryInsert;
          System.assert(lStoryInsert.size()>0);  
          Delete lStoryInsert.remove(0);                       
      Test.stopTest();
    } 
  }

}