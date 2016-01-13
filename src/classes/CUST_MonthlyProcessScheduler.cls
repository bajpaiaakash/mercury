/**
* CUST_MonthlyProcessScheduler
* Created By: Kyle Thornton, Mavens
* Description: This class should be referenced when attempting to schedule an apex batch job for CUST_UserSettingsExpireBatchable, which queries CST_User_Settings_CUST__c object for records that have an Access Status of Under Review then updates those records to an Access Status of Expired.
*/
global class CUST_MonthlyProcessScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		//instantiate CUST_UserSettingsExpireBatchable and then execute it.
		CUST_UserSettingsExpireBatchable b = new CUST_UserSettingsExpireBatchable();
		database.executeBatch(b);
	}
}