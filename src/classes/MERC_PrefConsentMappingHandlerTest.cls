@isTest
public with sharing class MERC_PrefConsentMappingHandlerTest {

	static List<Account> acctsList = MERC_TestFactory.insertAccounts(200);
	static User testUser = MERC_TestFactory.insertTestUsers(1, 'Mercury Meeting Functionary - Read Only').get(0);
	static Id recordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Preferences_and_Consent_GLBL__c' and DeveloperName = 'Preferences_Private_EVNT_MVN' limit 1].Id;
	static {
		insert new PC_to_Account_Mapping_MERC__c(
			Name                              = 'Communication Preference',
			PC_Record_Type_Id_MERC__c         = recordTypeId,
			Preference_Type_MERC__c           = 'Communication Preference',
			Account_Destination_Field_MERC__c = 'Communication_Preference_MERC__c'
		);
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
}