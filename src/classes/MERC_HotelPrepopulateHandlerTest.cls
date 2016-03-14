@isTest
private class MERC_HotelPrepopulateHandlerTest {

    static List<Meeting_MERC__c> meetings = MERC_TestFactory.insertMeetings(1);
    static List<Account> accounts = MERC_TestFactory.insertAccounts(200);
    static List<Meeting_Participant_MERC__c> participants;

	@isTest
	static void test_if_new_participant_does_not_create_itinerary() {
        Test.startTest();
        participants = MERC_TestFactory.insertParticipants(meetings[0].Id, accounts);
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM Travel_Itinerary_MERC__c WHERE Meeting_Participant_MERC__c in :participants].size());
	}

	@isTest
	static void test_if_new_participant_creates_itineraries_withOUT_vendor() {

		Test.startTest();
        whenMeetingParticipantsAreCreated();
        Test.stopTest();

        System.assertEquals(200, [SELECT Id FROM Travel_Itinerary_MERC__c WHERE Meeting_Participant_MERC__c IN :participants].size());
	}

    @isTest
    static void test_if_new_participant_creates_itineraries_with_vendor_when_only_one_vendor() {
        MERC_TestFactory.insertHotelsForMeetings(1, meetings);
        Test.startTest();
        whenMeetingParticipantsAreCreated();
        Test.stopTest();

        System.assertEquals(200, [SELECT Id FROM Travel_Itinerary_MERC__c WHERE Meeting_Participant_MERC__c IN :participants].size());
    }

    @isTest
    static void test_if_new_participant_creates_itineraries_withOUT_vendor_when_multiple_vendors() {
        MERC_TestFactory.insertHotelsForMeetings(2, meetings);
        Test.startTest();
        whenMeetingParticipantsAreCreated();
        Test.stopTest();

        System.assertEquals(200, [SELECT Id FROM Travel_Itinerary_MERC__c WHERE Meeting_Participant_MERC__c IN :participants].size());
    }

    private static void whenMeetingParticipantsAreCreated() {
        participants = new List<Meeting_Participant_MERC__c>();
        Meeting_MERC__c meeting = meetings[0];
        for(Account account : accounts) {
            Meeting_Participant_MERC__c participant = new Meeting_Participant_MERC__c(
                Account_MERC__c = account.Id,
                Meeting_MERC__c = meeting.Id,
                Status_MERC__c = 'Invited',
                Services_Rendered_MERC__c = 'Yes',
                Alliance_MERC__c = 'Not Applicable',
                Date_of_Check_In_MERC__c = date.newinstance(meeting.Start_Time_of_Meeting_MERC__c.year(),meeting.Start_Time_of_Meeting_MERC__c.month(),meeting.Start_Time_of_Meeting_MERC__c.day()),
                Date_of_Check_Out_MERC__c = date.newinstance(meeting.End_Time_of_Meeting_MERC__c.year(),meeting.End_Time_of_Meeting_MERC__c.month(),meeting.End_Time_of_Meeting_MERC__c.day()),
                Hotel_Required_MERC__c = 'Yes');
            participants.add(participant);
        }

        insert participants;
    }
}