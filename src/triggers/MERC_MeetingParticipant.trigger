trigger MERC_MeetingParticipant on Meeting_Participant_MERC__c (before insert, before update, after insert, after update, after delete, after undelete) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_ParticipantFMVCalculator('Meeting_Participant_MERC__c'))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_ParticipantFMVCalculator('Meeting_Participant_MERC__c'))
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_HcpCapActualsCalculator('Meeting_Participant_MERC__c'))
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_HcpCapActualsCalculator('Meeting_Participant_MERC__c'))
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_HcpCapActualsCalculator('Meeting_Participant_MERC__c'))
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_HcpCapActualsCalculator('Meeting_Participant_MERC__c'))
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_DeleteNotifyService())
        .manage();

}