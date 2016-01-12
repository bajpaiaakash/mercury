/**
  @author: Aakash Bajpai
   @Created Date: 07-Dec-2015
  @Description: For Scheduling the batch class 'CUST_UserSettingsUnderReviewBatchable'
*/
@isTest
private class CUST_UserSettingsUnderReviewSch_test{
     static testmethod void mytestmethod(){
     User testUser = MERC_TestFactory.getTestingUser(); 
     System.runAs(testUser) {
         Test.startTest();   
         CUST_UserSettingsUnderReviewScheduler.execuetUserSettingsUnderReviewScheduler();
         Test.stopTest();
       }
    }
    
}