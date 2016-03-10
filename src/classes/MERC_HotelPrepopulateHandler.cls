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

    void execute (List<Meeting_Participant_MERC__c> participants) {

        // This checks if the participant is a candidate for a hotel record being prepopulated
        boolean hotelPrepopulateCandidate = false;
        for (Meeting_Participant_MERC__c participant : participants) {
            if(participant.Date_of_Check_In_MERC__c != null
                && participant.Date_of_Check_Out_MERC__c != null
                && participant.Hotel_Required_MERC__c == 'Yes') {

                hotelPrepopulateCandidate = true;
            }
        }

        // This only runs the code if the participant is a candidate to have the hotel prepopulated to reduce SOQL queries
        if (hotelPrepopulateCandidate) {

            List<Id> participantIds = new List<Id>();
            List<Id> meetingIds = new List<Id>();

            for (Meeting_Participant_MERC__c participant : participants) {
                participantIds.add(participant.Id);
                meetingIds.add(participant.Meeting_MERC__c);
            }

            Map<Id,Id> hotelMap = new Map<Id,Id>();

            Id hotelRecordTypeId = Schema.SObjectType.Travel_Itinerary_MERC__c.getRecordTypeInfosByName().get('Hotel').getRecordTypeId();

            for (Travel_Itinerary_MERC__c itinerary : [SELECT Id, Meeting_Participant_MERC__c FROM Travel_Itinerary_MERC__c WHERE RecordTypeId = :hotelRecordTypeId AND Meeting_Participant_MERC__c in :participantIds]) {
                hotelMap.put(itinerary.Meeting_Participant_MERC__c, itinerary.Id);
            }

            // This checks if the participant is a candidate for a hotel record being prepopulated
            boolean hotelPrepopulateCandidateFinal = false;
            for (Meeting_Participant_MERC__c participant : participants) {
                if(!hotelMap.containsKey(participant.Id) 
                    && participant.Date_of_Check_In_MERC__c != null
                    && participant.Date_of_Check_Out_MERC__c != null
                    && participant.Hotel_Required_MERC__c == 'Yes') {

                    hotelPrepopulateCandidateFinal = true;
                }
            }

            // This only runs the code if the participant is a candidate to have the hotel prepopulated to reduce SOQL queries
            if (hotelPrepopulateCandidateFinal) {

                Id hotelVendorRecordTypeId = Schema.SObjectType.Meeting_Vendor_MERC__c.getRecordTypeInfosByName().get('Hotel').getRecordTypeId();

                Map<Id,Id> hotelVendorMap = new Map<Id,Id>();
                Map<Id,Boolean> singularHotelVendorMap = new Map<Id,Boolean>();
                System.debug('### query is: SELECT Id, Meeting_MERC__c FROM Meeting_Vendor_MERC__c WHERE Meeting_MERC__c in ' + meetingIds + ' AND RecordTypeId = \'' + hotelVendorRecordTypeId + '\'');
                for (Meeting_Vendor_MERC__c vendor : [SELECT Id, Meeting_MERC__c FROM Meeting_Vendor_MERC__c WHERE Meeting_MERC__c in :meetingIds AND RecordTypeId = :hotelVendorRecordTypeId]) {
                    System.debug('#### vendor = ' + vendor);
                    if (singularHotelVendorMap.containsKey(vendor.Meeting_MERC__c)) {
                        singularHotelVendorMap.put(vendor.Meeting_MERC__c, false);
                        System.debug('#### singularHotelVendorMap = ' + singularHotelVendorMap);
                    } else {
                        singularHotelVendorMap.put(vendor.Meeting_MERC__c, true);
                        System.debug('#### singularHotelVendorMap = ' + singularHotelVendorMap);
                    }
                    hotelVendorMap.put(vendor.Meeting_MERC__c, vendor.Id);
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
                        itinerary.Travel_Detail_Typ_MERC__c = 'Accommodation';
                        itinerary.Booking_Date_MERC__c = Date.today();
                        itinerary.Sgmnt_Bgin_TS_MERC__c = timeCorrection(participant.Date_of_Check_In_MERC__c, timeZoneMap.get(participant.Meeting_MERC__c)).addHours(16);
                        itinerary.Segment_Begin_Timezone_MERC__c = timeZoneMap.get(participant.Meeting_MERC__c);
                        itinerary.Sgmnt_End_TS_MERC__c = timeCorrection(participant.Date_of_Check_Out_MERC__c, timeZoneMap.get(participant.Meeting_MERC__c)).addHours(11);
                        itinerary.Segment_End_Timezone_MERC__c = timeZoneMap.get(participant.Meeting_MERC__c);
                        itinerary.CurrencyIsoCode = currencyMap.get(participant.Meeting_MERC__c);
                        itinerary.Status_MERC__c = 'In Progress';

                        System.debug('#### hotelMap = ' + hotelVendorMap);
                        if (hotelVendorMap.containsKey(participant.Meeting_MERC__c)
                            && singularHotelVendorMap.containsKey(participant.Meeting_MERC__c)
                            && singularHotelVendorMap.get(participant.Meeting_MERC__c)) {
                            itinerary.Meeting_Vendor_MERC__c = hotelVendorMap.get(participant.Meeting_MERC__c);
                        }

                        System.debug('#### Adding itinerary to itineraries for insertion: ' + itinerary);
                        itineraries.add(itinerary);
                    }
                }

                System.debug('#### Inserting itineraries: ' + itineraries);
                insert itineraries;
            }
        }
    }

    Datetime timeCorrection (DateTime dtValue, String timeZoneString) {
        String tzSidValueForAssociatedTimeZone = timeZoneString.split('\\(')[1].replace(')','');
        TimeZone associatedTimeZoneValue = TimeZone.getTimeZone(tzSidValueForAssociatedTimeZone);
        Integer associatedFieldGmtOffset = associatedTimeZoneValue.getOffset(dtValue); //gets meeting's offset to gmt
        DateTime result = dtValue.addMinutes(-(associatedFieldGmtOffset) / (1000 * 60));
        return result;
    }
}