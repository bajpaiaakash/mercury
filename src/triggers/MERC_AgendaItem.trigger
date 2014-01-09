trigger MERC_AgendaItem on Agenda_Item_MERC__c (before insert, before update, after update, after delete) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_TimestampHandler(Agenda_Item_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_TimestampHandler(Agenda_Item_MERC__c.SobjectType))
        .manage();
}