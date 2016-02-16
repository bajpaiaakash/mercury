/**
* MERC_MeetingTask Trigger
* Created By: Mavens Consulting
* Description: This trigger calls two classes to handle inserts, updates and deletes:
*	1.) MERC_LockedRecordHandler class that prevents Trigger actions on locked records.
*	2.) MERC_MeetingProcessHandler class that handles evalutation of rules on the Meeting_Process_Logic_MERC__c object.
*/
trigger MERC_MeetingTask on Meeting_Tasks_MERC__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    //for governor limit reasons, let's assign this once and only on before triggers
	Schema.DescribeFieldResult parentLookupField;
	if (Trigger.isBefore) {
		parentLookupField = Schema.sObjectType.Meeting_Tasks_MERC__c.fields.Meeting_MERC__c;
	}

	new GLBL_TriggerHandler()

		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_LockedRecordHandler(Meeting_Tasks_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_LockedRecordHandler(Meeting_Tasks_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforedelete, new MERC_LockedRecordHandler(Meeting_Tasks_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))

		.bind(GLBL_TriggerHandler.Evt.beforeinsert,   new MERC_MeetingProcessLogicHandler(Meeting_Tasks_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate,   new MERC_MeetingProcessLogicHandler(Meeting_Tasks_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterinsert,   new MERC_MeetingProcessLogicHandler(Meeting_Tasks_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterupdate,   new MERC_MeetingProcessLogicHandler(Meeting_Tasks_MERC__c.SobjectType))

        .manage();
}