/**
 * @author Joseph Ferraro
 *
 * Trigger handler that facilitates TOV rollups
 * @todo: need to refactor the hotel tov calculation
 * 1 - fix static boolean hack
 * 2 - move to async processing
 */

public with sharing class MERC_TOVCalculator implements GLBL_TriggerHandler.HandlerInterface {

	public static Boolean runHotelTovCalculation = true;

	Schema.SobjectType triggeredSobjectType;

	public MERC_TOVCalculator(Schema.SobjectType sobjectType) {
		this.triggeredSobjectType = sObjectType;
	}

	public Boolean isActive() {
		return MERC_TriggerHandlerStateManager.isActive(MERC_TOVCalculator.class);
	}

	public void handle() {
		if (MERC_TOVCalculator.runHotelTovCalculation) {
			if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
	    		calculateHotelTov(Trigger.new);
		   	} else if (Trigger.isDelete) {
		   		calculateHotelTov(Trigger.old);
		   	}
		}

		if (Trigger.isAfter) {
			if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
	    		rollupTovValues(Trigger.new);
		   	} else if (Trigger.isDelete) {
		   		rollupTovValues(Trigger.old);
		   	}
		}
	}

	void calculateHotelTov(List<SObject> sobjects) {
		if (
			(
				this.triggeredSobjectType == Meeting_Vendor_MERC__c.SobjectType ||
				this.triggeredSobjectType == Travel_Itinerary_MERC__c.SobjectType
			)
			&& Trigger.isAfter
		) {
			Set<Id> meetingIds = new Set<Id>();

			//check for room rate change
			if (this.triggeredSobjectType == Meeting_Vendor_MERC__c.SobjectType) {
				for (Meeting_Vendor_MERC__c vendor : (List<Meeting_Vendor_MERC__c>)sobjects) {
					if (Trigger.oldMap.get(vendor.Id).get('Room_Rate_MERC__c') != vendor.Room_Rate_MERC__c &&
						vendor.Meeting_Status_MERC__c != 'Completed' &&
						vendor.Meeting_Status_MERC__c != 'Cancelled') {
						//room rate has changed
						meetingIds.add(vendor.Meeting_MERC__c);
					}
				}

			//check for meeting vendor change
			//TODO: we don't need to process all meetings, so provide list of affected tavel itineraries instead
			} else if (this.triggeredSobjectType == Travel_Itinerary_MERC__c.SobjectType) {
				for (Travel_Itinerary_MERC__c ti : (List<Travel_Itinerary_MERC__c>)sobjects) {
					if ((Trigger.oldMap.get(ti.Id).get('Meeting_Vendor_MERC__c') != ti.Meeting_Vendor_MERC__c ||
						  Trigger.oldMap.get(ti.Id).get('Sgmnt_Bgin_TS_MERC__c') != ti.Sgmnt_Bgin_TS_MERC__c ||
						  Trigger.oldMap.get(ti.Id).get('Sgmnt_End_TS_MERC__c') != ti.Sgmnt_End_TS_MERC__c) &&
						ti.Meeting_Status_MERC__c != 'Completed' &&
						ti.Meeting_Status_MERC__c != 'Cancelled') {
						//room rate has changed
						meetingIds.add(ti.Meeting_Id_MERC__c);
					}
				}
			}

			if (meetingIds.size() == 0) return;

			Map<Id, Meeting_Day_MERC__c> meetingDays = new Map<Id, Meeting_Day_MERC__c>([SELECT ID, Date_MERC__c FROM Meeting_Day_MERC__c WHERE Meeting_MERC__c in :meetingIds]);

			Map<Id, List<Travel_Itinerary_MERC__c>> participantIdToHotelItineraries = new Map <Id, List<Travel_Itinerary_MERC__c>>();
			for (Meeting_Participant_MERC__c mp : [SELECT ID, Name,
														(SELECT
															ID, Sgmnt_Bgin_TS_MERC__c, Sgmnt_End_TS_MERC__c,
															Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c,
															Room_Rate_excl_VAT_MERC__c
																FROM Travel_Itineraries_MERC__r
																	WHERE RecordType.DeveloperName = 'Hotel_MERC')
														FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c in :meetingIds]) {
				participantIdToHotelItineraries.put(mp.Id, mp.Travel_Itineraries_MERC__r);
			}

			System.debug(participantIdToHotelItineraries);

			List<Daily_Attendance_TOV_MERC__c> tovRecordsToUpdate = new List<Daily_Attendance_TOV_MERC__c>();
			for (Daily_Attendance_TOV_MERC__c tov : [SELECT ID, Status_MERC__c, Meeting_Day_MERC__c, Meeting_Participant_MERC__c, Confirm_ToV_Reporting_Change_MERC__c
				                                       FROM Daily_Attendance_TOV_MERC__c
				 									  WHERE Meeting_Participant_MERC__c in :participantIdToHotelItineraries.keySet()]) {

				if (participantIdToHotelItineraries.containsKey(tov.Meeting_Participant_MERC__c)) {
					Date meetingDayDate = meetingDays.get(tov.Meeting_Day_MERC__c).Date_MERC__c;
					List<Travel_Itinerary_MERC__c> hotelTravelItinerariesForParticipant = participantIdToHotelItineraries.get(tov.Meeting_Participant_MERC__c);
					for (Travel_Itinerary_MERC__c t : hotelTravelItinerariesForParticipant) {
						Date timestampStart = t.Sgmnt_Bgin_TS_MERC__c.date();
						Date timestampEnd = t.Sgmnt_End_TS_MERC__c.date();
						//Set the confirm reporting to true. If confirmirmation was needed on the meeting vendor
						//or the travel itinerary we would not get here without the user having checked that box.
						tov.Confirm_ToV_Reporting_Change_MERC__c = true;
						if (meetingDayDate >= timestampStart && meetingDayDate <= timestampEnd.addDays(-1)) {
							tov.Est_Hotel_ToV_MERC__c = t.Room_Rate_excl_VAT_MERC__c;
						} else {
							if (t.Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes') {
								tov.Est_Hotel_ToV_MERC__c = 0.0;
							} else {
								tov.Est_Hotel_ToV_MERC__c = null;
							}
						}
					}
				}
				tovRecordsToUpdate.add(tov);
			}

			MERC_TOVCalculator.runHotelTovCalculation = false;
			update tovRecordsToUpdate;
		}

		//check for creation/edit of daily attendance/tov records
		if (
			this.triggeredSobjectType == Daily_Attendance_TOV_MERC__c.SobjectType &&
			MERC_TOVCalculator.runHotelTovCalculation &&
			Trigger.isBefore
		) {
			//get list of participant ids & meeting day ids associated with this transaction
			Set<Id> meetingParticipantIds = new Set<Id>();
			Set<Id> meetingDayIds = new Set<Id>();
			for (Daily_Attendance_TOV_MERC__c tov : (List<Daily_Attendance_TOV_MERC__c>)sobjects) {
				if (tov.Status_MERC__c == 'Attended') {
					meetingParticipantIds.add(tov.Meeting_Participant_MERC__c);
					meetingDayIds.add(tov.Meeting_Day_MERC__c);
				}
			}

			//get map of meeting days
			Map<Id, Meeting_Day_MERC__c> meetingDays = new Map<Id, Meeting_Day_MERC__c>([SELECT ID, Date_MERC__c FROM Meeting_Day_MERC__c WHERE ID in :meetingDayIds]);

			Map<Id, List<Travel_Itinerary_MERC__c>> participantIdToHotelItineraries = new Map <Id, List<Travel_Itinerary_MERC__c>>();
			for (Meeting_Participant_MERC__c mp : [SELECT ID, Name,
														(SELECT
															ID, Sgmnt_Bgin_TS_MERC__c, Sgmnt_End_TS_MERC__c,
															Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c,
															Room_Rate_excl_VAT_MERC__c
																FROM Travel_Itineraries_MERC__r
																	WHERE RecordType.DeveloperName = 'Hotel_MERC')
														FROM Meeting_Participant_MERC__c WHERE Id in :meetingParticipantIds]) {
				participantIdToHotelItineraries.put(mp.Id, mp.Travel_Itineraries_MERC__r);
			}

			for (Daily_Attendance_TOV_MERC__c tov : (List<Daily_Attendance_TOV_MERC__c>)sobjects) {
				if (participantIdToHotelItineraries.containsKey(tov.Meeting_Participant_MERC__c) && meetingDays.containsKey(tov.Meeting_Day_MERC__c)) {
					Date meetingDayDate = meetingDays.get(tov.Meeting_Day_MERC__c).Date_MERC__c;
					List<Travel_Itinerary_MERC__c> hotelTravelItinerariesForParticipant = participantIdToHotelItineraries.get(tov.Meeting_Participant_MERC__c);
					for (Travel_Itinerary_MERC__c t : hotelTravelItinerariesForParticipant) {
						Date timestampStart = t.Sgmnt_Bgin_TS_MERC__c.date();
						Date timestampEnd = t.Sgmnt_End_TS_MERC__c.date();
						if (meetingDayDate >= timestampStart && meetingDayDate <= timestampEnd.addDays(-1)) {
							tov.Est_Hotel_ToV_MERC__c = t.Room_Rate_excl_VAT_MERC__c;
						} else {
							if (t.Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes') {
								tov.Est_Hotel_ToV_MERC__c = 0.0;
							} else {
								tov.Est_Hotel_ToV_MERC__c = null;
							}
						}
					}
				}
			}
		}
	}

	void rollupTovValues(List<SObject> sobjects) {
		//prevent the meeting participant validation from firing when the lookup rollup summary fields hit it and try to
		//update it without checking the Confirm_ToV_Reporting_Change_MERC__c boolean.
		MERC_MeetingParticipantTovValidation.tovValidationByPass = true;

		List<Sobject> detailSobjects; //these should be Daily_Attendance_TOV_MERC__c records

		if (this.triggeredSobjectType == Meeting_Day_MERC__c.SobjectType) {
			detailSobjects = [Select ID, Meeting_Participant_MERC__c, Confirm_ToV_Reporting_Change_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Meeting_Day_MERC__c in :sobjects];
			for (sObject da : detailSobjects) {
				da.put('Confirm_ToV_Reporting_Change_MERC__c', true);
			}
		} else if (this.triggeredSobjectType == Daily_Attendance_TOV_MERC__c.SobjectType) {
			detailSobjects = sobjects;
		}

		if (detailSobjects != null && detailSobjects.size() > 0)
			GLBL_RollupService.triggerHandler(sobjects);
	}
}