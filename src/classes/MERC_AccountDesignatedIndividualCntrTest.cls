/**
*
* @author Kyle Thornton
*
* This is the test class for MERC_AccountDesignatedIndividualsCounter.
* Note that MERC_AccountDesignatedIndividualsCounterTest was too long of a name
**/

@isTest
private class MERC_AccountDesignatedIndividualCntrTest
{

	static List<Account> hcpAccounts  = MERC_TestFactory.insertAccounts(200, Schema.SObjectType.Account.getRecordTypeInfosByName().get('HCP').getRecordTypeId());
	static User          testUser     = MERC_TestFactory.insertTestUsers(1, null).get(0);
	static String        hcpRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Designated Individual').getRecordTypeId();

	static
	{
		PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='Mercury_Customer_Meeting_Services_Edit' limit 1];
		insert new PermissionSetAssignment( PermissionSetId=ps.Id
			                              , AssigneeId=testUser.id);
		update new User( id=testUser.Id
			           , UserRoleId=[SELECT Id FROM UserRole WHERE Name='Global' limit 1].id);
	}

	@isTest static void test_should_on_insert_increment_account_designated_indv_counter_by_1()
	{
		System.runAs(testUser)
		{
			Test.startTest();
			List<Account> diAccounts =  new List<Account>();
			for (Account a : hcpAccounts)
			{
				String randomString = MERC_Util.generateRandomString(8);
				diAccounts.add( new Account( FirstName    = 'UnitTest'
					                       , LastName     = randomString
					                       , RecordTypeId = hcpRecTypeId
					                       , PersonEmail  = 'ut-'+randomString+'@gmail.com'
					                       , HCP_MERC__c  = a.Id)
				);
			}
			insert diAccounts;
			Test.stopTest();

			hcpAccounts = [SELECT Id, Designated_Individual_Counter_MERC__c FROM Account WHERE Id IN :hcpAccounts];
			System.assertEquals(200, hcpAccounts.size());
			for (Account a : hcpAccounts)
			{
				System.assertEquals(1, a.Designated_Individual_Counter_MERC__c);
			}
		}
	}

	@isTest static void test_should_on_insert_increment_account_designated_indv_counter_by_200_for_first_acct()
	{
		System.runAs(testUser)
		{
			Test.startTest();
			List<Account> diAccounts =  new List<Account>();
			for (Integer i=0; i<200; i++)
			{
				String randomString = MERC_Util.generateRandomString(8);
				diAccounts.add( new Account( FirstName    = 'UnitTest'
					                       , LastName     = randomString
					                       , RecordTypeId = hcpRecTypeId
					                       , PersonEmail  = 'ut-'+randomString+'@gmail.com'
					                       , HCP_MERC__c  = hcpAccounts[0].Id)
				);
			}
			insert diAccounts;
			Test.stopTest();

			System.assertEquals(200, [SELECT Id, Designated_Individual_Counter_MERC__c FROM Account WHERE Id =:hcpAccounts[0].Id].Designated_Individual_Counter_MERC__c);
		}
	}

	@isTest static void test_should_on_update_increment_and_decrement_designated_indv_counter_for_correct_accounts()
	{
		System.runAs(testUser)
		{
			List<Account> diAccounts =  new List<Account>();
			for (Integer i=0; i<200; i++)
			{
				String randomString = MERC_Util.generateRandomString(8);
				diAccounts.add( new Account( FirstName    = 'UnitTest'
					                       , LastName     = randomString
					                       , RecordTypeId = hcpRecTypeId
					                       , PersonEmail  = 'ut-'+randomString+'@gmail.com'
					                       , HCP_MERC__c  = hcpAccounts[0].Id)
				);
			}
			insert diAccounts;

			/*----- at this point we know that we have account 1 with 200 DIs (per prior test) -----*/
			Test.startTest();
			for (Account a : diAccounts)
			{
				a.HCP_MERC__c = hcpAccounts[1].Id;
			}
			update diAccounts;
			Test.stopTest();

			/*----- verify that the count has gone down to 0 for the first account and up to 200 for the second -----*/
			System.assertEquals(0  , [SELECT Id, Designated_Individual_Counter_MERC__c FROM Account WHERE Id =:hcpAccounts[0].Id].Designated_Individual_Counter_MERC__c);
			System.assertEquals(200, [SELECT Id, Designated_Individual_Counter_MERC__c FROM Account WHERE Id =:hcpAccounts[1].Id].Designated_Individual_Counter_MERC__c);
		}
	}

	@isTest static void test_should_handle_deletes_and_undeletes()
	{
		System.runAs(testUser)
		{
			List<Account> diAccounts =  new List<Account>();
			for (Integer i=0; i<200; i++)
			{
				String randomString = MERC_Util.generateRandomString(8);
				diAccounts.add( new Account( FirstName    = 'UnitTest'
					                       , LastName     = randomString
					                       , RecordTypeId = hcpRecTypeId
					                       , PersonEmail  = 'ut-'+randomString+'@gmail.com'
					                       , HCP_MERC__c  = hcpAccounts[0].Id)
				);
			}
			insert diAccounts;

			Test.startTest();
			delete diAccounts;
			System.assertEquals(0  , [SELECT Id, Designated_Individual_Counter_MERC__c FROM Account WHERE Id =:hcpAccounts[0].Id].Designated_Individual_Counter_MERC__c);

			undelete diAccounts;
			System.assertEquals(200, [SELECT Id, Designated_Individual_Counter_MERC__c FROM Account WHERE Id =:hcpAccounts[0].Id].Designated_Individual_Counter_MERC__c);
			Test.stopTest();
		}
	}

}