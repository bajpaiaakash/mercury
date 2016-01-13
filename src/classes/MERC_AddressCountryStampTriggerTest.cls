/**
* MERC_AddressCountryStampTriggerTest
* Created By: Mavens Consulting 
* Description: Tests the MERC_AddressCountryStampTrigger which is responsible for stamping the Country on related Accounts when the Country changes or the address is inserted for addresses of record type Other.
*/
@isTest
private class MERC_AddressCountryStampTriggerTest {
	
	@isTest static void test_should_set_country_on_insert() {
		// insert accounts
		List<Account> accounts = MERC_TestFactory.insertAccounts(2);

		// assert that accounts are null
		System.assertEquals(NULL, accounts[0].Primary_Address_Country_GLBL__c);
		System.assertEquals(NULL, accounts[1].Primary_Address_Country_GLBL__c);

		// insert address associated to first account
		Address_GLBL__c address0 = MERC_TestFactory.insertAddressWithCountry(accounts[0],'US');

		// retrieve accounts after address insertion
		accounts = [SELECT Id, Primary_Address_Country_GLBL__c FROM Account WHERE Id IN :accounts];

		// assert that only the first account has the address
		System.assertEquals('US', accounts[0].Primary_Address_Country_GLBL__c);
		System.assertEquals(NULL, accounts[1].Primary_Address_Country_GLBL__c);
	}

	@isTest static void test_should_set_country_on_update() {
		// insert accounts
		List<Account> accounts = MERC_TestFactory.insertAccounts(2);

		// assert that accounts are null
		System.assertEquals(NULL, accounts[0].Primary_Address_Country_GLBL__c);
		System.assertEquals(NULL, accounts[1].Primary_Address_Country_GLBL__c);

		// insert address associated to first account
		Address_GLBL__c address0 = MERC_TestFactory.insertAddressWithCountry(accounts[0],'US');

		// retrieve accounts after address insertion
		accounts = [SELECT Id, Primary_Address_Country_GLBL__c FROM Account WHERE Id IN :accounts];

		// assert that only the first account has the address
		System.assertEquals('US', accounts[0].Primary_Address_Country_GLBL__c);
		System.assertEquals(NULL, accounts[1].Primary_Address_Country_GLBL__c);

		// update address to have UK address
		address0.Adrs_Cntry_Cd_GLBL__c = 'GB';
		update address0;

		// retrieve accounts after address update
		accounts = [SELECT Id, Primary_Address_Country_GLBL__c FROM Account WHERE Id IN :accounts];
		
		// assert that the country has changed on the account
		System.assertEquals('GB', accounts[0].Primary_Address_Country_GLBL__c);
		System.assertEquals(NULL, accounts[1].Primary_Address_Country_GLBL__c);
	}
}