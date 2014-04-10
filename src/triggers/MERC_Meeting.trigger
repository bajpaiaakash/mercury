trigger MERC_Meeting on Meeting_MERC__c (before insert, before update, before delete, after insert, after update, after delete) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_LockedRecordHandler(Meeting_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.beforedelete, new MERC_LockedRecordHandler(Meeting_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_TimestampHandler(Meeting_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_TimestampHandler(Meeting_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_HcpCapActualsCalculator(Meeting_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_DeleteNotifyService())
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_MeetingCancellationHandler())
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_MeetingCancellationHandler())
        .manage();
}