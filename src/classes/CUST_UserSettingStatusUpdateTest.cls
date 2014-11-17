/**
 * @author Kyle Thornton
 *
 * Test class for the CUST_UserSettingStatusUpdateTest
 */
@isTest
private class CUST_UserSettingStatusUpdateTest {

	static Account employee;
	static {
		Id acctEmpRecTypeId = [SELECT Id from RecordType WHERE SObjectType='Account' AND DeveloperName='Employee_GLBL' limit 1].Id;
		employee = new Account(lastname='testemployee', RecordTypeId=acctEmpRecTypeId);
		insert employee;
	}
	@isTest static void test_method_one() {
		CST_User_Settings_CUST__c setting = new CST_User_Settings_CUST__c(Access_Status_CUST__c='Under Review', CST_User_CUST__c=employee.id);
		insert setting;
		setting.Access_Status_CUST__c = 'Approved';
		update setting;

		setting = [SELECT Id, Audit_Date_CUST__c, Start_Date_CUST__c, Last_Status_CUST__c FROM CST_User_Settings_CUST__c WHERE Id=:setting.id];
		System.assertEquals('Under Review', setting.Last_Status_CUST__c);
		System.assertEquals(Date.today(), setting.Start_Date_CUST__c);
		System.assertEquals(Date.Today().addMonths(5).toStartOfMonth().addDays(14), setting.Audit_Date_CUST__c);

	}
}