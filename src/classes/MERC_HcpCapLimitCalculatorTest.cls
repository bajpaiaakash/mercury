@isTest
private class MERC_HcpCapLimitCalculatorTest {
	
	static List<Account> frenchAccounts;
	static List<Account> belgianAccounts;
	static List<Account> englishAccounts;

	static {
		MERC_TestFactory.loadCAPSettings();
		frenchAccounts = MERC_TestFactory.insertHcpAccountsInCountry(2, 'FR');
		belgianAccounts = MERC_TestFactory.insertHcpAccountsInCountry(1, 'BE');
		englishAccounts = MERC_TestFactory.insertHcpAccountsInCountry(1, 'GB');
	}

	@isTest static void test_should_calculate_cap_for_hcps() {
		CAP_Settings_MERC__c frenchCap = [SELECT Annual_Amount_MERC__c FROM CAP_Settings_MERC__c WHERE Year_MERC__c = '2014' AND Country_Code_MERC__c = 'FR']; 
		system.assertEquals(frenchCap.Annual_Amount_MERC__c, [SELECT Annual_CAP_Limit_MERC__c FROM Account WHERE Id in :frenchAccounts limit 1].Annual_CAP_Limit_MERC__c);
		
		CAP_Settings_MERC__c belgianCap = [SELECT Annual_Amount_MERC__c FROM CAP_Settings_MERC__c WHERE Year_MERC__c = '2014' AND Country_Code_MERC__c = 'BE']; 
		system.assertEquals(belgianCap.Annual_Amount_MERC__c, [SELECT Annual_CAP_Limit_MERC__c FROM Account WHERE Id in :belgianAccounts limit 1].Annual_CAP_Limit_MERC__c);

		CAP_Settings_MERC__c englishCap = [SELECT Annual_Amount_MERC__c FROM CAP_Settings_MERC__c WHERE Year_MERC__c = '2014' AND Country_Code_MERC__c = 'GB']; 
		system.assertEquals(englishCap.Annual_Amount_MERC__c, [SELECT Annual_CAP_Limit_MERC__c FROM Account WHERE Id in :englishAccounts limit 1].Annual_CAP_Limit_MERC__c);
	
		Account englishAccount = englishAccounts.get(0);
		englishAccount.Country_of_Residence_GLBL__c = 'FR';
		update englishAccount;
		system.assertEquals(frenchCap.Annual_Amount_MERC__c, [SELECT Annual_CAP_Limit_MERC__c FROM Account WHERE Id = :englishAccount.Id limit 1].Annual_CAP_Limit_MERC__c);
	}
	
}