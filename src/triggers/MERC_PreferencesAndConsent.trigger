trigger MERC_PreferencesAndConsent on Preferences_and_Consent_GLBL__c (before insert, before update) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_PrefConsentMappingHandler())
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_PrefConsentMappingHandler())
		.manage();

}