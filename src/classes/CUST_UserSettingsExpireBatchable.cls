/**
* CUST_UserSettingsExpireBatchable
* Created By: Mavens Consulting
* Description: Query CST_User_Settings_CUST__c object for records that have an Access Status of Under Review. Update those records to an Access Status of Expired.
*/
global class CUST_UserSettingsExpireBatchable implements Database.Batchable<sObject> {

	String query;

	// set query
	global CUST_UserSettingsExpireBatchable() {
		query = 'SELECT Id, Access_Status_CUST__c FROM CST_User_Settings_CUST__c WHERE Access_Status_CUST__c = \'Under Review\'';
	}

	// query database
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	// set access status to expired on all records and update
   	global void execute(Database.BatchableContext BC, List<CST_User_Settings_CUST__c> userSettings) {
		for (CST_User_Settings_CUST__c userSetting : userSettings){
			userSetting.Access_Status_CUST__c = 'Expired';
		}

		update userSettings;
	}

	global void finish(Database.BatchableContext BC) {

	}

}