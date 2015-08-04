/****************************************************************************************************************************************** 
 * Class Name   : KS55_Utility
 * Description  : Utility class for KS55 project for test classes
 * Created By   : Deloitte Consulting
 *
 *****************************************************************************************************************************************/
public with sharing class KS55_Utility {

   Public static final string ContactStatusComplete = 'Completed';

   //This code is written for creating a test user for test class
   public static User createTestUser(string permissionSetLabel) {
      Profile oProfile = [select id from profile where name = 'GSO Basic User_Platform'];
      User oUser = new User(alias = 'Admin', email = 'appAdmin@testorg.com',
         emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
         localesidkey = 'en_US', profileid = oProfile.Id, country = 'United States', CommunityNickname = 'u1',
         timezonesidkey = 'America/Los_Angeles', username = 'appAdmin@gso_org' + math.random() + '.com');
      Insert oUser;
      //This code is used for assigning permission set to test user.      
      PermissionSet oPerset = [SELECT ID, Label from PermissionSet WHERE Name = : PermissionSetLabel];
      PermissionSetAssignment oPersetAssign = New PermissionSetAssignment();
      oPersetAssign.assigneeId = oUser.Id;
      oPersetAssign.PermissionSetId = oPerset.Id;
      insert oPersetAssign;
      return oUser;
   }

   //This code is written for creating test Account Request record
   public static List < KS55_Account_Request__c > createactrequest(integer iCount) {
      List < KS55_Account_Request__c > lactrequest = new List < KS55_Account_Request__c > ();
      for (Integer i = 0; i < iCount; i++) {
         KS55_Account_Request__c oactrequest = new KS55_Account_Request__c();
         oactrequest.Name = 'Testaccountrequest' + i;
         oactrequest.Hub__c = 'LA';
         oactrequest.Business_Unit__c = 'Dairy';
         oactrequest.Currency_Type__c = 'Euro';
         oactrequest.Weight_Units__c = 'kg';
         oactrequest.Signed_Documentation_In_Place__c = 'yes';
         oactrequest.Documentation_Date_Signed__c = system.today();
         oactrequest.Documentation_Date_Expire__c = system.today() + 150;
         lactrequest.add(oactrequest);
      }
      return lactrequest;
   }

   //This code is written for creating test Contact Request record
   public static List < KS55_Contact_Request__c > createcontactrequest(integer iCount, KS55_Account_Request__c oaccreq) {
      List < KS55_Contact_Request__c > lcontactrequest = new List < KS55_Contact_Request__c > ();
      for (Integer i = 0; i < iCount; i++) {
         KS55_Contact_Request__c ocontactrequest = new KS55_Contact_Request__c();
         ocontactrequest.Name = 'Testcontactrequest' + i;
         ocontactrequest.Contact_To_Have_Access_Email_Address__c = 'test@test.com';
         ocontactrequest.Contact_To_Have_Access_Role__c = 'External';
         ocontactrequest.Contact_To_Have_Access_Tool__c = 'Feed Decision System';
         ocontactrequest.Business_Units__c = 'Dairy';
         ocontactrequest.Account_Name__c = oaccreq.Id;
         ocontactrequest.Status__c = 'Open';
         ocontactrequest.System_Using_Custom_Approval__c = true;
         lcontactrequest.add(ocontactrequest);
      }
      return lcontactrequest;
   }

   //This code is written for creating test Updating Request record
   public static List < KS55_Contact_Request__c > updatecontactrequest(List < KS55_Contact_Request__c > lconreq) {
      List < KS55_Contact_Request__c > lcontactrequest = new List < KS55_Contact_Request__c > ();
      for (KS55_Contact_Request__c ocontactrequest: lconreq) {
         ocontactrequest.Name = 'Testcontactrequest';
         ocontactrequest.Contact_To_Have_Access_Email_Address__c = 'test1@test.com';
         ocontactrequest.Contact_To_Have_Access_Role__c = 'External';
         ocontactrequest.Contact_To_Have_Access_Tool__c = 'Feed Decision System';
         ocontactrequest.Business_Units__c = 'Dairy';
         ocontactrequest.Status__c = 'Approved';
         ocontactrequest.System_Using_Custom_Approval__c = true;
         lcontactrequest.add(ocontactrequest);
      }
      return lcontactrequest;
   }

   //This code is written for creating test Approval Settings  Request record
   public static List < KS55_Approval_Setting__c > createapprovalsettings(User approver) {
      List < KS55_Approval_Setting__c > lapprovalsettings = new List < KS55_Approval_Setting__c > ();
      KS55_Approval_Setting__c oapprovalsettings = new KS55_Approval_Setting__c();
      oapprovalsettings.Business_Unit__c = 'Dairy';
      oapprovalsettings.Hub__c = 'LA';
      oapprovalsettings.Approver__c = approver.Id;
      oapprovalsettings.Operations__c = approver.Id;
      lapprovalsettings.add(oapprovalsettings);
      return lapprovalsettings;
   }

   public static List < Attachment > createattachments(Integer iCount, Id ParentId) {
      List < Attachment > lattachment = new List < Attachment > ();
      for (Integer i = 0; i < iCount; i++) {
         Attachment oAttachment = new Attachment();
         oAttachment.ParentId = ParentId;
         oAttachment.Name = 'TestAttachment';
         oAttachment.Body = Blob.valueOf('TestData');
         lattachment.add(oAttachment);
      }
      return lattachment;
   }

}