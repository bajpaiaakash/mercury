/**
 * @author Joseph Ferraro
 *
 * Stress tests (for larger meetings) daily attendance/tov controller functionality found in MERC_DailyAttendanceController
 */

@isTest
private class MERC_DailyAttendanceControllerStressTest {
	
	static List<Meeting_MERC__c> meetings;
	static List<Account> accounts;
	static List<Meeting_Day_MERC__c> meetingDays;
	static List<Meeting_Participant_MERC__c> participants;
	static List<Meeting_Vendor_MERC__c> hotels;
	static MERC_DailyAttendanceController controller;
	static List<Travel_Itinerary_MERC__c> hotelItineraries;
	static Meeting_MERC__c meeting;

	static {
		MERC_TestFactory.loadDeclarativeRollupSummaries();
		accounts = MERC_TestFactory.insertAccounts(100); //insert 100 accounts
		meetings = MERC_TestFactory.insertMeetings(1); //insert 1 meetings
		meeting = meetings.get(0);
		meetingDays = MERC_TestFactory.insertMeetingDays(meeting.Id, 3); //insert 3 days
		hotels = MERC_TestFactory.insertHotelsForMeeting(2, meeting.Id);
		participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts);
		hotelItineraries = MERC_TestFactory.insertHotelItineraries(participants, meetingDays.get(0).Date_MERC__c, meetingDays.get(2).Date_MERC__c);
	}

	static void loadPage() {
		//load page
		PageReference p = Page.MERC_DailyAttendance;
		p.getParameters().put('id', meeting.Id);
		Test.setCurrentPage(p);

		//load controller
		ApexPages.StandardSetController setController = new ApexPages.StandardSetController(new List<Daily_Attendance_TOV_MERC__c>());
		controller = new MERC_DailyAttendanceController(setController);
		controller.upsertMissingTovRecords();

		controller = new MERC_DailyAttendanceController(setController); //not sure why we need to do this, if we don't we get 0 participants in our controller
	}

	static void selectDay(Integer dayNumber) {
		controller.selectedMeetingDayId = controller.meetingDays.get(dayNumber-1).Id;
	}

	static void selectParticipants(Integer numberOfParticipants) {
		for (Integer i = 0; i < numberOfParticipants; i++) {
			controller.participants.get(i).selected = True;
		}
	}

	@isTest static void run_stress_test() {
		loadPage();

		Test.startTest();

		selectDay(1);

		System.assertEquals(meeting.Id, controller.meeting.Id);
		System.assertEquals(meetingDays.size(), controller.getMeetingDayOptions().size());
		System.assertEquals(participants.size(), controller.participants.size());

		selectParticipants(33);
		controller.setSelectedToAttended();
		System.assertEquals(33, [SELECT count() FROM Daily_Attendance_TOV_MERC__c WHERE Status_MERC__c = 'Attended']);

		selectParticipants(4);
		controller.setSelectedToNoShow();
		System.assertEquals(4, [SELECT count() FROM Daily_Attendance_TOV_MERC__c WHERE Status_MERC__c = 'No Show']);

		Test.stopTest();

		System.assertEquals(44, [SELECT Total_Hotel_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id].Total_Hotel_Tov_MERC__c);

	}
	
}