/**
* MERC_ContentVersion Trigger
* Created By: Mavens Consulting
* Description: This trigger calls three classes to handle inserts, updates and deletes:
*	1.) MERC_LockedRecordHandler class that prevents Trigger actions on locked records.
*	2.) MERC_ContentVersionHandler class that ensures that the Content RecordTypeId field is set based on the lookup provided.
*   3.) MERC_MeetingContentStampHandler class that stamps products on content version in the Product_X_Merc__c fields when content is associated to a meeting.
*/
trigger MERC_ContentVersion on ContentVersion (before insert, before update, before delete) {

	//for governor limit reasons, let's assign this once and only on before triggers
	Schema.DescribeFieldResult parentLookupField;
	if (Trigger.isBefore) {
		parentLookupField = Schema.sObjectType.ContentVersion.fields.Meeting_MERC__c;
	}

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_ContentVersionHandler())
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_LockedRecordHandler(ContentVersion.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_LockedRecordHandler(ContentVersion.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforedelete, new MERC_LockedRecordHandler(ContentVersion.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_MeetingContentStampHandler())
        .manage();
}