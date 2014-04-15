/**
 * Drives CUST_AdminUtilities.page to provide multiple admin functions.
 * Using inner classes to provide a type of "interface" approach to encourage each utility
 * to provide the same type of info back to the page.
 *
 * Author: Sean Harrison, Mavens 
 **/
public with sharing class CUST_AdminUtilitiesController {

    private CUST_Scheduler scheduler;

    public Integer status  {get; set;}
    public String  message {get; set;}
    public String  result  {get; set;}

    public static final String STATUS_SUCCESS = 'AdminUtilitiesSuccess';
    public static final String STATUS_ERR = 'AdminUtilitiesError';
    public Boolean jobsActive {get{ return !scheduler.checkActiveJobs().isEmpty();}}

    public CUST_AdminUtilitiesController() {
        scheduler = new CUST_Scheduler();
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
            CUST_Scheduler scheduler = new CUST_Scheduler();
            try {
                scheduler.abortAll();
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