/**
* MERC_TravelItinerary Trigger
* Created By: Mavens Consulting
* Description: Executes a variety of trigger handler classes that make changes to the Travel_Itinerary_MERC__c or associated records.
*/
trigger MERC_TravelItinerary on Travel_Itinerary_MERC__c (before insert, before update, after insert, after update, after delete, after undelete) {
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert,  new MERC_TimestampHandler(Travel_Itinerary_MERC__c.sObjectType))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate,  new MERC_TimestampHandler(Travel_Itinerary_MERC__c.sObjectType))

		.bind(GLBL_TriggerHandler.Evt.beforeinsert,  new MERC_ItineraryParticipantUpdateTrigger(Travel_Itinerary_MERC__c.sObjectType))

		.bind(GLBL_TriggerHandler.Evt.afterinsert,   new MERC_HotelAllocationCalculator(Travel_Itinerary_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterupdate,   new MERC_HotelAllocationCalculator(Travel_Itinerary_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterdelete,   new MERC_HotelAllocationCalculator(Travel_Itinerary_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_HotelAllocationCalculator(Travel_Itinerary_MERC__c.SobjectType))

		.bind(GLBL_TriggerHandler.Evt.afterinsert,   new MERC_TOVCalculator(Travel_Itinerary_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterupdate,   new MERC_TOVCalculator(Travel_Itinerary_MERC__c.SobjectType))

        .bind(GLBL_TriggerHandler.Evt.afterinsert,   new MERC_ParticipantTovStampHandler(Travel_Itinerary_MERC__c.SobjectType))
        .bind(GLBL_TriggerHandler.Evt.afterupdate,   new MERC_ParticipantTovStampHandler(Travel_Itinerary_MERC__c.SobjectType))

        .bind(GLBL_TriggerHandler.Evt.afterinsert,   new MERC_MeetingProcessLogicHandler(Travel_Itinerary_MERC__c.SobjectType))
        .bind(GLBL_TriggerHandler.Evt.afterupdate,   new MERC_MeetingProcessLogicHandler(Travel_Itinerary_MERC__c.SobjectType))

        .manage();
}