/**
 *  @author Kyle Thornton
 *
 * Test class for the CUST_MonthlyProcessScheduler
 */
@isTest
private class CUST_MonthlyProcessSchedulerTest {
	static CST_User_Settings_CUST__c setting;
	static {
		Id acctEmpRecTypeId = [SELECT Id from RecordType WHERE SObjectType='Account' AND DeveloperName='Employee_GLBL' limit 1].Id;
		Account employee = new Account(lastname='testemployee', RecordTypeId=acctEmpRecTypeId);
		insert employee;
		setting = new CST_User_Settings_CUST__c(Access_Status_CUST__c='Under Review', CST_User_CUST__c=employee.id);
		insert setting;
	}

	@isTest static void test_method_one() {
		Test.startTest();
		String CRON_EXP = '0 0 0 3 9 ? 2032';

      	// Schedule the test job
      	String jobId = System.schedule('testScheduledApex',
      									CRON_EXP,
         								new CUST_MonthlyProcessScheduler());

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

   		// Verify the job has run
		//System.assertEquals(1, ct.TimesTriggered);
   		//System.assertEquals('Expired', [SELECT Id, Access_Status_CUST__c FROM CST_User_Settings_CUST__c WHERE Id=:setting.Id].Access_Status_CUST__c);
	}
}