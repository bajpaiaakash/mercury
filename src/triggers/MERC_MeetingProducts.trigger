trigger MERC_MeetingProducts on Meeting_Products_MERC__c (before insert, before update, before delete, after delete) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_LockedRecordHandler(Meeting_Products_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, Schema.sObjectType.Meeting_Products_MERC__c.fields.Meeting_MERC__c))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_LockedRecordHandler(Meeting_Products_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, Schema.sObjectType.Meeting_Products_MERC__c.fields.Meeting_MERC__c))
		.bind(GLBL_TriggerHandler.Evt.beforedelete, new MERC_LockedRecordHandler(Meeting_Products_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, Schema.sObjectType.Meeting_Products_MERC__c.fields.Meeting_MERC__c))
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_DeleteNotifyService())
        .manage();

}