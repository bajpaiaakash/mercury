trigger MERC_ContentVersion on ContentVersion (before insert, before update, before delete) {
	
	//for governor limit reasons, let's assign this once 
	Schema.DescribeFieldResult parentLookupField = Schema.sObjectType.ContentVersion.fields.Meeting_MERC__c;
	
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_LockedRecordHandler(ContentVersion.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_LockedRecordHandler(ContentVersion.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforedelete, new MERC_LockedRecordHandler(ContentVersion.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_ContentVersionHandler())
        .manage();
}