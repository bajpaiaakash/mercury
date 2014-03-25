public with sharing class CUST_RefreshLOVsController {
	public CST_App_Settings_CUST__c settings;

	public CUST_RefreshLOVsController(ApexPages.StandardController controller) {
		settings = (CST_App_Settings_CUST__c) controller.getRecord();
		settings = [SELECT Id, Account_Bnft_Dsgn_Cd_CUST__c FROM CST_App_Settings_CUST__c WHERE Id = :settings.Id];
	}
}