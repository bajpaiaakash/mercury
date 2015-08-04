trigger MERC_MeetingProcess on Meeting_Process_MERC__c (before insert, before update, after insert, after update, after delete, after undelete) {
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_MeetingProcessLogicHandler(Meeting_Process_MERC__c.SobjectType))
        .manage();
}