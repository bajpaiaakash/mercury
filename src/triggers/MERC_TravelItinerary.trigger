trigger MERC_TravelItinerary on Travel_Itinerary_MERC__c (before insert, before update, after update) {
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_TimestampHandler(Travel_Itinerary_MERC__c.sObjectType))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_TimestampHandler(Travel_Itinerary_MERC__c.sObjectType))
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_TOVCalculator(Travel_Itinerary_MERC__c.SobjectType))
        .manage();
}