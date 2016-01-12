/**
  @author: Aakash Bajpai
   @Created Date: 07-Dec-2015
  @Description: For Scheduling the batch class 'CUST_UserSettingsUnderReviewBatchable'
*/

global class CUST_UserSettingsUnderReviewScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        CUST_UserSettingsUnderReviewBatchable b = new CUST_UserSettingsUnderReviewBatchable();
        database.executeBatch(b);
    }
    global static void execuetUserSettingsUnderReviewScheduler(){
        CUST_UserSettingsUnderReviewScheduler m = new CUST_UserSettingsUnderReviewScheduler();
        String sch = '0 0 9 2-15 * ?';
        String jobID = system.schedule('CUST_UserSettingsUnderReview', sch, m);    
    }
    
}