/**
  @author: Aakash Bajpai
   @Created Date: 07-Dec-2015
  @Description: For Scheduling the batch class 'CUST_UserSettingsUnderReviewBatchable'
*/

global class CUST_UserSettingsUnderReviewScheduler implements Schedulable {
   
    public static string strScheduleName='CUST_UserSettingsUnderReview';
    public static String scheduleName {
      get { return strScheduleName; }
      set { strScheduleName = value; }
   }
   
    global void execute(SchedulableContext sc) {
        CUST_UserSettingsUnderReviewBatchable b = new CUST_UserSettingsUnderReviewBatchable();
        database.executeBatch(b);
    }
    global static void executeUserSettingsUnderReviewScheduler(){
        CUST_UserSettingsUnderReviewScheduler m = new CUST_UserSettingsUnderReviewScheduler();
        String sch = '0 0 9 2-15 * ?';
        // This runs a scheduled job at 9am from 2nd to 15th date of every month
        String jobID = system.schedule(scheduleName, sch, m);    
    }
    
}