trigger CUST_CSTAppSettings on CST_App_Settings_CUST__c (before insert, before update) {
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new CUST_RecordTypeIdLookup())
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new CUST_RecordTypeIdLookup())
		.manage();
}