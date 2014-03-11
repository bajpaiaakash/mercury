global class CUST_UserSettingsStatusChangeBatchable implements Database.Batchable<sObject> {
	
	String query;
	
	global CUST_UserSettingsStatusChangeBatchable() {
		query = 'SELECT Id, Access_Status_CUST__c, Manager_Global_ID_CUST__c FROM CST_User_Settings_CUST__c WHERE Access_Status_CUST__c = \'New Request\'';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext bc, List<CST_User_Settings_CUST__c> userSettings) {
   		List<Account> accountsToClear = [SELECT Id, Flag_CST_Email_CUST__c FROM Account WHERE Flag_CST_Email_CUST__c = 'MANAGER'];
   		for (Account a : accountsToClear){
   			a.Flag_CST_Email_CUST__c = '';
   		}

   		update accountsToClear;

   		Map<String, Set<CST_User_Settings_CUST__c>> managerToUserSetting = new Map<String, Set<CST_User_Settings_CUST__c>>();
   		System.debug(userSettings);
		//Group by supervisor Id
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
   				//Otherwise change the status to 'Pending'
   				userSetting.Access_Status_CUST__c = 'Pending';
   				if (!managerToUserSetting.containsKey(userSetting.Manager_Global_ID_CUST__c)){
   					Set<CST_User_Settings_CUST__c> uss = new Set<CST_User_Settings_CUST__c>();
   					managerToUserSetting.put(userSetting.Manager_Global_ID_CUST__c,uss);
   				} else {
   					managerToUserSetting.get(userSetting.Manager_Global_ID_CUST__c).add(userSetting);
   				}
   			}
   		}
   		System.debug(managerToUserSetting);
   		update userSettings;

		//Flag each manager for the workflow that sends an email
		List<Account> accounts =  [SELECT Id, Flag_CST_Email_CUST__c, Prsnl_Nbr_GLBL__c FROM Account WHERE Prsnl_Nbr_GLBL__c in: managerToUserSetting.keySet() AND isPersonAccount = true];
		for (Account a : accounts){
			a.Flag_CST_Email_CUST__c = 'MANAGER';
		}

		update accounts;
		
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}