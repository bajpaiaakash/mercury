global class CUST_MonthlyProcessScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		CUST_UserSettingsExpireBatchable b = new CUST_UserSettingsExpireBatchable();
		database.executeBatch(b);
	}
}