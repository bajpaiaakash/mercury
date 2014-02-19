trigger MERC_TeamMember on Team_Member_MERC__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_LockedRecordHandler(Team_Member_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, Schema.sObjectType.Team_Member_MERC__c.fields.Meeting_MERC__c))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_LockedRecordHandler(Team_Member_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, Schema.sObjectType.Team_Member_MERC__c.fields.Meeting_MERC__c))
		.bind(GLBL_TriggerHandler.Evt.beforedelete, new MERC_LockedRecordHandler(Team_Member_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, Schema.sObjectType.Team_Member_MERC__c.fields.Meeting_MERC__c))
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_TeamMemberShareHandler())
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_TeamMemberShareHandler())
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_TeamMemberShareHandler())
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_TeamMemberShareHandler())
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_DeleteNotifyService())
        .manage();
}