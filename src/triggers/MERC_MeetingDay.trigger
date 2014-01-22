trigger MERC_MeetingDay on Meeting_Day_MERC__c (before insert, before update, after insert, after update, after delete, after undelete) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_TimestampHandler(Meeting_Day_MERC__c.sObjectType))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_TimestampHandler(Meeting_Day_MERC__c.sObjectType))
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_TOVCalculator(Meeting_Day_MERC__c.sObjectType))
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_TOVCalculator(Meeting_Day_MERC__c.sObjectType))
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_TOVCalculator(Meeting_Day_MERC__c.sObjectType))
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_TOVCalculator(Meeting_Day_MERC__c.sObjectType))
        .manage();

}