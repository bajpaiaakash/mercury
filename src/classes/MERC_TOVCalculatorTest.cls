/**
 * @author Joseph Ferraro && Kyle Thornton && Sean Harrison
 *
 * Unit tests for MERC_TOVCalculator
 */
@isTest
private class MERC_TOVCalculatorTest {

	static List<Account> accounts;
	static List<Meeting_MERC__c> meetings;
	static List<Meeting_Day_MERC__c> meetingDays;
	static List<Meeting_Participant_MERC__c> participants;
	static List<Meeting_Vendor_MERC__c> vendors;
	static List<Hotel_Allocation_MERC__c> hotelAllocations;
	static List<Travel_Itinerary_MERC__c> itineraries;

	static Date startDate;
	static Integer durationInDays;

	public static Id hcpRecordTypeId = 				[SELECT ID FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'HCP_GLBL' LIMIT 1].Id;
	public static Id vendorRecordTypeId = 			[SELECT ID FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Vendor_GLBL' LIMIT 1].Id;
	public static Id hotelItineraryRecordTypeId = 	[SELECT ID FROM RecordType WHERE SObjectType = 'Travel_Itinerary_MERC__c' AND DeveloperName = 'Hotel_MERC' LIMIT 1].Id;

	/*
		Set up 1 meeting with 3 meeting days and 5 participants
	*/
	static {
		MERC_TriggerHandlerStateManager.deactivateAll();
		MERC_TriggerHandlerStateManager.activate(MERC_TOVCalculator.class);

		MERC_TestFactory.loadDeclarativeRollupSummaries();

		// MERC_TestFactory has some bugs. Until this is cleaned up, data factory methods moved within class...
		//accounts = MERC_TestFactory.insertAccounts(3);
		//meetings = MERC_TestFactory.insertMeetings(1);
		//meetingDays = MERC_TestFactory.insertMeetingDays(meetings.get(0).Id, 3);
		//participants = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts);
		//meetingVendors = MERC_TestFactory.insertHotelsForMeeting(2, meetings.get(0).Id);
		//itineraries = MERC_TestFactory.insertHotelItineraries(participants, meetings.get(0).Date_of_Event_MERC__c, meetings.get(0).End_Date_of_Event_MERC__c);

		startDate = Date.today();
		durationInDays = 2;
		Date endDate = startDate.addDays(durationInDays);

		accounts = insertAccounts(3);
		meetings = insertMeetings(1,startDate,endDate);
		meetingDays = insertMeetingDays(meetings);
		participants = insertParticipants(meetings,accounts);
		vendors = insertHotels(2,meetings);
		itineraries = insertItineraries(participants,startDate,endDate);
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
//		Id hotelItineraryRecordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = 'Hotel_MERC' AND SObjectType = 'Travel_Itinerary_MERC__c'].Id;
		Meeting_Vendor_MERC__c hotel1 = vendors[0];
		Meeting_Vendor_MERC__c hotel2 = vendors[1];

		Test.startTest();
		// attendee stays at one hotel on Day 1
		List<Travel_Itinerary_MERC__c> changingItinerary = MERC_TestFactory.insertHotelItineraries(attendee, meetingDays.get(0).Date_MERC__c, meetingDays.get(1).Date_MERC__c);
		vendors[0].Room_Rate_MERC__c = 199;
		changingItinerary[0].Meeting_Vendor_MERC__c = hotel1.Id;
//		changingItinerary[0].RecordTypeId = hotelItineraryRecordTypeId;

		 // attendee upset; moves to local youth hostel
		 changingItinerary.add(MERC_TestFactory.insertHotelItineraries(attendee, meetingDays.get(1).Date_MERC__c, meetingDays.get(2).Date_MERC__c)[0]);
		 vendors[1].Room_Rate_MERC__c = 1;
		 changingItinerary[1].Meeting_Vendor_MERC__c = hotel2.Id;
//		 changingItinerary[1].RecordTypeId = hotelItineraryRecordTypeId;

		update vendors;
		update changingItinerary;

		//reset the static variable that got turned off during data loads
		MERC_TOVCalculator.runHotelTovCalculation = true;

		//set attendee to attending first two days.... 
		MERC_TestFactory.insertTov(meetingDays.get(0).Id, attendee.get(0).Id, 'Attended');
		MERC_TestFactory.insertTov(meetingDays.get(1).Id, attendee.get(0).Id, 'Attended');

		attendee = [SELECT Id, Total_Hotel_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :attendee[0].Id LIMIT 1];
		System.assertEquals(vendors[0].Room_Rate_MERC__c + vendors[1].Room_Rate_MERC__c, attendee[0].Total_Hotel_ToV_MERC__c, 'Totals does not match expected sum.');

		Test.stopTest();
	}

	/**
	 * For T#14374 - 
	 * Two itineraries across multiple days for a single participant + calculation triggered
	 * by vendor and itinerary change...
	 **/
	@isTest
	static void testShouldRollupMultipleItineraryVendorChange() {
		// get a participant
		Meeting_Participant_MERC__c attendee = participants[0];

		// get hotels
		Meeting_Vendor_MERC__c hotel1 = vendors[0];
		Meeting_Vendor_MERC__c hotel2 = vendors[1];
		hotel1.Room_Rate_MERC__c = 199;
		hotel2.Room_Rate_MERC__c = 1;
		update vendors;

		// set attendee to attending first two days.... 
//		MERC_TOVCalculator.runHotelTovCalculation = true;
		Daily_Attendance_TOV_MERC__c day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, attendee.Id, 'Attended');
		Daily_Attendance_TOV_MERC__c day2 = MERC_TestFactory.insertTov(meetingDays.get(1).Id, attendee.Id, 'Attended');
		//day1 = [SELECT Id, Est_Hotel_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :day1.Id LIMIT 1];
		//day2 = [SELECT Id, Est_Hotel_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :day2.Id LIMIT 1];
		//System.assert(day1.Est_Hotel_ToV_MERC__c != null);
		//System.assert(day2.Est_Hotel_ToV_MERC__c != null);

		Test.startTest();
		// clear itineraries to satisfy duplicate value validation check
		delete [SELECT Id, Combined_ID_MERC__c FROM Travel_Itinerary_MERC__c WHERE Meeting_Participant_MERC__c = :attendee.Id];

		List<Travel_Itinerary_MERC__c> changingItineraries = new List<Travel_Itinerary_MERC__c>();

		// attendee stays at one hotel on Day 1
		Travel_Itinerary_MERC__c ti1 = insertItinerary(attendee, meetingDays.get(0).Date_MERC__c, meetingDays.get(1).Date_MERC__c);
		ti1.Meeting_Vendor_MERC__c = hotel1.Id;
		changingItineraries.add(ti1);
		update changingItineraries;
//		p('dups? '+[SELECT Id, Combined_ID_MERC__c FROM Travel_Itinerary_MERC__c WHERE Meeting_Participant_MERC__c = :attendee.Id]);


		// attendee upset; moves to local youth hostel
//		MERC_TOVCalculator.runHotelTovCalculation = true;
		Travel_Itinerary_MERC__c ti2 = insertItinerary(attendee, meetingDays.get(1).Date_MERC__c, meetingDays.get(2).Date_MERC__c);
		ti2.Meeting_Vendor_MERC__c = hotel2.Id;

		changingItineraries.add(ti2);

		// reset the static variable that got turned off during data loads
		MERC_TOVCalculator.runHotelTovCalculation = true;
		update changingItineraries;
		Test.stopTest();

/*
		// attendee stays at one hotel on Day 1
		List<Travel_Itinerary_MERC__c> changingItinerary = MERC_TestFactory.insertHotelItineraries(attendee, meetingDays.get(0).Date_MERC__c, meetingDays.get(1).Date_MERC__c);
		hotel1.Room_Rate_MERC__c = 199;
		changingItinerary[0].Meeting_Vendor_MERC__c = hotel1.Id;

		// attendee upset; moves to local youth hostel
		changingItinerary.add(MERC_TestFactory.insertHotelItineraries(attendee, meetingDays.get(1).Date_MERC__c, meetingDays.get(2).Date_MERC__c)[0]);
		hotel2.Room_Rate_MERC__c = 1;
		changingItinerary[1].Meeting_Vendor_MERC__c = hotel2.Id;

		// reset the static variable that got turned off during data loads
		MERC_TOVCalculator.runHotelTovCalculation = true;
		update changingItinerary;
		MERC_TOVCalculator.runHotelTovCalculation = true;
		update meetingVendors;
*/

		day1 = [SELECT Id, Est_Hotel_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :day1.Id LIMIT 1];
		day2 = [SELECT Id, Est_Hotel_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :day2.Id LIMIT 1];
		System.assert(day1.Est_Hotel_ToV_MERC__c != null);
		System.assert(day2.Est_Hotel_ToV_MERC__c != null);
		System.assertEquals(hotel1.Room_Rate_MERC__c + hotel2.Room_Rate_MERC__c, day1.Est_Hotel_ToV_MERC__c + day2.Est_Hotel_ToV_MERC__c, 'Totals do not match expected sum. '+ day1.Est_Hotel_ToV_MERC__c +'+'+ day2.Est_Hotel_ToV_MERC__c);

	}

	//@isTest
	static void testShouldCalculateHotelTovOnRoomRateChange() {
		Test.startTest();
		System.debug(LoggingLevel.INFO, 'QUERY LIMIT BEFORE TEST EXECUTION: '+Limits.getQueries());
		System.assertEquals(0, Limits.getQueries());

		Meeting_Vendor_MERC__c hotel1 = vendors.get(0);

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

	static List<Account> insertAccounts(Integer numberOfAccounts) {
		return MERC_TestFactory.insertAccounts(numberOfAccounts, hcpRecordTypeId);
	}

	static List<Meeting_MERC__c> insertMeetings(Integer numberOfMeetings, Date start_date, Date end_date) {
		List<Meeting_MERC__c> mtgs = new List<Meeting_MERC__c>();
		for (Integer i = 0; i < numberOfMeetings; i++) {
			Meeting_MERC__c m = new Meeting_MERC__c();
			m.Date_of_Event_MERC__c = start_date;
			m.End_Date_of_Event_MERC__c = end_date;
			m.Start_Time_of_Meeting_MERC__c = DateTime.newInstance(start_date, Time.newInstance(10, 0, 0, 0));
			m.End_Time_of_Meeting_MERC__c = DateTime.newInstance(end_date, Time.newInstance(14, 0, 0, 0));
			m.Name = 'ToV Meeting'+i;
			m.Meeting_Time_Zone_MERC__c = 'Greenwich Mean Time (Europe/London)';
			m.Event_Country_MERC__c = 'GB';
			mtgs.add(m);
		}
		insert mtgs;
		return mtgs;
	}

	static List<Meeting_Day_MERC__c> insertMeetingDays(List<Meeting_MERC__c> meets) {
		List<Meeting_Day_MERC__c> mtgDays = new List<Meeting_Day_MERC__c>();
		for (Meeting_MERC__c meeting : meets) {
			Integer numberOfDays = meeting.Date_of_Event_MERC__c.daysBetween(meeting.End_Date_of_Event_MERC__c)+1;
			for (Integer i = 0; i < numberOfDays; i++) {
				Meeting_Day_MERC__c m = new Meeting_Day_MERC__c();
				m.Date_MERC__c = meeting.Date_of_Event_MERC__c.addDays(i);
				m.Meeting_MERC__c = meeting.Id;
				m.Daily_Food_Beverage_Amount_MERC__c = 100;
				m.Daily_Ground_Trans_Amount_MERC__c = 100;
				m.Daily_Registration_Amount_MERC__c = 100;
				mtgDays.add(m);
			}
		}
		insert mtgDays;
		return mtgDays;
	}

	static List<Meeting_Participant_MERC__c> insertParticipants(List<Meeting_MERC__c> meets, List<Account> accts) {
		List<Meeting_Participant_MERC__c> mps = new List<Meeting_Participant_MERC__c>();
		for (Meeting_MERC__c m : meets) {
			for (Integer i = 0; i < accts.size(); i++) {
				Meeting_Participant_MERC__c p = new Meeting_Participant_MERC__c();
				p.Account_MERC__c = accts.get(i).Id;
				p.Meeting_MERC__c = m.Id;
				p.Status_MERC__c = 'Invited';   // ?? impact of this status on ToV?
				p.Services_Rendered_MERC__c = 'Yes';
				p.Alliance_MERC__c = 'Not Applicable';
				mps.add(p);
			}
		}
		insert mps;
		return mps;
	}

	static List<Meeting_Vendor_MERC__c> insertHotels(Integer numberOfHotels, List<Meeting_MERC__c> meets) {
		List<Account> accts = new List<Account>();
		for (Integer i = 0; i < numberOfHotels; i++) {
			Account a = new Account();
			a.RecordTypeId = vendorRecordTypeId;
			a.Name = MERC_Util.generateRandomString(5);
			accts.add(a);
		}
		insert accts;

		List<Meeting_Vendor_MERC__c> hotels = new List<Meeting_Vendor_MERC__c>();
		for (Meeting_MERC__c meeting : meets) {
			for (Integer i = 0; i < accts.size(); i++) {
				Meeting_Vendor_MERC__c v = new Meeting_Vendor_MERC__c();
				v.Account_MERC__c = accts.get(i).Id;
				v.Room_Rate_MERC__c = (i+1)*50;
				v.Meeting_MERC__c = meeting.Id;
				hotels.add(v);
			}
		}
		insert hotels;
		return hotels;
	}

	static Travel_Itinerary_MERC__c insertItinerary(Meeting_Participant_MERC__c mp, Date start_date, Date end_date) {
		return insertItineraries(new List<Meeting_Participant_MERC__c>{mp}, start_date, end_date)[0];
	}
	static List<Travel_Itinerary_MERC__c> insertItineraries(List<Meeting_Participant_MERC__c> mps, Date start_date, Date end_date) {
		List<Travel_Itinerary_MERC__c> hotelItineraries = new List<Travel_Itinerary_MERC__c>();
		for (Meeting_Participant_MERC__c mp : mps) {
			Travel_Itinerary_MERC__c ti = new Travel_Itinerary_MERC__c();
			ti.RecordTypeId = hotelItineraryRecordTypeId;
			ti.Meeting_Participant_MERC__c = mp.Id;
			ti.Account_MERC__c = mp.Account_MERC__c;
			ti.Sgmnt_Bgin_TS_MERC__c = Datetime.newInstance(start_date, Time.newInstance(12, 0, 0, 0));
			ti.Sgmnt_End_TS_MERC__c = Datetime.newInstance(end_date, Time.newInstance(15, 0, 0, 0));
			hotelItineraries.add(ti);
		}
		insert hotelItineraries;
		return hotelItineraries;
	}


		static void p(String m) {
			System.debug(LoggingLevel.WARN,'\n\n\nYYZ - '+m+'\n\n\n\n');
		}
}