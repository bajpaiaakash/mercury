trigger MERC_Address on Address_GLBL__c (before insert, before update) {
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_AddressCountryStampTrigger())
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_AddressCountryStampTrigger())
        .manage();
}