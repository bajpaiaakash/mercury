/**
* MERC_MeetingParticipant Trigger
* Created By: Mavens Consulting
* Description: Executes a variety of trigger handler classes that make changes to the Meeting_Participant_MERC__c or associated records.
*/
trigger MERC_MeetingParticipant on Meeting_Participant_MERC__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	//for governor limit reasons, let's assign this once and only on before triggers
	Schema.DescribeFieldResult parentLookupField;
	if (Trigger.isBefore) {
		parentLookupField = Schema.sObjectType.Meeting_Participant_MERC__c.fields.Meeting_MERC__c;
	}

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_MeetingParticipantTovValidation())

		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_LockedRecordHandler(Meeting_Participant_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_LockedRecordHandler(Meeting_Participant_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))
		.bind(GLBL_TriggerHandler.Evt.beforedelete, new MERC_LockedRecordHandler(Meeting_Participant_MERC__c.SobjectType, Meeting_MERC__c.SobjectType, parentLookupField))

		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_ParticipantTriggerHandler())
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_ParticipantTriggerHandler())

		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_ParticipantFMVCalculator(Meeting_Participant_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_ParticipantFMVCalculator(Meeting_Participant_MERC__c.SobjectType))

		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_HcpCapActualsCalculator(Meeting_Participant_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_HcpCapActualsCalculator(Meeting_Participant_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_HcpCapActualsCalculator(Meeting_Participant_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_HcpCapActualsCalculator(Meeting_Participant_MERC__c.SobjectType))

		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_DeleteNotifyService())

		.bind(GLBL_TriggerHandler.Evt.afterinsert,   new MERC_MeetingProcessLogicHandler(Meeting_Participant_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterupdate,   new MERC_MeetingProcessLogicHandler(Meeting_Participant_MERC__c.SobjectType))

		.bind(GLBL_TriggerHandler.Evt.afterupdate,  new MERC_CancelDelegateMgmtProcesses(Meeting_Participant_MERC__c.SObjectType))

        .manage();

}