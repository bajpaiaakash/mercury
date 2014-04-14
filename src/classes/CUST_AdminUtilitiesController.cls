public with sharing class CUST_AdminUtilitiesController {

    public Integer status  {get; set;}
    public String  message {get; set;}
    public String  result  {get; set;}

    public static final String STATUS_SUCCESS = 'AdminUtilitiesSuccess';
    public static final String STATUS_ERR = 'AdminUtilitiesError';
    public Boolean jobsActive {get{ return checkActiveJobs();} set;}

    private List<CronTrigger> jobTriggers;

    public PageReference initJobs() {
        initJobsUtil util = new initJobsUtil();
        util.runTask();
        status = util.status;
        message = util.message;
        result = util.result;
        return null;
    }

    public Boolean checkActiveJobs() {
        Mercury_Settings_MERC__c settings = Mercury_Settings_MERC__c.getOrgDefaults();
        List<String> jobIds = new List<String>();
        if (settings.CST_Expire_Cron_Id_CUST__c!=null) jobIds.add(settings.CST_Expire_Cron_Id_CUST__c);
        if (settings.CST_Review_Cron_Id_CUST__c!=null) jobIds.add(settings.CST_Review_Cron_Id_CUST__c);
        if (settings.CST_Notify_Cron_Id_CUST__c!=null) jobIds.add(settings.CST_Notify_Cron_Id_CUST__c);

        jobTriggers = new List<CronTrigger>([
            SELECT Id, CreatedBy.Name, CreatedDate, CronJobDetailId, CronJobDetail.Name, NextFireTime, State, TimesTriggered
            FROM CronTrigger WHERE Id in :jobIds]);

        if (jobTriggers.isEmpty()) {
            return false;
        }

        //List<Id> jobDetailIds = new List<Id>();
        //for (CronTrigger t : jobTriggers) {
        //    jobDetailIds.add(t.CronJobDetailId);
        //}
        //currentJobs = [SELECT Id from CronJobDetail WHERE Id in :jobDetailIds];

        // status = 1;
        // message = String.valueOf(currentJobs);
        // result = STATUS_SUCCESS;
        return true;
    }

    public PageReference stopJobs() {
        for (CronTrigger t : jobTriggers) System.abortJob(t.Id);
        status = 1;
        message = 'Active Jobs Deleted';
        result = STATUS_SUCCESS;
        return null;
    }

    public class initJobsUtil {
        public Integer status  {get;set;}
        public String  message {get;set;}
        public String  result  {get;set;}

        public void runTask() {
            CUST_Scheduler scheduler = new CUST_Scheduler();
            try {
                scheduler.cronAll();
            } catch (Exception e) {
                status = 1;
                message = e.getMessage();
                result = STATUS_ERR;
                return;
            }
            status = 1;
            message = 'SUCCESS!  Click <a href="/08e?setupid=ScheduledJobs">here to view scheduled jobs</a>.';
            result = STATUS_SUCCESS;
        }
    }

}