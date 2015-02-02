trigger MERC_DailyAttendanceTOV on Daily_Attendance_TOV_MERC__c (before insert, before update, after insert, after update, after delete, after undelete) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.afterinsert,   new MERC_ParticipantStatusCalculator())
		.bind(GLBL_TriggerHandler.Evt.afterupdate,   new MERC_ParticipantStatusCalculator())
		.bind(GLBL_TriggerHandler.Evt.afterdelete,   new MERC_ParticipantStatusCalculator())
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_ParticipantStatusCalculator())

		.bind(GLBL_TriggerHandler.Evt.afterinsert,   new MERC_ParticipantTovStampHandler(Daily_Attendance_TOV_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterupdate,   new MERC_ParticipantTovStampHandler(Daily_Attendance_TOV_MERC__c.SobjectType))

		.bind(GLBL_TriggerHandler.Evt.beforeinsert,  new MERC_TOVCalculator(Daily_Attendance_TOV_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate,  new MERC_TOVCalculator(Daily_Attendance_TOV_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterinsert,   new MERC_TOVCalculator(Daily_Attendance_TOV_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterupdate,   new MERC_TOVCalculator(Daily_Attendance_TOV_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterdelete,   new MERC_TOVCalculator(Daily_Attendance_TOV_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_TOVCalculator(Daily_Attendance_TOV_MERC__c.SobjectType))
        .manage();
}