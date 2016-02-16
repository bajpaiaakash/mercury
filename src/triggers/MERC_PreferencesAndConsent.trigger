/**
* MERC_PreferencesAndConsent
* Created By: Mavens Consulting
* Description: This trigger calls two classes to handle inserts, updates and deletes:
*	1.) MERC_AccountPreferenceRollupManager class that ensures preference rollups are run on preference/consent DML operations.
*	2.) MERC_PrefConsentMappingHandler class that is responsible for parsing a value placed in Account_Field_Update_MERC__c in the format where api_name is the api name of the account field on the parent account to write to and value is the actual value to write to that field.
*/
trigger MERC_PreferencesAndConsent on Preferences_and_Consent_GLBL__c (after insert, after update, after delete, after undelete) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.afterinsert,   new MERC_PrefConsentMappingHandler())
		.bind(GLBL_TriggerHandler.Evt.afterupdate,   new MERC_PrefConsentMappingHandler())
		.bind(GLBL_TriggerHandler.Evt.afterdelete,   new MERC_PrefConsentMappingHandler())
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_PrefConsentMappingHandler())

		.bind(GLBL_TriggerHandler.Evt.afterinsert,   new MERC_AccountPreferenceRollupManager())
		.bind(GLBL_TriggerHandler.Evt.afterupdate,   new MERC_AccountPreferenceRollupManager())
		.bind(GLBL_TriggerHandler.Evt.afterdelete,   new MERC_AccountPreferenceRollupManager())
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_AccountPreferenceRollupManager())
		.manage();
}