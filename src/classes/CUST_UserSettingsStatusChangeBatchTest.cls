/**
 * @author Kyle Thornton
 *
 * Unit tests for CUST_UserSettingsStatusChangeBatchable
 */
@isTest
private class CUST_UserSettingsStatusChangeBatchTest {

	static final Integer TEST_DATA_SIZE = 200;
	static List<Account> employees = MERC_TestFactory.insertEmployeeAccounts(TEST_DATA_SIZE);
	static List<Account> managers  = MERC_TestFactory.insertEmployeeAccounts(TEST_DATA_SIZE);
	static List<CST_User_Settings_CUST__c> settings = new List<CST_User_Settings_CUST__c>();

	@isTest static void test_no_manager_new_requests() {
		for (Account a : employees) {
			settings.add(new CST_User_Settings_CUST__c(CST_User_CUST__c = a.id, Access_Status_CUST__c = 'New Request'));
		}
		insert settings;

		Test.startTest();
		CUST_UserSettingsStatusChangeBatchable b = new CUST_UserSettingsStatusChangeBatchable();
		Database.executeBatch(b);
		Test.stopTest();
		System.assertEquals(TEST_DATA_SIZE, [SELECT COUNT() FROM CST_User_Settings_CUST__c WHERE Access_Status_CUST__c='Error']);
	}

	@isTest static void test_has_manager_new_requests() {
		for (Integer i=0; i<TEST_DATA_SIZE; i++) {
			managers.get(i).put('Prsnl_Nbr_GLBL__c', 'nmbr' + i);
			settings.add(new CST_User_Settings_CUST__c(CST_User_CUST__c = employees.get(i).id,
				                                       Access_Status_CUST__c = 'New Request',
				                                       Manager_Global_ID_CUST__c = 'nmbr'+i));
		}
		//update the last setting to have the same manager as the prior setting so that the else statement in the map creation gets covered
		if (TEST_DATA_SIZE>1) settings.get(TEST_DATA_SIZE-1).Manager_Global_ID_CUST__c='nmbr' + (TEST_DATA_SIZE-2);
		insert settings;
		update managers;

		Test.startTest();
		CUST_UserSettingsStatusChangeBatchable b = new CUST_UserSettingsStatusChangeBatchable();
		Database.executeBatch(b);
		Test.stopTest();
		System.assertEquals(TEST_DATA_SIZE, [SELECT COUNT() FROM CST_User_Settings_CUST__c WHERE Access_Status_CUST__c='Pending']);
		System.assertEquals(TEST_DATA_SIZE-1, [SELECT COUNT() FROM Account WHERE Flag_CST_Email_CUST__c LIKE 'MANAGER:%']);
	}

	@isTest static void test_non_new_requests_get_flagged() {
		for (Integer i=0; i<TEST_DATA_SIZE; i++) {
			settings.add(new CST_User_Settings_CUST__c(CST_User_CUST__c = employees.get(i).id,
				                                       Access_Status_CUST__c = 'Approved',
				                                       Last_Status_CUST__c = 'Pending',
				                                       Manager_Global_ID_CUST__c = 'nmbr'+i));
		}
		insert settings;

		Test.startTest();
		CUST_UserSettingsStatusChangeBatchable b = new CUST_UserSettingsStatusChangeBatchable();
		Database.executeBatch(b);
		Test.stopTest();

		System.assertEquals(TEST_DATA_SIZE, [SELECT COUNT() FROM CST_User_Settings_CUST__c WHERE Last_Status_CUST__c='']);
		System.assertEquals(TEST_DATA_SIZE*2, [SELECT COUNT() FROM Account WHERE Flag_CST_User_Email_CUST__c = ''], [SELECT Flag_CST_User_Email_CUST__c FROM Account]);
	}

}