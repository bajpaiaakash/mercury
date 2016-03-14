public class MERC_HotelPrepopulateHandler implements GLBL_TriggerHandler.HandlerInterface {

    public static boolean firstRun = true;

    public boolean isActive() {
        return MERC_TriggerHandlerStateManager.isActive(MERC_ParticipantTriggerHandler.class);
    }

    public void handle() {
        if (firstRun) {
            firstRun = false;
            execute ((List<Meeting_Participant_MERC__c>)Trigger.new);
        }
        else {
            System.debug('#### MERC_HotelPrepopulateHandler has already ran!');
            return;
        }
    }

    public void execute (List<Meeting_Participant_MERC__c> participants) {
        // This checks if the participant is a candidate for a hotel record being prepopulated
        List<Id> participantIdsToProcess = new List<Id>();
        for (Meeting_Participant_MERC__c participant : participants) {
            if(participant.Date_of_Check_In_MERC__c != null
                && participant.Date_of_Check_Out_MERC__c != null
                && participant.Hotel_Required_MERC__c == 'Yes') {

                participantIdsToProcess.add(participant.Id);
            }
        }

        // This only runs the code if the participant is a candidate to have the hotel prepopulated to reduce SOQL queries
        if (!participantIdsToProcess.isEmpty()) {
            createItineraries(participantIdsToProcess);
        }
    }

    public void createItineraries(List<Id> participantIds) {
         //Requery for the partiants
        Id tiHotelRecordTypeId = Schema.SObjectType.Travel_Itinerary_MERC__c.getRecordTypeInfosByName().get('Hotel').getRecordTypeId();
        List<Meeting_Participant_MERC__c> participants = [SELECT Id, Meeting_MERC__c, Account_MERC__c, Date_of_Check_In_MERC__c, Date_of_Check_Out_MERC__c,
                                                                 (SELECT Id
                                                                    FROM Travel_Itineraries_MERC__r
                                                                   WHERE RecordTypeId = :tiHotelRecordTypeId)
                                                            FROM Meeting_Participant_MERC__c
                                                           WHERE Id IN :participantIds];

        //decide which participants need to be processed
        List<Meeting_Participant_MERC__c> participantsNeedingItinerary = new List<Meeting_Participant_MERC__c>();

        for (Meeting_Participant_MERC__c participant : participants) {
            if (participant.Travel_Itineraries_MERC__r.size() == 0) {
                participantsNeedingItinerary.add(participant);
            }
        }

        // This only runs the code if there are participants to create itineraries for
        if (!participantsNeedingItinerary.isEmpty()) {
            List<Id> meetingIds = new List<Id>();

            // build the list of participant meeting ids
            for (Meeting_Participant_MERC__c participant : participantsNeedingItinerary) {
                meetingIds.add(participant.Meeting_MERC__c);
            }

            Id hotelVendorRecordTypeId = Schema.SObjectType.Meeting_Vendor_MERC__c.getRecordTypeInfosByName().get('Hotel').getRecordTypeId();

            // get all of the meetings and their associated hotels and add them to a map. This is used to determine whether
            // the hotel will be added to the new hotel itinerary (if there is one) or if it will be left blank (zero or many)
            Map<Id,Meeting_MERC__c> meetingsWithHotelsMap = new Map<Id,Meeting_MERC__c>(
                                                                            [SELECT Id,
                                                                                    (SELECT Id
                                                                                       FROM Meeting_Vendors__r
                                                                                      WHERE RecordTypeId = :hotelVendorRecordTypeId)
                                                                               FROM Meeting_MERC__c
                                                                              WHERE Id in :meetingIds]);

            //account for timezone shifts
            Map<Id,String> currencyMap = new Map<Id,String>();
            Map<Id,String> timeZoneMap = new Map<Id,String>();
            for (Meeting_MERC__c meeting : [SELECT CurrencyIsoCode, Meeting_Time_Zone_MERC__c FROM Meeting_MERC__c WHERE Id in :meetingsWithHotelsMap.keySet()]) {
                currencyMap.put(meeting.Id, meeting.CurrencyIsoCode);
                timeZoneMap.put(meeting.Id, meeting.Meeting_Time_Zone_MERC__c);
            }

            // create the itineraries for these participants
            List<Travel_Itinerary_MERC__c> itineraries = new List<Travel_Itinerary_MERC__c>();

            for (Meeting_Participant_MERC__c participant : participantsNeedingItinerary) {
                Travel_Itinerary_MERC__c itinerary = new Travel_Itinerary_MERC__c(
                    Meeting_Participant_MERC__c = participant.Id,
                    Account_MERC__c = participant.Account_MERC__c,
                    RecordTypeId = tiHotelRecordTypeId,
                    Travel_Detail_Typ_MERC__c = 'Accommodation',
                    Booking_Date_MERC__c = Date.today(),
                    // default checkin to 16:00
                    Sgmnt_Bgin_TS_MERC__c = timeCorrection(participant.Date_of_Check_In_MERC__c, timeZoneMap.get(participant.Meeting_MERC__c)).addHours(16),
                    Segment_Begin_Timezone_MERC__c = timeZoneMap.get(participant.Meeting_MERC__c),
                    // defautl checkout to 11:00
                    Sgmnt_End_TS_MERC__c = timeCorrection(participant.Date_of_Check_Out_MERC__c, timeZoneMap.get(participant.Meeting_MERC__c)).addHours(11),
                    Segment_End_Timezone_MERC__c = timeZoneMap.get(participant.Meeting_MERC__c),
                    CurrencyIsoCode = currencyMap.get(participant.Meeting_MERC__c),
                    Status_MERC__c = 'In Progress');

                // if there is one and only one meeting hotel then set the meeting vendor for this itinerary with the id of that hotel vendor
                if (meetingsWithHotelsMap.containsKey(participant.Meeting_MERC__c) && meetingsWithHotelsMap.get(participant.Meeting_MERC__c).Meeting_Vendors__r.size() == 1) {
                    itinerary.Meeting_Vendor_MERC__c = meetingsWithHotelsMap.get(participant.Meeting_MERC__c).Meeting_Vendors__r[0].Id;
                }

                itineraries.add(itinerary);
            }

            // We are inserting In Progress itineraries which won't affect TOV. Turn off handlers
            // so that we don't invoke more logic than is needed
            MERC_TriggerHandlerStateManager.deactivate(Type.forName('MERC_MeetingProcessLogicHandler'));
            MERC_TriggerHandlerStateManager.deactivate(Type.forName('MERC_TOVCalculator'));
            insert itineraries;
        }
    }

    private Datetime timeCorrection(DateTime dtValue, String timeZoneString) {
        String tzSidValueForAssociatedTimeZone = timeZoneString.split('\\(')[1].replace(')','');
        TimeZone associatedTimeZoneValue = TimeZone.getTimeZone(tzSidValueForAssociatedTimeZone);
        Integer associatedFieldGmtOffset = associatedTimeZoneValue.getOffset(dtValue); //gets meeting's offset to gmt
        DateTime result = dtValue.addMinutes(-(associatedFieldGmtOffset) / (1000 * 60));
        return result;
    }
}