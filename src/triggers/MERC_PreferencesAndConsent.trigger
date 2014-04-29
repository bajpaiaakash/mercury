trigger MERC_PreferencesAndConsent on Preferences_and_Consent_GLBL__c (after insert, after update, after delete, after undelete) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_PrefConsentMappingHandler())
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_PrefConsentMappingHandler())
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_AccountPreferenceRollupManager())
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_AccountPreferenceRollupManager())
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_AccountPreferenceRollupManager())
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_AccountPreferenceRollupManager())
		.manage();
}