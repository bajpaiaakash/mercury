@isTest
public with sharing class MERC_PrefConsentMappingHandlerTest {

	static List<Account> acctsList = MERC_TestFactory.insertAccounts(200);
<<<<<<< HEAD
	static User testUser = new User(Id=UserInfo.getUserId()); //MERC_TestFactory.insertTestUsers(1, 'Mercury Meeting Functionary - Read Only').get(0);
	static Id recordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Preferences_and_Consent_GLBL__c' and DeveloperName = 'Preferences_Private_EVNT_MVN' limit 1].Id;
	static {
		List<PC_to_Account_Mapping_MERC__c> mappings =  new LIst<PC_to_Account_Mapping_MERC__c>();
		mappings.add (new PC_to_Account_Mapping_MERC__c(
=======
	static User testUser = MERC_TestFactory.insertTestUsers(1, 'Mercury Meeting Functionary - Read Only').get(0);
	static Id recordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Preferences_and_Consent_GLBL__c' and DeveloperName = 'Preferences_Private_EVNT_MVN' limit 1].Id;
	static {
		insert new PC_to_Account_Mapping_MERC__c(
>>>>>>> 038d9c54d876da9a1530fddfc3f8fbb7b4bdc2f5
			Name                              = 'Communication Preference',
			PC_Record_Type_Id_MERC__c         = recordTypeId,
			Preference_Type_MERC__c           = 'Communication Preference',
			Account_Destination_Field_MERC__c = 'Communication_Preference_MERC__c'
<<<<<<< HEAD
		));

		/*----- add a second preference to make sure the system can handle multiple preferences per recordTypeID -----*/
		mappings.add (new PC_to_Account_Mapping_MERC__c(
			Name                              = 'Second Preference',
			PC_Record_Type_Id_MERC__c         = recordTypeId,
			Preference_Type_MERC__c           = 'Second Preference',
			Account_Destination_Field_MERC__c = 'Communication_Preference_MERC__c'
		));

		insert mappings;
=======
		);
>>>>>>> 038d9c54d876da9a1530fddfc3f8fbb7b4bdc2f5
	}

	@isTest static void test_should_copy_preference_info_to_account() {
		System.runAs(testUser) {
			List<Preferences_and_Consent_GLBL__c> prefList = new List<Preferences_and_Consent_GLBL__c>();
			for (Account acct : acctsList) {
				prefList.add( new Preferences_and_Consent_GLBL__c(
								Account_GLBL__c             = acct.Id,
								RecordTypeId                = recordTypeId,
								Preference_Type_MERC__c     = 'Communication Preference',
								Preference_Sub_Type_MERC__c = 'E-Mail')
				);
			}

			Test.startTest();
			insert prefList;
			Test.stopTest();
			System.assertEquals(200, [SELECT COUNT() FROM Account WHERE Communication_Preference_MERC__c = 'E-Mail' AND Id IN :acctsList]);
		}
	}
<<<<<<< HEAD

	@isTest static void test_should_copy_preference_info_to_account_when_pref_type_is_other() {
		System.runAs(testUser) {
			List<Preferences_and_Consent_GLBL__c> prefList = new List<Preferences_and_Consent_GLBL__c>();
			for (Account acct : acctsList) {
				prefList.add( new Preferences_and_Consent_GLBL__c(
								Account_GLBL__c             = acct.Id,
								RecordTypeId                = recordTypeId,
								Preference_Type_MERC__c     = 'Communication Preference',
								Preference_Sub_Type_MERC__c = 'Other',
								Preference_Value_MERC__c    = 'My Value')
				);
			}

			Test.startTest();
			insert prefList;
			Test.stopTest();
			System.assertEquals(200, [SELECT COUNT() FROM Account WHERE Communication_Preference_MERC__c = 'My Value' AND Id IN :acctsList]);
		}
	}
=======
>>>>>>> 038d9c54d876da9a1530fddfc3f8fbb7b4bdc2f5
}