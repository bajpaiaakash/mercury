public with sharing class CUST_AdminUtilitiesController {

    public Integer status  {get; set;}
    public String  message {get; set;}
    public String  result  {get; set;}

    public static final String STATUS_SUCCESS = 'AdminUtilitiesSuccess';
    public static final String STATUS_ERR = 'AdminUtilitiesError';

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
}