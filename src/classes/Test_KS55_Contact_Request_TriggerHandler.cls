/****************************************************************************************************************************************** 
 * Class Name   : Test_KS55_Contact_Request_TriggerHandler
 * Description  : test Class for KS55_Contact_Request_TriggerHandler
 * Created By   : Deloitte Consulting
 *
 *****************************************************************************************************************************************/
@istest(SeeAllData = false)
public with sharing class Test_KS55_Contact_Request_TriggerHandler {
   static testmethod void ContactMaptoSettings() {
      User runAsUser = KS55_Utility.createTestUser('KS55_App_Admin');
      List < KS55_Account_Request__c > lactrequest = new List < KS55_Account_Request__c > ();
      List < KS55_Contact_Request__c > lconrequest = new List < KS55_Contact_Request__c > ();
      List < KS55_Approval_Setting__c > lappsettings = new List < KS55_Approval_Setting__c > ();
      System.runAs(runAsUser) {
         Test.startTest();
         lactrequest = KS55_Utility.createactrequest(100);
         insert lactrequest;
         System.assert(lactrequest.size() > 0);
         lappsettings = KS55_Utility.createapprovalsettings(runAsUser);
         insert lappsettings;
         System.assert(lappsettings.size() > 0);
         for (KS55_Account_Request__c oaccreq: lactrequest) {
            lconrequest = KS55_Utility.createcontactrequest(100, oaccreq);
         }
         insert lconrequest;
         System.assert(lconrequest.size() > 0);
         if (lconrequest.size() > 0) {
            lconrequest = KS55_Utility.updatecontactrequest(lconrequest);
            update lconrequest;
         }
         Delete lconrequest;
         System.assert(lconrequest.size() > 0);
         Test.stopTest();
      }
   }
  
}