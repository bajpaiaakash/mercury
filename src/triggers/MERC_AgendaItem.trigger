/**
* MERC_AgendaItem Trigger
* Created By: Joe Ferraro, Mavens Consulting
* Description: This trigger's main function is calling two classes:
* 		1.) MERC_LockedRecordHandler which prevents Trigger actions on locked records
* 		2.) MERC_TimeStampHandler which stamps static text field with a user-friendly date/time value
*/
trigger MERC_AgendaItem on Agenda_Item_MERC__c (before insert, before update, before delete, after update, after delete) {

	//for governor limit reasons, let's assign this once and only on before triggers
	Schema.DescribeFieldResult parentLookupField;
	if (Trigger.isBefore) {
		parentLookupField = Schema.sObjectType.Agenda_Item_MERC__c.fields.Meeting_MERC__c;	
	}

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_LockedRecordHandler(Agenda_Item_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_LockedRecordHandler(Agenda_Item_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforedelete, new MERC_LockedRecordHandler(Agenda_Item_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_TimestampHandler(Agenda_Item_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_TimestampHandler(Agenda_Item_MERC__c.SobjectType))
        .manage();
}