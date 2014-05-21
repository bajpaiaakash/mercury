/**
* @author Kyle Thornton
*
* This is the unit test class for the MERC_MergedAccountsApex class which is used by the MERC_MergedAccountsController
* If you make changes to the setup in this test class you may also want to review if the same
* changes need to be made to MERC_MergedAccountControllerTest.cls
*/
@isTest
private class MERC_MergedAccountApexTest
{

	static User testUser;
	static {
		System.runas(new User(Id=UserInfo.getUserId()))
		{
			testUser = MERC_TestFactory.insertTestUsers(1, null).get(0);
			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='Mercury_Customer_Meeting_Services_Edit' limit 1];
			insert new PermissionSetAssignment(PermissionSetId=ps.Id, AssigneeId=testUser.id);
			update new User(id=testUser.Id, UserRoleId=[SELECT Id FROM UserRole WHERE Name='Global' limit 1].id);
		}
	}
	static Account winningAccount = MERC_TestFactory.insertMasterAccountsInCountry(1, 'GB').get(0);
	static Account losingAccount  = MERC_TestFactory.insertMasterAccountsInCountry(1, 'GB').get(0);
	static
	{
		insert new Merge_History_GLBL__c( Winning_Id_GLBL__c=winningAccount.Cust_Id_GLBL__c, Original_Account_ID_GLBL__c=losingAccount.Cust_Id_GLBL__c );

		List<Preferences_and_Consent_GLBL__c> prefConsentRecords = new List<Preferences_and_Consent_GLBL__c>();
		List<String> prefTypes  = new List<String>{'Language Preference','Communication Preference','Speaker Interest', 'Contract Delivery', 'Payment Required'};
		List<String> prefValues = new List<String>{'English','E-Mail','Contract Request', 'E-Mail', 'Yes'};
		for (Integer i=0; i<5; i++)
		{
			prefConsentRecords.add(
				new Preferences_and_Consent_GLBL__c( Preference_Type_MERC__c     = prefTypes[i]
                 								   , Preference_Sub_Type_MERC__c = prefValues[i]
                 								   , Account_GLBL__c             = winningAccount.Id)
			);
			prefConsentRecords.add(
				new Preferences_and_Consent_GLBL__c( Preference_Type_MERC__c     = prefTypes[i]
                 								   , Preference_Sub_Type_MERC__c = prefValues[i]
                 								   , Account_GLBL__c             = losingAccount.Id)
			);
		}
		insert prefConsentRecords;

		/*----- create a custom setting for pref and consent records.
		        we need to make assumptions about existing metadata like field sets -----*/
		insert new Account_Merge_Related_Lists_MERC__c( Name                         = 'Preferences_and_Consent_GLBL__c'
													  , Parent_Account_Field_MERC__c = 'Account_GLBL__c'
                                                      , Path_to_Cust_Id_MERC__c      = 'Account_GLBL__r.Cust_Id_GLBL__c'
													  , Winning_Acct_Related_List_Field_Set_MERC__c = 'Account_Merge_Pref_and_Consent_MERC'
													  , Losing_Acct_Related_List_Field_Set_MERC__c	= 'Account_Merge_Pref_and_Consent_MERC'
													  , Allow_Winning_Account_Deletes__c            = true
													  , Related_Object_API_Name__c                  = 'Preferences_and_Consent_GLBL__c');
	}

	@isTest static void test_should_initialize_object_and_related_lists()
	{
		System.runAs(testUser)
		{
			MERC_MergedAccountApex maa = new MERC_MergedAccountApex(winningAccount.Cust_Id_GLBL__c, losingAccount.Cust_Id_GLBL__c);
			System.assertEquals(1, maa.getAllRelatedLists().size());
			System.assertEquals(5, maa.getAllRelatedLists().get(0).winningList.size());
			System.assertEquals(5, maa.getAllRelatedLists().get(0).losingList.size());

		}
	}

	@isTest static void test_should_handle_query_exception_gracefully()
	{
		update new User(id=testUser.Id, UserRoleId=null);
		System.runAs(testUser)
		{
			Boolean exceptionCaught = false;
			try
			{
				MERC_MergedAccountApex maa = new MERC_MergedAccountApex(winningAccount.Cust_Id_GLBL__c, losingAccount.Cust_Id_GLBL__c);
			}
			catch(MERC_Exception ex)
			{
				System.assertEquals('An error has occurred querying for the account information.', ex.getMessage());
				exceptionCaught = true;
			}
			System.assert(exceptionCaught, 'No excpetion was caught.');
		}
	}

	@isTest static void test_should_return_winning_account()
	{
		System.runAs(testUser)
		{
			MERC_MergedAccountApex maa = new MERC_MergedAccountApex(winningAccount.Cust_Id_GLBL__c, losingAccount.Cust_Id_GLBL__c);
			System.assertEquals(winningAccount.Id, maa.getAccount().Id);
		}
	}

	@isTest static void test_should_remove_all_records_from_losing_account()
	{
		System.runAs(testUser)
		{
			MERC_MergedAccountApex maa = new MERC_MergedAccountApex(winningAccount.Cust_Id_GLBL__c, losingAccount.Cust_Id_GLBL__c);
			maa.destroyLosingRecords();
			System.assertEquals(0, maa.getAllRelatedLists().get(0).losingList.size());
		}
	}

	@isTest static void test_should_delete_selected_records_from_winning_account()
	{
		System.runAs(testUser)
		{
			MERC_MergedAccountApex maa = new MERC_MergedAccountApex(winningAccount.Cust_Id_GLBL__c, losingAccount.Cust_Id_GLBL__c);
			for (MERC_MergedAccountApex.SelectableSObject so : maa.getAllRelatedLists().get(0).winningList)
			{
				so.selected = true;
			}
			maa.getAllRelatedLists().get(0).deleteSelectedWinningRecords();
			System.assertEquals(0, maa.getAllRelatedLists().get(0).winningList.size());
		}
	}

	@isTest static void test_should_reparent_selected_losing_records_to_winning_account()
	{
		/*----- remove the prefs from the winning account so we don't get duplicate pref type errors -----*/
		delete [SELECT Id FROM Preferences_and_Consent_GLBL__c WHERE Account_GLBL__c=:winningAccount.Id];

		System.runAs(testUser)
		{
			MERC_MergedAccountApex maa = new MERC_MergedAccountApex(winningAccount.Cust_Id_GLBL__c, losingAccount.Cust_Id_GLBL__c);
			for (MERC_MergedAccountApex.SelectableSObject so : maa.getAllRelatedLists().get(0).losingList)
			{
				so.selected = true;
			}
			maa.getAllRelatedLists().get(0).mergeSelectedRecords();
			System.assertEquals(5, maa.getAllRelatedLists().get(0).winningList.size());
			System.assertEquals(0, maa.getAllRelatedLists().get(0).losingList.size());
		}
	}

	@isTest static void test_exceptions_should_be_caught()
	{
		System.runAs(testUser)
		{
			MERC_MergedAccountApex maa = new MERC_MergedAccountApex(winningAccount.Cust_Id_GLBL__c, losingAccount.Cust_Id_GLBL__c);

			/*----- setting to readOnlyApplicationMode will lock the system and prevent updates -----*/
			Test.setReadOnlyApplicationMode(true);

			/*----- attempt destroy losing records, ensure error caught -----*/
			maa.destroyLosingRecords();
			System.assertEquals(1, ApexPages.getMessages().size());

			/*----- attempt delete selected winning records, ensure error caught -----*/
			maa.getAllRelatedLists().get(0).winningList.get(0).selected=true;
			maa.getAllRelatedLists().get(0).deleteSelectedWinningRecords();
			System.assertEquals(2, ApexPages.getMessages().size());

			/*----- attempt merge selected losing records, ensure error caught -----*/
			maa.getAllRelatedLists().get(0).losingList.get(0).selected=true;
			maa.getAllRelatedLists().get(0).mergeSelectedRecords();
			System.assertEquals(3, ApexPages.getMessages().size());
		}
	}
}