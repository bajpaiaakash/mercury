/**
 * @author Joseph Ferraro
 *
 * Test asserts MERC_AccountPreferenceRollupManager is properly rolling up dietary preferences to account
 */
@isTest
private class MERC_AccountPreferenceRollupManagerTest {

	static List<Account> accounts;
	static User runningUser = MERC_TestFactory.getRunningUser();
	static User testUser = MERC_TestFactory.getTestingUser();

	static {
		System.runAs(runningUser) {
			accounts = MERC_TestFactory.insertAccounts(100);
		}
	}

	@isTest static void test_should_rollup_dietary_preferences_to_account() {
		System.runAs(testUser) {

			Test.startTest();
			//insert three preferences
			MERC_TestFactory.insertPreferenceForAccounts(accounts, 'Meals Allergy Preferences', 'Halal', false);
			MERC_TestFactory.insertPreferenceForAccounts(accounts, 'Meals Allergy Preferences', 'Kosher', false);
			MERC_TestFactory.insertPreferenceForAccounts(accounts, 'Meals Allergy Preferences', 'Vegetarian', false);
			Test.stopTest();

			system.assertEquals(3, [SELECT Count_Dietary_Preferences_MERC__c FROM Account WHERE Id = :accounts.get(10).ID].Count_Dietary_Preferences_MERC__c);
			system.assertEquals(3, [SELECT Count_Dietary_Preferences_MERC__c FROM Account WHERE Id = :accounts.get(70).ID].Count_Dietary_Preferences_MERC__c);
		}
	}

	@isTest static void test_should_rollup_on_delete() {
		System.runAs(testUser) {
			//insert a preference
			MERC_TestFactory.insertPreferenceForAccounts(accounts, 'Meals Allergy Preferences', 'Kosher', false);

			//delete a preference, ensure a recalculation
			Test.startTest();
			delete [SELECT ID FROM Preferences_and_Consent_GLBL__c WHERE Preference_Sub_Type_MERC__c = 'Kosher'];
			Test.stopTest();

			system.assertEquals(0, [SELECT Count_Dietary_Preferences_MERC__c FROM Account WHERE Id = :accounts.get(10).ID].Count_Dietary_Preferences_MERC__c);
			system.assertEquals(0, [SELECT Count_Dietary_Preferences_MERC__c FROM Account WHERE Id = :accounts.get(70).ID].Count_Dietary_Preferences_MERC__c);
		}
	}
}