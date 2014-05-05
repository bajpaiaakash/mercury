/**
*
* @author Kyle Thornton
*
* This is the test class for MERC_AccountRollupHandler.
**/

@isTest
private class MERC_AccountRollupHandlerTest {
	static List<Account> hcpAccounts      = MERC_TestFactory.insertAccounts(100, Schema.SObjectType.Account.getRecordTypeInfosByName().get('HCP').getRecordTypeId());
	static User          testUser         = MERC_TestFactory.insertTestUsers(1, null).get(0);
	static String        desIndvRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Designated Individual').getRecordTypeId();
	static String        contrPartyTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contracting Party').getRecordTypeId();

	static
	{
		PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='Mercury_Customer_Meeting_Services_Edit' limit 1];
		insert new PermissionSetAssignment( PermissionSetId=ps.Id
			                              , AssigneeId=testUser.id);
		update new User( id=testUser.Id
			           , UserRoleId=[SELECT Id FROM UserRole WHERE Name='Global' limit 1].id);
	}

	@isTest static void test_should_on_insert_increment_account_counters_by_1()
	{
		System.runAs(testUser)
		{
			List<Account> relatedAccounts =  new List<Account>();
			for (Account a : hcpAccounts)
			{
				String randomString = MERC_Util.generateRandomString(8);
				relatedAccounts.add( new Account( FirstName    = 'UnitTestDI'
					                       , LastName     = randomString + 'di'
					                       , RecordTypeId = desIndvRecTypeId
					                       , PersonEmail  = 'ut-'+randomString+'@gmail.com'
					                       , HCP_MERC__c  = a.Id)
				);
				relatedAccounts.add( new Account( FirstName    = 'UnitTestCP'
					                       , LastName     = randomString + 'cp'
					                       , RecordTypeId = contrPartyTypeId
					                       , PersonEmail  = 'ut-'+randomString+'@gmail.com'
					                       , HCP_MERC__c  = a.Id)
				);
			}

			Test.startTest();
			insert relatedAccounts;
			Test.stopTest();

			hcpAccounts = [SELECT Id, Designated_Individual_Counter_MERC__c, Contracting_Parties_Counter_MERC__c FROM Account WHERE Id IN :hcpAccounts];
			System.assertEquals(100, hcpAccounts.size());
			for (Account a : hcpAccounts)
			{
				System.assertEquals(1, a.Designated_Individual_Counter_MERC__c);
				System.assertEquals(1, a.Contracting_Parties_Counter_MERC__c);
			}
		}
	}

	@isTest static void test_should_on_insert_increment_account_counters_by_100_for_first_acct()
	{
		System.runAs(testUser)
		{
			Test.startTest();
			List<Account> relatedAccounts =  new List<Account>();
			for (Integer i=0; i<100; i++)
			{
				String randomString = MERC_Util.generateRandomString(8);
				relatedAccounts.add( new Account( FirstName    = 'UnitTest'
					                       , LastName     = randomString + 'di'
					                       , RecordTypeId = desIndvRecTypeId
					                       , PersonEmail  = 'ut-'+randomString+'@gmail.com'
					                       , HCP_MERC__c  = hcpAccounts[0].Id)
				);
				relatedAccounts.add( new Account( FirstName    = 'UnitTest'
					                       , LastName     = randomString + 'cp'
					                       , RecordTypeId = contrPartyTypeId
					                       , PersonEmail  = 'ut-'+randomString+'@gmail.com'
					                       , HCP_MERC__c  = hcpAccounts[0].Id)
				);
			}
			insert relatedAccounts;
			Test.stopTest();

			System.assertEquals(100, [SELECT Id, Designated_Individual_Counter_MERC__c FROM Account WHERE Id =:hcpAccounts[0].Id].Designated_Individual_Counter_MERC__c);
			System.assertEquals(100, [SELECT Id, Contracting_Parties_Counter_MERC__c FROM Account WHERE Id =:hcpAccounts[0].Id].Contracting_Parties_Counter_MERC__c);
		}
	}

	@isTest static void test_should_on_update_increment_and_decrement_designated_counters_for_correct_accounts()
	{
		System.runAs(testUser)
		{
			List<Account> relatedAccounts =  new List<Account>();
			for (Integer i=0; i<100; i++)
			{
				String randomString = MERC_Util.generateRandomString(8);
				relatedAccounts.add( new Account( FirstName    = 'UnitTest'
					                       , LastName     = randomString + 'di'
					                       , RecordTypeId = desIndvRecTypeId
					                       , PersonEmail  = 'ut-'+randomString+'@gmail.com'
					                       , HCP_MERC__c  = hcpAccounts[0].Id)
				);
				relatedAccounts.add( new Account( FirstName    = 'UnitTest'
					                       , LastName     = randomString + 'cp'
					                       , RecordTypeId = contrPartyTypeId
					                       , PersonEmail  = 'ut-'+randomString+'@gmail.com'
					                       , HCP_MERC__c  = hcpAccounts[0].Id)
				);
			}
			insert relatedAccounts;

			/*----- at this point we know that we have account 1 with 100 DIs (per prior test) -----*/
			Test.startTest();
			for (Account a : relatedAccounts)
			{
				a.HCP_MERC__c = hcpAccounts[1].Id;
			}
			update relatedAccounts;
			Test.stopTest();

			/*----- verify that the count has gone down to 0 for the first account and up to 200 for the second -----*/
			System.assertEquals(0  , [SELECT Id, Designated_Individual_Counter_MERC__c FROM Account WHERE Id =:hcpAccounts[0].Id].Designated_Individual_Counter_MERC__c);
			System.assertEquals(100, [SELECT Id, Designated_Individual_Counter_MERC__c FROM Account WHERE Id =:hcpAccounts[1].Id].Designated_Individual_Counter_MERC__c);
			System.assertEquals(0  , [SELECT Id, Contracting_Parties_Counter_MERC__c FROM Account WHERE Id =:hcpAccounts[0].Id].Contracting_Parties_Counter_MERC__c);
			System.assertEquals(100, [SELECT Id, Contracting_Parties_Counter_MERC__c FROM Account WHERE Id =:hcpAccounts[1].Id].Contracting_Parties_Counter_MERC__c);
		}
	}

	@isTest static void test_should_handle_deletes_and_undeletes()
	{
		System.runAs(testUser)
		{
			List<Account> relatedAccounts =  new List<Account>();
			for (Integer i=0; i<100; i++)
			{
				String randomString = MERC_Util.generateRandomString(8);
				relatedAccounts.add( new Account( FirstName    = 'UnitTest'
					                       , LastName     = randomString + 'di'
					                       , RecordTypeId = desIndvRecTypeId
					                       , PersonEmail  = 'ut-'+randomString+'@gmail.com'
					                       , HCP_MERC__c  = hcpAccounts[0].Id)
				);
				relatedAccounts.add( new Account( FirstName    = 'UnitTest'
					                       , LastName     = randomString + 'cp'
					                       , RecordTypeId = contrPartyTypeId
					                       , PersonEmail  = 'ut-'+randomString+'@gmail.com'
					                       , HCP_MERC__c  = hcpAccounts[0].Id)
				);
			}
			insert relatedAccounts;

			Test.startTest();
			delete relatedAccounts;
			System.assertEquals(0  , [SELECT Id, Designated_Individual_Counter_MERC__c FROM Account WHERE Id =:hcpAccounts[0].Id].Designated_Individual_Counter_MERC__c);
			System.assertEquals(0  , [SELECT Id, Contracting_Parties_Counter_MERC__c FROM Account WHERE Id =:hcpAccounts[0].Id].Contracting_Parties_Counter_MERC__c);

			undelete relatedAccounts;
			System.assertEquals(100, [SELECT Id, Designated_Individual_Counter_MERC__c FROM Account WHERE Id =:hcpAccounts[0].Id].Designated_Individual_Counter_MERC__c);
			System.assertEquals(100, [SELECT Id, Contracting_Parties_Counter_MERC__c FROM Account WHERE Id =:hcpAccounts[0].Id].Contracting_Parties_Counter_MERC__c);
			Test.stopTest();
		}
	}

}