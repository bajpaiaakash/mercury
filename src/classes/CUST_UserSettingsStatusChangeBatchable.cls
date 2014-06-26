global class CUST_UserSettingsStatusChangeBatchable implements Database.Batchable<sObject> {

	String query;

	global CUST_UserSettingsStatusChangeBatchable() {
		query = 'SELECT Id, Access_Status_CUST__c, CST_User_CUST__c, Last_Status_CUST__c, Manager_Global_ID_CUST__c FROM CST_User_Settings_CUST__c WHERE Access_Status_CUST__c = \'New Request\' OR Last_Status_CUST__c != \'\'';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext bc, List<CST_User_Settings_CUST__c> userSettings) {

   		Map<String, Set<CST_User_Settings_CUST__c>> managerToUserSetting = new Map<String, Set<CST_User_Settings_CUST__c>>();
        Set<Id> userAccountsIdsToFlag = new Set<Id>();
   		System.debug(userSettings);
		//Group by supervisor Id
   		for (CST_User_Settings_CUST__c userSetting : userSettings){
            if (userSetting.Access_Status_CUST__c == 'New Request'){
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
            } else {
                if(userSetting.Last_Status_CUST__c != 'New Request'){
                    userAccountsIdsToFlag.add(userSetting.CST_User_CUST__c);
                }

                userSetting.Last_Status_CUST__c = '';
            }
   		}

   		update userSettings;

		//Flag each manager or user for the workflow that sends an email
		List<Account> accounts =  [SELECT Id, Flag_CST_Email_CUST__c, Flag_CST_User_Email_CUST__c, Prsnl_Nbr_GLBL__c FROM Account
                WHERE (Prsnl_Nbr_GLBL__c in: managerToUserSetting.keySet() OR Id in :userAccountsIdsToFlag) AND isPersonAccount = true];
		for (Account a : accounts){
            if (managerToUserSetting.containsKey(a.Prsnl_Nbr_GLBL__c)){
                a.Flag_CST_Email_CUST__c = 'MANAGER:' + Datetime.Now();
            }
            if (userAccountsIdsToFlag.contains(a.Id)){
                a.Flag_CST_User_Email_CUST__c = 'USER:' + Datetime.Now();
            }
		}
        System.debug(accounts);
		update accounts;

	}

	global void finish(Database.BatchableContext BC) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'mercury@mavensconsulting.com'};

        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('CST Batch');
        mail.setSubject('CST Batch : ' + Datetime.Now());
        String body = '';
        body += 'batch completed';
        mail.setPlainTextBody(body);

        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

}