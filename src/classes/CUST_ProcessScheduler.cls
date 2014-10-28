/*
  *	   CUST_ProcessScheduler
  *    Created By: Vincent Reeder       
  *    Created Date: 2013-03-03
  *    Description: Scheduled Job 
 */
global class CUST_ProcessScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		CUST_UserSettingsStatusChangeBatchable b = new CUST_UserSettingsStatusChangeBatchable();
		database.executebatch(b);
	}
}