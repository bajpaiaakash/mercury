/**
 * @author Joseph Ferraro
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
	static User testUser = MERC_TestFactory.getTestingUser();
	static User runningUser = MERC_TestFactory.getRunningUser();

	static {

		MERC_TriggerHandlerStateManager.deactivateAll();

		System.runAs(testUser) {
			accounts = MERC_TestFactory.insertAccounts(100); //insert 100 accounts
			meetings = MERC_TestFactory.insertMeetings(1); //insert 1 meetings
			meeting = meetings.get(0);
			meetingDays = MERC_TestFactory.insertMeetingDays(meeting.Id, 3); //insert 3 days
			hotels = MERC_TestFactory.insertHotelsForMeeting(2, meeting.Id);
			participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts,'Accepted');
			hotelItineraries = MERC_TestFactory.insertHotelItineraries(participants, meetingDays.get(0).Date_MERC__c, meetingDays.get(2).Date_MERC__c);
		}
	}

	static void selectDay(Integer dayNumber) {
		controller.selectedMeetingDayId = controller.meetingDays.get(dayNumber-1).Id;
	}

	static void selectParticipants(Integer numberOfParticipants) {
		for (Integer i = 0; i < numberOfParticipants; i++) {
			controller.participants.get(i).selected = True;
		}
	}

	@isTest
	static void run_stress_test() {

		PageReference p = Page.MERC_DailyAttendance;
		p.getParameters().put('id', meeting.Id);
		Test.setCurrentPage(p);
		MERC_TriggerHandlerStateManager.activateAll();
		Test.startTest();

		//load controller
		ApexPages.StandardSetController setController = new ApexPages.StandardSetController(new List<Daily_Attendance_TOV_MERC__c>());
		controller = new MERC_DailyAttendanceController(setController);
		controller.upsertMissingTovRecords();

		controller = new MERC_DailyAttendanceController(setController); //not sure why we need to do this, if we don't we get 0 participants in our controller

		System.runAs(testUser) {
			selectDay(1);

			System.assertEquals(meeting.Id, controller.meeting.Id,'meeting id doesn\'t match the controller record id');
			System.assertEquals(meetingDays.size(), controller.getMeetingDayOptions().size(),'unexpected meetingDays size.');
			System.assertEquals(participants.size(), controller.participants.size(),'unexpected participants size.');

			selectParticipants(33);
			controller.setSelectedToAttended();
			System.assertEquals(33, [SELECT count() FROM Daily_Attendance_TOV_MERC__c WHERE Status_MERC__c = 'Attended' AND Meeting_Participant_MERC__c in :participants]);

			selectParticipants(4);
			controller.setSelectedToNoShow();
			System.assertEquals(4, [SELECT count() FROM Daily_Attendance_TOV_MERC__c WHERE Status_MERC__c = 'No Show' AND Meeting_Participant_MERC__c in :participants]);

		}

		Test.stopTest();
	}
}