trigger MERC_TeamMember on Team_Member_MERC__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	
	//for governor limit reasons, let's assign this once and only on before triggers
	Schema.DescribeFieldResult parentLookupField;
	if (Trigger.isBefore) {
		parentLookupField = Schema.sObjectType.Team_Member_MERC__c.fields.Meeting_MERC__c;	
	}

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_LockedRecordHandler(Team_Member_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_LockedRecordHandler(Team_Member_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforedelete, new MERC_LockedRecordHandler(Team_Member_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_TeamMemberShareHandler())
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_TeamMemberShareHandler())
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_TeamMemberShareHandler())
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_TeamMemberShareHandler())
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_DeleteNotifyService())
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_TeamMemberDeletePMO())
        .manage();
}