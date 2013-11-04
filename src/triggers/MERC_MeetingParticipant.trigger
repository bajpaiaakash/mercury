trigger MERC_MeetingParticipant on Meeting_Participant_MERC__c (before insert, before update) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_ParticipantFMVCalculator())
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_ParticipantFMVCalculator())
        .manage();

}