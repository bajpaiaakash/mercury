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

    /**
    * The constructor
    * @param sobjectType - Schema.SobjectType 
    */
    public MERC_TOVCalculator(Schema.SobjectType sobjectType) {
        this.triggeredSobjectType = sObjectType;
    }

    /**
    * This boolean determines if this trigger class is active or inactive. Primarily used manipulated for testing purposes.
    */
    public Boolean isActive() {
        return MERC_TriggerHandlerStateManager.isActive(MERC_TOVCalculator.class);
    }

    /**
    * Handle for this trigger class. Determines what needs to be done and passes to the correct methods.
    */
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
            Set<Id> meetingParticipantIds = new Set<Id>();

            for (Travel_Itinerary_MERC__c ti : (List<Travel_Itinerary_MERC__c>)sobjects) {
                if (Trigger.isInsert ||
                    (Trigger.oldMap.get(ti.Id).get('Sgmnt_Bgin_TS_MERC__c') != ti.Sgmnt_Bgin_TS_MERC__c ||
                        Trigger.oldMap.get(ti.Id).get('Sgmnt_End_TS_MERC__c') != ti.Sgmnt_End_TS_MERC__c ||
                        Trigger.oldMap.get(ti.Id).get('Status_MERC__c') != ti.Status_Merc__c ||
                        Trigger.oldMap.get(ti.Id).get('Individual_Travel_ToV_Applicable_MERC__c') != ti.Individual_Travel_ToV_Applicable_MERC__c ||
                        Trigger.oldMap.get(ti.Id).get('Total_Fare_Amount_MERC__c') != ti.Total_Fare_Amount_MERC__c) &&
                        !ti.Meeting_Status_MERC__c.startsWith('Complete')) {
                    meetingIds.add(ti.Meeting_Id_MERC__c);
                    meetingParticipantIds.add(ti.Meeting_Participant_MERC__c);
                }
            }

            if (meetingIds.size() == 0) return;

            Map<Id, Meeting_Day_MERC__c> meetingDays = new Map<Id, Meeting_Day_MERC__c>([SELECT ID, Date_MERC__c FROM Meeting_Day_MERC__c WHERE Meeting_MERC__c in :meetingIds]);

            Map<Id, List<Travel_Itinerary_MERC__c>> participantIdToTransferItineraries = new Map <Id, List<Travel_Itinerary_MERC__c>>();
            for (Meeting_Participant_MERC__c mp : [SELECT ID,
                                                          Name,
                                                          (SELECT ID,
                                                                  Sgmnt_Bgin_TS_MERC__c,
                                                                  Sgmnt_End_TS_MERC__c,
                                                                  Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c,
                                                                  Include_ToV_MERC__c,
                                                                  Total_Fare_Amount_MERC__c
                                                             FROM Travel_Itineraries_MERC__r
                                                            WHERE Individual_Travel_ToV_Applicable_MERC__c = true)
                                                     FROM Meeting_Participant_MERC__c
                                                    WHERE Id in :meetingParticipantIds]) {
                participantIdToTransferItineraries.put(mp.Id, mp.Travel_Itineraries_MERC__r);
            }

            List<Daily_Attendance_TOV_MERC__c> tovs = [SELECT Id,
                                                              Status_MERC__c,
                                                              Est_Indv_Transfer_MERC__c,
                                                              Meeting_Day_MERC__c,
                                                              Meeting_Participant_MERC__c,
                                                              Confirm_ToV_Reporting_Change_MERC__c,
                                                              Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c
                                                         FROM Daily_Attendance_TOV_MERC__c
                                                        WHERE Meeting_Participant_MERC__c IN :participantIdToTransferItineraries.keySet()];

            Map<Id,Daily_Attendance_TOV_MERC__c> tovRecordsToUpdate = applyIndividualTransferValues(tovs, participantIdToTransferItineraries, meetingDays);

            MERC_TOVCalculator.runIndividualTransferTovCalculation = false;
            update new List<Daily_Attendance_TOV_MERC__c>(tovRecordsToUpdate.values());
        }

        // Individual Transfers: check for creation/edit of daily attendance/tov records
        if (
            this.triggeredSobjectType == Daily_Attendance_TOV_MERC__c.SobjectType &&
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
                                                            ID, Sgmnt_Bgin_TS_MERC__c, Sgmnt_End_TS_MERC__c, Include_ToV_MERC__c,
                                                            Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c, Total_Fare_Amount_MERC__c
                                                                FROM Travel_Itineraries_MERC__r
                                                                    WHERE Individual_Travel_ToV_Applicable_MERC__c = true)
                                                        FROM Meeting_Participant_MERC__c WHERE Id in :meetingParticipantIds]) {
                participantIdToTransferItineraries.put(mp.Id, mp.Travel_Itineraries_MERC__r);
            }

            List<Daily_Attendance_TOV_MERC__c> tovs = new List<Daily_Attendance_TOV_MERC__c>();
            for (Daily_Attendance_TOV_MERC__c tov : [SELECT Id, Status_MERC__c, Est_Indv_Transfer_MERC__c, Meeting_Day_MERC__c, Meeting_Participant_MERC__c,
                                                    Confirm_ToV_Reporting_Change_MERC__c, Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c
                                                    FROM Daily_Attendance_TOV_MERC__c
                                                    WHERE Id in :sobjects]) {
                tovs.add(tov);
            }

            Map<Id,Daily_Attendance_TOV_MERC__c> updatedToVs = applyIndividualTransferValues(tovs, participantIdToTransferItineraries, meetingDays);

            for (Sobject obj : sobjects) {
                if (updatedToVs.containsKey(obj.Id)) obj.put('Est_Indv_Transfer_MERC__c', updatedToVs.get(obj.Id).Est_Indv_Transfer_MERC__c);
            }
        }
    }


    /**
     * This method combines some repeated code, this method applies rule-based changes to ToV Est_Indv_Transfer_MERC__c
     * @param  tovs                                 List of Daily_Attendance_TOV_MERC records for input.
     * @param  participantIdToTransferItineraries   Map of Meeting_Participant Ids to Lists of Itineraries
     * @param  meetingDays                          Map of Meeting_Day Ids to related Meeting_Days
     * @return                                      Map of DA/ToV Ids to Daily_Attendance_TOV_MERC records
     */
    private Map<Id,Daily_Attendance_TOV_MERC__c> applyIndividualTransferValues(List<Daily_Attendance_TOV_MERC__c> tovs,
                                                                               Map<Id, List<Travel_Itinerary_MERC__c>> participantIdToTransferItineraries,
                                                                               Map<Id, Meeting_Day_MERC__c> meetingDays) {


        Map<Id,Daily_Attendance_TOV_MERC__c> tovRecordsToUpdate = new Map<Id,Daily_Attendance_TOV_MERC__c>();

        Set<Id> processedItineraries = new Set<Id>();

        Map<Daily_Attendance_TOV_MERC__c,List<Travel_Itinerary_MERC__c>> tovToItinerary = new Map<Daily_Attendance_TOV_MERC__c,List<Travel_Itinerary_MERC__c>>();
        for (Daily_Attendance_TOV_MERC__c tov : tovs) {

            Boolean accountedFor = false;

            if (participantIdToTransferItineraries.containsKey(tov.Meeting_Participant_MERC__c) && meetingDays.containsKey(tov.Meeting_Day_MERC__c)) {
                Date meetingDayDate = meetingDays.get(tov.Meeting_Day_MERC__c).Date_MERC__c;
                List<Travel_Itinerary_MERC__c> transferTravelItinerariesForParticipant = participantIdToTransferItineraries.get(tov.Meeting_Participant_MERC__c);

                for (Travel_Itinerary_MERC__c t : transferTravelItinerariesForParticipant) {
                    Date timestampStart = t.Sgmnt_Bgin_TS_MERC__c.date();
                    Date timestampEnd = t.Sgmnt_End_TS_MERC__c.date();

                    if (meetingDayDate >= timestampStart && meetingDayDate <= timestampEnd && !processedItineraries.contains(t.Id)) {
                        if (tovToItinerary.get(tov)==null) {
                            tovToItinerary.put(tov, new List<Travel_Itinerary_MERC__c>());
                        }
                        tovToItinerary.get(tov).add(t);
                        accountedFor = true;
                        processedItineraries.add(t.Id);
                    }
                }
            }

            // what if date is changed or no longer individual travel and tov left orphaned? set t to null
            if (!accountedFor) {
                tovToItinerary.put(tov,null);
            }
        }

        Map<Id,Daily_Attendance_TOV_MERC__c> tovKeys = new Map<Id,Daily_Attendance_TOV_MERC__c>();
        for (Daily_Attendance_TOV_MERC__c tov : tovToItinerary.keySet()) {
            tovKeys.put(tov.Id,tov);
        }

        for (String tovId : tovKeys.keySet()) {
            Daily_Attendance_TOV_MERC__c tov = tovKeys.get(tovId);
            List<Travel_Itinerary_MERC__c> tList = tovToItinerary.get(tov);
            Decimal sumOfIndvTransfer = 0;

            // initializing
            Boolean tovIsFinal = tov.Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes';
            if (tovIsFinal)
            {
                if (tov.Est_Indv_Transfer_MERC__c != null)
                {
                    tov.Est_Indv_Transfer_MERC__c = 0.0;
                }
            } else {
                tov.Est_Indv_Transfer_MERC__c = null;
            }

            if (tList!=null)
            {
                for (Travel_Itinerary_MERC__c t : tList) {
                    if (t.Include_ToV_MERC__c)
                    {
                        if (t.Total_Fare_Amount_MERC__c != null) sumOfIndvTransfer += t.Total_Fare_Amount_MERC__c;
                        tov.Est_Indv_Transfer_MERC__c = sumOfIndvTransfer;
                    }
                }
            } else {
                tov.Est_Indv_Transfer_MERC__c = (tovIsFinal && tov.Est_Indv_Transfer_MERC__c!=null) ? 0.0 : null;
            }

            if (!tovIsFinal && tov.Est_Indv_Transfer_MERC__c==0) {
                tov.Est_Indv_Transfer_MERC__c = null;
            }
            tovRecordsToUpdate.put(tov.Id,tov);
        }
        return tovRecordsToUpdate;
    }

    /**
     * Calculating the hotel ToV based on the status of related objects. Per the admin guide:
     * <p>
     * Hotel ToV is managed by the creation of a Travel Itinerary record with the Hotel Record Type.
     * Mercury ignores No Show/Attended Daily Attendance & ToV Status values. For each Meeting Day with
     * a corresponding Segment Begin/End Date within a Travel Itinerary record of type Hotel, the Room Rate
     * on the Travel Itinerary becomes the ToV value for Hotel ToV. AODS will determine which days need
     * reporting based upon the Daily Status values that are pulled from Mercury.
     * </p>
     *
     * @param sobjects  List of Meeting_Vendor_MERC__c, Travel_Itinerary_MERC__c or Daily_Attendance_TOV_MERC__c
     **/
     private void calculateHotelTov(List<SObject> sobjects) {

        /*** =============== check for creation/edit of vendor or itinerary records  =============== ***/
        if (Trigger.isAfter &&(this.triggeredSobjectType == Meeting_Vendor_MERC__c.SobjectType || this.triggeredSobjectType == Travel_Itinerary_MERC__c.SobjectType)) {

            Set<Id> meetingIds = new Set<Id>();
            //check for room rate change
            Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c> tovToItinerary;
            if (this.triggeredSobjectType == Meeting_Vendor_MERC__c.SobjectType) {
                for (Meeting_Vendor_MERC__c vendor : (List<Meeting_Vendor_MERC__c>)sobjects) {
                    if (Trigger.oldMap.get(vendor.Id).get('Room_Rate_MERC__c') != vendor.Room_Rate_MERC__c &&
                        !vendor.Meeting_Status_MERC__c.startsWith('Complete')) {
                        //room rate has changed
                        meetingIds.add(vendor.Meeting_MERC__c);
                    }
                }
                tovToItinerary = associateToVwithHotelItinerary(meetingIds);
            //check for itinerary change
            } else if (this.triggeredSobjectType == Travel_Itinerary_MERC__c.SobjectType) {
                Set<Id> mpIds = new Set<Id>();
                for (Travel_Itinerary_MERC__c ti : (List<Travel_Itinerary_MERC__c>)sobjects) {
                    if (Trigger.isInsert ||
                        (Trigger.oldMap.get(ti.Id).get('Meeting_Vendor_MERC__c') != ti.Meeting_Vendor_MERC__c ||
                            Trigger.oldMap.get(ti.Id).get('Sgmnt_Bgin_TS_MERC__c') != ti.Sgmnt_Bgin_TS_MERC__c ||
                            Trigger.oldMap.get(ti.Id).get('Sgmnt_End_TS_MERC__c') != ti.Sgmnt_End_TS_MERC__c ||
                            Trigger.oldMap.get(ti.Id).get('Status_MERC__c') != ti.Status_Merc__c) &&
                        !ti.Meeting_Status_MERC__c.startsWith('Complete')) {
                        meetingIds.add(ti.Meeting_Id_MERC__c);
                        mpIds.add(ti.Meeting_Participant_MERC__c);
                    }
                }
                tovToItinerary = associateToVwithHotelItinerary(meetingIds,mpIds);
            }

            // Determine which TOVs to process and how...
            List<Daily_Attendance_TOV_MERC__c> tovRecordsToUpdate = new List<Daily_Attendance_TOV_MERC__c>();

            Map<Id,Daily_Attendance_TOV_MERC__c> tovKeys = new Map<Id,Daily_Attendance_TOV_MERC__c>();
            for (Daily_Attendance_TOV_MERC__c tov : tovToItinerary.keySet()) {
                tovKeys.put(tov.Id,tov);
            }

            for (Id tovId : tovKeys.keySet()) {
                Daily_Attendance_TOV_MERC__c tov = tovKeys.get(tovId);
                Travel_Itinerary_MERC__c t = tovToItinerary.get(tov);

                Boolean tovIsNull = tov.Est_Hotel_ToV_MERC__c == null;

                if (t!=null) {
                    //Set the confirm reporting to true. If confirmirmation was needed on the meeting vendor
                    //or the travel itinerary we would not get here without the user having checked that box.
                    //tov.Confirm_ToV_Reporting_Change_MERC__c = true;

                    // has value already been sent to Activity ODS?
                    Boolean tovIsFinal = t.Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes';
                    Boolean noRoomRate = t.Room_Rate_excl_VAT_MERC__c==null;
                    Boolean itineraryCancelled = t.Status_MERC__c == 'Cancelled';

                    if (noRoomRate || !t.Include_ToV_MERC__c || itineraryCancelled) {
                        if (tovIsFinal) {
                            if (!tovIsNull) {
                                tov.Est_Hotel_ToV_MERC__c = 0.0;
                                tovRecordsToUpdate.add(tov);
                            }
                        } else {
                                tov.Est_Hotel_ToV_MERC__c = null;
                                tovRecordsToUpdate.add(tov);
                        }
                    } else {
                        tov.Est_Hotel_ToV_MERC__c = t.Room_Rate_excl_VAT_MERC__c;
                        tovRecordsToUpdate.add(tov);
                    }
                } else {
                    Boolean tovIsFinal = tov.Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes';
                    tov.Est_Hotel_ToV_MERC__c = (tovIsFinal && !tovIsNull) ? 0.0 : null;
                    tovRecordsToUpdate.add(tov);
                }

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

            List<Daily_Attendance_TOV_MERC__c> tovs = (List<Daily_Attendance_TOV_MERC__c>) sobjects;
            Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c> tovToItinerary = associateToVwithHotelItinerary(tovs,meetingDayIds,meetingParticipantIds);

            // Determine which TOVs to process and how...
            Map<Id,Daily_Attendance_TOV_MERC__c> tovKeys = new Map<Id,Daily_Attendance_TOV_MERC__c>();
            for (Daily_Attendance_TOV_MERC__c tov : tovToItinerary.keySet()) {
                tovKeys.put(tov.Id,tov);
            }

            for (Id tovId : tovKeys.keySet()) {
                Daily_Attendance_TOV_MERC__c tov = tovKeys.get(tovId);

                //apply itinerary to tov
                Travel_Itinerary_MERC__c t = tovToItinerary.get(tov);

                if (t!=null) {
                    Boolean tovIsFinal = t.Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes';
                    Boolean noRoomRate = t.Room_Rate_excl_VAT_MERC__c==null;
                    Boolean statusUpdate = Trigger.isUpdate && (Trigger.oldMap.get(tov.Id).get('Status_MERC__c') != tov.Status_Merc__c);
                    Boolean itineraryCancelled = t.Status_MERC__c == 'Cancelled';

                    if (itineraryCancelled) {
                        if (tovIsFinal) {
                            tov.Est_Hotel_ToV_MERC__c = 0.0;
                        } else {
                            tov.Est_Hotel_ToV_MERC__c = null;
                        }
                    } else {
                        tov.Est_Hotel_ToV_MERC__c = t.Room_Rate_excl_VAT_MERC__c;
                    }
                }
            }
        }
    }

    private void rollupTovValues(List<SObject> sobjects) {
        Set<Id> meetingParticipantIds = new Set<Id>();

        if (this.triggeredSobjectType == Meeting_Day_MERC__c.SobjectType) {
            for (Daily_Attendance_TOV_MERC__c da : [SELECT ID, Meeting_Participant_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Meeting_Day_MERC__c in :sobjects]) {
                meetingParticipantIds.add(da.Meeting_Participant_MERC__c);
            }
        } else if (this.triggeredSobjectType == Daily_Attendance_TOV_MERC__c.SobjectType) {
            for (sObject so : sobjects) {
                meetingParticipantIds.add((Id)so.get('Meeting_Participant_MERC__c'));
            }
        }

        if (!meetingParticipantIds.isEmpty()) {
            System.enqueueJob( new MERC_MeetingParticipantRollups( meetingParticipantIds ));
        }
    }



    /**********
        ASSOCIATE TOV WITH HOTELITINERARY
            Below are several methods, all named associateToVwithHotelItinerary with different signatures. The first three build up the parameters needed for
            the last call.
            The methods below will all return a map of daily attendance records to travel itinerary records

            participantSoql is a string which is used by two of the methods so it is consolidated to it's own variable.
    ***********/
    private static String participantSoql = 'SELECT ID, Name, '+
                            '(SELECT '+
                            '   ID, Sgmnt_Bgin_TS_MERC__c, Sgmnt_End_TS_MERC__c, Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c, '+
                            '   Status_MERC__c, Room_Rate_excl_VAT_MERC__c, Include_ToV_MERC__c '+
                            'FROM Travel_Itineraries_MERC__r '+
                            'WHERE RecordType.DeveloperName = \'MERC_Hotel\') '+
                       'FROM Meeting_Participant_MERC__c WHERE ';

    private static Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c> associateToVwithHotelItinerary(Set<Id> meetingIds) {
        return associateToVwithHotelItinerary(meetingIds, null);
    }

    private static Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c> associateToVwithHotelItinerary(Set<Id> meetingIds, Set<Id> meetingParticipantIds) {
        Map<Id, Meeting_Day_MERC__c> meetingDayMap = new Map<Id, Meeting_Day_MERC__c>([SELECT Id, Date_MERC__c FROM Meeting_Day_MERC__c WHERE Meeting_MERC__c IN :meetingIds]);
        String thisParticipantSoql = participantSoql;
        if (meetingParticipantIds == null) {
            thisParticipantSoql += 'Meeting_MERC__c IN :meetingIds';
        } else {
            thisParticipantSoql += 'Id IN :meetingParticipantIds';
        }

        List<Meeting_Participant_MERC__c> participantsWithItineraries = (List<Meeting_Participant_MERC__c>) Database.query(thisParticipantSoql);

        List<Daily_Attendance_TOV_MERC__c> tovs = [SELECT ID,
                                                          Status_MERC__c,
                                                          Est_Hotel_ToV_MERC__c,
                                                          Meeting_Day_MERC__c,
                                                          Meeting_Participant_MERC__c,
                                                          Confirm_ToV_Reporting_Change_MERC__c,
                                                          Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c
                                                    FROM Daily_Attendance_TOV_MERC__c
                                                   WHERE Meeting_Participant_MERC__c IN :participantsWithItineraries];
        return associateToVwithHotelItinerary(tovs, meetingDayMap, participantsWithItineraries);
    }

    private static Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c> associateToVwithHotelItinerary(List<Daily_Attendance_TOV_MERC__c> tovs, Set<Id> meetingDayIds, Set<Id> meetingParticipantIds) {
        Map<Id, Meeting_Day_MERC__c> meetingDayMap = new Map<Id, Meeting_Day_MERC__c>([SELECT ID, Date_MERC__c FROM Meeting_Day_MERC__c WHERE Id IN :meetingDayIds]);

        String thisParticipantSoql = participantSoql + 'Id IN :meetingParticipantIds';
        List<Meeting_Participant_MERC__c> participantsWithItineraries = Database.query(thisParticipantSoql);
        return associateToVwithHotelItinerary(tovs, meetingDayMap, participantsWithItineraries);
    }

    /**
     * Combining some repeated code, this method associates Daily_Attendance_TOV_MERC__c records with a related *hotel* itinerary record assuming (for now) a
     * one-to-one coorespondence.
     *
     * @param  tovs                             List of Daily_Attendance_TOV_MERC records for input.
     * @param  meetingDays                      Map of meeting days for meetings any participants are part of
     * @param  meetingParticipants              List of particiapants to process
     * @return                                  Map of Daily_Attendance_TOV_MERC records to related Travel_Itinerary_MERCs
     **/
    private static Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c> associateToVwithHotelItinerary(
        List<Daily_Attendance_TOV_MERC__c> tovs,
        Map<Id, Meeting_Day_MERC__c>       meetingDays,
        List<Meeting_Participant_MERC__c>  meetingParticipants
    ) {

        Map<Id, List<Travel_Itinerary_MERC__c>> participantIdToHotelItineraries = new Map<Id, List<Travel_Itinerary_MERC__c>>();

        for (Meeting_Participant_MERC__c mp : meetingParticipants) {
            participantIdToHotelItineraries.put(mp.Id, mp.Travel_Itineraries_MERC__r);
        }

        Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c> tovToItinerary = new Map<Daily_Attendance_TOV_MERC__c,Travel_Itinerary_MERC__c>();
        for (Daily_Attendance_TOV_MERC__c tov : tovs) {

            Boolean accountedFor = false;

            if (participantIdToHotelItineraries.containsKey(tov.Meeting_Participant_MERC__c) && meetingDays.containsKey(tov.Meeting_Day_MERC__c)) {
                Date meetingDayDate = meetingDays.get(tov.Meeting_Day_MERC__c).Date_MERC__c;
                List<Travel_Itinerary_MERC__c> hotelTravelItinerariesForParticipant = participantIdToHotelItineraries.get(tov.Meeting_Participant_MERC__c);

                for (Travel_Itinerary_MERC__c t : hotelTravelItinerariesForParticipant) {
                    Date timestampStart = t.Sgmnt_Bgin_TS_MERC__c.date();
                    Date timestampEnd = t.Sgmnt_End_TS_MERC__c.date();

                    if (meetingDayDate >= timestampStart && meetingDayDate <= timestampEnd.addDays(-1)) {
                        tovToItinerary.put(tov,t);
                        accountedFor = true;
                    }
                }
            }

            // what if date is changed and tov left orphaned? set t to null
            if (!accountedFor) {
                tovToItinerary.put(tov,null);
            }
        }
        return tovToItinerary;
    }
}