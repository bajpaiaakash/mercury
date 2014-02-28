/** 
* @author Sean Harrison 
* 
* This is a unit test class for GLBL_GlobalIdAccountLookup.cls
*
*/
@isTest
private class GLBL_GlobalIdAccountLookupTest {
	
	static List<CST_User_Log_CUST__c> logs;
	static List<Account> accts;
	static String foobar = 'Test';
	
	static {
		logs = new List<CST_User_Log_CUST__c>();
	}

	/**
	 * Insert some logs with a global id matching some inserted accounts.
	 */
	@isTest static void insertNewLogs() {
		init();
     	Test.startTest();

    	for (Integer i=0;i<250;i++) {
    		String s = foobar+String.valueOf(i);
    		logs.add(new CST_User_Log_CUST__c(Prsnl_Nbr_GLBL__c=s));
    	}
    	insert logs;

    	Test.stopTest();

    	logs = [SELECT Id, User_Account_CUST__c FROM CST_User_Log_CUST__c WHERE Id in :logs];
    	Map<Id,Account> acctMap = new Map<Id,Account>(accts);
    	for (CST_User_Log_CUST__c log : logs) {
    		System.assertNotEquals(log.User_Account_CUST__c,null);
    		System.assert(acctMap.keySet().contains(log.User_Account_CUST__c), 
    			'Did not find '+log.User_Account_CUST__c+' in Accounts keySet');
    	}
	}
	
	/**
	 * Let's make sure updated logs get a new account
	 */
	@isTest static void updateLogs() {
		init();
     	Test.startTest();

		Account a = new Account(FirstName = 'fname',LastName = 'CUST_GlobalIdLookupTest');
		a.Prsnl_Nbr_GLBL__c = '989';
		insert a;
		Integer testSize = 250;
    	for (Integer i=0;i<testSize;i++) {
    		logs.add(new CST_User_Log_CUST__c(Prsnl_Nbr_GLBL__c='989',Term_Language_CUST__c='xx'));
    	}
    	insert logs;

    	Integer i=0;
    	for (CST_User_Log_CUST__c log : logs) {
    		String s = foobar+String.valueOf(i);
     		log.Prsnl_Nbr_GLBL__c = s;
    		log.Term_Language_CUST__c = 'yy';
    		i++;
    	}
    	update logs;

    	Test.stopTest();

    	logs = [SELECT Id, User_Account_CUST__c FROM CST_User_Log_CUST__c WHERE Id in :logs];
    	Map<Id,Account> acctMap = new Map<Id,Account>(accts);
    	for (CST_User_Log_CUST__c log : logs) {
    		System.assertNotEquals(log.User_Account_CUST__c,null);
    		System.assert(acctMap.keySet().contains(log.User_Account_CUST__c), 
    			'Did not find '+log.User_Account_CUST__c+' in Accounts keySet');
    	}
	}

	@isTest static void confirmErrorsThrown() {
     	Test.startTest();
		Account a = new Account(FirstName = 'fname',LastName = 'CUST_GlobalIdLookupTest');
		a.Prsnl_Nbr_GLBL__c = '989';
		insert a;

		CST_User_Log_CUST__c log = new CST_User_Log_CUST__c(Prsnl_Nbr_GLBL__c='YYZ');
		logs.add(log);
		GLBL_GlobalIdAccountLookup engine = new GLBL_GlobalIdAccountLookup('Prsnl_Nbr_GLBL__c','User_Account_CUST__c',true);
		boolean errThrown = false;
	    try {
				engine.findAndPopulateLookup(logs);
			} catch (GLBL_GlobalIdAccountLookup.GLBL_GlobalIdAccountLookupException e) {
				System.assert(e.getMessage().contains('Invalid Global Id'),'Wrong error thrown: '+e.getMessage());
				errThrown = true;
			} catch (Exception e) {
				System.assert(errThrown, 'Wrong exception type thrown: '+e.getMessage());
			}
		System.assert(errThrown, 'Expected an error but insert was successful instead');
	}

    // data setup
    static void init() {
    	Integer n = 300;
    	accts = MERC_TestFactory.insertEmployeeAccounts(n);
    	for (Integer i=0;i<accts.size();i++) {
    		accts.get(i).Prsnl_Nbr_GLBL__c = foobar+String.valueOf(i);
    	}
    	update accts;
    }
}