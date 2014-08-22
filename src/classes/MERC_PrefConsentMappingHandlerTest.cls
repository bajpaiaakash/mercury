/**
* @author Kyle Thornton
*
* This is the unit test class for MERC_PrefConsentMappingHandler.cls
*/
@isTest
public with sharing class MERC_PrefConsentMappingHandlerTest {

	static User testUser;
	
	static final Integer NUM_TEST_ACCTS = 200;
	static List<Account> acctsList      = new List<Account>();

	static {
		testUser = MERC_TestFactory.getUserInRole('CEO');

		User employeeUser = MERC_TestFactory.getUserInRole('Lilly Employee');
		System.runAs(employeeUser){
			acctsList = MERC_TestFactory.insertAccounts(NUM_TEST_ACCTS);	
		}				
	}	

	@isTest static void test_should_copy_preference_info_to_account_for_private_preference() {
		// test user doesn't have access to private prefs. run as admin.
		List<Preferences_and_Consent_GLBL__c> prefList = new List<Preferences_and_Consent_GLBL__c>();
		Id recordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Preferences_and_Consent_GLBL__c' and DeveloperName = 'Preferences_EVNT_MVN' limit 1].Id;
		for (Account acct : acctsList) {
			prefList.add( new Preferences_and_Consent_GLBL__c(
							Account_GLBL__c             = acct.Id,
							RecordTypeId                = recordTypeId,
							Account_Field_Update_MERC__c= 'Communication_Preference_MERC__c=E-mail')
			);
		}

		Test.startTest();
		insert prefList;
		Test.stopTest();
		System.assertEquals(NUM_TEST_ACCTS, [SELECT COUNT() FROM Account WHERE Communication_Preference_MERC__c = 'E-Mail' AND Id IN :acctsList]);

	}

	@isTest static void test_should_copy_preference_info_to_account_for_public_preference() {
		System.runAs(testUser) {
			List<Preferences_and_Consent_GLBL__c> prefList = new List<Preferences_and_Consent_GLBL__c>();
			Id recordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Preferences_and_Consent_GLBL__c' and DeveloperName = 'Preferences_EVNT_MVN' limit 1].Id;
			for (Account acct : acctsList) {
				prefList.add( new Preferences_and_Consent_GLBL__c(
								Account_GLBL__c             = acct.Id,
								RecordTypeId                = recordTypeId,
								Account_Field_Update_MERC__c= 'Communication_Preference_MERC__c=A longer value')
				);
			}

			Test.startTest();
			insert prefList;
			Test.stopTest();
			System.assertEquals(NUM_TEST_ACCTS, [SELECT COUNT() FROM Account WHERE Communication_Preference_MERC__c = 'A longer value' AND Id IN :acctsList]);
		}
	}

	@isTest static void test_should_fail_gracefully() {
		System.runAs(testUser) {
			List<Preferences_and_Consent_GLBL__c> prefList = new List<Preferences_and_Consent_GLBL__c>();
			Id recordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Preferences_and_Consent_GLBL__c' and DeveloperName = 'Preferences_EVNT_MVN' limit 1].Id;
			for (Account acct : acctsList) {
				prefList.add( new Preferences_and_Consent_GLBL__c(
								Account_GLBL__c             = acct.Id,
								RecordTypeId                = recordTypeId,
								Account_Field_Update_MERC__c= 'Communication_Preference_MERC__c=A longer value that is too long for the field that we are writing to so it will break')
				);
			}

			Test.startTest();
			Boolean capturedException = false;
			try
			{
				insert prefList;
			}
			catch(System.DMLException ex)
			{
				capturedException = true;
				System.assert(ex.getMessage().contains('An error has occurred updating an associated account.'), ex);
			}
			Test.stopTest();
			System.assert(capturedException);
		}
	}

	@isTest static void test_should_keep_account_in_sync_on_delete() {
		System.runAs(testUser) {
			List<Preferences_and_Consent_GLBL__c> prefList1 = new List<Preferences_and_Consent_GLBL__c>();
			List<Preferences_and_Consent_GLBL__c> prefList2 = new List<Preferences_and_Consent_GLBL__c>();
			Id recordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Preferences_and_Consent_GLBL__c' and DeveloperName = 'Preferences_EVNT_MVN' limit 1].Id;
			for (Account acct : acctsList) {
				prefList1.add( new Preferences_and_Consent_GLBL__c(
								Account_GLBL__c             = acct.Id,
								RecordTypeId                = recordTypeId,
								Preference_Type_MERC__c     = 'Communication Preference',
								Preference_Sub_Type_MERC__c = 'E-mail')
				);

				prefList2.add( new Preferences_and_Consent_GLBL__c(
								Account_GLBL__c             = acct.Id,
								RecordTypeId                = recordTypeId,
								Preference_Type_MERC__c     = 'Language Preference',
								Preference_Sub_Type_MERC__c = 'en')
				);
			}

			insert prefList1;
			insert prefList2;
			System.assertEquals(NUM_TEST_ACCTS, [SELECT COUNT() FROM Account WHERE Communication_Preference_MERC__c = 'E-mail' AND Id IN :acctsList]);
			System.assertEquals(NUM_TEST_ACCTS, [SELECT COUNT() FROM Account WHERE Language_Preference_MERC__c = 'en' AND Id IN :acctsList]);

			Test.startTest();
			delete prefList2;
			Test.stopTest();

			System.assertEquals(NUM_TEST_ACCTS, [SELECT COUNT() FROM Account WHERE Communication_Preference_MERC__c = 'E-mail' AND Id IN :acctsList]);
			System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Language_Preference_MERC__c = 'en' AND Id IN :acctsList]);
		}
	}
}