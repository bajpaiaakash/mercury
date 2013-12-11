trigger MERC_Meeting on Meeting_MERC__c (before insert, before update, after update, after delete) {

	new GLBL_TriggerHandler()
		//.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_TimeZoneCalculator('Meeting_MERC__c')) removing this for now, putting in vf controller
		//.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_TimeZoneCalculator('Meeting_MERC__c')) removing this for now, putting in vf controller
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_HcpCapActualsCalculator('Meeting_MERC__c'))
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_DeleteNotifyService())
        .manage();
}