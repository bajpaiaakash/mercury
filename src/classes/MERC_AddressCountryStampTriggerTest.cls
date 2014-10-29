@isTest
private class MERC_AddressCountryStampTriggerTest {
	
	@isTest static void test_should_set_country_on_insert() {
		List<Account> accounts = MERC_TestFactory.insertAccounts(2);

		System.assertEquals(NULL, accounts[0].Primary_Address_Country_GLBL__c);
		System.assertEquals(NULL, accounts[1].Primary_Address_Country_GLBL__c);

		Address_GLBL__c address0 = MERC_TestFactory.insertAddressWithCountry(accounts[0],'US');

		accounts = [SELECT Id, Primary_Address_Country_GLBL__c FROM Account WHERE Id IN :accounts];
		System.assertEquals('US', accounts[0].Primary_Address_Country_GLBL__c);
		System.assertEquals(NULL, accounts[1].Primary_Address_Country_GLBL__c);
	}

	@isTest static void test_should_set_country_on_update() {
		List<Account> accounts = MERC_TestFactory.insertAccounts(2);

		System.assertEquals(NULL, accounts[0].Primary_Address_Country_GLBL__c);
		System.assertEquals(NULL, accounts[1].Primary_Address_Country_GLBL__c);

		Address_GLBL__c address0 = MERC_TestFactory.insertAddressWithCountry(accounts[0],'US');

		accounts = [SELECT Id, Primary_Address_Country_GLBL__c FROM Account WHERE Id IN :accounts];
		System.assertEquals('US', accounts[0].Primary_Address_Country_GLBL__c);
		System.assertEquals(NULL, accounts[1].Primary_Address_Country_GLBL__c);

		address0.Adrs_Cntry_Cd_GLBL__c = 'GB';
		update address0;

		accounts = [SELECT Id, Primary_Address_Country_GLBL__c FROM Account WHERE Id IN :accounts];
		System.assertEquals('GB', accounts[0].Primary_Address_Country_GLBL__c);
		System.assertEquals(NULL, accounts[1].Primary_Address_Country_GLBL__c);
	}
}