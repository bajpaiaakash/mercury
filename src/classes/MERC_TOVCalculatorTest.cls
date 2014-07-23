/**
 * @author Joseph Ferraro && Kyle Thornton
 *
 * Unit tests for MERC_TOVCalculator
 */
@isTest
private class MERC_TOVCalculatorTest {

	static List<Account> accounts;
	static List<Meeting_MERC__c> meetings;
	static List<Meeting_Day_MERC__c> meetingDays;
	static List<Meeting_Participant_MERC__c> participants;
	static List<Meeting_Vendor_MERC__c> meetingVendors;
	static List<Hotel_Allocation_MERC__c> hotelAllocations;
	static List<Travel_Itinerary_MERC__c> itineraries;

	/*
		Set up 1 meeting with 3 meeting days and 5 participants
	*/
	static {
		MERC_TriggerHandlerStateManager.deactivateAll();
		MERC_TriggerHandlerStateManager.activate(MERC_TOVCalculator.class);

		MERC_TestFactory.loadDeclarativeRollupSummaries();

		accounts = MERC_TestFactory.insertAccounts(3);
		meetings = MERC_TestFactory.insertMeetings(1);
		meetingDays = MERC_TestFactory.insertMeetingDays(meetings.get(0).Id, 3);
		participants = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts);
		meetingVendors = MERC_TestFactory.insertHotelsForMeeting(1, meetings.get(0).Id);
		itineraries = MERC_TestFactory.insertHotelItineraries(participants, meetings.get(0).Date_of_Event_MERC__c, meetings.get(0).End_Date_of_Event_MERC__c);
	}

	@isTest static void testShouldCalculateHotelTovOnRoomRateChange() {
		Test.startTest();
		System.debug(LoggingLevel.INFO, 'QUERY LIMIT BEFORE TEST EXECUTION: '+Limits.getQueries());
		System.assertEquals(0, Limits.getQueries());

		Id hotelItineraryRecordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = 'Hotel_MERC' AND SObjectType = 'Travel_Itinerary_MERC__c'].Id;

		Meeting_Vendor_MERC__c hotel1 = meetingVendors.get(0);

		List<Hotel_Allocation_MERC__c> allocations = new List<Hotel_Allocation_MERC__c>();

		Hotel_Allocation_MERC__c hotel1Day1Allocation = new Hotel_Allocation_MERC__c();
		hotel1Day1Allocation.Meeting_Vendor_MERC__c = hotel1.Id;
		hotel1Day1Allocation.Meeting_Day_MERC__c = meetingDays.get(0).Id;
		hotel1Day1Allocation.Total_Rooms_in_Block_MERC__c = 50;
		allocations.add(hotel1Day1Allocation);

		Hotel_Allocation_MERC__c hotel1Day2Allocation = new Hotel_Allocation_MERC__c();
		hotel1Day2Allocation.Meeting_Vendor_MERC__c = hotel1.Id;
		hotel1Day2Allocation.Meeting_Day_MERC__c = meetingDays.get(1).Id;
		hotel1Day2Allocation.Total_Rooms_in_Block_MERC__c = 50;
		allocations.add(hotel1Day2Allocation);

		Hotel_Allocation_MERC__c hotel1Day3Allocation = new Hotel_Allocation_MERC__c();
		hotel1Day3Allocation.Meeting_Vendor_MERC__c = hotel1.Id;
		hotel1Day3Allocation.Meeting_Day_MERC__c = meetingDays.get(2).Id;
		hotel1Day3Allocation.Total_Rooms_in_Block_MERC__c = 50;
		allocations.add(hotel1Day3Allocation);

		insert allocations;

		System.debug(LoggingLevel.INFO, 'QUERIES: '+Limits.getQueries());

		Travel_Itinerary_MERC__c t = new Travel_Itinerary_MERC__c();
		t.Meeting_Participant_MERC__c = participants.get(0).Id;
		t.Sgmnt_Bgin_TS_MERC__c = meetingDays.get(0).Date_MERC__c; //check in day 1
		t.Sgmnt_End_TS_MERC__c = meetingDays.get(2).Date_MERC__c; //check out day 3
		t.Account_MERC__c = participants.get(0).Account_MERC__c;
		t.RecordTypeId = hotelItineraryRecordTypeId;
		t.Meeting_Vendor_MERC__c = hotel1.Id;
		insert t;

		System.debug(LoggingLevel.INFO, 'QUERIES: '+Limits.getQueries());

		//reset the static variable that got turned off during data loads
		MERC_TOVCalculator.runHotelTovCalculation = true;

		//set participant 1 to attending on day 1
		Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

		//reset the static variable that got turned off during data loads
		MERC_TOVCalculator.runHotelTovCalculation = true;

		hotel1.Room_Rate_MERC__c = 600;
		update hotel1;
		Test.stopTest();

		System.debug('QUERY LIMIT AFTER TEST EXECUTION: '+Limits.getQueries());

		Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Hotel_ToV_MERC__c, Total_Hours_of_Service_MERC__c, Total_Ground_Transporation_ToV_MERC__c, Total_Registration_ToV_MERC__c, Total_Food_Beverage_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

		//assert that meeting day 1's food bev estimate rolled up up to the participant total
		System.assertEquals(600, participant1.Total_Hotel_ToV_MERC__c);
	}

	@isTest static void testShouldCalculateRollupsOnDailyAttendanceUpdate() {
		//set participant 1 to attending on day 1
		Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

		Meeting_Day_MERC__c day1 = [SELECT Id,
										Daily_Ground_Trans_Amount_MERC__c,
										Daily_Registration_Amount_MERC__c,
										Daily_Food_Beverage_Amount_MERC__c
											FROM Meeting_Day_MERC__c WHERE Id = :meetingDays.get(0).Id];



		Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Hours_of_Service_MERC__c, Total_Ground_Transporation_ToV_MERC__c, Total_Registration_ToV_MERC__c, Total_Food_Beverage_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

		tovForParticipant1Day1 = [SELECT Id, Est_Grnd_Transp_MERC__c, Est_Reg_Amt_ToV_MERC__c, Est_Food_Bev_ToV_MERC__c, Status_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day1.Id];

		//assert that meeting day 1's food bev estimate rolled up up to the participant total
		System.assert(tovForParticipant1Day1.Est_Food_Bev_ToV_MERC__c == participant1.Total_Food_Beverage_ToV_MERC__c);

		//reset the static variable
		MERC_TOVCalculator.runHotelTovCalculation = true;
		//now remove attendance on day 1
		Test.startTest();
		tovForParticipant1Day1.Status_MERC__c = 'No Show';
		update tovForParticipant1Day1;
		Test.stopTest();
		participant1 = [SELECT Id, Total_Hours_of_Service_MERC__c, Total_Ground_Transporation_ToV_MERC__c, Total_Registration_ToV_MERC__c, Total_Food_Beverage_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

		//now ensure the rollup re-calculated
		System.assertEquals(null, participant1.Total_Food_Beverage_ToV_MERC__c);
	}

	@isTest static void testShouldEnsureDeletesRecalculateRollups() {
		//set participant 1 to attending on day 1
		Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

		Meeting_Day_MERC__c day1 = [SELECT Id,
										Daily_Ground_Trans_Amount_MERC__c,
										Daily_Registration_Amount_MERC__c,
										Daily_Food_Beverage_Amount_MERC__c
											FROM Meeting_Day_MERC__c WHERE Id = :meetingDays.get(0).Id];



		Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Hours_of_Service_MERC__c, Total_Ground_Transporation_ToV_MERC__c, Total_Registration_ToV_MERC__c, Total_Food_Beverage_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

		tovForParticipant1Day1 = [SELECT Id, Est_Grnd_Transp_MERC__c, Est_Reg_Amt_ToV_MERC__c, Est_Food_Bev_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day1.Id];

		//assert that meeting day 1's food bev estimate rolled up up to the participant total
		System.assert(tovForParticipant1Day1.Est_Food_Bev_ToV_MERC__c == participant1.Total_Food_Beverage_ToV_MERC__c);

		//reset the static variable
		MERC_TOVCalculator.runHotelTovCalculation = true;
		//now remove attendance on day 1
		Test.startTest();
		delete tovForParticipant1Day1;
		Test.stopTest();
		participant1 = [SELECT Id, Total_Hours_of_Service_MERC__c, Total_Ground_Transporation_ToV_MERC__c, Total_Registration_ToV_MERC__c, Total_Food_Beverage_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

		//now ensure the rollup re-calculated
		System.assertEquals(null, participant1.Total_Food_Beverage_ToV_MERC__c);
	}

	@isTest static void testShouldRollTovUpToParticipant() {
		Test.startTest();

		//set participant 1 to attending on day 1
		Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

		Meeting_Day_MERC__c day1 = [SELECT Id,
										Daily_Ground_Trans_Amount_MERC__c,
										Daily_Registration_Amount_MERC__c,
										Daily_Food_Beverage_Amount_MERC__c
											FROM Meeting_Day_MERC__c WHERE Id = :meetingDays.get(0).Id];



		Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Hours_of_Service_MERC__c, Total_Ground_Transporation_ToV_MERC__c, Total_Registration_ToV_MERC__c, Total_Food_Beverage_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

		tovForParticipant1Day1 = [SELECT Id, Est_Grnd_Transp_MERC__c, Est_Reg_Amt_ToV_MERC__c, Est_Food_Bev_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day1.Id];

		//assert that meeting day 1's food bev estimate rolled up up to the participant total
		System.assert(tovForParticipant1Day1.Est_Food_Bev_ToV_MERC__c == participant1.Total_Food_Beverage_ToV_MERC__c);

		Test.stopTest();

	}
}