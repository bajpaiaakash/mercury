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
		meetingVendors = MERC_TestFactory.insertHotelsForMeeting(2, meetings.get(0).Id);
		p('inserting itineraries');
		itineraries = MERC_TestFactory.insertHotelItineraries(participants, meetings.get(0).Date_of_Event_MERC__c, meetings.get(0).End_Date_of_Event_MERC__c);
	}

	/**
	 * For T#14374 - 
	 * Two itineraries across multiple days for a single participant...
	 **/
	//@isTest
	static void testShouldRollupMultipleItineraries() {

		// make a new participant
		List<Meeting_Participant_MERC__c> attendee = MERC_TestFactory.insertParticipants(meetings.get(0).Id, MERC_TestFactory.insertAccounts(1));

		//setup hotels
		Id hotelItineraryRecordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = 'Hotel_MERC' AND SObjectType = 'Travel_Itinerary_MERC__c'].Id;
		Meeting_Vendor_MERC__c hotel1 = meetingVendors[0];
		Meeting_Vendor_MERC__c hotel2 = meetingVendors[1];

		Test.startTest();
		// attendee stays at one hotel on Day 1
		List<Travel_Itinerary_MERC__c> changingItinerary = MERC_TestFactory.insertHotelItineraries(attendee, meetingDays.get(0).Date_MERC__c, meetingDays.get(1).Date_MERC__c);
		meetingVendors[0].Room_Rate_MERC__c = 199;
		changingItinerary[0].Meeting_Vendor_MERC__c = hotel1.Id;
		changingItinerary[0].RecordTypeId = hotelItineraryRecordTypeId;

		 // attendee upset; moves to local youth hostel
		 changingItinerary.add(MERC_TestFactory.insertHotelItineraries(attendee, meetingDays.get(1).Date_MERC__c, meetingDays.get(2).Date_MERC__c)[0]);
		 meetingVendors[1].Room_Rate_MERC__c = 1;
		 changingItinerary[1].Meeting_Vendor_MERC__c = hotel2.Id;
		 changingItinerary[1].RecordTypeId = hotelItineraryRecordTypeId;

		update meetingVendors;
		update changingItinerary;

		//reset the static variable that got turned off during data loads
		MERC_TOVCalculator.runHotelTovCalculation = true;

		//set attendee to attending first two days.... 
		MERC_TestFactory.insertTov(meetingDays.get(0).Id, attendee.get(0).Id, 'Attended');
		MERC_TestFactory.insertTov(meetingDays.get(1).Id, attendee.get(0).Id, 'Attended');

		attendee = [SELECT Id, Total_Hotel_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :attendee[0].Id LIMIT 1];
		System.assertEquals(meetingVendors[0].Room_Rate_MERC__c + meetingVendors[1].Room_Rate_MERC__c, attendee[0].Total_Hotel_ToV_MERC__c, 'Totals does not match expected sum.');

		Test.stopTest();
	}

	/**
	 * For T#14374 - 
	 * Two itineraries across multiple days for a single participant + calculation triggered
	 * by vendor and itinerary change...
	 **/
	@isTest
	static void testShouldRollupMultipleItineraryVendorChange() {

		// make a new participant
		List<Meeting_Participant_MERC__c> attendee = MERC_TestFactory.insertParticipants(meetings.get(0).Id, MERC_TestFactory.insertAccounts(1));

		// setup hotels
		Id hotelItineraryRecordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = 'Hotel_MERC' AND SObjectType = 'Travel_Itinerary_MERC__c'].Id;
		Meeting_Vendor_MERC__c hotel1 = meetingVendors[0];
		Meeting_Vendor_MERC__c hotel2 = meetingVendors[1];

		// set attendee to attending first two days.... 
		MERC_TOVCalculator.runHotelTovCalculation = true;
		Daily_Attendance_TOV_MERC__c day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, attendee.get(0).Id, 'Attended');
		MERC_TOVCalculator.runHotelTovCalculation = true;
		Daily_Attendance_TOV_MERC__c day2 = MERC_TestFactory.insertTov(meetingDays.get(1).Id, attendee.get(0).Id, 'Attended');

		Test.startTest();
		// attendee stays at one hotel on Day 1
		MERC_TOVCalculator.runHotelTovCalculation = true;
		List<Travel_Itinerary_MERC__c> changingItinerary = MERC_TestFactory.insertHotelItineraries(attendee, meetingDays.get(0).Date_MERC__c, meetingDays.get(1).Date_MERC__c);
		hotel1.Room_Rate_MERC__c = 199;
		changingItinerary[0].Meeting_Vendor_MERC__c = hotel1.Id;
		changingItinerary[0].RecordTypeId = hotelItineraryRecordTypeId;
		day1 = [SELECT Id, Est_Hotel_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :day1.Id LIMIT 1];
		day2 = [SELECT Id, Est_Hotel_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :day2.Id LIMIT 1];
		System.assert(day1.Est_Hotel_ToV_MERC__c != null);
		System.assert(day2.Est_Hotel_ToV_MERC__c != null);

		// attendee upset; moves to local youth hostel
		MERC_TOVCalculator.runHotelTovCalculation = true;
		changingItinerary.add(MERC_TestFactory.insertHotelItineraries(attendee, meetingDays.get(1).Date_MERC__c, meetingDays.get(2).Date_MERC__c)[0]);

		// reset the static variable that got turned off during data loads
		MERC_TOVCalculator.runHotelTovCalculation = true;
		update changingItinerary;
		MERC_TOVCalculator.runHotelTovCalculation = true;
		update meetingVendors;

		day1 = [SELECT Id, Est_Hotel_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :day1.Id LIMIT 1];
		day2 = [SELECT Id, Est_Hotel_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :day2.Id LIMIT 1];
		System.assert(day1.Est_Hotel_ToV_MERC__c != null);
		System.assert(day2.Est_Hotel_ToV_MERC__c != null);
		System.assertEquals(meetingVendors[0].Room_Rate_MERC__c + meetingVendors[1].Room_Rate_MERC__c, day1.Est_Hotel_ToV_MERC__c + day2.Est_Hotel_ToV_MERC__c, 'Totals does not match expected sum. '+ day1.Est_Hotel_ToV_MERC__c +'+'+ day2.Est_Hotel_ToV_MERC__c);

		Test.stopTest();
	}

	//@isTest
	static void testShouldCalculateHotelTovOnRoomRateChange() {
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

	//@isTest
	static void testShouldCalculateRollupsOnDailyAttendanceUpdate() {
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

	//@isTest
	static void testShouldCalculateHotelOnDailyAttendanceStatusUpdate() {

		//set participant 1 to attending on day 1
		Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = 
									MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

		Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Hotel_ToV_MERC__c
													FROM Meeting_Participant_MERC__c 
													WHERE Id = :participants.get(0).Id];

		tovForParticipant1Day1 = [SELECT Id, Est_Hotel_ToV_MERC__c, Status_MERC__c 
									FROM Daily_Attendance_TOV_MERC__c 
									WHERE Id = :tovForParticipant1Day1.Id];

		//assert that meeting day 1's hotel estimate rolled up up to the participant total
		System.assertNotEquals(participant1.Total_Hotel_ToV_MERC__c,null,'Unexpected null value for participant tov.');
		System.assertEquals(tovForParticipant1Day1.Est_Hotel_ToV_MERC__c, participant1.Total_Hotel_ToV_MERC__c, 'Unexpected hotel ToV values do not match.');

		//reset the static variable
		MERC_TOVCalculator.runHotelTovCalculation = true;
		//now remove attendance on day 1
		Test.startTest();
		tovForParticipant1Day1.Status_MERC__c = 'No Show';
		update tovForParticipant1Day1;
		Test.stopTest();
		participant1 = [SELECT Id, Total_Hotel_ToV_MERC__c
						FROM Meeting_Participant_MERC__c 
						WHERE Id = :participants.get(0).Id];

		//now ensure the rollup re-calculated
		System.assertEquals(null, participant1.Total_Hotel_ToV_MERC__c);
	}

	//@isTest
	static void testShouldNotCalculateHotelOnDailyAttendanceStatusUpdateWhenFinal() {

		Meeting_Participant_MERC__c participant1 = [SELECT Id, Meeting_MERC__c, Total_Hotel_ToV_MERC__c
													FROM Meeting_Participant_MERC__c 
													WHERE Id = :participants.get(0).Id];

		//set participant 1 to attending on day 1
		MERC_TOVCalculator.runHotelTovCalculation = true;
		Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = 
									MERC_TestFactory.insertTov(meetingDays.get(0).Id, participant1.Id, 'Attended');

		Meeting_MERC__c meeting1 = [SELECT Id, Participant_ToV_Final_MERC__c FROM Meeting_MERC__c WHERE Id = :participant1.Meeting_MERC__c];

		tovForParticipant1Day1 = [SELECT Id, Est_Hotel_ToV_MERC__c, Status_MERC__c 
									FROM Daily_Attendance_TOV_MERC__c 
									WHERE Id = :tovForParticipant1Day1.Id];

		Decimal previousValue = tovForParticipant1Day1.Est_Hotel_ToV_MERC__c;
		System.assert(previousValue > 0,'Unexpected value for Est_Hotel_ToV during test setup. '+previousValue);

		//assert that meeting day 1's hotel estimate rolled up up to the participant total
		System.assertEquals(tovForParticipant1Day1.Est_Hotel_ToV_MERC__c, participant1.Total_Hotel_ToV_MERC__c, 'Unexpected hotel ToV values do not match');

		//reset the static variable
		MERC_TOVCalculator.runHotelTovCalculation = true;

		//set ToV to Final
		meeting1.Participant_ToV_Final_MERC__c = 'Yes';
		update meeting1;

		Test.startTest();
		MERC_TOVCalculator.runHotelTovCalculation = true;

		//now remove attendance on day 1
		tovForParticipant1Day1.Status_MERC__c = 'No Show';
		update tovForParticipant1Day1;
		Test.stopTest();
		participant1 = [SELECT Id, Total_Hotel_ToV_MERC__c
						FROM Meeting_Participant_MERC__c 
						WHERE Id = :participants.get(0).Id];

		//now ensure the rollup re-calculated
		System.assertNotEquals(null, participant1.Total_Hotel_ToV_MERC__c);

		tovForParticipant1Day1 = [SELECT Id, Est_Hotel_ToV_MERC__c, Status_MERC__c 
									FROM Daily_Attendance_TOV_MERC__c 
									WHERE Id = :tovForParticipant1Day1.Id];

		//ensure Hotel didn't get erased/changed
		System.assertEquals(tovForParticipant1Day1.Est_Hotel_ToV_MERC__c,previousValue,'Hotel ToV on Daily Attendance has unexpectedly changed.');
	}

	//@isTest
	static void testShouldEnsureDeletesRecalculateRollups() {
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

	//@isTest
	static void testShouldRollTovUpToParticipant() {
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

		static void p(String m) {
			System.debug('\n\n\nYYZ - '+m+'\n\n\n\n');
		}
}