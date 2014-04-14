/**
 *
 * Responsible for starting all schedulable apex jobs for the Customer Search Tool
 */
global with sharing class CUST_Scheduler {

	// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
	public static String EXPIRE_CRON = '0 0 13 1 * ?';
	public static String REVIEW_CRON = '0 0 13 15 * ?';
	public static String NOTIFY_CRON = '0 0 * * * ?';
	public static String EXPIRE_NAME = 'CST Set Access To Expired';
	public static String REVIEW_NAME = 'CST Set Access To Under Review';
	public static String NOTIFY_NAME = 'CST Set Access To Will Expire';
	private Boolean useSettings = false;
	private Mercury_Settings_MERC__c settings;

	public CUST_Scheduler() {
		settings = Mercury_Settings_MERC__c.getOrgDefaults();
		if (settings.Id != null) {
			if (settings.CST_Expire_Cron_Name_CUST__c != null) EXPIRE_NAME = settings.CST_Expire_Cron_Name_CUST__c;
			if (settings.CST_Expire_Cron_Sched_CUST__c != null) EXPIRE_CRON = settings.CST_Expire_Cron_Sched_CUST__c;
			if (settings.CST_Notify_Cron_Name_CUST__c != null) NOTIFY_NAME = settings.CST_Notify_Cron_Name_CUST__c;
			if (settings.CST_Notify_Cron_Sched_CUST__c != null) NOTIFY_CRON = settings.CST_Notify_Cron_Sched_CUST__c;
			if (settings.CST_Review_Cron_Name_CUST__c != null) REVIEW_NAME = settings.CST_Review_Cron_Name_CUST__c;
			if (settings.CST_Review_Cron_Sched_CUST__c != null) REVIEW_CRON = settings.CST_Review_Cron_Sched_CUST__c;
			useSettings = true;
		}
	}

	public void cronAll() {
		cronExpire();
		cronReview();
		cronNotify();
	}

	public void cronExpire() {
		// CUST_MonthlyProcessScheduler // day 1 monthly  //  CST_Access_To_Expired
		CUST_MonthlyProcessScheduler monthlySetAccessToExpired = new CUST_MonthlyProcessScheduler();
		String jobID = system.schedule(EXPIRE_NAME, EXPIRE_CRON, monthlySetAccessToExpired);

		if (useSettings) {
			settings.CST_Expire_Cron_Id_CUST__c = jobId;
			update settings;
		}
	}

	public void cronReview() {
		// CUST_ProcessScheduler  // day 15 montly  //  CST_Access_To_Under_Review
		CUST_ProcessScheduler monthlySetAccessToUnderReview = new CUST_ProcessScheduler();
		String jobID = system.schedule(REVIEW_NAME, REVIEW_CRON, monthlySetAccessToUnderReview);

		if (useSettings) {
			settings.CST_Review_Cron_Id_CUST__c = jobId;
			update settings;
		}
	}

	public void cronNotify() {
		// CUST_UserSettingsWillExpireBatchable  // hourly
		CUST_UserSettingsWillExpireBatchable hourlyNotifyAccessToExpired = new CUST_UserSettingsWillExpireBatchable();
		String jobID = system.schedule(NOTIFY_NAME, NOTIFY_CRON, hourlyNotifyAccessToExpired);		

		if (useSettings) {
			settings.CST_Notify_Cron_Id_CUST__c = jobId;
			update settings;
		}
	}
}