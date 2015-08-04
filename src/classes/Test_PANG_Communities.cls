/****************************************************************************************************************************************** 
* Class Name   : Test_PANG_Communities
* Description  : Test Class for PANG_Communities 
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/

@isTest(SeeAllData=false)

public class Test_PANG_Communities {

    /* 
    * @Method Name                    :  test_main
    * @Description                    :  Testing of Creating a Account for Communities and User accessing the Community
    * @Return Type                    :  void
    * @Parameters                     :  None
    */   

  @isTest
  static void test_main(){
     
        User u = PANG_TestFactory.getTestingUser();
        String PSetName = 'PANG_RWE_Partnership_Manager';
        PANG_TestFactory.givePermissions(u.id, PSetName);
        system.runAs(u) {
        Id p = [select id from profile where name='Partner Community User'].id;
        
        RecordType rt = [select id,DeveloperName from RecordType where SobjectType='Account' and DeveloperName='PANG_RWE_Account' Limit 1];
        Account ac = new Account(Name='Test',RWE_Partner_Welcome_Description__c='Test',RWE_Logo_URL__c='www.google.com',recordTypeId=rt.id);
        insert ac;  
       
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
              
        
        String uname = System.now().millisecond() + 'test12345@test.com';
        User comUser = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username=uname);
        insert comUser;

        system.runAs(comUser) {
         Test.startTest();      
           
          ApexPages.StandardController stdController = new ApexPages.StandardController(ac);
          PANG_Communities controller = new PANG_Communities (stdController);
          
          //System assert to check
          system.assertEquals(Controller.a.RWE_Partner_Welcome_Description__c,ac.RWE_Partner_Welcome_Description__c);
          system.assertEquals(Controller.a.RWE_Logo_URL__c,ac.RWE_Logo_URL__c);
          
          Test.stopTest();
         }
      
    }
    }
  }