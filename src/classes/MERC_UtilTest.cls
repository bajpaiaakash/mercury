/**
* MERC_UtilTest
* Created By: Mavens Consulting 
* Description: Tests all the utility methods in the MERC_Util class.
*/
@isTest
private class MERC_UtilTest {
	static User runningUser = MERC_TestFactory.getRunningUser();
	static User testUser = MERC_TestFactory.getTestingUser();
	static
	{
		MERC_TestFactory.insertMercuryCustomSettings();
		MERC_TestFactory.loadTimeZoneFieldMapSettings();
	}

	@isTest static void exercise_select_all_inner_class_with_empty_constructor()
	{
		Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1)[0];
		System.runAs(testUser)
		{
			MERC_Util.SelectAll selectAll1 = new MERC_Util.SelectAll(); //exercise empty constructor
			System.assertEquals(null, selectAll1.allFields);
			System.assertEquals(null, selectAll1.SOQL);
			System.assertEquals(null, selectAll1.d);
		}
	}

	@isTest static void exercise_select_all_inner_class_with_meeting_id()
	{
		Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1)[0];
		System.runAs(testUser)
		{
			MERC_Util.SelectAll selectAll = new MERC_Util.SelectAll(Meeting_MERC__c.SobjectType, meeting.id);
			System.assert(selectAll.allFields.contains('status_merc__c'));
			System.assert(selectAll.SOQL.startsWith('SELECT'));
			System.assertEquals(Meeting_MERC__c.SobjectType.getDescribe(), selectAll.d);
		}
	}

	@isTest static void exercise_select_all_inner_class_with_meeting()
	{
		Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1)[0];
		System.runAs(testUser)
		{
			MERC_Util.SelectAll selectAll = new MERC_Util.SelectAll(Meeting_MERC__c.SobjectType);
			System.assert(selectAll.allFields.contains('status_merc__c'));
			System.assertEquals(null, selectAll.SOQL);
			System.assertEquals(Meeting_MERC__c.SobjectType.getDescribe(), selectAll.d);
		}
	}

	@isTest static void exercise_select_all_inner_class_by_meeting_id()
	{
		Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1)[0];
		System.runAs(testUser)
		{
			MERC_Util.SelectAll selectAll = new MERC_Util.SelectAll(Meeting_MERC__c.SobjectType);
			selectAll.byId(meeting.id);
			System.assert(selectAll.allFields.contains('status_merc__c'));
			System.assert(selectAll.SOQL.startsWith('SELECT'));
			System.assert(selectAll.SOQL.endsWith('\'' + meeting.id + '\''));
			System.assertEquals(Meeting_MERC__c.SobjectType.getDescribe(), selectAll.d);
		}
	}

	@isTest static void exercise_select_all_inner_class_by_theListName()
	{
		Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1)[0];
		System.runAs(testUser)
		{
			MERC_Util.SelectAll selectAll = new MERC_Util.SelectAll(Meeting_MERC__c.SobjectType);
			selectAll.byList('theListName');
			System.assert(selectAll.allFields.contains('status_merc__c'));
			System.assert(selectAll.SOQL.endsWith(':theListName'));
			System.assertEquals(Meeting_MERC__c.SobjectType.getDescribe(), selectAll.d);
		}
	}

	@isTest static void exercise_remoteResponse_inner_class()
	{
		System.runAs(testUser)
		{
			MERC_Util.RemoteResponse r= new MERC_Util.RemoteResponse(true, 'a String', 'a cid');
			System.assertEquals(true,r.success);
			System.assertEquals('a String',r.message);
			System.assertEquals('a cid',r.contextId);
		}
	}

	@isTest static void test_enable_budged_edit_validation()
	{
		System.runAs(testUser) {
			MERC_Util.enableBudgetEditValidation();
			System.assertEquals(true, Mercury_Settings_MERC__c.getOrgDefaults().Budget_Edit_Validation_MERC__c);
		}
	}

	@isTest static void test_disable_budged_edit_validation()
	{
		System.runAs(testUser) {
			MERC_Util.disableBudgetEditValidation();
			System.assertEquals(false, Mercury_Settings_MERC__c.getOrgDefaults().Budget_Edit_Validation_MERC__c);
		}
	}

	@isTest static void test_picklist_methods()
	{
		System.runAs(testUser) {
			String picklistValue = MERC_Util.getTimeZonePicklistValueForCurrentUser(Meeting_MERC__c.Meeting_Time_Zone_MERC__c.getDescribe());
			System.assertEquals('Greenwich Mean Time (GMT)', picklistValue);

			System.assert( MERC_Util.getPicklistValues(Account.Country_of_Residence_GLBL__c.getDescribe()).size() > 0);

			System.assert( MERC_Util.getPicklistValues(Account.Country_of_Residence_GLBL__c.getDescribe(),true).size() > 1);

			List<SelectOption> options = MERC_Util.getCSTPicklistValuesForFieldName('Affiliation_Role_Types_CUST__c', false);
			System.assert(options.size() > 0);
			List<SelectOption> optionsWithDefault = MERC_Util.getCSTPicklistValuesForFieldName('Affiliation_Role_Types_CUST__c', true);
			System.assert(optionsWithDefault.size() == options.size()+1);
		}
	}

	@isTest static void exercise_other_utility_methods()
	{

		System.runAs(testUser) {
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

			Set<String> fieldVals = MERC_Util.getPicklistValueList(Meeting_MERC__c.Meeting_Status_MERC__c.getDescribe());
			System.assertEquals(6, fieldVals.size());
			System.assert(fieldVals.contains('Active'));

			//can't add user to territory in test so we just exercise as much code as we can here.
			System.assert(MERC_Util.getCountryPicklistValuesForCurrentUser(false).isEmpty());

			System.assertEquals(0, MERC_Util.getTerrDescendents(new Map<Id, Territory>(), new Map<Id, Territory>()).size());
		}
	}
}