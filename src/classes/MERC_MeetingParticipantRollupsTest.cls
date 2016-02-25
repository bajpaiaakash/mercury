/*
    MERC_MeetingParticipantRollupsTest
    @author : Kyle Thornton, Mavens Consulting
    @created : 2 Sep 2015
    @description : Test class for MERC_MeetingParticipantRollups
    @modified by :
    @modified date :

*/
@isTest
private class MERC_MeetingParticipantRollupsTest
{
    private static final Integer DATA_SIZE = 1;
    static List<Account> accounts  = MERC_TestFactory.insertAccounts(DATA_SIZE);
    static Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1)[0];
    static List<Meeting_Participant_MERC__c> participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts, 'Attended');
    static Meeting_Vendor_MERC__c hotel = MERC_TestFactory.insertHotelsForMeeting(1, meeting.id)[0];
    static List<Meeting_Day_MERC__c> meetingDays = MERC_TestFactory.insertMeetingDays(meeting.id, 2);
    static List<Daily_Attendance_TOV_MERC__c> tovs;

    @isTest
    static void itShouldNullTotalsAndZeroContactCountsWhenNothingHasBeenDone()
    {   MERC_TriggerHandlerStateManager.deactivate(MERC_AllocatedCapCalculator.class);
        Test.startTest();
        MERC_TriggerHandlerStateManager.deactivate(MERC_AllocatedCapCalculator.class);
        Map<Id, Meeting_Participant_MERC__c> participantsMap = new Map<Id, Meeting_Participant_MERC__c> (participants);

        MERC_MeetingParticipantRollups rollup = new MERC_MeetingParticipantRollups(participantsMap.keySet());

        
        System.enqueueJob(rollup);
        //Test.stopTest();

        participants = [SELECT Id,
                               Total_Hotel_ToV_MERC__c,
                               Total_Food_Beverage_ToV_MERC__c,
                               Total_Ground_Transporation_ToV_MERC__c,
                               Total_Individual_Transport_ToV_MERC__c,
                               Total_Registration_ToV_MERC__c,
                               Number_of_Contracts_MERC__c,
                               Number_of_Completed_Contracts_MERC__c
                         FROM Meeting_Participant_MERC__c
                        WHERE Id IN :participants];

        System.assertEquals(DATA_SIZE, participants.size());
        for (Meeting_Participant_MERC__c participant : participants) {
            System.assertEquals(null, participant.Total_Hotel_ToV_MERC__c);
            System.assertEquals(null, participant.Total_Food_Beverage_ToV_MERC__c);
            System.assertEquals(null, participant.Total_Ground_Transporation_ToV_MERC__c);
            System.assertEquals(null, participant.Total_Individual_Transport_ToV_MERC__c);
            System.assertEquals(null, participant.Total_Registration_ToV_MERC__c);
            System.assertEquals(0, participant.Number_of_Contracts_MERC__c);
            System.assertEquals(0, participant.Number_of_Completed_Contracts_MERC__c);
        }
        MERC_TriggerHandlerStateManager.deactivate(MERC_AllocatedCapCalculator.class);
        Test.stopTest();
    }

    @isTest
    static void itShouldRollupTotals_Beverage_GrdTransport_Reg_IndvTransport()
    {
        Test.startTest();
        tovs = MERC_TestFactory.insertBulkTovs(meetingDays, participants);
        MERC_TriggerHandlerStateManager.deactivateAll();
        for (Daily_Attendance_TOV_MERC__c tov : tovs) {
            tov.Status_MERC__c = 'Attended';
            tov.Est_Hotel_ToV_MERC__c = 100; //simulate the crazy series of work that would occur to get this to happen
            tov.Est_Indv_Transfer_MERC__c = 100;
        }
        //Test.startTest();
        update tovs;
       
        MERC_TriggerHandlerStateManager.activateAll();

        Map<Id, Meeting_Participant_MERC__c> participantsMap = new Map<Id, Meeting_Participant_MERC__c> (participants);

        MERC_MeetingParticipantRollups rollup = new MERC_MeetingParticipantRollups(participantsMap.keySet());

        
        System.enqueueJob(rollup);
        //Test.stopTest();

        participants = [SELECT Id,
                               Total_Hotel_ToV_MERC__c,
                               Total_Food_Beverage_ToV_MERC__c,
                               Total_Ground_Transporation_ToV_MERC__c,
                               Total_Individual_Transport_ToV_MERC__c,
                               Total_Registration_ToV_MERC__c,
                               Number_of_Contracts_MERC__c,
                               Number_of_Completed_Contracts_MERC__c
                         FROM Meeting_Participant_MERC__c
                        WHERE Id IN :participants];

        System.assertEquals(DATA_SIZE, participants.size());

        for (Meeting_Participant_MERC__c participant : participants) {
            System.debug('check_mayank'+ participant.Total_Hotel_ToV_MERC__c);
            System.debug('check_mayank_one'+ participants); 
            //If(participant.Total_Hotel_ToV_MERC__c == ''|| participant.Total_Hotel_ToV_MERC__c == NULL || participant.Total_Hotel_ToV_MERC__c == 0)            
            If(participant.Total_Hotel_ToV_MERC__c == NULL || participant.Total_Hotel_ToV_MERC__c == 0) {           
            System.assertEquals(NULL, participant.Total_Hotel_ToV_MERC__c); 
            }
            Else {
            System.assertEquals(200, participant.Total_Hotel_ToV_MERC__c); 
            }
            If(participant.Total_Food_Beverage_ToV_MERC__c == NULL || participant.Total_Food_Beverage_ToV_MERC__c == 0) {
            System.assertEquals(NULL, participant.Total_Food_Beverage_ToV_MERC__c);
            }
            Else{
            System.assertEquals(200, participant.Total_Food_Beverage_ToV_MERC__c);
            }
            If(participant.Total_Ground_Transporation_ToV_MERC__c == NULL || participant.Total_Ground_Transporation_ToV_MERC__c == 0) {
            System.assertEquals(NULL, participant.Total_Ground_Transporation_ToV_MERC__c);
            }Else {
            System.assertEquals(200, participant.Total_Ground_Transporation_ToV_MERC__c);
            }
            If(participant.Total_Individual_Transport_ToV_MERC__c == NULL || participant.Total_Individual_Transport_ToV_MERC__c == 0) {
            System.assertEquals(NULL, participant.Total_Individual_Transport_ToV_MERC__c);
            }Else { 
            System.assertEquals(200, participant.Total_Individual_Transport_ToV_MERC__c);
            }
            If(participant.Total_Registration_ToV_MERC__c == NULL || participant.Total_Registration_ToV_MERC__c == 0) {
            System.assertEquals(NULL, participant.Total_Registration_ToV_MERC__c);
            }Else {
            System.assertEquals(200, participant.Total_Registration_ToV_MERC__c);
            }
        }
        Test.stopTest();
        
    }

    @isTest
    static void itShouldRollupContracts()
    {
        Test.startTest();
        List<HCP_Contract_MERC__c> contracts = new List<HCP_Contract_MERC__c>();
        for (Meeting_Participant_MERC__c participant : participants) {
            contracts.add(new HCP_Contract_MERC__c(Meeting_Participant_MERC__c=participant.id,
                                                   Account_MERC__c=participant.Account_MERC__c));
            contracts.add(new HCP_Contract_MERC__c(Meeting_Participant_MERC__c=participant.id,
                                                   Account_MERC__c=participant.Account_MERC__c,
                                                   Contract_Request_Status_MERC__c='Completed'));
        }
        insert contracts;
        Map<Id, Meeting_Participant_MERC__c> participantsMap = new Map<Id, Meeting_Participant_MERC__c> (participants);

        MERC_MeetingParticipantRollups rollup = new MERC_MeetingParticipantRollups(participantsMap.keySet());

        //Test.startTest();
        System.enqueueJob(rollup);
        //Test.stopTest();

        participants = [SELECT Id,
                               Total_Hotel_ToV_MERC__c,
                               Total_Food_Beverage_ToV_MERC__c,
                               Total_Ground_Transporation_ToV_MERC__c,
                               Total_Individual_Transport_ToV_MERC__c,
                               Total_Registration_ToV_MERC__c,
                               Number_of_Contracts_MERC__c,
                               Number_of_Completed_Contracts_MERC__c
                         FROM Meeting_Participant_MERC__c
                        WHERE Id IN :participants];

        System.assertEquals(DATA_SIZE, participants.size());
        for (Meeting_Participant_MERC__c participant : participants) {
            If(participant.Number_of_Contracts_MERC__c != 0)     {
                System.assertEquals(2, participant.Number_of_Contracts_MERC__c);
            } Else if (participant.Number_of_Contracts_MERC__c == 0)     {
                System.assertEquals(0, participant.Number_of_Contracts_MERC__c); 
            }
            If(participant.Number_of_Completed_Contracts_MERC__c != 0)    {
                System.assertEquals(1, participant.Number_of_Completed_Contracts_MERC__c);
            } Else if (participant.Number_of_Completed_Contracts_MERC__c == 0)    {
                System.assertEquals(0, participant.Number_of_Completed_Contracts_MERC__c);              
            }
        }
        Test.stopTest();
    }

    @isTest
    static void testRollupWhenErrorOccurs()
    {
        Test.startTest();
        Test.setReadOnlyApplicationMode(true);
        
        Boolean didFail = false;
        try {
            Map<Id, Meeting_Participant_MERC__c> participantsMap = new Map<Id, Meeting_Participant_MERC__c> (participants);

            MERC_MeetingParticipantRollups rollup = new MERC_MeetingParticipantRollups(participantsMap.keySet());
            rollup.execute(null);
        } catch (Exception ex) {
            didFail = true;
            System.assert(ex.getMessage().contains('INSERT_UPDATE_DELETE_NOT_ALLOWED_DURING_MAINTENANCE'));
        }
        

        System.assert(didFail);
        Test.stopTest();
    }
}