/****************************************************************************************************************************************** 
 * Class Name   : Test_KS55_ContactRequestNew
 * Description  : test Class for Test_KS55_ContactRequestNew
 * Created By   : Deloitte Consulting
 *
 *****************************************************************************************************************************************/
@istest(SeeAllData = false)
public class Test_KS55_ContactRequestNew {

   static testmethod void ContactRequestNewNull() {
      User runAsUser = KS55_Utility.createTestUser('KS55_App_Admin');
      System.runAs(runAsUser) {
         Test.startTest();
         list < KS55_Account_Request__c > laccObj = KS55_Utility.createactrequest(1);
         insert laccObj;
         list < KS55_Contact_Request__c > lconObj = KS55_Utility.createcontactrequest(1, laccObj[0]);
         insert lconObj;
         KS55_ContactRequestNew Controller = new KS55_ContactRequestNew(new ApexPages.standardController(lconObj[0]));
         Pagereference prSaveandNew = controller.SaveandNew();
         controller.cancel();
         controller.SelectAccount();
         system.assertEquals(prSaveandNew.geturl(), '/apex/ks55_contactrequestnew');
         Test.stopTest();
      }
   }

   //Test method to test error message if user is editing a submitted contact request
   static testmethod void SubmittedContactRequestEdit() {
      User runAsUser = KS55_Utility.createTestUser('KS55_App_Admin');
      System.runAs(runAsUser) {
         Test.startTest();
         list < KS55_Account_Request__c > laccObj = KS55_Utility.createactrequest(1);
         insert laccObj;
         list < KS55_Contact_Request__c > lconObj = KS55_Utility.createcontactrequest(1, laccObj[0]);
         lconObj[0].Submitted_TF__c = True;
         insert lconObj;
         apexpages.currentpage().getParameters().put('id', lconObj[0].id);
         KS55_ContactRequestNew Controller = new KS55_ContactRequestNew(new ApexPages.standardController(lconObj[0]));
         controller.contReq = lconObj[0];
         Test.stopTest();
      }
   }

   //Test method to test error message if user is editing a completed contact request
   static testmethod void CompletedContactRequestEdit() {
      User runAsUser = KS55_Utility.createTestUser('KS55_App_Admin');
      System.runAs(runAsUser) {
         Test.startTest();
         list < KS55_Account_Request__c > laccObj = KS55_Utility.createactrequest(1);
         insert laccObj;
         list < KS55_Contact_Request__c > lconObj = KS55_Utility.createcontactrequest(1, laccObj[0]);
         lconObj[0].status__c = 'Completed';
         insert lconObj;
         apexpages.currentpage().getParameters().put('id', lconObj[0].id);
         KS55_ContactRequestNew Controller = new KS55_ContactRequestNew(new ApexPages.standardController(lconObj[0]));
         controller.contReq = lconObj[0];
         Test.stopTest();
      }
   }

   static testmethod void ContactRequestNew() {
      User runAsUser = KS55_Utility.createTestUser('KS55_App_Admin');
      System.runAs(runAsUser) {
         Test.startTest();
         list < KS55_Account_Request__c > laccObj = KS55_Utility.createactrequest(1);
         insert laccObj;
         List < Attachment > lAttachments = KS55_Utility.createattachments(1, laccObj[0].id);
         insert lAttachments;
         list < KS55_Contact_Request__c > lconObj = KS55_Utility.createcontactrequest(1, laccObj[0]);
         insert lconObj;
         KS55_ContactRequestNew Controller = new KS55_ContactRequestNew(new ApexPages.standardController(lconObj[0]));
         controller.contReq = lconObj[0];
         Pagereference prSaveandNew = controller.SaveandNew();
         controller.retUrl = '/' + lconObj[0].Id;
         controller.cancel();
         controller.SelectAccount();
         system.assertEquals(prSaveandNew.getUrl(), '/apex/ks55_contactrequestnew');
         Test.stopTest();
      }

   }

   static testmethod void ContactRequestSaveandNew() {

      User runAsUser = KS55_Utility.createTestUser('KS55_App_Admin');
      System.runAs(runAsUser) {
         Test.startTest();
         list < KS55_Account_Request__c > laccObj = KS55_Utility.createactrequest(1);
         insert laccObj;
         List < Attachment > lAttachments = KS55_Utility.createattachments(1, laccObj[0].id);
         insert lAttachments;
         list < KS55_Contact_Request__c > lconObj = KS55_Utility.createcontactrequest(1, laccObj[0]);
         KS55_ContactRequestNew Controller = new KS55_ContactRequestNew(new ApexPages.standardController(lconObj[0]));
         controller.contReq = lconObj[0];
         Pagereference prSave = controller.SaveandNew();
         controller.retUrl = '/' + lconObj[0].Id;
         apexpages.currentPage().getparameters().put('retUrl', controller.retUrl);
         controller.cancel();
         controller.SelectAccount();
         system.assertNotEquals(prSave.getUrl(), null);
         Test.stopTest();
      }
   }

   //Test method to validate delete
   static testmethod void ValidateDelete() {
      User runAsUser = KS55_Utility.createTestUser('KS55_App_Admin');
      System.runAs(runAsUser) {
         Test.startTest();
         list < KS55_Account_Request__c > laccObj = KS55_Utility.createactrequest(1);
         insert laccObj;
         List < Attachment > lAttachments = KS55_Utility.createattachments(1, laccObj[0].id);
         insert lAttachments;
         list < KS55_Contact_Request__c > lconObj = KS55_Utility.createcontactrequest(1, laccObj[0]);
         insert lconObj[0];
         lconObj[0].Submitted_TF__c = True;
         Update lconObj[0];
         KS55_ContactRequestNew Controller = new KS55_ContactRequestNew(new ApexPages.standardController(lconObj[0]));
         controller.contReq = lconObj[0];
         ApexPages.currentPage().getParameters().put('delID', lconObj[0].id);
         Pagereference prSave = controller.validateDelete();
         lconObj[0].Submitted_TF__c = False;
         Update lconObj[0];
         prSave = controller.validateDelete();
         Test.stopTest();
      }
   }
  
}