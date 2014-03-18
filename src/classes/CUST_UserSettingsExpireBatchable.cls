global class CUST_UserSettingsExpireBatchable implements Database.Batchable<sObject> {
	
	String query;
	
	global CUST_UserSettingsExpireBatchable() {
		query = 'SELECT Id, Access_Status_CUST__c FROM CST_User_Settings_CUST__c WHERE Access_Status_CUST__c = \'Under Review\'';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<CST_User_Settings_CUST__c> userSettings) {
		for (CST_User_Settings_CUST__c userSetting : userSettings){
			userSetting.Access_Status_CUST__c = 'Expired';
		}

		update userSettings;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}