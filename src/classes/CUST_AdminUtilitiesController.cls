/**
 * Drives CUST_AdminUtilities.page to provide multiple admin functions.
 * Using inner classes to provide a type of "interface" approach to encourage each utility
 * to provide the same type of info back to the page.
 *
 * Author: Sean Harrison, Mavens
 **/
public with sharing class CUST_AdminUtilitiesController {

    public Integer status  {get; set;}
    public String  message {get; set;}
    public String  result  {get; set;}

    public static final String STATUS_SUCCESS = 'AdminUtilitiesSuccess';
    public static final String STATUS_ERR = 'AdminUtilitiesError';
    public Boolean jobsActive {get{ return !checkActiveJobs().isEmpty();}}

    public static List<CronTrigger> checkActiveJobs() {
        Mercury_Settings_MERC__c settings = Mercury_Settings_MERC__c.getOrgDefaults();
        List<String> jobIds = new List<String>();
        if (settings.CST_Expire_Cron_Id_CUST__c!=null) jobIds.add(settings.CST_Expire_Cron_Id_CUST__c);
        if (settings.CST_Review_Cron_Id_CUST__c!=null) jobIds.add(settings.CST_Review_Cron_Id_CUST__c);
        if (settings.CST_Notify_Cron_Id_CUST__c!=null) jobIds.add(settings.CST_Notify_Cron_Id_CUST__c);

        List<CronTrigger> jobTriggers = new List<CronTrigger>([
            SELECT Id FROM CronTrigger WHERE Id in :jobIds
            ]);
        return jobTriggers;
    }

    public PageReference initJobs() {
        initJobsUtil util = new initJobsUtil();
        util.runTask();
        status = util.status;
        message = util.message;
        result = util.result;
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

    public PageReference stopJobs() {
        stopJobsUtil util = new stopJobsUtil();
        util.runTask();
        status = util.status;
        message = util.message;
        result = util.result;
        return null;
    }

    public class stopJobsUtil {
        public Integer status  {get;set;}
        public String  message {get;set;}
        public String  result  {get;set;}

        private List<CronTrigger> jobTriggers;

        public void runTask() {
            try {
                List<CronTrigger> jobTriggers = CUST_AdminUtilitiesController.checkActiveJobs();               
                for (CronTrigger t : jobTriggers) System.abortJob(t.Id);
            } catch (Exception e) {
                status = 1;
                message = e.getMessage();
                result = STATUS_ERR;
                return;
            }
            status = 1;
            message = 'Active Jobs Deleted';
            result = STATUS_SUCCESS;
        }
    }
}