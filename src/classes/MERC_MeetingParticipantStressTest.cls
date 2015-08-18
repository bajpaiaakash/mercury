@isTest
private class MERC_MeetingParticipantStressTest {

	static List<Meeting_MERC__c> meetings;
	static List<Account> accounts;
	static List<Meeting_Day_MERC__c> meetingDays;
	static List<Meeting_Participant_MERC__c> participants;
	static List<Meeting_Vendor_MERC__c> hotels;
	static MERC_DailyAttendanceController controller;
	static List<Travel_Itinerary_MERC__c> hotelItineraries;
	static Meeting_MERC__c meeting;

	static {
		//accounts = MERC_TestFactory.insertAccounts(100); //insert 100 accounts
		accounts = [SELECT ID, FirstName, LastName, RecordTypeId, PersonEmail FROM Account WHERE RecordTypeId = :MERC_TestFactory.hcpRecordTypeId limit 100];
		meetings = MERC_TestFactory.insertMeetings(1); //insert 1 meetings
		meeting = meetings.get(0);
		meetingDays = MERC_TestFactory.insertMeetingDays(meeting.Id, 3); //insert 3 days
		hotels = MERC_TestFactory.insertHotelsForMeeting(2, meeting.Id);
		participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts);
		hotelItineraries = MERC_TestFactory.insertHotelItineraries(participants, meetingDays.get(0).Date_MERC__c, meetingDays.get(2).Date_MERC__c);
	}

	@isTest static void run_stress_test() {
		MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts);
	}

}