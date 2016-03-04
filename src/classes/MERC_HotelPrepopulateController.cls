public with sharing class MERC_HotelPrepopulateController {

    private ApexPages.StandardController standardController;
 
    public MERC_HotelPrepopulateController(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
    }

    // Let's get it prepopping up in here.
    public PageReference prepopulation() {
        
        Id hotelRecordTypeId = [Select ID From RecordType Where SObjectType = 'Travel_Itinerary_MERC__c' and DeveloperName = 'MERC_Hotel'].ID;

        // Apex code for handling record from a Detail page goes here
        Id participantId = standardController.getId();
        Meeting_Participant_MERC__c participant = 
        [SELECT Account_MERC__c
              , Date_of_Check_In_MERC__c
              , Date_of_Check_Out_MERC__c
              , CurrencyIsoCode
           FROM Meeting_Participant_MERC__c
          WHERE Id = :participantId];

        Travel_Itinerary_MERC__c itinerary = new Travel_Itinerary_MERC__c();

        itinerary.Meeting_Participant_MERC__c = participant.Id;
        itinerary.Account_MERC__c = participant.Account_MERC__c;
        itinerary.RecordTypeId = hotelRecordTypeId;
        itinerary.Travel_Detail_Typ_MERC__c = 'Accomidation';
        itinerary.Booking_Date_MERC__c = Date.today();
        itinerary.Sgmnt_Bgin_TS_MERC__c = participant.Date_of_Check_In_MERC__c;
        itinerary.Sgmnt_End_TS_MERC__c = participant.Date_of_Check_Out_MERC__c;
        itinerary.CurrencyIsoCode = participant.CurrencyIsoCode;
        itinerary.Status_MERC__c = 'Draft';

        // TODO: query vendors.

        insert itinerary;

        return null;
    }


}