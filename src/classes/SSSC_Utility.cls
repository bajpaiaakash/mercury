public with sharing class SSSC_Utility {
  
  //This is the list of static variables used in various classes
  public static string actionInsert = 'Insert';
  public static string groupName = 'SafeStart Story Center';
  public static string feedBodyforInsert = 'New SafeStart Story has been created!';
  public static List<CollaborationGroup> lColGroup = new List<CollaborationGroup>();
  
  //This is a method to get Group Id for SafeStart Chatter Group
  public static List<CollaborationGroup> queryGroup(){     
    lColGroup = [SELECT id,Name from CollaborationGroup where Name=:groupName];
    return lColGroup;
  }
  
  //This code is written for creating a test user for test class
  public static User createTestUser(string permissionSetLabel){
    Profile oProfile = [select id from profile where name='GSO Basic User_Platform'];
    User oUser = new User(alias = 'Admin', email='appAdmin@testorg.com',
      emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
      localesidkey='en_US', profileid = oProfile.Id,  country='United States', CommunityNickname = 'u1',
      timezonesidkey='America/Los_Angeles', username='appAdmin@gso_org'+math.random()+'.com');
    Insert oUser;     
    
    //This code is used for assigning permission set to test user.      
    PermissionSet oPerset = [SELECT ID,Label from PermissionSet WHERE Name=:PermissionSetLabel];
    PermissionSetAssignment oPersetAssign = New PermissionSetAssignment();
    oPersetAssign.assigneeId=oUser.Id;
    oPersetAssign.PermissionSetId=oPerset.Id;
    insert oPersetAssign;   
    return oUser;
  }
  
  //This code is written for creating test SafeStartStory record
  public static List<SSSC_SafeStart_Story__c> createSafeStory(integer iCount){
    List<SSSC_SafeStart_Story__c> lSafeStory = new List<SSSC_SafeStart_Story__c>();
    for(Integer i = 0 ; i < iCount ; i++){
      SSSC_SafeStart_Story__c oSafeStory = new SSSC_SafeStart_Story__c();
      oSafeStory.Name='TestStory'+i;
      oSafeStory.Additional_Information__c='TestAddInfo'+i;                
      oSafeStory.How_could_it_have_been_worse__c='TestWorstInfo'+i;
      oSafeStory.What_CERTs_may_have_prevented_this__c='Work on habits';   
      oSafeStory.What_happened__c='TestWhatInfo'+i;
      oSafeStory.What_was_the_injury_or_close_call__c='TestInjuryInfo'+i;                
      oSafeStory.What_were_the_Errors__c='Line-of-Fire';
      oSafeStory.What_were_the_States__c='Rushing';
      oSafeStory.Where__c='Work';
      oSafeStory.Where_do_you_work__c='Admin';
      lSafeStory.add(oSafeStory);
    }  
    return lSafeStory;
  }
  
     
}