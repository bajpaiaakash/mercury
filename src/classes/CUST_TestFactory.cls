@isTest
public with sharing class CUST_TestFactory {

	public static CST_App_Settings_CUST__c insertAppSetting() {
		CST_App_Settings_CUST__c a = new CST_App_Settings_CUST__c();
		insert a;
		return a;
	}
}