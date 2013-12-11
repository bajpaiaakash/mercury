trigger MERC_TeamMember on Team_Member_MERC__c (after insert, after update, after delete, after undelete) {
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_TeamMemberShareHandler())
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_TeamMemberShareHandler())
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_TeamMemberShareHandler())
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_TeamMemberShareHandler())
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_DeleteNotifyService())
        .manage();
}