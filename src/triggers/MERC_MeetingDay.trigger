trigger MERC_MeetingDay on Meeting_Day_MERC__c (after insert, after update, after delete, after undelete) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_TOVCalculator())
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_TOVCalculator())
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_TOVCalculator())
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_TOVCalculator())
        .manage();

}