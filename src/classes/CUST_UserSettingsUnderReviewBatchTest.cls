/**
  @author: Aakash Bajpai
   @Created Date: 07-Dec-2015
  @Description: For Updating the Access status to 'Under review' for CST User settings object.
*/
@isTest
private class CUST_UserSettingsUnderReviewBatchTest {
  static List<Account> accounts = MERC_TestFactory.insertEmployeeAccounts(2);
    @isTest static void testUserSettingsUnderReviewBatch() {
    Test.startTest();
    List<CST_User_Settings_CUST__c> settings = new List<CST_User_Settings_CUST__c>{
        new CST_User_Settings_CUST__c(Access_Status_CUST__c='Approved',CST_User_CUST__c=accounts.get(0).Id, Audit_Date_CUST__c=Date.Today()),
        new CST_User_Settings_CUST__c(Access_Status_CUST__c='Approved',CST_User_CUST__c=accounts.get(1).Id, Audit_Date_CUST__c=Date.Today())
    };
    insert settings;
    
    CUST_UserSettingsUnderReviewBatchable b = new CUST_UserSettingsUnderReviewBatchable();
    database.executeBatch(b);    
    Test.stopTest();
    
    }
    @isTest static void test_schedule() {
    Test.startTest();
    String CRON_EXP = '0 0 9 1-15 * ?';

        // Schedule the test job
        String jobId = System.schedule('testScheduledApex',
                        CRON_EXP,
                         new CUST_UserSettingsUnderReviewScheduler());

    // Get the information from the CronTrigger API object
    CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
             FROM CronTrigger WHERE id = :jobId];

    // Verify the expressions are the same
    System.assertEquals(CRON_EXP, ct.CronExpression);

    // Verify the job has not run
    System.assertEquals(0, ct.TimesTriggered);
    
    Test.stopTest();
  }
  
}