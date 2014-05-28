/**
 * @author Joseph Ferraro
 *
 * Calculates the number of booked rooms based on Travel Itinerary dates for Meeting Participants
 */

public with sharing class MERC_HotelAllocationCalculator implements GLBL_TriggerHandler.HandlerInterface {
	
	Schema.SobjectType triggeredSobjectType;

	public MERC_HotelAllocationCalculator(Schema.SobjectType sobjectType) {
		this.triggeredSobjectType = sObjectType;
	}

	public Boolean isActive() {
	    return true;
	}

	public void handle() {
		if (Trigger.isAfter) {
			if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
	    		rollupHotelAllocations(Trigger.new);
		   	} else if (Trigger.isDelete) {
		   		rollupHotelAllocations(Trigger.old);
		   	}	
		}
	}

	void rollupHotelAllocations(List<SObject> sobjects) {
		
		Id hotelItineraryRecordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = 'Hotel_MERC' AND SObjectType = 'Travel_Itinerary_MERC__c'].Id;

		if ( this.triggeredSobjectType == Travel_Itinerary_MERC__c.SobjectType ) {
			
			system.debug('processing hotel itinerary ----->');

			List<Travel_Itinerary_MERC__c> itineraries = (List<Travel_Itinerary_MERC__c>)sobjects;
			Map<Id, List<Meeting_Vendor_MERC__c>> meetingIdToListOfHotels = new Map<Id, List<Meeting_Vendor_MERC__c>>();
			
			Map<Id, Set<Date>> travelItineraryIdToHotelDates = new Map<Id, Set<Date>>();
			Map<Id, Id> travelItineraryIdToMeetingVendorId = new Map<Id, Id>();

			Map<String,Integer> dateMeetingVendorToNumberOfTravelItineraries = new Map<String,Integer>();

			//2014-02-02;meetingId;vendorId;

			Set<Id> meetingIds = new Set<Id>();

			for (Travel_Itinerary_MERC__c t : itineraries) {
				if (t.RecordTypeId == hotelItineraryRecordTypeId)
					meetingIds.add(t.Meeting_Id_MERC__c);
			}

			system.debug('-----> meetingIds: '+meetingIds);

			if (meetingIds.size() == 0) return;

			//retrieve all hotel itineraries for all associated meetings
			List<Travel_Itinerary_MERC__c> hotelItineraries = [SELECT ID, Sgmnt_Bgin_TS_MERC__c, Sgmnt_End_TS_MERC__c, Meeting_Vendor_MERC__c, Meeting_Id_MERC__c  
																		FROM Travel_Itinerary_MERC__c WHERE 
																			Meeting_Participant_MERC__r.Meeting_MERC__c in :meetingIds AND
																			RecordTypeId = :hotelItineraryRecordTypeId];

			system.debug('-----> hotelItineraries: '+hotelItineraries);

			for (Travel_Itinerary_MERC__c t : hotelItineraries) {
				
				String vendorId = t.Meeting_Vendor_MERC__c;
				String meetingId = t.Meeting_Id_MERC__c;

				Date firstDay = t.Sgmnt_Bgin_TS_MERC__c.date();
				Date lastDay = t.Sgmnt_End_TS_MERC__c.date();
				Integer daysBetween = firstDay.daysBetween(lastDay);

				//Set<Date> travelItineraryDates = new Set<Date>();
				for (Integer i = 0; i < daysBetween; i++) {
					Date d = firstDay.addDays(i);
					String dString = d.year()+'-'+d.month()+'-'+d.day();
					//travelItineraryDates.add(d);
					if (dateMeetingVendorToNumberOfTravelItineraries.containsKey(dString+';'+meetingId+';'+vendorId)) {
						Integer existing = dateMeetingVendorToNumberOfTravelItineraries.get(dString+';'+meetingId+';'+vendorId);
						dateMeetingVendorToNumberOfTravelItineraries.put(dString+';'+meetingId+';'+vendorId, existing+1);
					} else {
						dateMeetingVendorToNumberOfTravelItineraries.put(dString+';'+meetingId+';'+vendorId, 1);
					}
				}
				//travelItineraryIdToHotelDates.put(t.Id, travelItineraryDates);
				//travelItineraryIdToMeetingVendorId.put(t.Id, t.Meeting_Vendor_MERC__c);
			}

			system.debug('-----> dateMeetingVendorToNumberOfTravelItineraries: '+dateMeetingVendorToNumberOfTravelItineraries);

			List<Hotel_Allocation_MERC__c> hotelAllocations = [SELECT ID, Booked_Rooms__c, Meeting_Day_MERC__r.Meeting_MERC__c, Meeting_Day_Date_MERC__c, Meeting_Day_MERC__c, Meeting_Vendor_MERC__c 
																		FROM Hotel_Allocation_MERC__c WHERE 
																			Meeting_Day_MERC__r.Meeting_MERC__c in :meetingIds AND Meeting_Day_MERC__c != null];

			
			system.debug('-----> hotelAllocations: '+hotelAllocations);

			if (hotelAllocations.size() > 0) {
				for (Hotel_Allocation_MERC__c allocation : hotelAllocations) {
					String vendorId = allocation.Meeting_Vendor_MERC__c;
					String meetingId = allocation.Meeting_Day_MERC__r.Meeting_MERC__c;
					Date d = allocation.Meeting_Day_Date_MERC__c;
					String dString = d.year()+'-'+d.month()+'-'+d.day();
					system.debug('----> KEY: '+dString+';'+meetingId+';'+vendorId);
					if (dateMeetingVendorToNumberOfTravelItineraries.containsKey(dString+';'+meetingId+';'+vendorId)) {
						Integer bookedRooms = dateMeetingVendorToNumberOfTravelItineraries.get(dString+';'+meetingId+';'+vendorId);
						allocation.Booked_Rooms__c = bookedRooms;
					} else {
						allocation.Booked_Rooms__c = 0;
					}
				}
				
				update hotelAllocations;	
			}
		}
	}
}