/**
 * @author Joseph Ferraro
 * @author Sean Harrison
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

		p('calculateIndividualTransportToV()!\rObject Type:'+this.triggeredSobjectType+
			'\r runIndividualTransferTovCalculation='+MERC_TOVCalculator.runIndividualTransferTovCalculation+
			'\rTrigger.isBefore='+Trigger.isBefore);


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
			p('Accounting for modified Itineraries. MeetingIds : ' + meetingIds);
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

			Map<String,Daily_Attendance_TOV_MERC__c> tovs = new Map<String,Daily_Attendance_TOV_MERC__c>(
													[SELECT Id, Status_MERC__c, Est_Indv_Transfer_MERC__c, Meeting_Day_MERC__c, Meeting_Participant_MERC__c, Confirm_ToV_Reporting_Change_MERC__c
				                                     FROM Daily_Attendance_TOV_MERC__c
				 									 WHERE Meeting_Participant_MERC__c in :participantIdToTransferItineraries.keySet()]);

			p('tovs.size:'+tovs.size());
			p('tovs:'+tovs);
			Map<Id,Daily_Attendance_TOV_MERC__c> tovRecordsToUpdate = applyIndividualTransferValues(tovs, participantIdToTransferItineraries, meetingDays);

			//new Map<Id,Daily_Attendance_TOV_MERC__c>();

			//for (Id tovId : tovs.keySet()) {
			//	Daily_Attendance_TOV_MERC__c tov = tovs.get(tovId);
			//	Decimal sumOfIndvTransfer = 0;
			//	if (participantIdToTransferItineraries.containsKey(tov.Meeting_Participant_MERC__c)) 
			//	{
			//		Date meetingDayDate = meetingDays.get(tov.Meeting_Day_MERC__c).Date_MERC__c;
			//		List<Travel_Itinerary_MERC__c> individualTransfersForParticipant = participantIdToTransferItineraries.get(tov.Meeting_Participant_MERC__c);
			//		for (Travel_Itinerary_MERC__c t : individualTransfersForParticipant) 
			//		{
			//			Date timestampStart = t.Sgmnt_Bgin_TS_MERC__c.date();
			//			Date timestampEnd = t.Sgmnt_End_TS_MERC__c.date();
			//			//Set the confirm reporting to true. If confirmirmation was needed on the meeting vendor
			//			//or the travel itinerary we would not get here without the user having checked that box.
			//			tov.Confirm_ToV_Reporting_Change_MERC__c = true;
			//			if (t.Include_ToV_MERC__c && meetingDayDate == timestampStart) 
			//			{
			//				if (t.Total_Fare_Amount_MERC__c != null) sumOfIndvTransfer += t.Total_Fare_Amount_MERC__c;
			//				tov.Est_Indv_Transfer_MERC__c = sumOfIndvTransfer;
			//				tovRecordsToUpdate.put(tov.Id,tov);
			//			} else {
			//				if (t.Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes') 
			//				{
			//					if (tov.Est_Indv_Transfer_MERC__c != null) 
			//					{
			//						tov.Est_Indv_Transfer_MERC__c = 0.0;
			//						tovRecordsToUpdate.put(tov.Id,tov);
			//					}
			//				} else {
			//					tov.Est_Indv_Transfer_MERC__c = null;
			//					tovRecordsToUpdate.put(tov.Id,tov);
			//				}
			//			}
			//		}
			//	}
			//}

			MERC_TOVCalculator.runIndividualTransferTovCalculation = false;
			update new List<Daily_Attendance_TOV_MERC__c>(tovRecordsToUpdate.values());
		}

		// Individual Transfers: check for creation/edit of daily attendance/tov records
		if (
			this.triggeredSobjectType == Daily_Attendance_TOV_MERC__c.SobjectType &&
			Trigger.isBefore
		) {
			p('Accounting for modified ToVs.');
			//get list of participant ids & meeting day ids associated with this transaction
			Set<Id> meetingParticipantIds = new Set<Id>();
			Set<Id> meetingDayIds = new Set<Id>();
			for (Daily_Attendance_TOV_MERC__c tov : (List<Daily_Attendance_TOV_MERC__c>)sobjects) {
				meetingParticipantIds.add(tov.Meeting_Participant_MERC__c);
				meetingDayIds.add(tov.Meeting_Day_MERC__c);
			}

			p('meetingParticipantIds'+meetingParticipantIds);

			//get map of meeting days
			Map<Id, Meeting_Day_MERC__c> meetingDays = new Map<Id, Meeting_Day_MERC__c>([SELECT ID, Date_MERC__c FROM Meeting_Day_MERC__c WHERE ID in :meetingDayIds]);

			Map<Id, List<Travel_Itinerary_MERC__c>> participantIdToTransferItineraries = new Map <Id, List<Travel_Itinerary_MERC__c>>();
			for (Meeting_Participant_MERC__c mp : [SELECT ID, Name,
														(SELECT
															ID, Sgmnt_Bgin_TS_MERC__c, Sgmnt_End_TS_MERC__c, Include_ToV_MERC__c, 
															Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c,
															Total_Fare_Amount_MERC__c
																FROM Travel_Itineraries_MERC__r
																	WHERE Individual_Travel_ToV_Applicable_MERC__c = true)
														FROM Meeting_Participant_MERC__c WHERE Id in :meetingParticipantIds]) {
				participantIdToTransferItineraries.put(mp.Id, mp.Travel_Itineraries_MERC__r);
			}
p('participantIdToTransferItineraries'+participantIdToTransferItineraries);
			Integer i = 0;
			Map<String,Daily_Attendance_TOV_MERC__c> tovs = new Map<String,Daily_Attendance_TOV_MERC__c>();
			for (Daily_Attendance_TOV_MERC__c tov : (List<Daily_Attendance_TOV_MERC__c>)sobjects) {
				tovs.put(String.valueOf(i),tov);
				i++;
			}

			applyIndividualTransferValues(tovs, participantIdToTransferItineraries, meetingDays);
			//for (Integer tovId : tovKeys.keySet()) {
			//	Daily_Attendance_TOV_MERC__c tov = tovKeys.get(tovId);
			//	Decimal sumOfIndvTransfer = 0;
			//	if (participantIdToTransferItineraries.containsKey(tov.Meeting_Participant_MERC__c) && meetingDays.containsKey(tov.Meeting_Day_MERC__c)) 
			//	{
			//		Date meetingDayDate = meetingDays.get(tov.Meeting_Day_MERC__c).Date_MERC__c;
			//		List<Travel_Itinerary_MERC__c> travelItinerariesForParticipant = participantIdToTransferItineraries.get(tov.Meeting_Participant_MERC__c);
			//		for (Travel_Itinerary_MERC__c t : travelItinerariesForParticipant) 
			//		{
			//			//Set the confirm reporting to true. If confirmirmation was needed on the meeting vendor
			//			//or the travel itinerary we would not get here without the user having checked that box.
			//			tov.Confirm_ToV_Reporting_Change_MERC__c = true;

			//			Date timestampStart = t.Sgmnt_Bgin_TS_MERC__c.date();
			//			Date timestampEnd = t.Sgmnt_End_TS_MERC__c.date();
			//			if (t.Include_ToV_MERC__c && meetingDayDate == timestampStart) 
			//			{
			//				if (t.Total_Fare_Amount_MERC__c != null) sumOfIndvTransfer += t.Total_Fare_Amount_MERC__c;
			//				tov.Est_Indv_Transfer_MERC__c = sumOfIndvTransfer;
			//			} else {
			//				if (t.Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes') 
			//				{
			//					if (tov.Est_Indv_Transfer_MERC__c != null) {
			//						tov.Est_Indv_Transfer_MERC__c = 0.0;
			//					}
			//				} else {
			//					tov.Est_Indv_Transfer_MERC__c = null;
			//				}
			//			}
			//		}
			//	}
			//}
		}
	}

	/*
	 * Combining some repeated code, this method applies rule-based changes to ToV Est_Indv_Transfer_MERC__c
	 *
	 * @param  tovs 								Map of unique String key to Daily_Attendance_TOV_MERC records for input.
	 * @param  participantIdToTransferItineraries	Map of Meeting_Participant Ids to Lists of Itineraries
	 * @param  meetingDays							Map of Meeting_Day Ids to related Meeting_Days
	 * @return 										Map of DA/ToV Ids to Daily_Attendance_TOV_MERC records
	 */
	private Map<Id,Daily_Attendance_TOV_MERC__c> applyIndividualTransferValues(Map<String,Daily_Attendance_TOV_MERC__c> tovs, 
																			   Map<Id, List<Travel_Itinerary_MERC__c>> participantIdToTransferItineraries,
																			   Map<Id, Meeting_Day_MERC__c> meetingDays) {

		Map<Id,Daily_Attendance_TOV_MERC__c> tovRecordsToUpdate = new Map<Id,Daily_Attendance_TOV_MERC__c>();

		p('applyIndividualTransferValues()!\rObject Type:'+this.triggeredSobjectType+
			'\r runIndividualTransferTovCalculation='+MERC_TOVCalculator.runIndividualTransferTovCalculation+
			'\r Trigger.isBefore='+Trigger.isBefore);

p('participantIdToTransferItineraries: '+participantIdToTransferItineraries);
		Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c> tovToItinerary = new Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c>();
		for (Daily_Attendance_TOV_MERC__c tov : tovs.values()) {
			p('tov: '+tov);
			Boolean accountedFor = false;
p('participantIdToTransferItineraries.containsKey(tov.Meeting_Participant_MERC__c):'+participantIdToTransferItineraries.containsKey(tov.Meeting_Participant_MERC__c));
p('meetingDays.containsKey(tov.Meeting_Day_MERC__c):'+meetingDays.containsKey(tov.Meeting_Day_MERC__c));

			if (participantIdToTransferItineraries.containsKey(tov.Meeting_Participant_MERC__c) && meetingDays.containsKey(tov.Meeting_Day_MERC__c)) {
				Date meetingDayDate = meetingDays.get(tov.Meeting_Day_MERC__c).Date_MERC__c;
				List<Travel_Itinerary_MERC__c> transferTravelItinerariesForParticipant = participantIdToTransferItineraries.get(tov.Meeting_Participant_MERC__c);

				for (Travel_Itinerary_MERC__c t : transferTravelItinerariesForParticipant) {
					Date timestampStart = t.Sgmnt_Bgin_TS_MERC__c.date();
					Date timestampEnd = t.Sgmnt_End_TS_MERC__c.date();
					p('itinerary within date range?: \r\r'+timestampStart+'>='+meetingDayDate+'<='+timestampEnd+'\r\r'+tov+' \r\r '+t);
					if (meetingDayDate >= timestampStart && meetingDayDate <= timestampEnd) {  
						tovToItinerary.put(tov,t);
						accountedFor = true;
					}
				}
			}

			// what if date is changed and tov left orphaned? set t to null
			if (!accountedFor) {
				p('tov orphaned? '+tov);
				tovToItinerary.put(tov,null);
			}
		}

p('tovToItinerary: '+tovToItinerary);
		Map<Id,Daily_Attendance_TOV_MERC__c> tovKeys = new Map<Id,Daily_Attendance_TOV_MERC__c>();
		for (Daily_Attendance_TOV_MERC__c tov : tovToItinerary.keySet()) {
			tovKeys.put(tov.Id,tov);
		}
Integer i = 100;
		for (String tovId : tovKeys.keySet()) {
			Daily_Attendance_TOV_MERC__c tov = tovKeys.get(tovId);
			Travel_Itinerary_MERC__c t = tovToItinerary.get(tov);
			Decimal sumOfIndvTransfer = 0;
p('tov'+i+': '+sumOfIndvTransfer+' '+tov);
p('t'+i+': '+t);
			if (t!=null) 
			{
				//Set the confirm reporting to true. If confirmirmation was needed on the meeting vendor
				//or the travel itinerary we would not get here without the user having checked that box.
				tov.Confirm_ToV_Reporting_Change_MERC__c = true;

				// has value already been sent to Activity ODS?
				Boolean tovIsFinal = t.Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes';
				if (t.Include_ToV_MERC__c) 
				{
p(i+': Include_ToV_MERC__c');
					if (t.Total_Fare_Amount_MERC__c != null) sumOfIndvTransfer += t.Total_Fare_Amount_MERC__c;
					tov.Est_Indv_Transfer_MERC__c = sumOfIndvTransfer;
p(i+': Setting Est_Indv_Transfer_MERC__c = '+sumOfIndvTransfer);
				} else {
p(i+': Include_ToV_MERC__c = '+t.Include_ToV_MERC__c);
					if (tovIsFinal) 
					{
p(i+'ToV is Final');
						if (tov.Est_Indv_Transfer_MERC__c != null) 
						{
p(i+'Est_Indv_Transfer_MERC__c != null');
							tov.Est_Indv_Transfer_MERC__c = 0.0;
						}
p(i+'Est_Indv_Transfer_MERC__c is already null');
					} else {
p(i+'Setting Est_Indv_Transfer_MERC__c to null');
						tov.Est_Indv_Transfer_MERC__c = null;
					}
				}
			} else {
p('no itineraries for this DA/ToV. Setting to null.');
				tov.Est_Indv_Transfer_MERC__c = null;
			}
			tovRecordsToUpdate.put(tov.Id,tov);
		}
		return tovRecordsToUpdate;
	}

	private void calculateHotelTov(List<SObject> sobjects) {

		p('calculateHotelTov()!\rObject Type:'+this.triggeredSobjectType+
			'\rrunHotelTovCalculation='+MERC_TOVCalculator.runHotelTovCalculation+
			'\rTrigger.isBefore='+Trigger.isBefore);

		/*** =============== check for creation/edit of vendor or itinerary records  =============== ***/
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

			//check for itinerary change
			//TODO: we don't need to process all meetings, so provide list of affected travel itineraries instead *************
			} else if (this.triggeredSobjectType == Travel_Itinerary_MERC__c.SobjectType) {
				for (Travel_Itinerary_MERC__c ti : (List<Travel_Itinerary_MERC__c>)sobjects) {
					if (Trigger.isInsert ||
						(Trigger.oldMap.get(ti.Id).get('Meeting_Vendor_MERC__c') != ti.Meeting_Vendor_MERC__c ||
						  Trigger.oldMap.get(ti.Id).get('Sgmnt_Bgin_TS_MERC__c') != ti.Sgmnt_Bgin_TS_MERC__c ||
						  Trigger.oldMap.get(ti.Id).get('Sgmnt_End_TS_MERC__c') != ti.Sgmnt_End_TS_MERC__c ||
						  Trigger.oldMap.get(ti.Id).get('Status_MERC__c') != ti.Status_Merc__c) &&
						!ti.Meeting_Status_MERC__c.startsWith('Complete')) {

						meetingIds.add(ti.Meeting_Id_MERC__c);
					}
				}
			}

p('calculateHotelTov-isAfter '+this.triggeredSobjectType+':'+meetingIds);

			if (meetingIds.size() == 0) return;
			Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c> tovToItinerary = associateToVwithHotelItinerary(null,meetingIds,null);

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
				Travel_Itinerary_MERC__c t = tovToItinerary.get(tov);
p('tov'+i+': '+tov);


p('t'+i+': '+t);
				if (t!=null) {
					//Set the confirm reporting to true. If confirmirmation was needed on the meeting vendor
					//or the travel itinerary we would not get here without the user having checked that box.
					tov.Confirm_ToV_Reporting_Change_MERC__c = true;

					// has value already been sent to Activity ODS?
					Boolean tovIsFinal = t.Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes';
					Boolean noRoomRate = t==null || t.Room_Rate_excl_VAT_MERC__c==null;

					if (noRoomRate || !t.Include_ToV_MERC__c) {
						if (tovIsFinal) {
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
				} else {
					tov.Est_Hotel_ToV_MERC__c = null;
					tovRecordsToUpdate.add(tov);
				}
i++;
			}

			MERC_TOVCalculator.runHotelTovCalculation = false;
			update tovRecordsToUpdate;
		}

		/*** =============== check for creation/edit of daily attendance/tov records  =============== ***/
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
			Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c> tovToItinerary = associateToVwithHotelItinerary(tovs,meetingDayIds,meetingParticipantIds);

			p('tovToItinerary'+tovToItinerary);

p('hotel ToV #2 from DA');
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

				if (t!=null) {
					Boolean tovIsFinal = t.Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes';
					Boolean statusUpdate = Trigger.isUpdate && (Trigger.oldMap.get(tov.Id).get('Status_MERC__c') != tov.Status_Merc__c);

					if (tovIsFinal) {
						if (!statusUpdate && tov.Est_Hotel_ToV_MERC__c != null) tov.Est_Hotel_ToV_MERC__c = 0.0;
					} else if (tov.Status_MERC__c=='No Show') {
						tov.Est_Hotel_ToV_MERC__c = null;
					} else {
						tov.Est_Hotel_ToV_MERC__c = t.Room_Rate_excl_VAT_MERC__c;
						tovRecordsToUpdate.add(tov);
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
		p('rolling up these detailSObjects : ' + detailSobjects);
		if (detailSobjects != null && detailSobjects.size() > 0)
			GLBL_RollupService.triggerHandler(detailSobjects);
	}

	/**
	 * Combining some repeated code, this method associates Daily_Attendance_TOV_MERC__c records with a related *hotel* itinerary record assuming (for now) a
	 * one-to-one coorespondence.
	 *
	 * @param  tovs 							List of Daily_Attendance_TOV_MERC records for input. Param can be null in which case records will be queried for.
	 * @param  idListOne						Set of Ids. If Meeting_Day_MERC ids, meetingParticipantIds param cannot be null
	 * @param  meetingParticipantIds			Set of related Meeting_Participant_MERC Ids. Param can be null in which case param idListOne will be used in its place.
	 * @return 									Map of Daily_Attendance_TOV_MERC records to related Travel_Itinerary_MERCs
	 **/
	private static Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c> associateToVwithHotelItinerary(
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
			Boolean accountedFor = false;

			if (participantIdToHotelItineraries.containsKey(tov.Meeting_Participant_MERC__c) && meetingDays.containsKey(tov.Meeting_Day_MERC__c)) {
				Date meetingDayDate = meetingDays.get(tov.Meeting_Day_MERC__c).Date_MERC__c;
				List<Travel_Itinerary_MERC__c> hotelTravelItinerariesForParticipant = participantIdToHotelItineraries.get(tov.Meeting_Participant_MERC__c);

				for (Travel_Itinerary_MERC__c t : hotelTravelItinerariesForParticipant) {
					Date timestampStart = t.Sgmnt_Bgin_TS_MERC__c.date();
					Date timestampEnd = t.Sgmnt_End_TS_MERC__c.date();
					p('itinerary within date range?: \r\r'+timestampStart+'>='+meetingDayDate+'<='+timestampEnd.addDays(-1)+'\r\r'+tov+' \r\r '+t);
					if (meetingDayDate >= timestampStart && meetingDayDate <= timestampEnd.addDays(-1)) {  
						p('itinerary within date range: '+tov+' \r\r '+t);
						tovToItinerary.put(tov,t);
						accountedFor = true;
					}
				}
			}

			// what if date is changed and tov left orphaned? set t to null
			if (!accountedFor) {
				p('tov orphaned? '+tov);
				tovToItinerary.put(tov,null);
			}
		}
		return tovToItinerary;
	}

	// TODO: Remove debug statements. Hide for now by setting to FINE
	private static void p(String m) {
		System.debug(LoggingLevel.INFO,'\n\nYYZ - '+m+'\n\n');
	}
}