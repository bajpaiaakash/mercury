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


	@isTest
	static void confirmTOVReportingChangeShouldBeSetToFalse() {
		Meeting_Participant_MERC__c participant = participants[0];
		Test.startTest();
		System.runAs(runningUser) {
			//participant.Status_MERC__c = 'Approved';
			//update participant;

			RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Travel_Itinerary_MERC__c' AND isActive = true LIMIT 1];

			Travel_Itinerary_MERC__c itinerary = new Travel_Itinerary_MERC__c();
			itinerary.Account_MERC__c = participant.Account_MERC__c;
			itinerary.Meeting_Participant_MERC__c = participant.Id;
			itinerary.Status_MERC__c = 'Confirmed';
			itinerary.RecordTypeId = rt.Id;
			itinerary.Sgmnt_Bgin_TS_MERC__c = Datetime.now().addDays(2);
			itinerary.Sgmnt_End_TS_MERC__c = Datetime.now().addDays(2).addHours(2);
			itinerary.Individual_Travel_ToV_Applicable_MERC__c = true;
			itinerary.Total_Fare_Amount_MERC__c = 10.00;
			insert itinerary;
		}

		System.runAs(testUser) {
			Meeting_MERC__c mtg = meetings.get(0);

			PageReference p = Page.MERC_DailyAttendance;
			p.getParameters().put('id', mtg.Id);
			Test.setCurrentPage(p);

			ApexPages.StandardSetController setController = new ApexPages.StandardSetController(new List<Daily_Attendance_TOV_MERC__c>());
			MERC_DailyAttendanceController c = new MERC_DailyAttendanceController(setController);
			// System.assertNotEquals(true, c.hasError, 'Error in controller(1): '+ApexPages.getMessages());

			// System.assertEquals(true,MERC_TOVCalculator.runIndividualTransferTovCalculation,'transfer tov not set to run');
			// System.assertEquals(true,MERC_TOVCalculator.runHotelTovCalculation,'hotel tov not set to run');
			MERC_TOVCalculator.runIndividualTransferTovCalculation = true;
			MERC_TOVCalculator.runHotelTovCalculation = true;

			p = c.upsertMissingTovRecords();
			System.assertNotEquals(null, p, 'Unexpected null value for returned page reference.');
			c = new MERC_DailyAttendanceController(setController);
			System.assertNotEquals(true, c.hasError, 'Error in controller(2): '+ApexPages.getMessages());
			// c.upsertMissingTovRecords();
			// c = new MERC_DailyAttendanceController(setController);

			System.assertEquals(c.participants.size(),5,'no participants??');
			for(MERC_DailyAttendanceController.ParticipantWrapper part : c.participants) {
				if(part.tov.Meeting_Participant_MERC__c == participant.Id) {
					System.assertEquals(part.tov.Confirm_ToV_Reporting_Change_MERC__c, false);
					part.selected = true;
				}
			}
			c.setSelectedToAttended();
			System.assertNotEquals(true, c.hasError, 'Error in controller(3): '+ApexPages.getMessages());
			c.refreshParticipants = true;

			for(MERC_DailyAttendanceController.ParticipantWrapper part : c.participants) {
				if(part.tov.Meeting_Participant_MERC__c == participant.Id) {
					System.assertEquals(part.tov.Confirm_ToV_Reporting_Change_MERC__c, false);
					System.assertEquals('Attended', part.tov.Status_MERC__c, 'Unexpected value for status: '+ part.tov.Status_MERC__c +'; '+part);
				}
			}
		}


	}
}