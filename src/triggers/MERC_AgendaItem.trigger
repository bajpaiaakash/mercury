trigger MERC_AgendaItem on Agenda_Item_MERC__c (before insert, before update, before delete, after update, after delete) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_LockedRecordHandler(Agenda_Item_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, Schema.sObjectType.Agenda_Item_MERC__c.fields.Meeting_MERC__c))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_LockedRecordHandler(Agenda_Item_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, Schema.sObjectType.Agenda_Item_MERC__c.fields.Meeting_MERC__c))
		.bind(GLBL_TriggerHandler.Evt.beforedelete, new MERC_LockedRecordHandler(Agenda_Item_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, Schema.sObjectType.Agenda_Item_MERC__c.fields.Meeting_MERC__c))
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_TimestampHandler(Agenda_Item_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_TimestampHandler(Agenda_Item_MERC__c.SobjectType))
        .manage();
}