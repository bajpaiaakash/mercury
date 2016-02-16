/**
* MERC_MeetingProducts Trigger
* Created By: Mavens Consulting
* Description: This trigger calls two classes to handle inserts, updates and deletes:
*	1.) MERC_LockedRecordHandler class that prevents Trigger actions on locked records.
*	2.) MERC_DeleteNotifyService class that notifies the Real-Time Integration listener of deletes.
*/
trigger MERC_MeetingProducts on Meeting_Products_MERC__c (before insert, before update, before delete, after delete) {

	//for governor limit reasons, let's assign this once and only on before triggers
	Schema.DescribeFieldResult parentLookupField;
	if (Trigger.isBefore) {
		parentLookupField = Schema.sObjectType.Meeting_Products_MERC__c.fields.Meeting_MERC__c;	
	}

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_LockedRecordHandler(Meeting_Products_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_LockedRecordHandler(Meeting_Products_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforedelete, new MERC_LockedRecordHandler(Meeting_Products_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_DeleteNotifyService())
        .manage();

}