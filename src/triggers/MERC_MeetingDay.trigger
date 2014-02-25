trigger MERC_MeetingDay on Meeting_Day_MERC__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	//for governor limit reasons, let's assign this once 
	Schema.DescribeFieldResult parentLookupField = Schema.sObjectType.Meeting_Day_MERC__c.fields.Meeting_MERC__c;
	
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_LockedRecordHandler(Meeting_Day_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_LockedRecordHandler(Meeting_Day_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforedelete, new MERC_LockedRecordHandler(Meeting_Day_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_TimestampHandler(Meeting_Day_MERC__c.sObjectType))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_TimestampHandler(Meeting_Day_MERC__c.sObjectType))
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_TOVCalculator(Meeting_Day_MERC__c.sObjectType))
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_TOVCalculator(Meeting_Day_MERC__c.sObjectType))
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_TOVCalculator(Meeting_Day_MERC__c.sObjectType))
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_TOVCalculator(Meeting_Day_MERC__c.sObjectType))
        .manage();

}