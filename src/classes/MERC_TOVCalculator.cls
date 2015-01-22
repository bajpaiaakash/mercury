/**
 * @author Joseph Ferraro
 *
 * Trigger handler that facilitates TOV rollups
 *
 * 1 - fix static boolean hack
 * 2 - move to async processing
 */

public with sharing class MERC_TOVCalculator implements GLBL_TriggerHandler.HandlerInterface {

	public static Boolean runHotelTovCalculation = true;
	public static Boolean runIndividualTransferTovCalculation = true;

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
			p('MeetingIds : ' + meetingIds);
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

			p('participantIdToTransferItineraries:'+participantIdToTransferItineraries);

			Map<Id,Daily_Attendance_TOV_MERC__c> tovs = new Map<Id,Daily_Attendance_TOV_MERC__c>(
													[SELECT Id, Status_MERC__c, Est_Indv_Transfer_MERC__c, Meeting_Day_MERC__c, Meeting_Participant_MERC__c, Confirm_ToV_Reporting_Change_MERC__c
				                                     FROM Daily_Attendance_TOV_MERC__c
				 									 WHERE Meeting_Participant_MERC__c in :participantIdToTransferItineraries.keySet()]);

			p('tovs.size:'+tovs.size());
			p('tovs:'+tovs);
			Map<Id,Daily_Attendance_TOV_MERC__c> tovRecordsToUpdate = new Map<Id,Daily_Attendance_TOV_MERC__c>();

			for (Id tovId : tovs.keySet()) {
				p('processing '+tovId);
				Daily_Attendance_TOV_MERC__c tov = tovs.get(tovId);
				Decimal sumOfIndvTransfer = 0;
				if (participantIdToTransferItineraries.containsKey(tov.Meeting_Participant_MERC__c)) 
				{
					Date meetingDayDate = meetingDays.get(tov.Meeting_Day_MERC__c).Date_MERC__c;
					List<Travel_Itinerary_MERC__c> individualTransfersForParticipant = participantIdToTransferItineraries.get(tov.Meeting_Participant_MERC__c);
					for (Travel_Itinerary_MERC__c t : individualTransfersForParticipant) 
					{
						Date timestampStart = t.Sgmnt_Bgin_TS_MERC__c.date();
						Date timestampEnd = t.Sgmnt_End_TS_MERC__c.date();
						//Set the confirm reporting to true. If confirmirmation was needed on the meeting vendor
						//or the travel itinerary we would not get here without the user having checked that box.
						tov.Confirm_ToV_Reporting_Change_MERC__c = true;
						p('meetingDayDate: ' + meetingDayDate + ' and timestampStart: ' + timestampStart);
						if ( t.Include_ToV_MERC__c && meetingDayDate == timestampStart) 
						{
							if (t.Total_Fare_Amount_MERC__c != null) sumOfIndvTransfer += t.Total_Fare_Amount_MERC__c;
							tov.Est_Indv_Transfer_MERC__c = sumOfIndvTransfer;
							tovRecordsToUpdate.put(tov.Id,tov);
						} else {
							if (t.Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes') 
							{
								if (tov.Est_Indv_Transfer_MERC__c != null) 
								{
									tov.Est_Indv_Transfer_MERC__c = 0.0;
									tovRecordsToUpdate.put(tov.Id,tov);
								}
							} else {
								tov.Est_Indv_Transfer_MERC__c = null;
								tovRecordsToUpdate.put(tov.Id,tov);
							}
						}
					}
				}
			}

			MERC_TOVCalculator.runIndividualTransferTovCalculation = false;
			update new List<Daily_Attendance_TOV_MERC__c>(tovRecordsToUpdate.values());
		}

		// Individual Transfers: check for creation/edit of daily attendance/tov records
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

		p('calculateHotelTov()!\r\r'+this.triggeredSobjectType);
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

p('calculateHotelTov-isAfter '+this.triggeredSobjectType+':'+meetingIds);

			if (meetingIds.size() == 0) return;
Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c> tovToItinerary = associateToVwithItinerary(null,meetingIds,null);

//			Map<Id, Meeting_Day_MERC__c> meetingDays = new Map<Id, Meeting_Day_MERC__c>([SELECT ID, Date_MERC__c FROM Meeting_Day_MERC__c WHERE Meeting_MERC__c in :meetingIds]);

//			Map<Id, List<Travel_Itinerary_MERC__c>> participantIdToHotelItineraries = new Map <Id, List<Travel_Itinerary_MERC__c>>();
//			for (Meeting_Participant_MERC__c mp : [SELECT ID, Name,
//														(SELECT
//															ID, Sgmnt_Bgin_TS_MERC__c, Sgmnt_End_TS_MERC__c,
//															Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c,
//															Room_Rate_excl_VAT_MERC__c, Include_ToV_MERC__c
//																FROM Travel_Itineraries_MERC__r
//																	WHERE RecordType.DeveloperName = 'Hotel_MERC')
//														FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c in :meetingIds]) {
//				participantIdToHotelItineraries.put(mp.Id, mp.Travel_Itineraries_MERC__r);
//			}

//p('participantIdToHotelItineraries:'+participantIdToHotelItineraries);

//			// Associate TOVs with their respective Itineraries
//			Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c> tovToItinerary = new Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c>();
//			for (Daily_Attendance_TOV_MERC__c tov : [SELECT ID, Status_MERC__c, Est_Hotel_ToV_MERC__c, Meeting_Day_MERC__c, Meeting_Participant_MERC__c, Confirm_ToV_Reporting_Change_MERC__c,
//															Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c
//				                                       FROM Daily_Attendance_TOV_MERC__c
//				 									  WHERE Meeting_Participant_MERC__c in :participantIdToHotelItineraries.keySet()]) {
//p('Daily_Attendance_TOV_MERC__c: '+tov);
//				if (participantIdToHotelItineraries.containsKey(tov.Meeting_Participant_MERC__c)) {
//					Date meetingDayDate = meetingDays.get(tov.Meeting_Day_MERC__c).Date_MERC__c;
//					List<Travel_Itinerary_MERC__c> hotelTravelItinerariesForParticipant = participantIdToHotelItineraries.get(tov.Meeting_Participant_MERC__c);

//// items modified need to go into new collection to prevent double processing (eg. itin 1 vs. meetingday 2)

//					for (Travel_Itinerary_MERC__c t : hotelTravelItinerariesForParticipant) {
//						Date timestampStart = t.Sgmnt_Bgin_TS_MERC__c.date();
//						Date timestampEnd = t.Sgmnt_End_TS_MERC__c.date();
//						if (meetingDayDate >= timestampStart && meetingDayDate <= timestampEnd.addDays(-1)) {  
//							p('itinerary within date range: '+tov+' \r\r '+t);
//							//tov.Est_Hotel_ToV_MERC__c = t.Room_Rate_excl_VAT_MERC__c;
//							tovToItinerary.put(tov,t);
//						//} else {
//						//	p(meetingDayDate +'>='+ timestampStart +'&&'+ meetingDayDate +'<='+ timestampEnd.addDays(-1));
//							// TODO - make the next if/else a util method as it's used with slight variation in many places
//							// no longer skipping any tovs due to overcharging when dates are adjusted (per T-1378). This may need to be rolled back
//							//t.Status_MERC__c = 'Confirmed';
//							//if (t.Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes') { // this value has already been sent to Activity ODS
//							//	p('ToV is Final');
//							//	if (tov.Est_Hotel_ToV_MERC__c != null) {
//							//		p('Est_Hotel_ToV_MERC__c is not null but '+tov.Est_Hotel_ToV_MERC__c);
//							//	 	tov.Est_Hotel_ToV_MERC__c = 0.0;
//							//		tovToItinerary.put(tov,t);
//							//	}
//							//} else {
//							//	p('ToV is not final, so setting value to null');
//							//	tov.Est_Hotel_ToV_MERC__c = null;
//							//	tovToItinerary.put(tov,t);
//							//}
//						}
//					}
//				}
//			}


p('hotel ToV #1 from travel itinerary: '+tovToItinerary);
			// Determine which TOVs to process and how...
			List<Daily_Attendance_TOV_MERC__c> tovRecordsToUpdate = new List<Daily_Attendance_TOV_MERC__c>();

			Map<Id,Daily_Attendance_TOV_MERC__c> tovKeys = new Map<Id,Daily_Attendance_TOV_MERC__c>();
			for (Daily_Attendance_TOV_MERC__c tov : tovToItinerary.keySet()) {
				tovKeys.put(tov.Id,tov);
			}
Integer i = 0;
			for (Id tovId : tovKeys.keySet()) {
				Daily_Attendance_TOV_MERC__c tov = tovKeys.get(tovId);
p('tov'+i+': '+tov);

				//apply itinerary to tov
				Travel_Itinerary_MERC__c t = tovToItinerary.get(tov);
p('t'+i+': '+t);

				//Set the confirm reporting to true. If confirmirmation was needed on the meeting vendor
				//or the travel itinerary we would not get here without the user having checked that box.
				tov.Confirm_ToV_Reporting_Change_MERC__c = true;

				if ((t==null || t.Room_Rate_excl_VAT_MERC__c==null) || !t.Include_ToV_MERC__c) {
					if (tov.Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes') { // this value has already been sent to Activity ODS
p(i+': ToV is Final');
						if (tov.Est_Hotel_ToV_MERC__c != null) {
p(i+': Est_Hotel_ToV_MERC__c is not null but '+tov.Est_Hotel_ToV_MERC__c);
						 	tov.Est_Hotel_ToV_MERC__c = 0.0;
							tovRecordsToUpdate.add(tov);
						}
					} else {
p(i+': ToV is not final, so setting value to null');
						tov.Est_Hotel_ToV_MERC__c = null;
						tovRecordsToUpdate.add(tov);
					}
				} else {
p(i+': updating room rate to '+t.Room_Rate_excl_VAT_MERC__c);
					tov.Est_Hotel_ToV_MERC__c = t.Room_Rate_excl_VAT_MERC__c;
					tovRecordsToUpdate.add(tov);
				}
i++;
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

			p('YYZ: calculateHotelTov-isBefore '+meetingParticipantIds);
List<Daily_Attendance_TOV_MERC__c> tovs = (List<Daily_Attendance_TOV_MERC__c>) sobjects;
Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c> tovToItinerary = associateToVwithItinerary(tovs,meetingDayIds,meetingParticipantIds);
			//get map of meeting days
//			Map<Id, Meeting_Day_MERC__c> meetingDays = new Map<Id, Meeting_Day_MERC__c>([SELECT ID, Date_MERC__c FROM Meeting_Day_MERC__c WHERE ID in :meetingDayIds]);

//			Map<Id, List<Travel_Itinerary_MERC__c>> participantIdToHotelItineraries = new Map <Id, List<Travel_Itinerary_MERC__c>>();
//			for (Meeting_Participant_MERC__c mp : [SELECT ID, Name,
//														(SELECT
//															ID, Sgmnt_Bgin_TS_MERC__c, Sgmnt_End_TS_MERC__c,
//															Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c,
//															Room_Rate_excl_VAT_MERC__c
//																FROM Travel_Itineraries_MERC__r
//																	WHERE RecordType.DeveloperName = 'Hotel_MERC')
//														FROM Meeting_Participant_MERC__c WHERE Id in :meetingParticipantIds]) {
//				participantIdToHotelItineraries.put(mp.Id, mp.Travel_Itineraries_MERC__r);
//			}
//			p('participantIdToHotelItineraries:'+participantIdToHotelItineraries);

//			// Associate TOVs with their respective Itineraries
//			Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c> tovToItinerary = new Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c>();
//			for (Daily_Attendance_TOV_MERC__c tov : (List<Daily_Attendance_TOV_MERC__c>)sobjects) {
//p('Daily_Attendance_TOV_MERC__c: '+tov);
//				if (participantIdToHotelItineraries.containsKey(tov.Meeting_Participant_MERC__c) && meetingDays.containsKey(tov.Meeting_Day_MERC__c)) {
//					Date meetingDayDate = meetingDays.get(tov.Meeting_Day_MERC__c).Date_MERC__c;
//					List<Travel_Itinerary_MERC__c> hotelTravelItinerariesForParticipant = participantIdToHotelItineraries.get(tov.Meeting_Participant_MERC__c);
//					for (Travel_Itinerary_MERC__c t : hotelTravelItinerariesForParticipant) {
//						Date timestampStart = t.Sgmnt_Bgin_TS_MERC__c.date();
//						Date timestampEnd = t.Sgmnt_End_TS_MERC__c.date();
//						if (meetingDayDate >= timestampStart && meetingDayDate <= timestampEnd.addDays(-1)) {
//							p('Setting t.Room_Rate_excl_VAT_MERC__c to '+t.Room_Rate_excl_VAT_MERC__c);
//							tov.Est_Hotel_ToV_MERC__c = t.Room_Rate_excl_VAT_MERC__c;
//							tovToItinerary.put(tov,t);
//						} else {
//							p('Skipping this itinerary: '+tov+'|'+t);
//							p(meetingDayDate +'>='+ timestampStart +'&&'+ meetingDayDate +'<='+ timestampEnd.addDays(-1));
//						}
//					}
//				}
//			}

			p('tovToItinerary'+tovToItinerary);

p('hotel ToV #2 from DA');
			// Determine which TOVs to process and how...
			List<Daily_Attendance_TOV_MERC__c> tovRecordsToUpdate = new List<Daily_Attendance_TOV_MERC__c>();

			Map<Id,Daily_Attendance_TOV_MERC__c> tovKeys = new Map<Id,Daily_Attendance_TOV_MERC__c>();
			for (Daily_Attendance_TOV_MERC__c tov : tovToItinerary.keySet()) {
				tovKeys.put(tov.Id,tov);
			}
Integer i = 0;

//			for (Daily_Attendance_TOV_MERC__c tov : tovToItinerary.keySet()) {
			for (Id tovId : tovKeys.keySet()) {
				Daily_Attendance_TOV_MERC__c tov = tovKeys.get(tovId);
p('tov'+i+': '+tov);

				//apply itinerary to tov
				Travel_Itinerary_MERC__c t = tovToItinerary.get(tov);
p('t'+i+': '+t);

				if (t.Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes') {  // this value has already been sent to Activity ODS
					// if (tov.Est_Hotel_ToV_MERC__c != null) {
					// 	tov.Est_Hotel_ToV_MERC__c = 0.0;    // make no change if status update!
					// }
				} else {
					tov.Est_Hotel_ToV_MERC__c = t.Room_Rate_excl_VAT_MERC__c;
					tovRecordsToUpdate.add(tov);
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
		p('detailSObjects : ' + detailSobjects);
		if (detailSobjects != null && detailSobjects.size() > 0)
			GLBL_RollupService.triggerHandler(detailSobjects);
	}

	/*
	 * Combining some repeated code, this method associates Daily_Attendance_TOV_MERC__c records with a related itinerary record assuming (for now) a
	 * one-to-one coorespondence.
	 *
	 * @param  tovs 							List of Daily_Attendance_TOV_MERC records for input. Param can be null in which case records will be queried for.
	 * @param  idListOne						Set of Ids. If Meeting_Day_MERC ids, meetingParticipantIds param cannot be null
	 * @param  meetingParticipantIds			Set of related Meeting_Participant_MERC Ids. Param can be null in which case param idListOne will be used in its place
	 * @return 									Map of Daily_Attendance_TOV_MERC records to related Travel_Itinerary_MERCs
	 */
	private static Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c> associateToVwithItinerary(
		List<Daily_Attendance_TOV_MERC__c>      	tovs, 
		Set<Id> 									idListOne,
		Set<Id> 									meetingParticipantIds
	) {

		String mpFilter = (meetingParticipantIds==null) ? 'Meeting_MERC__c' : 'Id';  // idListOne contains Meeting ids or Meeting_Day

		String soql = 'SELECT ID, Date_MERC__c FROM Meeting_Day_MERC__c WHERE '+mpFilter+' in :idListOne';
		List<Meeting_Day_MERC__c> meetingDayList = (List<Meeting_Day_MERC__c>) Database.query(soql);
		Map<Id, Meeting_Day_MERC__c> meetingDays = new Map<Id, Meeting_Day_MERC__c>(meetingDayList);

		Map<Id, List<Travel_Itinerary_MERC__c>> participantIdToHotelItineraries = new Map<Id, List<Travel_Itinerary_MERC__c>>();
		soql = 'SELECT ID, Name, '+ 
							'(SELECT '+
							'	ID, Sgmnt_Bgin_TS_MERC__c, Sgmnt_End_TS_MERC__c,Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c, '+
							'	Room_Rate_excl_VAT_MERC__c, Include_ToV_MERC__c '+
							'FROM Travel_Itineraries_MERC__r '+
							'WHERE RecordType.DeveloperName = \'Hotel_MERC\') '+
					   'FROM Meeting_Participant_MERC__c WHERE '+mpFilter+' in ';
		soql += (meetingParticipantIds==null) ? ':idListOne' : ':meetingParticipantIds';
					
		for (Meeting_Participant_MERC__c mp : (List<Meeting_Participant_MERC__c>) Database.query(soql)) {
			participantIdToHotelItineraries.put(mp.Id, mp.Travel_Itineraries_MERC__r);
		}

		if (tovs==null) {
			tovs = [SELECT ID, Status_MERC__c, Est_Hotel_ToV_MERC__c, Meeting_Day_MERC__c, Meeting_Participant_MERC__c, Confirm_ToV_Reporting_Change_MERC__c,
						Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c
                    FROM Daily_Attendance_TOV_MERC__c
					WHERE Meeting_Participant_MERC__c in :participantIdToHotelItineraries.keySet()];
		}

		Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c> tovToItinerary = new Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c>();
		for (Daily_Attendance_TOV_MERC__c tov : tovs) {
			p('tov: '+tov);
			if (participantIdToHotelItineraries.containsKey(tov.Meeting_Participant_MERC__c) && meetingDays.containsKey(tov.Meeting_Day_MERC__c)) {
				Date meetingDayDate = meetingDays.get(tov.Meeting_Day_MERC__c).Date_MERC__c;
				List<Travel_Itinerary_MERC__c> hotelTravelItinerariesForParticipant = participantIdToHotelItineraries.get(tov.Meeting_Participant_MERC__c);

				for (Travel_Itinerary_MERC__c t : hotelTravelItinerariesForParticipant) {
					Date timestampStart = t.Sgmnt_Bgin_TS_MERC__c.date();
					Date timestampEnd = t.Sgmnt_End_TS_MERC__c.date();
					if (meetingDayDate >= timestampStart && meetingDayDate <= timestampEnd.addDays(-1)) {  
						p('itinerary within date range: '+tov+' \r\r '+t);
						tovToItinerary.put(tov,t);
					}
				}
			}
		}
		return tovToItinerary;
	}

	private static void p(String m) {
		System.debug(LoggingLevel.INFO,'\n\nYYZ - '+m+'\n\n');
	}
}