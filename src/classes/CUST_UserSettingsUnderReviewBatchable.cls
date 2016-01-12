/**
  @author: Aakash Bajpai
   @Created Date: 07-Dec-2015
  @Description: For Updating the Access status to 'Under review' for CST User settings object.
*/
global class CUST_UserSettingsUnderReviewBatchable implements Database.Batchable<sObject> {

  String query;
  Date dt = Date.Today();
  String sdt = string.valueof(dt);

  global CUST_UserSettingsUnderReviewBatchable() 
  {
      query = 'SELECT Id, Access_Status_CUST__c,CST_User_CUST__r.CST_Approver_ID_GLBL__c,Audit_Date_CUST__c FROM CST_User_Settings_CUST__c WHERE Access_Status_CUST__c = \'Approved\' AND Audit_Date_CUST__c <='+sdt;
  }

  global Database.QueryLocator start(Database.BatchableContext BC) 
  {
    return Database.getQueryLocator(query);
  }

    global void execute(Database.BatchableContext BC, List<CST_User_Settings_CUST__c> userSettings) {
        for (CST_User_Settings_CUST__c userSetting : userSettings){
          userSetting.Access_Status_CUST__c = 'Under Review';
          userSetting.Manager_Global_ID_CUST__c= userSetting.CST_User_CUST__r.CST_Approver_ID_GLBL__c;
        }

        update userSettings;
  }

  global void finish(Database.BatchableContext BC) {

  }
}