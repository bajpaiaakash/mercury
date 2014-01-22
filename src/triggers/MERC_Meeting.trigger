trigger MERC_Meeting on Meeting_MERC__c (before insert, before update, after insert, after update, after delete) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_TimestampHandler(Meeting_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_TimestampHandler(Meeting_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_MeetingCampaignHandler())
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_HcpCapActualsCalculator('Meeting_MERC__c'))
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_DeleteNotifyService())
        .manage();
}