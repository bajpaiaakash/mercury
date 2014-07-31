@isTest
private class MERC_UtilTest {
	static User testUser = MERC_TestFactory.getRunningUser();
	static
	{
		MERC_TestFactory.insertMercuryCustomSettings();
		MERC_TestFactory.loadTimeZoneFieldMapSettings();
	}

	@isTest static void exercise_utility_methods()
	{

		System.runAs(testUser)
		{
			MERC_Util.disableBudgetEditValidation();
			System.assertEquals(false, Mercury_Settings_MERC__c.getOrgDefaults().Budget_Edit_Validation_MERC__c);

			MERC_Util.enableBudgetEditValidation();
			System.assertEquals(true, Mercury_Settings_MERC__c.getOrgDefaults().Budget_Edit_Validation_MERC__c);

			String picklistValue = MERC_Util.getTimeZonePicklistValueForCurrentUser(Meeting_MERC__c.Meeting_Time_Zone_MERC__c.getDescribe());
			System.assertEquals('Greenwich Mean Time (GMT)', picklistValue);

			System.assert( MERC_Util.getPicklistValues(Account.Country_of_Residence_GLBL__c.getDescribe()).size() > 0);

			System.assert( MERC_Util.getPicklistValues(Account.Country_of_Residence_GLBL__c.getDescribe(),true).size() > 1);

			List<SelectOption> options = MERC_Util.getCSTPicklistValuesForFieldName('Affiliation_Role_Types_CUST__c', false);
			System.assert(options.size() > 0);
			List<SelectOption> optionsWithDefault = MERC_Util.getCSTPicklistValuesForFieldName('Affiliation_Role_Types_CUST__c', true);
			System.assert(optionsWithDefault.size() == options.size()+1);

			Account a = MERC_TestFactory.insertAccounts(1).get(0);
			System.assertEquals('Account', MERC_Util.getSobjectAPIName(a));

			System.assert(MERC_Util.getTimeZoneFieldMapForObject('Meeting_MERC__c').size() > 0);
			System.assert(MERC_Util.getStampFieldMapForObject('Meeting_MERC__c').size() > 0);

			System.assert(MERC_Util.getFieldSetFieldList('Meeting_Day_MERC__c', new List<String>{'Meeting_Day_Manager_Columns_MERC'}).size() > 0);

			PageReference pageRef = Page.Get_Started;
			pageRef.getParameters().put('test','value');
			Test.setCurrentPage(pageRef);

			System.assertEquals('value', MERC_Util.getUrlParam('test'));

			System.assert( MERC_Util.getFieldSetLabels(Meeting_MERC__c.SobjectType,new List<String> {'Meeting_Date_Time_Edit_MERC'}).size() > 0);
		}
	}
}