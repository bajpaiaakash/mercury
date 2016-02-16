/**
* MERC_Answer Trigger
* Created By: Mavens Consulting
* Description: This trigger calls the LockedRecordHandler class that prevents Trigger actions on locked records.
*/
trigger MERC_Answer on Answer_MERC__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    //for governor limit reasons, let's assign this once and only on before triggers
	Schema.DescribeFieldResult parentLookupField;
	if (Trigger.isBefore) {
		parentLookupField = Schema.sObjectType.Answer_MERC__c.fields.Meeting_MERC__c;
	}

	new GLBL_TriggerHandler()

		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_LockedRecordHandler(Answer_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_LockedRecordHandler(Answer_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforedelete, new MERC_LockedRecordHandler(Answer_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))

        .manage();
}