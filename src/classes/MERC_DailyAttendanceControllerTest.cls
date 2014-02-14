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

	static {
		accounts = MERC_TestFactory.insertAccounts(5); //insert 5 accounts
		meetings = MERC_TestFactory.insertMeetings(2); //insert 2 meetings
		meetingDays = MERC_TestFactory.insertMeetingDays(meetings.get(0).Id, 3); //insert 3 days
		participants = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts); //insert 5 participants
	}

	@isTest static void basic_daily_attendance_test() {
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

		// c.participants.get(0).tov.Status_MERC__c = 'No Show';
		// ApexPages.currentPage().getParameters().put('tovRecordId', c.participants.get(0).tov.Id);
		// c.updateTov();
		// System.assertEquals('No Show', [SELECT Status_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :c.participants.get(0).tov.Id].Status_MERC__c);

		Test.stopTest();
	}
	
}