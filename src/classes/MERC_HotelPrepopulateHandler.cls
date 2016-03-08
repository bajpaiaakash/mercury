public with sharing class MERC_HotelPrepopulateHandler implements GLBL_TriggerHandler.HandlerInterface {

    public Boolean isActive() {
        return MERC_TriggerHandlerStateManager.isActive(MERC_ParticipantTriggerHandler.class);
    }

    public void handle() {
        execute ((List<Meeting_Participant_MERC__c>)Trigger.new);
    }

    void execute (List<Meeting_Participant_MERC__c> participants) {
        
        Id hotelRecordTypeId = [Select ID From RecordType Where SObjectType = 'Travel_Itinerary_MERC__c' and DeveloperName = 'MERC_Hotel'].ID;

        List<Id> participantIds = new List<Id>();
        List<Id> meetingIds = new List<Id>();

        for (Meeting_Participant_MERC__c participant : participants) {
        	participantIds.add(participant.Id);
        	meetingIds.add(participant.Meeting_MERC__c);
        }

        Map<Id,Id> hotelMap = new Map<Id,Id>();

        for (Travel_Itinerary_MERC__c itinerary : [SELECT Id, Meeting_Participant_MERC__c FROM Travel_Itinerary_MERC__c WHERE RecordTypeId = :hotelRecordTypeId AND Meeting_Participant_MERC__c in :participantIds]) {
        	hotelMap.put(itinerary.Meeting_Participant_MERC__c, itinerary.Id);
        }

        Map<Id,String> currencyMap = new Map<Id,String>();
        Map<Id,String> timeZoneMap = new Map<Id,String>();
        for (Meeting_MERC__c meeting : [SELECT CurrencyIsoCode, Meeting_Time_Zone_MERC__c FROM Meeting_MERC__c WHERE Id in :meetingIds]) {
        	currencyMap.put(meeting.Id, meeting.CurrencyIsoCode);
            timeZoneMap.put(meeting.Id, meeting.Meeting_Time_Zone_MERC__c);
        }

        List<Travel_Itinerary_MERC__c> itineraries = new List<Travel_Itinerary_MERC__c>();

        System.debug('#### Participans size is ' + participants.size());
        for (Meeting_Participant_MERC__c participant : participants) {

            System.debug('#### participant processing: ' + participant);
            if(!hotelMap.containsKey(participant.Id) 
                && participant.Date_of_Check_In_MERC__c != null
                && participant.Date_of_Check_Out_MERC__c != null
                && participant.Hotel_Required_MERC__c == 'Yes') {

		        Travel_Itinerary_MERC__c itinerary = new Travel_Itinerary_MERC__c();

		        itinerary.Meeting_Participant_MERC__c = participant.Id;
		        itinerary.Account_MERC__c = participant.Account_MERC__c;
		        itinerary.RecordTypeId = hotelRecordTypeId;
		        itinerary.Travel_Detail_Typ_MERC__c = 'Accomidation';
		        itinerary.Booking_Date_MERC__c = Date.today();
		        itinerary.Sgmnt_Bgin_TS_MERC__c = participant.Date_of_Check_In_MERC__c;
                itinerary.Segment_Begin_Timezone_MERC__c = timeZoneMap.get(participant.Meeting_MERC__c);
		        itinerary.Sgmnt_End_TS_MERC__c = participant.Date_of_Check_Out_MERC__c;
                itinerary.Segment_End_Timezone_MERC__c = timeZoneMap.get(participant.Meeting_MERC__c);
		        itinerary.CurrencyIsoCode = currencyMap.get(participant.Meeting_MERC__c);
		        itinerary.Status_MERC__c = 'Draft';

                System.debug('#### Adding itinerary to itineraries for insertion: ' + itinerary);
		        itineraries.add(itinerary);
	    	}
    	}

        System.debug('#### Inserting itineraries: ' + itineraries);
    	insert itineraries;

    }
}