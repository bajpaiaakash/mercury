public with sharing class MERC_ItineraryParticipantUpdateTrigger implements GLBL_TriggerHandler.HandlerInterface {

    public Boolean isActive() {
        return MERC_TriggerHandlerStateManager.isActive(MERC_ItineraryParticipantUpdateTrigger.class);
    }

	public MERC_ItineraryParticipantUpdateTrigger() {
	    execute(Trigger.new);
	}

	public MERC_ItineraryParticipantUpdateTrigger(Schema.SobjectType sobjectType) {
	    execute(Trigger.new);
	}

    public void handle() {
    	execute(Trigger.new);
    }

    private void execute(List<Travel_Itinerary_MERC__c> itineraries) {

    	List<Id> participantIds = new List<Id>();

    	for (Travel_Itinerary_MERC__c itinerary : itineraries) {
    		participantIds.add(itinerary.Meeting_Participant_MERC__c);
    	}

    	List<Meeting_Participant_MERC__c> participants = [SELECT Potential_ToV_MERC__c FROM Meeting_Participant_MERC__c];
    	List<Meeting_Participant_MERC__c> participantsToUpdate = new List<Meeting_Participant_MERC__c>();

    	for (Meeting_Participant_MERC__c participant : participants) {
    		if (participant.Potential_ToV_MERC__c == NULL || participant.Potential_ToV_MERC__c != 'Yes') {
    			participant.Potential_ToV_MERC__c = 'Yes';
    			participantsToUpdate.add(participant);
    		}
    	}

    	update participantsToUpdate;
    }
}