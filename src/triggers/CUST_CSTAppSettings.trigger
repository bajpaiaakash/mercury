/*
 * @author Sean Harrison
 *
 * Binds Customer Search Tool Application Settings obj to CUST_RecordTypeIdLookup which
 * is responsible for setting Record Type ids based on Admin input.
 */
trigger CUST_CSTAppSettings on CST_App_Settings_CUST__c (before insert, before update) {
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new CUST_RecordTypeIdLookup())
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new CUST_RecordTypeIdLookup())
		.manage();
}