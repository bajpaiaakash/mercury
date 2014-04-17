trigger MERC_PreferencesAndConsent on Preferences_and_Consent_GLBL__c (after insert, after update) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_PrefConsentMappingHandler())
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_PrefConsentMappingHandler())
		.manage();

}