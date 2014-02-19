trigger MERC_ContentVersion on ContentVersion (before insert, before update, before delete) {
	new GLBL_TriggerHandler()
		//.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_LockedRecordHandler(ContentVersion.SobjectType, Meeting_MERC__c.SobjectType, Schema.sObjectType.ContentVersion.fields.Meeting_MERC__c))
		//.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_LockedRecordHandler(ContentVersion.SobjectType, Meeting_MERC__c.SobjectType, Schema.sObjectType.ContentVersion.fields.Meeting_MERC__c))
		//.bind(GLBL_TriggerHandler.Evt.beforedelete, new MERC_LockedRecordHandler(ContentVersion.SobjectType, Meeting_MERC__c.SobjectType, Schema.sObjectType.ContentVersion.fields.Meeting_MERC__c))
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_ContentVersionHandler())
        .manage();
}