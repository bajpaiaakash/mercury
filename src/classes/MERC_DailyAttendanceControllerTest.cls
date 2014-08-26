/**
 * @author Joseph Ferraro
 *
 * Asserts functionality for daily attendance/tov controller functionality found in MERC_DailyAttendanceController
 */

@isTest
private class MERC_DailyAttendanceControllerTest {

	static List<Meeting_MERC__c> meetings;
	static List<Account> accounts;
	static List<Meeting_Day_MERC__c> meetingDays;
	static List<Meeting_Participant_MERC__c> participants;
	static User runningUser = MERC_TestFactory.getRunningUser();
	static User testUser = MERC_TestFactory.getTestingUser();

	static {
		System.runAs(runningUser) {
			accounts = MERC_TestFactory.insertAccounts(5); //insert 5 accounts
			meetings = MERC_TestFactory.insertMeetings(2); //insert 2 meetings
			meetingDays = MERC_TestFactory.insertMeetingDays(meetings.get(0).Id, 3); //insert 3 days
			participants = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts, 'Accepted'); //insert 5 participants
		}
	}

	@isTest static void basic_daily_attendance_test() {
		System.runAs(testUser) {
			Meeting_MERC__c mtg = meetings.get(0);

			PageReference p = Page.MERC_DailyAttendance;
			p.getParameters().put('id', mtg.Id);
			Test.setCurrentPage(p);

			Test.startTest();

			ApexPages.StandardSetController setController = new ApexPages.StandardSetController(new List<Daily_Attendance_TOV_MERC__c>());
			MERC_DailyAttendanceController c = new MERC_DailyAttendanceController(setController);
			c.upsertMissingTovRecords();
			c = new MERC_DailyAttendanceController(setController);

			c.selectedMeetingDayId = c.meetingDays.get(0).Id;

			System.assertEquals(mtg.Id, c.meeting.Id);
			System.assertEquals(meetingDays.size(), c.getMeetingDayOptions().size());
			System.assertEquals(participants.size(), c.participants.size());

			c.participants.get(0).selected = True;
			c.setSelectedToAttended();
			System.assertEquals('Attended', [SELECT Status_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :c.participants.get(0).tov.Id].Status_MERC__c);

			c.participants.get(1).selected = True;
			c.setSelectedToNoShow();
			System.assertEquals('No Show', [SELECT Status_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :c.participants.get(1).tov.Id].Status_MERC__c);

			Test.stopTest();
		}
	}

	@isTest static void all_attended_test() {
		System.runAs(testUser) {
			Meeting_MERC__c mtg = meetings.get(0);

			PageReference p = Page.MERC_DailyAttendance;
			p.getParameters().put('id', mtg.Id);
			Test.setCurrentPage(p);

			Test.startTest();

			ApexPages.StandardSetController setController = new ApexPages.StandardSetController(new List<Daily_Attendance_TOV_MERC__c>());
			MERC_DailyAttendanceController c = new MERC_DailyAttendanceController(setController);
			c.upsertMissingTovRecords();
			c = new MERC_DailyAttendanceController(setController);

			c.selectedMeetingDayId = c.meetingDays.get(0).Id;

			System.assertEquals(mtg.Id, c.meeting.Id);
			System.assertEquals(meetingDays.size(), c.getMeetingDayOptions().size());
			System.assertEquals(participants.size(), c.participants.size());

			c.participants.get(0).selected = True;
			c.setSelectedToAttended();
			System.assertEquals('Attended', [SELECT Status_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :c.participants.get(0).tov.Id].Status_MERC__c);

			c.selectedMeetingDayId = c.meetingDays.get(1).Id;
			c.participants.get(0).selected = True;
			c.setSelectedToAttended();
			System.assertEquals('Attended', [SELECT Status_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :c.participants.get(0).tov.Id].Status_MERC__c);

			c.selectedMeetingDayId = c.meetingDays.get(2).Id;
			c.participants.get(0).selected = True;
			c.setSelectedToAttended();
			System.assertEquals('Attended', [SELECT Status_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :c.participants.get(0).tov.Id].Status_MERC__c);

			System.assertEquals('Attended', [SELECT Status_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :c.participants.get(0).tov.Meeting_Participant_MERC__c].Status_MERC__c);
			Test.stopTest();
		}
	}

	@isTest static void some_attended_test() {
		System.runAs(testUser) {
			Meeting_MERC__c mtg = meetings.get(0);

			PageReference p = Page.MERC_DailyAttendance;
			p.getParameters().put('id', mtg.Id);
			Test.setCurrentPage(p);

			Test.startTest();

			ApexPages.StandardSetController setController = new ApexPages.StandardSetController(new List<Daily_Attendance_TOV_MERC__c>());
			MERC_DailyAttendanceController c = new MERC_DailyAttendanceController(setController);
			c.upsertMissingTovRecords();
			c = new MERC_DailyAttendanceController(setController);

			c.selectedMeetingDayId = c.meetingDays.get(0).Id;

			System.assertEquals(mtg.Id, c.meeting.Id);
			System.assertEquals(meetingDays.size(), c.getMeetingDayOptions().size());
			System.assertEquals(participants.size(), c.participants.size());

			c.participants.get(0).selected = True;
			c.setSelectedToAttended();
			System.assertEquals('Attended', [SELECT Status_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :c.participants.get(0).tov.Id].Status_MERC__c);

			c.selectedMeetingDayId = c.meetingDays.get(1).Id;
			c.participants.get(0).selected = True;
			c.setSelectedToAttended();
			System.assertEquals('Attended', [SELECT Status_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :c.participants.get(0).tov.Id].Status_MERC__c);

			c.selectedMeetingDayId = c.meetingDays.get(2).Id;
			c.participants.get(0).selected = True;
			c.setSelectedToNoShow();
			System.assertEquals('No Show', [SELECT Status_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :c.participants.get(0).tov.Id].Status_MERC__c);

			System.assertEquals('Attended', [SELECT Status_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :c.participants.get(0).tov.Meeting_Participant_MERC__c].Status_MERC__c);
			Test.stopTest();
		}
	}

	@isTest static void no_show_test() {
		Meeting_MERC__c mtg = meetings.get(0);

		PageReference p = Page.MERC_DailyAttendance;
		p.getParameters().put('id', mtg.Id);
		Test.setCurrentPage(p);

		Test.startTest();

		ApexPages.StandardSetController setController = new ApexPages.StandardSetController(new List<Daily_Attendance_TOV_MERC__c>());
		MERC_DailyAttendanceController c = new MERC_DailyAttendanceController(setController);
		c.upsertMissingTovRecords();
		c = new MERC_DailyAttendanceController(setController);

		c.selectedMeetingDayId = c.meetingDays.get(0).Id;

		System.assertEquals(mtg.Id, c.meeting.Id);
		System.assertEquals(meetingDays.size(), c.getMeetingDayOptions().size());
		System.assertEquals(participants.size(), c.participants.size());

		c.participants.get(0).selected = True;
		c.setSelectedToNoShow();
		System.assertEquals('No Show', [SELECT Status_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :c.participants.get(0).tov.Id].Status_MERC__c);

		c.selectedMeetingDayId = c.meetingDays.get(1).Id;
		c.participants.get(0).selected = True;
		c.setSelectedToNoShow();
		System.assertEquals('No Show', [SELECT Status_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :c.participants.get(0).tov.Id].Status_MERC__c);

		c.selectedMeetingDayId = c.meetingDays.get(2).Id;
		c.participants.get(0).selected = True;
		c.setSelectedToNoShow();
		System.assertEquals('No Show', [SELECT Status_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :c.participants.get(0).tov.Id].Status_MERC__c);

		System.assertEquals('No Show', [SELECT Status_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :c.participants.get(0).tov.Meeting_Participant_MERC__c].Status_MERC__c);
		Test.stopTest();
	}

	@isTest	static void acceptedMeetingParticpantsShouldNotShow() {
		participants.get(0).Status_MERC__c = 'Approved';
		participants.get(1).Status_MERC__c = 'Approved';
		update participants;
		System.runAs(testUser) {
			Meeting_MERC__c mtg = meetings.get(0);

			PageReference p = Page.MERC_DailyAttendance;
			p.getParameters().put('id', mtg.Id);
			Test.setCurrentPage(p);

			Test.startTest();

			ApexPages.StandardSetController setController = new ApexPages.StandardSetController(new List<Daily_Attendance_TOV_MERC__c>());
			MERC_DailyAttendanceController c = new MERC_DailyAttendanceController(setController);
			c.upsertMissingTovRecords();
			c = new MERC_DailyAttendanceController(setController);

			c.selectedMeetingDayId = c.meetingDays.get(0).Id;

			System.assertEquals(participants.size()-2, c.participants.size());
		}
	}
}