trigger MERC_MeetingVendor on Meeting_Vendor_MERC__c (before insert, before update, before delete, after update) {

	//for governor limit reasons, let's assign this once 
	Schema.DescribeFieldResult parentLookupField = Schema.sObjectType.Meeting_Vendor_MERC__c.fields.Meeting_MERC__c;
	
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_LockedRecordHandler(Meeting_Vendor_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_LockedRecordHandler(Meeting_Vendor_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforedelete, new MERC_LockedRecordHandler(Meeting_Vendor_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_TOVCalculator(Meeting_Vendor_MERC__c.SobjectType))
        .manage();

}