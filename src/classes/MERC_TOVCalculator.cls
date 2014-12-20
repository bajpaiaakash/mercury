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
	public static Boolean  runIndividualTransferTovCalculation = true;

	Schema.SobjectType triggeredSobjectType;

	public MERC_TOVCalculator(Schema.SobjectType sobjectType) {
		this.triggeredSobjectType = sObjectType;
		//prevent the meeting participant validation from firing when the lookup rollup summary fields hit it and try to
		//update it without checking the Confirm_ToV_Reporting_Change_MERC__c boolean.
		MERC_MeetingParticipantTovValidation.tovValidationByPass = true;
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

		if (MERC_TOVCalculator.runIndividualTransferTovCalculation) {
			if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
	    		calculateIndividualTransportToV(Trigger.new);
		   	} else if (Trigger.isDelete) {
		   		calculateIndividualTransportToV(Trigger.old);
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

	private void calculateIndividualTransportToV(List<SObject> sobjects) {
		if ( this.triggeredSobjectType == Travel_Itinerary_MERC__c.SobjectType && Trigger.isAfter) {
			Set<Id> meetingIds = new Set<Id>();

			for (Travel_Itinerary_MERC__c ti : (List<Travel_Itinerary_MERC__c>)sobjects) {
				if (Trigger.isInsert ||
					(Trigger.oldMap.get(ti.Id).get('Sgmnt_Bgin_TS_MERC__c') != ti.Sgmnt_Bgin_TS_MERC__c ||
						Trigger.oldMap.get(ti.Id).get('Sgmnt_End_TS_MERC__c') != ti.Sgmnt_End_TS_MERC__c ||
						Trigger.oldMap.get(ti.Id).get('Status_MERC__c') != ti.Status_Merc__c |
						Trigger.oldMap.get(ti.Id).get('Total_Fare_Amount_MERC__c') != ti.Total_Fare_Amount_MERC__c) &&
 						!ti.Meeting_Status_MERC__c.startsWith('Complete')) {
					meetingIds.add(ti.Meeting_Id_MERC__c);
				}
			}
			System.debug('\n\n\nMeetingIds : ' + meetingIds);
			if (meetingIds.size() == 0) return;

			Map<Id, Meeting_Day_MERC__c> meetingDays = new Map<Id, Meeting_Day_MERC__c>([SELECT ID, Date_MERC__c FROM Meeting_Day_MERC__c WHERE Meeting_MERC__c in :meetingIds]);

			Map<Id, List<Travel_Itinerary_MERC__c>> participantIdToTransferItineraries = new Map <Id, List<Travel_Itinerary_MERC__c>>();
			for (Meeting_Participant_MERC__c mp : [SELECT ID, Name,
														(SELECT
															ID, Sgmnt_Bgin_TS_MERC__c, Sgmnt_End_TS_MERC__c,
															Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c,
															Total_Fare_Amount_MERC__c, Include_ToV_MERC__c
																FROM Travel_Itineraries_MERC__r
																	WHERE Individual_Travel_ToV_Applicable_MERC__c = true)
														FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c in :meetingIds]) {
				participantIdToTransferItineraries.put(mp.Id, mp.Travel_Itineraries_MERC__r);
			}

			System.debug(participantIdToTransferItineraries);

			List<Daily_Attendance_TOV_MERC__c> tovRecordsToUpdate = new List<Daily_Attendance_TOV_MERC__c>();
			for (Daily_Attendance_TOV_MERC__c tov : [SELECT ID, Status_MERC__c, Est_Indv_Transfer_MERC__c, Meeting_Day_MERC__c, Meeting_Participant_MERC__c, Confirm_ToV_Reporting_Change_MERC__c
				                                       FROM Daily_Attendance_TOV_MERC__c
				 									  WHERE Meeting_Participant_MERC__c in :participantIdToTransferItineraries.keySet()]) {

				if (participantIdToTransferItineraries.containsKey(tov.Meeting_Participant_MERC__c)) {
					Date meetingDayDate = meetingDays.get(tov.Meeting_Day_MERC__c).Date_MERC__c;
					List<Travel_Itinerary_MERC__c> individualTransfersForParticipant = participantIdToTransferItineraries.get(tov.Meeting_Participant_MERC__c);
					for (Travel_Itinerary_MERC__c t : individualTransfersForParticipant) {
						Date timestampStart = t.Sgmnt_Bgin_TS_MERC__c.date();
						Date timestampEnd = t.Sgmnt_End_TS_MERC__c.date();
						//Set the confirm reporting to true. If confirmirmation was needed on the meeting vendor
						//or the travel itinerary we would not get here without the user having checked that box.
						tov.Confirm_ToV_Reporting_Change_MERC__c = true;
						System.debug('\n\n\nmeetingDayDate: ' + meetingDayDate + ' and timestampStart: ' + timestampStart + '\n\n\n');
						if ( t.Include_ToV_MERC__c && meetingDayDate == timestampStart) {
							tov.Est_Indv_Transfer_MERC__c = t.Total_Fare_Amount_MERC__c;
							tovRecordsToUpdate.add(tov);
						} else {
							if (t.Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes') {
								if (tov.Est_Indv_Transfer_MERC__c != null) {
									tov.Est_Indv_Transfer_MERC__c = 0.0;
									tovRecordsToUpdate.add(tov);
								}
							} else {
								tov.Est_Indv_Transfer_MERC__c = null;
								tovRecordsToUpdate.add(tov);
							}
						}
					}
				}
			}

			MERC_TOVCalculator.runIndividualTransferTovCalculation = false;
			update tovRecordsToUpdate;
		}

		//check for creation/edit of daily attendance/tov records

		/**
		 * The requirements have changed! ToV not to be updated based on Daily Attendence records so 
		 * Trigger no longer bound to TOVCalculation
		 **/
		if (
			this.triggeredSobjectType == Daily_Attendance_TOV_MERC__c.SobjectType &&
			MERC_TOVCalculator.runIndividualTransferTovCalculation &&
			Trigger.isBefore
		) {
			//get list of participant ids & meeting day ids associated with this transaction
			Set<Id> meetingParticipantIds = new Set<Id>();
			Set<Id> meetingDayIds = new Set<Id>();
			for (Daily_Attendance_TOV_MERC__c tov : (List<Daily_Attendance_TOV_MERC__c>)sobjects) {
				meetingParticipantIds.add(tov.Meeting_Participant_MERC__c);
				meetingDayIds.add(tov.Meeting_Day_MERC__c);
			}

			//get map of meeting days
			Map<Id, Meeting_Day_MERC__c> meetingDays = new Map<Id, Meeting_Day_MERC__c>([SELECT ID, Date_MERC__c FROM Meeting_Day_MERC__c WHERE ID in :meetingDayIds]);

			Map<Id, List<Travel_Itinerary_MERC__c>> participantIdToTransferItineraries = new Map <Id, List<Travel_Itinerary_MERC__c>>();
			for (Meeting_Participant_MERC__c mp : [SELECT ID, Name,
														(SELECT
															ID, Sgmnt_Bgin_TS_MERC__c, Sgmnt_End_TS_MERC__c,
															Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c,
															Total_Fare_Amount_MERC__c
																FROM Travel_Itineraries_MERC__r
																	WHERE Individual_Travel_ToV_Applicable_MERC__c = true)
														FROM Meeting_Participant_MERC__c WHERE Id in :meetingParticipantIds]) {
				participantIdToTransferItineraries.put(mp.Id, mp.Travel_Itineraries_MERC__r);
			}

			for (Daily_Attendance_TOV_MERC__c tov : (List<Daily_Attendance_TOV_MERC__c>)sobjects) {
				if (participantIdToTransferItineraries.containsKey(tov.Meeting_Participant_MERC__c) && meetingDays.containsKey(tov.Meeting_Day_MERC__c)) {
					Date meetingDayDate = meetingDays.get(tov.Meeting_Day_MERC__c).Date_MERC__c;
					List<Travel_Itinerary_MERC__c> hotelTravelItinerariesForParticipant = participantIdToTransferItineraries.get(tov.Meeting_Participant_MERC__c);
					for (Travel_Itinerary_MERC__c t : hotelTravelItinerariesForParticipant) {
						Date timestampStart = t.Sgmnt_Bgin_TS_MERC__c.date();
						Date timestampEnd = t.Sgmnt_End_TS_MERC__c.date();
						if (meetingDayDate == timestampStart) {
							tov.Est_Indv_Transfer_MERC__c = t.Total_Fare_Amount_MERC__c;
						} else {
							if (t.Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes') {
								if (tov.Est_Indv_Transfer_MERC__c != null) {
									tov.Est_Indv_Transfer_MERC__c = 0.0;
								}
							} else {
								tov.Est_Indv_Transfer_MERC__c = null;
							}
						}
					}
				}
			}
		}
	}

	private void calculateHotelTov(List<SObject> sobjects) {
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
						!vendor.Meeting_Status_MERC__c.startsWith('Complete')) {
						//room rate has changed
						meetingIds.add(vendor.Meeting_MERC__c);
					}
				}

			//check for meeting vendor change
			//TODO: we don't need to process all meetings, so provide list of affected travel itineraries instead *************
			} else if (this.triggeredSobjectType == Travel_Itinerary_MERC__c.SobjectType) {
				for (Travel_Itinerary_MERC__c ti : (List<Travel_Itinerary_MERC__c>)sobjects) {
					if (Trigger.isInsert ||
						(Trigger.oldMap.get(ti.Id).get('Meeting_Vendor_MERC__c') != ti.Meeting_Vendor_MERC__c ||
						  Trigger.oldMap.get(ti.Id).get('Sgmnt_Bgin_TS_MERC__c') != ti.Sgmnt_Bgin_TS_MERC__c ||
						  Trigger.oldMap.get(ti.Id).get('Sgmnt_End_TS_MERC__c') != ti.Sgmnt_End_TS_MERC__c ||
						  Trigger.oldMap.get(ti.Id).get('Status_MERC__c') != ti.Status_Merc__c) &&
						!ti.Meeting_Status_MERC__c.startsWith('Complete')) {
						//room rate has changed
						meetingIds.add(ti.Meeting_Id_MERC__c);
					}
				}
			}

			System.debug(LoggingLevel.INFO, 'YYZ: calculateHotelTov-isAfter '+this.triggeredSobjectType+':'+meetingIds);

			if (meetingIds.size() == 0) return;

			Map<Id, Meeting_Day_MERC__c> meetingDays = new Map<Id, Meeting_Day_MERC__c>([SELECT ID, Date_MERC__c FROM Meeting_Day_MERC__c WHERE Meeting_MERC__c in :meetingIds]);

			Map<Id, List<Travel_Itinerary_MERC__c>> participantIdToHotelItineraries = new Map <Id, List<Travel_Itinerary_MERC__c>>();
			for (Meeting_Participant_MERC__c mp : [SELECT ID, Name,
														(SELECT
															ID, Sgmnt_Bgin_TS_MERC__c, Sgmnt_End_TS_MERC__c,
															Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c,
															Room_Rate_excl_VAT_MERC__c, Include_ToV_MERC__c
																FROM Travel_Itineraries_MERC__r
																	WHERE RecordType.DeveloperName = 'Hotel_MERC')
														FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c in :meetingIds]) {
				participantIdToHotelItineraries.put(mp.Id, mp.Travel_Itineraries_MERC__r);
			}

			System.debug(participantIdToHotelItineraries);

			// Associate TOVs with their respective Itineraries
			Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c> tovToItinerary = new Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c>();
			for (Daily_Attendance_TOV_MERC__c tov : [SELECT ID, Status_MERC__c, Est_Hotel_ToV_MERC__c, Meeting_Day_MERC__c, Meeting_Participant_MERC__c, Confirm_ToV_Reporting_Change_MERC__c
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
							tovToItinerary.put(tov,t);
						}
					}
				}
			}

			// Determine which TOVs to process and how...
			List<Daily_Attendance_TOV_MERC__c> tovRecordsToUpdate = new List<Daily_Attendance_TOV_MERC__c>();
			for (Daily_Attendance_TOV_MERC__c tov : tovToItinerary.keySet()) {
				Travel_Itinerary_MERC__c t = tovToItinerary.get(tov);
				if (t.Include_ToV_MERC__c) {
					tovRecordsToUpdate.add(tov);
				} else {
					if (t.Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes') { // this value has already been sent to Activity ODS
						if (tov.Est_Hotel_ToV_MERC__c != null) {
							tov.Est_Hotel_ToV_MERC__c = 0.0;
							tovRecordsToUpdate.add(tov);
						}
					} else {
						tov.Est_Hotel_ToV_MERC__c = null;
						tovRecordsToUpdate.add(tov);
					}
				}
			}


			MERC_TOVCalculator.runHotelTovCalculation = false;
			update tovRecordsToUpdate;
		}

		// check for creation/edit of daily attendance/tov records
		if (
			this.triggeredSobjectType == Daily_Attendance_TOV_MERC__c.SobjectType &&
			MERC_TOVCalculator.runHotelTovCalculation &&
			Trigger.isBefore
		) {

			//get list of participant ids & meeting day ids associated with this transaction
			Set<Id> meetingParticipantIds = new Set<Id>();
			Set<Id> meetingDayIds = new Set<Id>();
			for (Daily_Attendance_TOV_MERC__c tov : (List<Daily_Attendance_TOV_MERC__c>)sobjects) {
				meetingParticipantIds.add(tov.Meeting_Participant_MERC__c);
				meetingDayIds.add(tov.Meeting_Day_MERC__c);
			}

			System.debug(LoggingLevel.INFO, 'YYZ: calculateHotelTov-isBefore '+meetingParticipantIds);

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

			// Associate TOVs with their respective Itineraries
			Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c> tovToItinerary = new Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c>();
			for (Daily_Attendance_TOV_MERC__c tov : (List<Daily_Attendance_TOV_MERC__c>)sobjects) {
				if (participantIdToHotelItineraries.containsKey(tov.Meeting_Participant_MERC__c) && meetingDays.containsKey(tov.Meeting_Day_MERC__c)) {
					Date meetingDayDate = meetingDays.get(tov.Meeting_Day_MERC__c).Date_MERC__c;
					List<Travel_Itinerary_MERC__c> hotelTravelItinerariesForParticipant = participantIdToHotelItineraries.get(tov.Meeting_Participant_MERC__c);
					for (Travel_Itinerary_MERC__c t : hotelTravelItinerariesForParticipant) {
						Date timestampStart = t.Sgmnt_Bgin_TS_MERC__c.date();
						Date timestampEnd = t.Sgmnt_End_TS_MERC__c.date();
						if (meetingDayDate >= timestampStart && meetingDayDate <= timestampEnd.addDays(-1)) {
							tov.Est_Hotel_ToV_MERC__c = t.Room_Rate_excl_VAT_MERC__c;
							tovToItinerary.put(tov,t);
						} else {
							System.debug(LoggingLevel.INFO, 'YYZ \n\nSkipping this itinerary: '+tov+'|'+t);
							System.debug(LoggingLevel.INFO, 'YYZ \n\n'+meetingDayDate +'>='+ timestampStart +'&&'+ meetingDayDate +'<='+ timestampEnd.addDays(-1));
						}
					}
				}
			}

			System.debug(LoggingLevel.INFO, 'YYZ \n\n'+tovToItinerary);

			// Determine which TOVs to process and how...
			List<Daily_Attendance_TOV_MERC__c> tovRecordsToUpdate = new List<Daily_Attendance_TOV_MERC__c>();
			for (Daily_Attendance_TOV_MERC__c tov : tovToItinerary.keySet()) {
				Travel_Itinerary_MERC__c t = tovToItinerary.get(tov);
				if (t.Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes') {  // this value has already been sent to Activity ODS
					if (tov.Est_Hotel_ToV_MERC__c != null) {
						tov.Est_Hotel_ToV_MERC__c = 0.0;
					}
				}
			}
		}
	}

	private void rollupTovValues(List<SObject> sobjects) {

		List<Sobject> detailSobjects; //these should be Daily_Attendance_TOV_MERC__c records

		if (this.triggeredSobjectType == Meeting_Day_MERC__c.SobjectType) {
			detailSobjects = [Select ID, Meeting_Participant_MERC__c, Confirm_ToV_Reporting_Change_MERC__c, Est_Reg_Amt_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Meeting_Day_MERC__c in :sobjects];
			for (sObject da : detailSobjects) {
				da.put('Confirm_ToV_Reporting_Change_MERC__c', true);
			}
		} else if (this.triggeredSobjectType == Daily_Attendance_TOV_MERC__c.SobjectType) {
			detailSobjects = sobjects; //[SELECT Id, Meeting_Participant_MERC__c, Est_Reg_Amt_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id IN :sobjects];
		}
		System.debug('\n\n\ndetailSObjects : ' + detailSobjects);
		if (detailSobjects != null && detailSobjects.size() > 0)
			GLBL_RollupService.triggerHandler(detailSobjects);
	}
}