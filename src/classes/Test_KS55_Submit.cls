/****************************************************************************************************************************************** 
 * Class Name   : Test_KS55_Submit
 * Description  : test Class for KS55_ContactRequestNew
 * Created By   : Deloitte Consulting
 *
 *****************************************************************************************************************************************/
@istest(SeeAllData = false)
public class Test_KS55_Submit {
   static testmethod void Submit() {
      User runAsUser = KS55_Utility.createTestUser('KS55_App_Admin');
      List < KS55_Account_Request__c > lactrequest = new List < KS55_Account_Request__c > ();
      List < KS55_Contact_Request__c > lconrequest = new List < KS55_Contact_Request__c > ();
      List < Attachment > lattachments = new List < Attachment > ();
      System.runAs(runAsUser) {
         Test.startTest();
         lactrequest = KS55_Utility.createactrequest(1);
         insert lactrequest;
         System.assert(lactrequest.size() > 0);
         for (KS55_Account_Request__c oaccreq: lactrequest) {
            lattachments = KS55_Utility.createattachments(100, oaccreq.Id);
         }
         insert lattachments;
         System.assert(lattachments.size() > 0);
         for (KS55_Account_Request__c oaccreq: lactrequest) {
            lconrequest = KS55_Utility.createcontactrequest(1, oaccreq);
         }
         insert lconrequest;
         System.assert(lconrequest.size() > 0);
         List < KS55_Contact_Request__c > condbObj = [Select Account_Name__c,Account_Name__r.Signed_Documentation_In_Place__c, Account_Name__r.Documentation_Date_Expire__c,
            Account_Name__r.Documentation_Date_Signed__c, Status__c from KS55_Contact_Request__c where Id = : lconrequest[0].Id];
         KS55_Submit con = new KS55_Submit(new ApexPages.standardcontroller(condbObj[0]));
         con.submitforApproval();
         con.submitforApproval();
         Test.stopTest();
      }
   }
   static testmethod void SubmitNull() {
      User runAsUser = KS55_Utility.createTestUser('KS55_App_Admin');
      List < KS55_Account_Request__c > lactrequest = new List < KS55_Account_Request__c > ();
      List < KS55_Contact_Request__c > lconrequest = new List < KS55_Contact_Request__c > ();
      List < Attachment > lattachments = new List < Attachment > ();
      System.runAs(runAsUser) {
         Test.startTest();
         lactrequest = KS55_Utility.createactrequest(1);
         insert lactrequest;
         System.assert(lactrequest.size() > 0);
         for (KS55_Account_Request__c oaccreq: lactrequest) {
            lconrequest = KS55_Utility.createcontactrequest(1, oaccreq);
         }
         lconrequest[0].Status__c = 'Completed';     
         insert lconrequest;
         System.assert(lconrequest.size() > 0);
         
         List < KS55_Contact_Request__c > condbObj = [Select Account_Name__c,Account_Name__r.Signed_Documentation_In_Place__c, Account_Name__r.name, Account_Name__r.Documentation_Date_Expire__c,
            Account_Name__r.Documentation_Date_Signed__c, Status__c from KS55_Contact_Request__c where Id = : lconrequest[0].Id];
         KS55_Submit con = new KS55_Submit(new ApexPages.standardcontroller(condbObj[0]));
         con.submitforApproval();
         Test.stopTest();
      }
   }
}