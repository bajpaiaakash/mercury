@isTest (SeeAllData = false)
public class Test_SSSC_NewStoryOverride_Extension {

    Static testMethod void testNewStory() {  
    User runAsUser = SSSC_Utility.createTestUser('SSSC_App_Admin');
    System.runAs(runAsUser) {        
      Test.startTest();
        //Declaring the instance of class and calling the method
        SSSC_NewStoryOverride_Extension newClass = New SSSC_NewStoryOverride_Extension(New ApexPages.StandardController(New SSSC_SafeStart_Story__c()));     
        Integer iOne = newClass.getStoryRedirect();     
        system.assertEquals(iOne,0);   
        newClass.getthrowError();
      Test.stopTest();
     } 
   }
   Static testMethod void testNewStory1() {  
    User runAsUser = SSSC_Utility.createTestUser('SSSC_App_Admin');
    System.runAs(runAsUser) {        
      Test.startTest();
        //Declaring the instance of class and calling the method
        SSSC_NewStoryOverride_Extension newClass = New SSSC_NewStoryOverride_Extension(New ApexPages.StandardController(New SSSC_SafeStart_Story__c()));   
        apexpages.currentpage().getParameters().put('retURL', 'projectone');  
        Integer iOne = newClass.getStoryRedirect();
        system.assertEquals(iOne,null);   
        newClass.getthrowError();                                  
      Test.stopTest();
    } 
  }

}