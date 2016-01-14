/**
 * @author Kyle Thornton
 *
 * Unit tests for CUST_UserSettingsWillExpireBatchable class
 */
@isTest
private class CUST_UserSettingsWillExpireBatchableTest {

	static List<Account> accounts = MERC_TestFactory.insertEmployeeAccounts(2);

	@isTest static void test_manager_is_blank() {
		Test.startTest();
		List<CST_User_Settings_CUST__c> settings = new List<CST_User_Settings_CUST__c>{
				new CST_User_Settings_CUST__c(Access_Status_CUST__c='Under Review',CST_User_CUST__c=accounts.get(0).Id),
				new CST_User_Settings_CUST__c(Access_Status_CUST__c='Under Review',CST_User_CUST__c=accounts.get(1).Id)
		};
		insert settings;

		CUST_UserSettingsWillExpireBatchable b = new CUST_UserSettingsWillExpireBatchable();
		Database.executeBatch(b);
		Test.stopTest();
	}

	@isTest static void test_manager_is_not_blank() {
		accounts.get(0).Prsnl_Nbr_GLBL__c = '123';
		accounts.get(1).Prsnl_Nbr_GLBL__c = '123';
		update accounts;

		List<CST_User_Settings_CUST__c> settings = new List<CST_User_Settings_CUST__c>{
				new CST_User_Settings_CUST__c(Access_Status_CUST__c='Under Review',CST_User_CUST__c=accounts.get(0).Id, Manager_Global_ID_CUST__c='123'),
				new CST_User_Settings_CUST__c(Access_Status_CUST__c='Under Review',CST_User_CUST__c=accounts.get(1).Id, Manager_Global_ID_CUST__c='123')
		};
		insert settings;

		Test.startTest();
		CUST_UserSettingsWillExpireBatchable b = new CUST_UserSettingsWillExpireBatchable();
		Database.executeBatch(b);
		Test.stopTest();

		System.assertEquals(2, [SELECT COUNT() FROM Account WHERE Flag_CST_Expire_Email_CUST__c='MANAGER']);
	}

	@isTest static void test_schedule() {
		Test.startTest();
		String CRON_EXP = '0 0 0 3 9 ? 2032';

      	// Schedule the test job
      	String jobId = System.schedule('testScheduledApex',
      									CRON_EXP,
         								new CUST_UserSettingsWillExpireBatchable());

		// Get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
		 				FROM CronTrigger WHERE id = :jobId];

		// Verify the expressions are the same
		System.assertEquals(CRON_EXP, ct.CronExpression);

		// Verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);

		// Verify the next time the job will run
		System.assertEquals('2032-09-03 00:00:00',
		String.valueOf(ct.NextFireTime));

   		Test.stopTest();
	}
}