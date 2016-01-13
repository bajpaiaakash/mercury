/**
 * CUST_UserSettingsWillExpireBatchable
 * Created By: Mavens Consulting
 * Description: Collect all CST_User_Settings_CUST__c records with an Access Status of Under Review. Update associated Account records' Flag_CST_Expire_Email_CUST field to manager if their is a manager on CST_User_Settings_CUST__c record.
 */

global class CUST_UserSettingsWillExpireBatchable implements Database.Batchable<sObject>, Schedulable {
	
	String query;
	
    // set query
	global CUST_UserSettingsWillExpireBatchable() {
		query = 'SELECT Id, Access_Status_CUST__c, CST_User_CUST__c, Manager_Global_ID_CUST__c '+
            'FROM CST_User_Settings_CUST__c WHERE Access_Status_CUST__c = \'Under Review\'';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<CST_User_Settings_CUST__c> userSettings) {
   		Map<String, Set<CST_User_Settings_CUST__c>> managerToUserSetting = new Map<String, Set<CST_User_Settings_CUST__c>>();
		for (CST_User_Settings_CUST__c userSetting : userSettings){
           	//If Manager Id is blank set the Status to 'Error'
            if (String.isBlank(userSetting.Manager_Global_ID_CUST__c)){
                userSetting.Access_Status_CUST__c = 'Error';

                if (!managerToUserSetting.containsKey('NO_MANAGER')){
                    Set<CST_User_Settings_CUST__c> uss = new Set<CST_User_Settings_CUST__c>();
                    managerToUserSetting.put('NO_MANAGER',uss);
                } else {
                    managerToUserSetting.get('NO_MANAGER').add(userSetting);
                }
            } else {
                if (!managerToUserSetting.containsKey(userSetting.Manager_Global_ID_CUST__c)){
                    Set<CST_User_Settings_CUST__c> uss = new Set<CST_User_Settings_CUST__c>();
                    managerToUserSetting.put(userSetting.Manager_Global_ID_CUST__c,uss);
                } else {
                    managerToUserSetting.get(userSetting.Manager_Global_ID_CUST__c).add(userSetting);
                }
            } 
   		}

		List<Account> accounts =  [SELECT Id, Flag_CST_Email_CUST__c, Prsnl_Nbr_GLBL__c FROM Account 
		WHERE Prsnl_Nbr_GLBL__c in: managerToUserSetting.keySet()];
		for (Account a : accounts){
            if (managerToUserSetting.containsKey(a.Prsnl_Nbr_GLBL__c)){
                a.Flag_CST_Expire_Email_CUST__c = 'MANAGER';
            } 
		}

		update accounts;

	}
	
    global void execute(SchedulableContext sc) {
        CUST_UserSettingsWillExpireBatchable b = new CUST_UserSettingsWillExpireBatchable();
        database.executeBatch(b);
    }    

	global void finish(Database.BatchableContext BC) {
		
	}
	
}