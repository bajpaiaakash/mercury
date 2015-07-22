@isTest
private class MERC_MeetingProcessLogicHandlerTest {

	//Build data for MERC_MeetingProcessLogicHandler
	@isTest static void test_method_one() {

		//create data necessary for MeetingTaskEditor page.
		Meeting_MERC__c meeting = Merc_TestFactory.insertMeetings(1)[0];
		Account acc = Merc_TestFactory.insertAccounts(1)[0];
		Meeting_Participant_MERC__c participant = Merc_TestFactory.insertParticipants(meeting.Id, new List<Account>{acc})[0];

		Travel_Itinerary_MERC__c itinerary = Merc_TestFactory.insertHotelItineraries(
			new List<Meeting_Participant_MERC__c>{participant}, 
			Date.today().addDays(1), 
			Date.today().addDays(2))[0];

		Meeting_Process_MERC__c process = new Meeting_Process_MERC__c(
			Meeting_Participant_MERC__c = participant.Id,
			Process_Type_MERC__c = 'Registration'
			);

		insert process;

		Meeting_Tasks_MERC__c task = new Meeting_Tasks_MERC__c(
			Meeting_Process_MERC__c = process.Id,
			Task_Status_MERC__c = 'Completed - Process Complete'
			);

		insert task;
	}
	
}