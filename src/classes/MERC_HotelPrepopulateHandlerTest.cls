@isTest
private class MERC_HotelPrepopulateHandlerTest {
	
    static Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1)[0];
    static Account account = MERC_TestFactory.insertAccounts(1)[0];

	@isTest
	static void test_if_new_participant_does_not_create_itinerary() {
		Test.startTest();
	        List<Meeting_Participant_MERC__c> participants = MERC_TestFactory.insertParticipants(meeting.Id, new List<Account>{account});
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM Travel_Itinerary_MERC__c WHERE Meeting_Participant_MERC__c in :participants].size());
	}

	@isTest
	static void test_if_new_participant_creates_itineraries() {

		Test.startTest();
            Meeting_Participant_MERC__c participant = new Meeting_Participant_MERC__c();
            participant.Account_MERC__c = account.Id;
            participant.Meeting_MERC__c = meeting.Id;
            participant.Status_MERC__c = 'Invited';
            participant.Services_Rendered_MERC__c = 'Yes';
            participant.Alliance_MERC__c = 'Not Applicable';
        	participant.Date_of_Check_In_MERC__c = date.newinstance(meeting.Start_Time_of_Meeting_MERC__c.year(),meeting.Start_Time_of_Meeting_MERC__c.month(),meeting.Start_Time_of_Meeting_MERC__c.day());
            participant.Date_of_Check_Out_MERC__c = date.newinstance(meeting.End_Time_of_Meeting_MERC__c.year(),meeting.End_Time_of_Meeting_MERC__c.month(),meeting.End_Time_of_Meeting_MERC__c.day());
            participant.Hotel_Required_MERC__c = 'Yes';
            insert participant;
        Test.stopTest();

        Id participantId = participant.Id;

        System.assertEquals(1, [SELECT Id FROM Travel_Itinerary_MERC__c WHERE Meeting_Participant_MERC__c = :participantId].size());
	}
}