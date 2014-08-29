@isTest
private class MERC_ParticipantTovStampHandlerTest {

	static User runningUser = MERC_TestFactory.getRunningUser();
	static User testUser = MERC_TestFactory.getTestingUser();
	static Meeting_MERC__c meeting                        = new Meeting_MERC__c();
	static List<Account> accounts                         = new List<Account>();
	static List<Meeting_Participant_MERC__c> participants = new List<Meeting_Participant_MERC__c>();
	static List<Travel_Itinerary_MERC__c> itineraries     = new List<Travel_Itinerary_MERC__c>();
	static List<Daily_Attendance_TOV_MERC__c> tovs        = new List<Daily_Attendance_TOV_MERC__c>();

	static {
		System.runAs(runningUser) {
			MERC_TriggerHandlerStateManager.deactivateAll();
			meeting			= MERC_TestFactory.insertMeetings(1).get(0);
			accounts		= MERC_TestFactory.insertAccounts(200);
			participants 	= MERC_TestFactory.insertParticipants(meeting.Id, accounts);
			MERC_TriggerHandlerStateManager.activateAll();
		}
	}

	@isTest
	static void test_travel_itinerary_update_stamps_meeting() {
		insertItineraries();
		System.runAs(testUser)
		{
			meeting = [SELECT Id, Participant_ToV_Updated_Date_MERC__c, Participant_Tov_Final_MERC__c
			                , End_Time_of_Meeting_MERC__c, Confirm_Meeting_Date_Change_MERC__c
			                , Start_Time_of_Meeting_MERC__c FROM Meeting_MERC__c WHERE Id = :meeting.Id limit 1];

			meeting.Participant_Tov_Final_MERC__c = 'Yes';
			meeting.End_Time_of_Meeting_MERC__c = Date.today();
			meeting.Confirm_Meeting_Date_Change_MERC__c = true;
			meeting.Start_Time_of_Meeting_MERC__c = Date.today().addDays(-1);
			update meeting;

			Test.startTest();
			DateTime initialTime = [SELECT Id, Participant_ToV_Updated_Date_MERC__c FROM Meeting_MERC__c WHERE Id = :meeting.Id limit 1].Participant_ToV_Updated_Date_MERC__c;

			for (Travel_Itinerary_MERC__c ti : itineraries)
			{
				ti.Confirm_ToV_Reporting_Change_MERC__c = true;
			}
			update itineraries;
			System.assert(initialTime < [SELECT Participant_ToV_Updated_Date_MERC__c FROM Meeting_MERC__c WHERE Id = :meeting.Id].Participant_ToV_Updated_Date_MERC__c);
			Test.stopTest();
		}
	}

	@isTest
	static void test_travel_itinerary_update_does_not_stamp_meeting_when_tov_is_not_final() {
		insertItineraries();
		System.runAs(testUser)
		{
			meeting = [SELECT Id, Participant_ToV_Updated_Date_MERC__c, Participant_Tov_Final_MERC__c
			                , End_Time_of_Meeting_MERC__c, Confirm_Meeting_Date_Change_MERC__c
			                , Start_Time_of_Meeting_MERC__c FROM Meeting_MERC__c WHERE Id = :meeting.Id limit 1];

			Test.startTest();
			DateTime initialTime = [SELECT Id, Participant_ToV_Updated_Date_MERC__c FROM Meeting_MERC__c WHERE Id = :meeting.Id limit 1].Participant_ToV_Updated_Date_MERC__c;
			for (Travel_Itinerary_MERC__c ti : itineraries)
			{
				ti.Confirm_ToV_Reporting_Change_MERC__c = true;
			}
			update itineraries;
			System.assertEquals(initialTime, [SELECT Participant_ToV_Updated_Date_MERC__c FROM Meeting_MERC__c WHERE Id = :meeting.Id].Participant_ToV_Updated_Date_MERC__c);
			Test.stopTest();
		}
	}

	/* TODO - fix Too many SOQL queries: 101
	 *
	 * Class.MERC_ParticipantFMVCalculator.execute: line 71, column 1 
	 * Class.MERC_ParticipantFMVCalculator.handle: line 22, column 1 
	 * Class.GLBL_TriggerHandler.manage: line 104, column 1 
	 * Trigger.MERC_MeetingParticipant: line 30, column 1
	 */
	// @isTest
	static void test_daily_attendance_update_stamps_meeting()
	{
		insertDailyTov();
		System.runAs(testUser)
		{
			meeting = [SELECT Id, Participant_ToV_Updated_Date_MERC__c, Participant_Tov_Final_MERC__c
			                , End_Time_of_Meeting_MERC__c, Confirm_Meeting_Date_Change_MERC__c
			                , Start_Time_of_Meeting_MERC__c FROM Meeting_MERC__c WHERE Id = :meeting.Id limit 1];
			meeting.Participant_Tov_Final_MERC__c = 'Yes';
			meeting.End_Time_of_Meeting_MERC__c = Date.today();
			meeting.Confirm_Meeting_Date_Change_MERC__c = true;
			meeting.Start_Time_of_Meeting_MERC__c = Date.today().addDays(-1);
			update meeting;

			Test.startTest();

			DateTime initialTime = [SELECT Id, Participant_ToV_Updated_Date_MERC__c FROM Meeting_MERC__c WHERE Id = :meeting.Id limit 1].Participant_ToV_Updated_Date_MERC__c;
			for (Daily_Attendance_TOV_MERC__c tov : tovs)
			{
				tov.Confirm_ToV_Reporting_Change_MERC__c = true;
			}

			update tovs;
			System.assert(initialTime < [SELECT Participant_ToV_Updated_Date_MERC__c FROM Meeting_MERC__c WHERE Id = :meeting.Id].Participant_ToV_Updated_Date_MERC__c);
			Test.stopTest();
		}

	}

	@isTest
	static void test_daily_attendance_update_does_not_stamp_meeting_when_participant_tov_not_final()
	{
		insertDailyTov();
		System.runAs(testUser)
		{
			meeting = [SELECT Id, Participant_ToV_Updated_Date_MERC__c, Participant_Tov_Final_MERC__c
			                , End_Time_of_Meeting_MERC__c, Confirm_Meeting_Date_Change_MERC__c
			                , Start_Time_of_Meeting_MERC__c FROM Meeting_MERC__c WHERE Id = :meeting.Id limit 1];

			Test.startTest();
			DateTime initialTime = [SELECT Id, Participant_ToV_Updated_Date_MERC__c FROM Meeting_MERC__c WHERE Id = :meeting.Id limit 1].Participant_ToV_Updated_Date_MERC__c;
			for (Daily_Attendance_TOV_MERC__c tov : tovs)
			{
				tov.Confirm_ToV_Reporting_Change_MERC__c = true;
			}
			update tovs;
			System.assertEquals(initialTime, [SELECT Participant_ToV_Updated_Date_MERC__c FROM Meeting_MERC__c WHERE Id = :meeting.Id].Participant_ToV_Updated_Date_MERC__c);
			Test.stopTest();
		}
	}

	private static void insertItineraries()
	{
		Account vendorAcct = new Account( Name         = 'Vendor'
			                            , RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType='Account' AND DeveloperName='Vendor_GLBL' limit 1].Id);
		insert vendorAcct;

		Meeting_Vendor_MERC__c vendor = new Meeting_Vendor_MERC__c(Meeting_MERC__c=meeting.id, Account_MERC__c=vendorAcct.Id);
		insert vendor;

		Id hotelRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Hotel_MERC' AND sObjectType='Travel_Itinerary_MERC__c' limit 1].Id;
		for (Meeting_Participant_MERC__c p : participants)
		{
			itineraries.add( new Travel_Itinerary_MERC__c( RecordTypeId                = hotelRecTypeId
														 , Meeting_Participant_MERC__c = p.id
														 , Travel_Detail_Typ_MERC__c   = 'Accomidation'
														 , Sgmnt_Bgin_TS_MERC__c       = DateTime.now().addDays(-1)
														 , Sgmnt_End_TS_MERC__c        = DateTime.now().addDays(1)
														 , Meeting_Vendor_MERC__c      = vendor.Id
														 , Account_MERC__c             = accounts[0].Id
														 , Confirm_ToV_Reporting_Change_MERC__c = false)
			);
		}
		insert itineraries;
	}

	private static void insertDailyTov()
	{
		Meeting_Day_MERC__c meetingDay = MERC_TestFactory.insertMeetingDays(meeting.id, 1).get(0);
		for (Meeting_Participant_MERC__c p : participants)
		{
			tovs.add( new Daily_Attendance_TOV_MERC__c( Meeting_Day_MERC__c                  = meetingDay.id
				                                      , Meeting_Participant_MERC__c          = p.id
				                                      , Confirm_ToV_Reporting_Change_MERC__c = false
				                                      , Status_MERC__c                       = '')
			);
		}
		insert tovs;
	}

}