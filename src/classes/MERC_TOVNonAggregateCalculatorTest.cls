/**
 * @author Paul Battisson
 *
 * Unit tests for MERC_TOVCalculator bit with non-aggregating functions used. FYI - methods are in alpha order
 */
@isTest
private class MERC_TOVNonAggregateCalculatorTest {

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
	public static Id rentalCarRecordTypeId = 		[SELECT ID FROM RecordType WHERE SObjectType = 'Travel_Itinerary_MERC__c' AND DeveloperName = 'Car_MERC' LIMIT 1].Id;

	static void setup() {
		MERC_TriggerHandlerStateManager.deactivateAll();
		MERC_TriggerHandlerStateManager.activate(MERC_TOVCalculator.class);

		MERC_TestFactory.loadDeclarativeRollupNonAggregateSummaries();

		//List<LookupRollupSummary_GLBL__c> lrSummaries = [SELECT DoNotAggregate_GLBL__c, Active_GLBL__c FROM LookupRollupSummary_GLBL__c WHERE Active_GLBL__c = true];

		//for(LookupRollupSummary_GLBL__c lrs : lrSummaries){
		//	System.debug('LRS DEBUG: ' + lrs);
		//	lrs.DoNotAggregate_GLBL__c = true;
		//}

		//update lrSummaries;

		// MERC_TestFactory has some bugs. Until this is cleaned up, data factory methods moved within class...
		startDate = Date.today();
		durationInDays = 2;
		Date endDate = startDate.addDays(durationInDays);

		accounts = insertAccounts(3);
		meetings = insertMeetings(1,startDate,endDate);
		meetingDays = insertMeetingDays(meetings);
		participants = insertParticipants(meetings,accounts);
		vendors = insertHotels(2,meetings);
		itineraries = insertHotelItineraries(participants,startDate,endDate,vendors[0]);

		MERC_TOVCalculator.runHotelTovCalculation = true;

		p('1.Limits:'+Limits.getQueries()+'/'+Limits.getLimitQueries());
	}

	/**
	 * Food/Beverage ToV test for DA/ToV updates
	 * ---
	 * Start Meeting Day 1 with Daily_Food_Beverage_Amount_MERC__c = value
	 * Set DA/ToV for participant 1 to 'Attended' on day 1
	 * Confirm participant has correct Total_Food_Beverage_ToV_MERC__c
	 * Change DA/ToV for participant 1 from 'Attended' to 'No Show' on day 1
	 * Confirm participant has null for Total_Food_Beverage_ToV_MERC__c

	 TODO: change to check Ground and Registration also
	 **/
	@isTest
	static void foodShouldCalculateOnDailyAttendanceUpdate() {
		setup();
		//set participant 1 to attending on day 1
p('starting'+[SELECT Id, Total_Hours_of_Service_MERC__c, Total_Ground_Transporation_ToV_MERC__c, Total_Registration_ToV_MERC__c, Total_Food_Beverage_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id]);

		Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

		Meeting_Day_MERC__c day1 = [SELECT Id,
										Daily_Ground_Trans_Amount_MERC__c,
										Daily_Registration_Amount_MERC__c,
										Daily_Food_Beverage_Amount_MERC__c
											FROM Meeting_Day_MERC__c WHERE Id = :meetingDays.get(0).Id];

		Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Hours_of_Service_MERC__c, Total_Ground_Transporation_ToV_MERC__c, Total_Registration_ToV_MERC__c, Total_Food_Beverage_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

		tovForParticipant1Day1 = [SELECT Id, Est_Grnd_Transp_MERC__c, Est_Reg_Amt_ToV_MERC__c, Est_Food_Bev_ToV_MERC__c, Status_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day1.Id];

		//assert that meeting day 1's food bev estimate rolled up up to the participant total
p('participant1'+participant1);
p('tovForParticipant1Day1'+tovForParticipant1Day1);
		System.assertEquals(tovForParticipant1Day1.Est_Food_Bev_ToV_MERC__c, participant1.Total_Food_Beverage_ToV_MERC__c, 'Est_Food_Bev_ToV_MERC__c did not rollup as expected.');

		//now remove attendance on day 1
		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();

		tovForParticipant1Day1.Status_MERC__c = 'No Show';
		update tovForParticipant1Day1;

		profiler.stopProfiling();
		profiler.debugUsage();
		Test.stopTest();
		participant1 = [SELECT Id, Total_Hours_of_Service_MERC__c, Total_Ground_Transporation_ToV_MERC__c, Total_Registration_ToV_MERC__c, Total_Food_Beverage_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

		//now ensure the rollup re-calculated
		System.assertEquals(null, participant1.Total_Food_Beverage_ToV_MERC__c,'Unexpected non-null value for MP Total Food/Bev');
	}

	/**
	 * Food/Beverage ToV test for DA/ToV deletes
	 * ---
	 * Start Meeting Day 1 with Daily_Food_Beverage_Amount_MERC__c = value
	 * Set DA/ToV for participant 1 to 'Attended' on day 1
	 * Confirm participant has correct Total_Food_Beverage_ToV_MERC__c
	 * Delete DA/ToV for participant 1 on day 1
	 * Confirm has null for Total_Food_Beverage_ToV_MERC__c

	 TODO: change to check Ground and Registration also
	 **/
	@isTest
	static void foodShouldRecalculateOnToVDelete() {
		setup();
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
		System.assertEquals(tovForParticipant1Day1.Est_Food_Bev_ToV_MERC__c, participant1.Total_Food_Beverage_ToV_MERC__c, 'Est_Food_Bev_ToV_MERC__c did not rollup as expected.');

		//reset the static variable
		
		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();

			//now remove attendance on day 1
			delete tovForParticipant1Day1;

		profiler.stopProfiling();
		profiler.debugUsage();
		Test.stopTest();
		participant1 = [SELECT Id, Total_Hours_of_Service_MERC__c, Total_Ground_Transporation_ToV_MERC__c, Total_Registration_ToV_MERC__c, Total_Food_Beverage_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

		//now ensure the rollup re-calculated
		System.assertEquals(null, participant1.Total_Food_Beverage_ToV_MERC__c);
	}

	/**
	 * Food/Beverage ToV test
	 * ---
	 * Start Meeting Day 1 with Daily_Food_Beverage_Amount_MERC__c = value
	 * Set DA/ToV for participant 1 to 'Attended' on day 1
	 * Confirm participant has correct Total_Food_Beverage_ToV_MERC__c

	 TODO: change to check Ground and Registration also
	 **/
	@isTest
	static void foodShouldRollTovUpToParticipant() {
		setup();
		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();

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
		System.assertEquals(tovForParticipant1Day1.Est_Food_Bev_ToV_MERC__c, participant1.Total_Food_Beverage_ToV_MERC__c, 'Est_Food_Bev_ToV_MERC__c did not rollup as expected.');

		profiler.stopProfiling();
		profiler.debugUsage();
		Test.stopTest();

	}

	/**
	 * Lilly T-1346
	 * Multiple private transfer itineraries should be combined to give you a SUM of the Individual Travel ToV
	 * ---
	 * Start Meeting Days with Daily_Ground_Trans_Amount_MERC__c = null
	 * Set DA/ToV for participant 1 to 'Attended' for each day
	 * Create multiple private transfer Itineraries (3) with Total_Fare = value for participant 1 for duration of meeting
	 * Confirm DA/ToVs reflect sum of Total_Fare values
	 **/
	@isTest
	static void groundShouldCaptureMultiplePrivateTransfersOnItineraryCreate() {
		setup();
		// get a participant
		Meeting_Participant_MERC__c attendee = participants[0];

		// clear initial trans amount
		for (Meeting_Day_MERC__c m : meetingDays) {
			m.Daily_Ground_Trans_Amount_MERC__c = null;
		}
		MERC_TOVCalculator.runIndividualTransferTovCalculation = true;
		update meetingDays;

		// set participant as "attended"
		MERC_TOVCalculator.runIndividualTransferTovCalculation = true;
		List<Daily_Attendance_TOV_MERC__c> tovs = insertTovs(meetingDays, attendee.Id, 'Attended');

		attendee = [SELECT Id, Account_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :attendee.Id LIMIT 1];

		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();

		 	// create new travel itineraries of type Car_MERC
			MERC_TOVCalculator.runIndividualTransferTovCalculation = true;
	 		List<Travel_Itinerary_MERC__c> pvtTransfers = insertPrivateTransferItineraries(new List<Meeting_Participant_MERC__c>{attendee},startDate,startDate.addDays(2),3);

	 	profiler.stopProfiling();
		profiler.debugUsage();
		Test.stopTest();

		Decimal itinerarySum = 0;
		for (Travel_Itinerary_MERC__c ti : pvtTransfers) {
			if (ti.Total_Fare_Amount_MERC__c != null) itinerarySum += ti.Total_Fare_Amount_MERC__c;
		}
		System.assert(itinerarySum>0,'Why is the sum of these fares = '+itinerarySum);


		System.debug('MEETING DAYS: ' + meetingDays);
	 	// ground transportation match should be sum of initeraries above
	 	tovs = [SELECT Est_Grnd_Transp_MERC__c 
	 			FROM Daily_Attendance_TOV_MERC__c 
	 			WHERE Meeting_Participant_MERC__c = :attendee.Id AND Meeting_Day_MERC__c in :meetingDays];
		Decimal tovSum = 0;
	 	for (Daily_Attendance_TOV_MERC__c tov : tovs) {
	 		if (tov.Est_Grnd_Transp_MERC__c != null) tovSum += tov.Est_Grnd_Transp_MERC__c;
	 	}

	 	System.assertEquals(itinerarySum,tovSum,'Unexpected total for Daily Transport ToV');
	 }

	/**
	 * Lilly T-1346
	 * When entered one-a-day, multiple private transfer itineraries should be combined to give you a SUM of the Individual Travel ToV
	 * ---
	 * Start Meeting Days with Daily_Ground_Trans_Amount_MERC__c = null
	 * Set DA/ToV for participant 1 to 'Attended' for each day
	 * Create multiple private transfer Itineraries (3) with Total_Fare = value for participant 1 for duration of meeting
	 * Confirm DA/ToVs reflect sum of Total_Fare values
	 **/
	@isTest
	static void groundShouldCaptureMultipleDailyPrivateTransfersOnItineraryCreate() {
		setup();
		// get a participant
		Meeting_Participant_MERC__c attendee = participants[0];

		// clear initial trans amount
		for (Meeting_Day_MERC__c m : meetingDays) {
			m.Daily_Ground_Trans_Amount_MERC__c = null;
		}
		update meetingDays;

		// set participant as "attended"
		List<Daily_Attendance_TOV_MERC__c> tovs = insertTovs(meetingDays, attendee.Id, 'Attended');
		attendee = [SELECT Id, Account_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :attendee.Id LIMIT 1];

		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();
		 	// create new travel itineraries of type Car_MERC
			MERC_TOVCalculator.runIndividualTransferTovCalculation = true;
	 		List<Travel_Itinerary_MERC__c> pvtTransfers = insertDailyPrivateTransferItineraries(new List<Meeting_Participant_MERC__c>{attendee},startDate,startDate.addDays(durationInDays));
	 	profiler.stopProfiling();
		profiler.debugUsage();
		Test.stopTest();

		Decimal itinerarySum = 0;
		for (Travel_Itinerary_MERC__c ti : pvtTransfers) {
			if (ti.Total_Fare_Amount_MERC__c != null) itinerarySum += ti.Total_Fare_Amount_MERC__c;
		}
		System.assert(itinerarySum>0,'Why is the sum of these fares = '+itinerarySum);

	 	// ground transportation match should be sum of initeraries above
	 	tovs = [SELECT Est_Grnd_Transp_MERC__c 
	 			FROM Daily_Attendance_TOV_MERC__c 
	 			WHERE Meeting_Participant_MERC__c = :attendee.Id AND Meeting_Day_MERC__c in :meetingDays];
		Decimal tovSum = 0;
	 	for (Daily_Attendance_TOV_MERC__c tov : tovs) {
	 		if (tov.Est_Grnd_Transp_MERC__c != null) tovSum += tov.Est_Grnd_Transp_MERC__c;
	 	}

	 	System.assertEquals(itinerarySum,tovSum,'Unexpected total for Daily Transport ToV');
	 }

	/**
	 * Lilly T-1346
	 * Multiple private transfer itineraries should be combined to give you a SUM of the Individual Travel ToV
	 * ---
	 * [different order of events]
	 * Start Meeting Days with Daily_Ground_Trans_Amount_MERC__c = null
	 * Create multiple private transfer Itineraries (3) with Total_Fare = value for participant 1 for duration of meeting
	 * Set DA/ToV for participant 1 to 'Attended' for each day
	 * Confirm DA/ToVs reflect sum of Total_Fare values
	 **/
	@isTest
	static void groundShouldCaptureMultiplePrivateTransfersOnTovCreate() {
		setup();
		// get a participant
		Meeting_Participant_MERC__c attendee = participants[0];

		// clear initial trans amount
		for (Meeting_Day_MERC__c m : meetingDays) {
			m.Daily_Ground_Trans_Amount_MERC__c = null;
		}
		MERC_TOVCalculator.runIndividualTransferTovCalculation = true;
		update meetingDays;

		attendee = [SELECT Id, Account_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :attendee.Id LIMIT 1];

		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();

		 	// create new travel itineraries of type Car_MERC
			MERC_TOVCalculator.runIndividualTransferTovCalculation = true;
	 		List<Travel_Itinerary_MERC__c> pvtTransfers = insertPrivateTransferItineraries(new List<Meeting_Participant_MERC__c>{attendee},startDate,startDate.addDays(2),3);

			// set participant as "attended"
			MERC_TOVCalculator.runIndividualTransferTovCalculation = true; // why are we resetting this?
			List<Daily_Attendance_TOV_MERC__c> tovs = insertTovs(meetingDays, attendee.Id, 'Attended');

	 	profiler.stopProfiling();
		profiler.debugUsage();
		Test.stopTest();

		Decimal itinerarySum = 0;
		for (Travel_Itinerary_MERC__c ti : pvtTransfers) {
			if (ti.Total_Fare_Amount_MERC__c != null) itinerarySum += ti.Total_Fare_Amount_MERC__c;
		}
		System.assert(itinerarySum>0,'Why is the sum of these fares = '+itinerarySum);

	 	// ground transportation match should be sum of initeraries above
	 	tovs = [SELECT Est_Grnd_Transp_MERC__c 
	 			FROM Daily_Attendance_TOV_MERC__c 
	 			WHERE Meeting_Participant_MERC__c = :attendee.Id AND Meeting_Day_MERC__c in :meetingDays];
		Decimal tovSum = 0;
	 	for (Daily_Attendance_TOV_MERC__c tov : tovs) {
	 		if (tov.Est_Grnd_Transp_MERC__c != null) tovSum += tov.Est_Grnd_Transp_MERC__c;
	 	}

	 	System.assertEquals(itinerarySum,tovSum,'Unexpected total for Daily Transport ToV');
	 }

	/**
	 * T-1376
	 * Group Ground Transportation ToV test
	 * ---
	 * Start Meeting Day 1 with Daily_Ground_Trans_Amount_MERC__c = value
	 * Set DA/ToV for participant 1 to 'Attended' on day 1
	 * Confirm participant has correct Total_Ground_Transporation_ToV_MERC__c
	 **/
	@isTest
	static void groupGroundShouldRollTovUpToParticipant() {
		setup();
		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();

		//set participant 1 to attending on day 1
		Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

		Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Ground_Transporation_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

		tovForParticipant1Day1 = [SELECT Id, Est_Grp_Grnd_Transp_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day1.Id];

		//assert that meeting day 1's food bev estimate rolled up up to the participant total
		System.assertEquals(tovForParticipant1Day1.Est_Grp_Grnd_Transp_MERC__c, participant1.Total_Ground_Transporation_ToV_MERC__c, 'Est_Grp_Grnd_Transp did not rollup as expected.');

		profiler.stopProfiling();
		profiler.debugUsage();
		Test.stopTest();
	}

	/**
	 *  Lilly T-1344
	 *  If a travel itinerary is cancelled the ToV should be reduced accordingly.
	 * 
	 *  Description: Meeting Participant Holger King, Hotel ToV allocated in Mercury although Travel Itinerary 
	 *	was cancelled prior to managing daily attendance and prior to sending ToV and completing the meeting. 
	 *	If the Itinerary is cancelled, the associated ToV should be unallocated.
	 *
	 *	Steps to re-create the defect:
	 *
	 *	1.    Created a new meeting.
	 *	2.    Added meeting participant
	 *	3.    Created travel itinerary for the meeting participant
	 *	4.    Cancelled Travel Itinerary prior to managing daily attendance and prior to sending ToV
	 *	5.    Hotel ToV is still allocated for the HCP in the system
	 **/
	@isTest
	static void hotelShouldAdjustToVWhenItineraryCancelled() {
		setup();

		Date d1 = Date.today();
		Date d2 = d1.addDays(1);

		List<Account> accts = insertAccounts(1);
		List<Meeting_MERC__c> meets = insertMeetings(1, d1, d2);
		List<Meeting_Day_MERC__c> days = insertMeetingDays(meets);
		List<Meeting_Participant_MERC__c> parts = insertParticipants(meets,accts);
		List<Meeting_Vendor_MERC__c> vends = insertHotels(1,meets);
		Hotel_Allocation_MERC__c hotelAllocation = new Hotel_Allocation_MERC__c(
			Meeting_Vendor_MERC__c = vends[0].Id,
			Meeting_Day_MERC__c = days.get(0).Id,
			Total_Rooms_in_Block_MERC__c = 5
		);
		insert hotelAllocation;

		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();
			Travel_Itinerary_MERC__c ti = new Travel_Itinerary_MERC__c();
			ti.RecordTypeId = hotelItineraryRecordTypeId;
			ti.Meeting_Vendor_MERC__c = vends[0].Id;
			ti.Meeting_Participant_MERC__c = parts[0].Id;
			ti.Account_MERC__c = parts[0].Account_MERC__c;
			ti.Sgmnt_Bgin_TS_MERC__c = Datetime.newInstance(d1, Time.newInstance(12, 0, 0, 0));
			ti.Sgmnt_End_TS_MERC__c = Datetime.newInstance(d2, Time.newInstance(15, 0, 0, 0));

				insert ti;

				ti.Status_MERC__c = 'Cancelled';
			update ti;
		profiler.stopProfiling();
		profiler.debugUsage();
		Test.stopTest();

	 	// if ToV not final, value should be null
		Meeting_Participant_MERC__c attendee = [SELECT Id, Total_Hotel_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :parts[0].Id LIMIT 1];
		System.assertEquals(null,attendee.Total_Hotel_ToV_MERC__c,'Unexpected '+attendee.Total_Hotel_ToV_MERC__c+' value for total hotel');
	 }

	/**
	 * When meeting is active (ie. ToV not Final), hotel DA/ToV values should be reflected in participant hotel totals
	 * ---
	 * Start hotel Itinerary with Vendor & Vendor Room Rate = value
	 * Set DA/ToV for participant 1 to 'Attended' for each day
	 * Confirm Room Rate values reflected in DA/ToV & MP Total Hotel
	 * Change DA/ToV Status to 'No Show'
	 * Confirm MP Total Hotel remained the same
	 **/
	@isTest
	static void hotelShouldCalculateOnDailyAttendanceNoShowUpdate() {
		setup();

		//set participant 1 to attending on day 1
		Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = 
									MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

		Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Hotel_ToV_MERC__c
													FROM Meeting_Participant_MERC__c 
													WHERE Id = :participants.get(0).Id];

		tovForParticipant1Day1 = [SELECT Id, Est_Hotel_ToV_MERC__c, Status_MERC__c 
									FROM Daily_Attendance_TOV_MERC__c 
									WHERE Id = :tovForParticipant1Day1.Id];

		//assert that meeting day 1's hotel estimate rolled up to the participant total
		System.assert(participant1.Total_Hotel_ToV_MERC__c>0,'Unexpected value for participant tov: '+participant1.Total_Hotel_ToV_MERC__c);
		System.assertEquals(tovForParticipant1Day1.Est_Hotel_ToV_MERC__c, participant1.Total_Hotel_ToV_MERC__c, 'Unexpected hotel ToV values do not match.');
		Decimal previousValue = participant1.Total_Hotel_ToV_MERC__c;

		//now remove attendance on day 1
		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();
			tovForParticipant1Day1.Status_MERC__c = 'No Show';
			update tovForParticipant1Day1;
		profiler.stopProfiling();
		profiler.debugUsage();
		Test.stopTest();

		participant1 = [SELECT Id, Total_Hotel_ToV_MERC__c
						FROM Meeting_Participant_MERC__c 
						WHERE Id = :participants.get(0).Id];

		//now ensure the rollup did not clear value
		System.assertNotEquals(null, participant1.Total_Hotel_ToV_MERC__c);
		System.assertEquals(previousValue, participant1.Total_Hotel_ToV_MERC__c, 'Unexpected hotel ToV values do not match after status change.');

		tovForParticipant1Day1 = [SELECT Id, Est_Hotel_ToV_MERC__c, Status_MERC__c 
									FROM Daily_Attendance_TOV_MERC__c 
									WHERE Id = :tovForParticipant1Day1.Id];

		//ensure Hotel didn't get erased/changed
		System.assertEquals(tovForParticipant1Day1.Est_Hotel_ToV_MERC__c,previousValue,'Hotel ToV on Daily Attendance has unexpectedly changed.');
	}

	/**
	 * When vendor room rates change, DA/ToV & MP totals should reflect new values
	 * ---
	 * Start hotel Itinerary with Vendor & Vendor Room Rate = value
	 * Set DA/ToV for participant 1 to 'Attended' on day 1
	 * Change Vendor Room Rate to new value
	 * Confirm DA/ToV reflects new value
	 * Confirm MP Total Hotel is adjusted appropriately
	 **/
	@isTest
	static void hotelShouldCalculateRoomRateChange() {
		setup();

		Meeting_Vendor_MERC__c hotel1 = vendors.get(0);

		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();

			//set participant 1 to attending on day 1
			Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

			hotel1.Room_Rate_MERC__c = 666;
			update hotel1;

		profiler.stopProfiling();
		profiler.debugUsage();
		Test.stopTest();

		Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Hotel_ToV_MERC__c, Total_Hours_of_Service_MERC__c, 
														Total_Ground_Transporation_ToV_MERC__c, Total_Registration_ToV_MERC__c, 
														Total_Food_Beverage_ToV_MERC__c 
														FROM Meeting_Participant_MERC__c 
														WHERE Id = :participants.get(0).Id];
		hotel1 = [SELECT Id, Room_Rate_MERC__c FROM Meeting_Vendor_MERC__c WHERE Id = :hotel1.Id];
		tovForParticipant1Day1 = [SELECT Id, Est_Hotel_ToV_MERC__c, Status_MERC__c 
									FROM Daily_Attendance_TOV_MERC__c 
									WHERE Id = :tovForParticipant1Day1.Id];

		//assert that meeting day 1's food bev estimate rolled up up to the participant total
		System.assertNotEquals(hotel1.Room_Rate_MERC__c,null,'Unexpected null value on room rate.');
		System.assertEquals(hotel1.Room_Rate_MERC__c, tovForParticipant1Day1.Est_Hotel_ToV_MERC__c,'tov does not equal new room rate');
		System.assertEquals(hotel1.Room_Rate_MERC__c, participant1.Total_Hotel_ToV_MERC__c,'Participant total hotel does not equal new room rate');
	}

	/**
	 * Lilly T-1344
	 * Itinerary cancellation should clear final ToV
	 * ---
	 * Start hotel Itinerary with Vendor & Vendor Room Rate = value
	 * Set DA/ToV for participant 1 to 'Attended' for each day
	 * Confirm MP Total Hotel reflects initial Vendor Room Rate
	 * Change Meeting Participant ToV to Final
	 * Change all Itineraries to Confirm_ToV_Reporting_Change_MERC__c = true & Status_MERC__c = 'Cancelled'
	 * Confirm DA/ToV has Est_Hotel = 0
	 * Confirm MP Total Hotel = null   (MP rollup has "treat 0 as null" = true)
	 **/
	@isTest
	static void hotelShouldClearFinalToVOnItineraryCancel() {
		setup();

		// get a participant
		Meeting_Participant_MERC__c attendee = participants[0];

		//set attendee to attending.... 
		List<Daily_Attendance_TOV_MERC__c> tovs = insertTovs(meetingDays, attendee.Id, 'Attended');
		attendee = [SELECT Id, Total_Hotel_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :attendee.Id LIMIT 1];
		System.assert(attendee.Total_Hotel_ToV_MERC__c>0,'Unexpected '+attendee.Total_Hotel_ToV_MERC__c+' value for total hotel');

		for (Meeting_MERC__c meet : meetings) {
			meet.Participant_ToV_Final_MERC__c = 'Yes';
		}
		update meetings;

		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();
		 	// Change travel itinerary to "cancelled"
			for (Travel_Itinerary_MERC__c ti : itineraries) {
				ti.Confirm_ToV_Reporting_Change_MERC__c = true;
				ti.Status_MERC__c = 'Cancelled';
			}
				update itineraries;
		profiler.stopProfiling();
		profiler.debugUsage();
		Test.stopTest();

	 	// if ToV final, value should be 0
	 	tovs = [SELECT Est_Hotel_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Meeting_Participant_MERC__c = :attendee.Id];
	 	System.assertEquals(0,tovs[0].Est_Hotel_ToV_MERC__c,'Unexpected '+tovs[0].Est_Hotel_ToV_MERC__c+' value for daily hotel tov');
	 	// MP rollup has "treat 0 as null" = true
		attendee = [SELECT Id, Total_Hotel_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :attendee.Id LIMIT 1];
		System.assertEquals(null,attendee.Total_Hotel_ToV_MERC__c,'Unexpected '+attendee.Total_Hotel_ToV_MERC__c+' value for total hotel');
	 }

	/**
	 * When meeting participant ToV is Final, DA/ToV status updates should not be reflected in participant hotel totals
	 * ---
	 * Start hotel Itinerary with Vendor & Vendor Room Rate = value
	 * Set DA/ToV for participant 1 to 'Attended' on day 1
	 * Confirm Room Rate values reflected in DA/ToV & MP Total Hotel
	 * Change Meeting Participant_ToV_Final = 'Yes'
	 * Change DA/ToV Status to "No Show"
	 * Confirm MP Total Hotel is not null
	 * Confirm MP Total Hotel has not changed
	 * Confirm DA/ToV has not changed
	 **/
	@isTest
	static void hotelShouldNotCalculateOnDailyAttendanceStatusUpdateWhenFinal() {
		setup();

		//set participant 1 to attending on day 1
		Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = 
									MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

		tovForParticipant1Day1 = [SELECT Id, Est_Hotel_ToV_MERC__c, Status_MERC__c 
									FROM Daily_Attendance_TOV_MERC__c 
									WHERE Id = :tovForParticipant1Day1.Id];

		Meeting_Participant_MERC__c participant1 = [SELECT Id, Meeting_MERC__c, Total_Hotel_ToV_MERC__c
													FROM Meeting_Participant_MERC__c 
													WHERE Id = :participants.get(0).Id];

		Decimal previousValue = tovForParticipant1Day1.Est_Hotel_ToV_MERC__c;
		System.assert(previousValue > 0,'Unexpected value for Est_Hotel_ToV during test setup. '+previousValue);

		//assert that meeting day 1's hotel estimate rolled up up to the participant total
		System.assertEquals(previousValue, participant1.Total_Hotel_ToV_MERC__c, 'Unexpected hotel ToV values do not match');

		//set ToV to Final
		Meeting_MERC__c meeting1 = [SELECT Id, Participant_ToV_Final_MERC__c FROM Meeting_MERC__c WHERE Id = :participant1.Meeting_MERC__c];
		meeting1.Participant_ToV_Final_MERC__c = 'Yes';
		update meeting1;

		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();

			//now remove attendance on day 1
			tovForParticipant1Day1.Status_MERC__c = 'No Show';
			tovForParticipant1Day1.Confirm_ToV_Reporting_Change_MERC__c = true;
			update tovForParticipant1Day1;
		
		profiler.stopProfiling();
		profiler.debugUsage();
		Test.stopTest();
		participant1 = [SELECT Id, Total_Hotel_ToV_MERC__c
						FROM Meeting_Participant_MERC__c 
						WHERE Id = :participant1.Id];

		//now ensure the rollup did not clear value
		System.assertNotEquals(null, participant1.Total_Hotel_ToV_MERC__c);
		System.assertEquals(previousValue, participant1.Total_Hotel_ToV_MERC__c, 'Unexpected hotel ToV values do not match after status change.');

		tovForParticipant1Day1 = [SELECT Id, Est_Hotel_ToV_MERC__c, Status_MERC__c 
									FROM Daily_Attendance_TOV_MERC__c 
									WHERE Id = :tovForParticipant1Day1.Id];

		//ensure Hotel didn't get erased/changed
		System.assertEquals(tovForParticipant1Day1.Est_Hotel_ToV_MERC__c,previousValue,'Hotel ToV on Daily Attendance has unexpectedly changed.');
	}

	/**
	 * Lilly T-1344
	 * Itinerary cancellation should clear ToV
	 * ---
	 * Start hotel Itinerary with Vendor & Vendor Room Rate = value
	 * Set DA/ToV for participant 1 to 'Attended' for each day
	 * Confirm MP Total Hotel reflects initial Vendor Room Rate
	 * Change all Itineraries to Status_MERC__c = 'Cancelled'
	 * Confirm DA/ToV has Est_Hotel = null
	 * Confirm MP Total Hotel = null
	 **/
	@isTest
	static void hotelShouldNullifyActiveToVOnItineraryCancel() {
		setup();

		// get a participant
		Meeting_Participant_MERC__c attendee = participants[0];

		//set attendee to attending.... 
		List<Daily_Attendance_TOV_MERC__c> tovs = insertTovs(meetingDays, attendee.Id, 'Attended');
		attendee = [SELECT Id, Total_Hotel_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :attendee.Id LIMIT 1];
		System.assert(attendee.Total_Hotel_ToV_MERC__c>0,'Unexpected '+attendee.Total_Hotel_ToV_MERC__c+' value for total hotel');

		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();
		 	// Change travel itinerary to "cancelled"
			for (Travel_Itinerary_MERC__c ti : itineraries) {
				ti.Status_MERC__c = 'Cancelled';
			}
				update itineraries;
		profiler.stopProfiling();
		profiler.debugUsage();
		Test.stopTest();

	 	// if ToV not final, value should be null
	 	tovs = [SELECT Est_Hotel_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Meeting_Participant_MERC__c = :attendee.Id];
	 	System.assertEquals(null,tovs[0].Est_Hotel_ToV_MERC__c,'Unexpected '+tovs[0].Est_Hotel_ToV_MERC__c+' value for daily hotel tov');
		attendee = [SELECT Id, Total_Hotel_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :attendee.Id LIMIT 1];
		System.assertEquals(null,attendee.Total_Hotel_ToV_MERC__c,'Unexpected '+attendee.Total_Hotel_ToV_MERC__c+' value for total hotel');
	 }

	/**
	 * Lilly T-1344
	 * Itinerary created as "cancelled" should have no ToV
	 * ---
	 * Create Vendor with Vendor Room Rate = value
	 * Create new Itinerary with Vender & Status = 'Cancelled'
	 * Set DA/ToV for participant 1 to 'Attended' for each day
	 * Confirm DA/ToV has Est_Hotel = null
	 * Confirm MP Total Hotel = null
	 **/
	@isTest
	static void hotelShouldOmitUponItineraryInsertAsCancelled() {
		setup();

		Date d = Date.today().addDays(1);

		List<Account> accts = insertAccounts(1);
		List<Meeting_MERC__c> meets = insertMeetings(1, d, d);
		List<Meeting_Day_MERC__c> days = insertMeetingDays(meets);
		List<Meeting_Participant_MERC__c> parts = insertParticipants(meets,accts);
		List<Meeting_Vendor_MERC__c> vends = insertHotels(1,meets);
		Hotel_Allocation_MERC__c hotelAllocation = new Hotel_Allocation_MERC__c(
			Meeting_Vendor_MERC__c = vends[0].Id,
			Meeting_Day_MERC__c = days.get(0).Id,
			Total_Rooms_in_Block_MERC__c = 5
		);
		insert hotelAllocation;

		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();

			Meeting_Participant_MERC__c attendee = parts[0];

		 	// create new travel itinerary with status "cancelled"
			Travel_Itinerary_MERC__c ti = new Travel_Itinerary_MERC__c();
			ti.RecordTypeId = hotelItineraryRecordTypeId;
			ti.Meeting_Vendor_MERC__c = vends[0].Id;
			ti.Meeting_Participant_MERC__c = attendee.Id;
			ti.Account_MERC__c = attendee.Account_MERC__c;
			ti.Sgmnt_Bgin_TS_MERC__c = Datetime.newInstance(d, Time.newInstance(8, 0, 0, 0));
			ti.Sgmnt_End_TS_MERC__c = Datetime.newInstance(d, Time.newInstance(18, 0, 0, 0));
			ti.Status_MERC__c = 'Cancelled';

				insert ti;

		 	// set participant as "attended"
				List<Daily_Attendance_TOV_MERC__c> tovs = insertTovs(days, attendee.Id, 'Attended');
			attendee = [SELECT Id, Total_Hotel_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :attendee.Id LIMIT 1];

		 	// if ToV not final, value should be null
		 	System.assertEquals(1,tovs.size(),'Unexpected # of tov records');
		 	System.assertEquals(null,tovs[0].Est_Hotel_ToV_MERC__c,'Unexpected '+tovs[0].Est_Hotel_ToV_MERC__c+' value for daily hotel tov');
			System.assertEquals(null,attendee.Total_Hotel_ToV_MERC__c,'Unexpected '+attendee.Total_Hotel_ToV_MERC__c+' value for total hotel');

		 	// if ToV final, value should be 0
	 }

	/**
	 * Lilly T-1378
	 * When entering a hotel itinerary for 2 nights, managing daily attendance and then changing 
	 * the check-out date so that only one night remains, Hotel ToV should only reflect remaining dates
	 * ---
	 * Start hotel Itinerary with Vendor & Vendor Room Rate = value
	 * Set DA/ToV for participant 1 to 'Attended' for each day
	 * Confirm MP Total Hotel reflects initial Vendor Room Rate
	 * Change Itineraries from duration of meeting to leaving "early"
	 * Confirm MP Total Hotel was reduced accordingly
	 **/
	@isTest
	static void hotelShouldRecalculateOnDateChange() {
		setup();

		// Set MP to attended.  
		Meeting_Participant_MERC__c attendee = participants[0];
		List<Daily_Attendance_TOV_MERC__c> tovs = insertTovs(meetingDays, attendee.Id, 'Attended');

		// Confirm Hotel ToV
		attendee = [SELECT Id, Account_MERC__c, Total_Hotel_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :attendee.Id LIMIT 1];
		System.assertNotEquals(attendee.Total_Hotel_ToV_MERC__c,null,'Unexpected null value for participant tov.');
		Decimal valueBefore = attendee.Total_Hotel_ToV_MERC__c;
		p('valueBefore: '+valueBefore);

		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();
			// Change Travel Itinerary hotel record to be one night
			List<Travel_Itinerary_MERC__c> changingItineraries = [SELECT Id, Combined_ID_MERC__c, Sgmnt_Bgin_TS_MERC__c, Sgmnt_End_TS_MERC__c FROM Travel_Itinerary_MERC__c WHERE Meeting_Participant_MERC__c = :attendee.Id];
			p('retrieved itineraries: '+changingItineraries);
			for (Travel_Itinerary_MERC__c ti : changingItineraries) {
				ti.Sgmnt_Bgin_TS_MERC__c = Datetime.newInstance(startDate, Time.newInstance(12, 0, 0, 0));
				ti.Sgmnt_End_TS_MERC__c = Datetime.newInstance(startDate.addDays(durationInDays-1), Time.newInstance(15, 0, 0, 0));
			}

			p('starting update: '+changingItineraries);
			update changingItineraries;
			p('update done');
		profiler.stopProfiling();
		profiler.debugUsage();
		Test.stopTest();

		// Hotel ToV should reduced accordingly 
		attendee = [SELECT Id, Account_MERC__c, Total_Hotel_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :attendee.Id LIMIT 1];
		System.assert(attendee.Total_Hotel_ToV_MERC__c < valueBefore,'Did not reduce? before:'+valueBefore+'after:'+attendee.Total_Hotel_ToV_MERC__c);
	 }

	/**
	 * For T#14374 - 
	 * Two itineraries across multiple days for a single participant...
	 * ---
	 * Create hotel Itinerary with Vendor A & Vendor Room Rate = value 1 for Day 1
	 * Create hotel Itinerary with Vendor B & Vendor Room Rate = value 2 for Day 2
	 * Set DA/ToV for participant 1 to 'Attended' for both days
	 * Confirm MP Total Hotel reflects sum of both Vendor Room Rates
	 **/
	@isTest
	static void hotelShouldRollupMultipleItineraries() {
		setup();

		// get a participant
		Meeting_Participant_MERC__c attendee = participants[0];

		//setup hotels
		Meeting_Vendor_MERC__c hotel1 = vendors[0];
		Meeting_Vendor_MERC__c hotel2 = vendors[1];
		hotel1.Room_Rate_MERC__c = 199;
		hotel2.Room_Rate_MERC__c = 1;
		update vendors;

		// clear itineraries to satisfy duplicate value validation check
		delete [SELECT Id, Combined_ID_MERC__c FROM Travel_Itinerary_MERC__c WHERE Meeting_Participant_MERC__c = :attendee.Id];

		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();

			List<Travel_Itinerary_MERC__c> changingItineraries = new List<Travel_Itinerary_MERC__c>();

			// attendee stays at one hotel on Day 1
			Travel_Itinerary_MERC__c ti1 = insertHotelItinerary(attendee, meetingDays.get(0).Date_MERC__c, meetingDays.get(1).Date_MERC__c);
			ti1.Meeting_Vendor_MERC__c = hotel1.Id;
			changingItineraries.add(ti1);
			update ti1;

			// attendee upset; moves to local youth hostel
			Travel_Itinerary_MERC__c ti2 = insertHotelItinerary(attendee, meetingDays.get(1).Date_MERC__c, meetingDays.get(2).Date_MERC__c);
			ti2.Meeting_Vendor_MERC__c = hotel2.Id;
			changingItineraries.add(ti2);
			update ti2;

			//reset the static variable that got turned off during data loads
			MERC_TOVCalculator.runHotelTovCalculation = true;

			//set attendee to attending first two days.... 
			List<String> meetingDayIds = new List<String>();
			meetingDayIds.add(meetingDays.get(0).Id);
			meetingDayIds.add(meetingDays.get(1).Id);
			insertTovs(meetingDayIds, attendee.Id, 'Attended');

		profiler.stopProfiling();
		profiler.debugUsage();
		Test.stopTest();

		attendee = [SELECT Id, Total_Hotel_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :attendee.Id LIMIT 1];
		System.assert(attendee.Total_Hotel_ToV_MERC__c>0,'Unexpected '+attendee.Total_Hotel_ToV_MERC__c+' value for total hotel');
		System.assertEquals(hotel1.Room_Rate_MERC__c + hotel2.Room_Rate_MERC__c, attendee.Total_Hotel_ToV_MERC__c, 'Totals does not match expected sum.');

	}

	/**
	 * For T#14374 - 
	 * Two itineraries across multiple days for a single participant + calculation triggered
	 * by vendor and itinerary change...
	 * ---
	 * Set DA/ToV for participant 1 to 'Attended' for Day 1 & 2 days
	 * Create hotel Itinerary with Vendor A & Vendor Room Rate = value 1 for Day 1
	 * Create hotel Itinerary with Vendor B & Vendor Room Rate = value 2 for Day 2
	 * Change room rates for both Vendors
	 * Confirm DA/ToV Est Hotel reflects new Vendor Room Rates
	 **/
	@isTest
	static void hotelShouldRollupMultipleVendorChange() {
		setup();

		// get a participant
		Meeting_Participant_MERC__c attendee = participants[0];

		// set attendee to attending first two days.... 
		List<String> meetingDayIds = new List<String>();
		meetingDayIds.add(meetingDays.get(0).Id);
		meetingDayIds.add(meetingDays.get(1).Id);
		List<Daily_Attendance_TOV_MERC__c> tovs = insertTovs(meetingDayIds, attendee.Id, 'Attended');
		p('2.Limits:'+Limits.getQueries()+'/'+Limits.getLimitQueries());

		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();

			// clear itineraries to satisfy duplicate value validation check
			delete [SELECT Id, Combined_ID_MERC__c FROM Travel_Itinerary_MERC__c WHERE Meeting_Participant_MERC__c = :attendee.Id];
			List<Travel_Itinerary_MERC__c> hotelItineraries = new List<Travel_Itinerary_MERC__c>();

			Meeting_Vendor_MERC__c hotel1 = vendors[0];
			Meeting_Vendor_MERC__c hotel2 = vendors[1];

			// attendee stays at one hotel on Day 1
			Travel_Itinerary_MERC__c ti1 = new Travel_Itinerary_MERC__c();
			ti1.RecordTypeId = hotelItineraryRecordTypeId;
			ti1.Meeting_Vendor_MERC__c = hotel1.Id;
			ti1.Meeting_Participant_MERC__c = attendee.Id;
			ti1.Account_MERC__c = attendee.Account_MERC__c;
			ti1.Sgmnt_Bgin_TS_MERC__c = Datetime.newInstance(meetingDays.get(0).Date_MERC__c, Time.newInstance(12, 0, 0, 0));
			ti1.Sgmnt_End_TS_MERC__c = Datetime.newInstance(meetingDays.get(1).Date_MERC__c, Time.newInstance(15, 0, 0, 0));
			ti1.Status_MERC__c = 'Confirmed';
			hotelItineraries.add(ti1);

			// attendee upset; moves to local youth hostel
			Travel_Itinerary_MERC__c ti2 = new Travel_Itinerary_MERC__c();
			ti2.RecordTypeId = hotelItineraryRecordTypeId;
			ti2.Meeting_Vendor_MERC__c = hotel2.Id;
			ti2.Meeting_Participant_MERC__c = attendee.Id;
			ti2.Account_MERC__c = attendee.Account_MERC__c;
			ti2.Sgmnt_Bgin_TS_MERC__c = Datetime.newInstance(meetingDays.get(1).Date_MERC__c, Time.newInstance(12, 0, 0, 0));
			ti2.Sgmnt_End_TS_MERC__c = Datetime.newInstance(meetingDays.get(2).Date_MERC__c, Time.newInstance(15, 0, 0, 0));
			ti2.Status_MERC__c = 'Confirmed';
			hotelItineraries.add(ti2);

			MERC_TOVCalculator.runHotelTovCalculation = true;
			insert hotelItineraries;
// TODO: confirm initial room rates

			// change to new room rates
			hotel1.Room_Rate_MERC__c = 199;
			hotel2.Room_Rate_MERC__c = 10;

			MERC_TOVCalculator.runHotelTovCalculation = true;
			update vendors;

		profiler.stopProfiling();
		profiler.debugUsage();
		Test.stopTest();

		Daily_Attendance_TOV_MERC__c day1 = [SELECT Id, Est_Hotel_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovs[0].Id LIMIT 1];
		Daily_Attendance_TOV_MERC__c day2 = [SELECT Id, Est_Hotel_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovs[1].Id LIMIT 1];
		System.assertNotEquals(null,day1.Est_Hotel_ToV_MERC__c, 'Unexpected null value for day1');
		System.assertNotEquals(null,day2.Est_Hotel_ToV_MERC__c, 'Unexpected null value for day2');
		System.assertEquals(hotel1.Room_Rate_MERC__c + hotel2.Room_Rate_MERC__c, day1.Est_Hotel_ToV_MERC__c + day2.Est_Hotel_ToV_MERC__c, 
											'Totals do not match expected sum. day1='+ day1.Est_Hotel_ToV_MERC__c +'+day2='+ day2.Est_Hotel_ToV_MERC__c);
	}

	/**
	 * T-1376
	 * Individual Travel ToV test
	 * ---
	 * Start Meeting Day 1 with Daily_Ground_Trans_Amount_MERC__c = value
	 * Set DA/ToV for participant 1 to 'Attended' on day 1
	 * Confirm participant has correct Total_Individual_Transport_ToV_MERC__c
	 **/
	@isTest
	static void individualTransferShouldRollTovUpToParticipant() {
		setup();

		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();

		//set participant 1 to attending on day 1
		Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');
		tovForParticipant1Day1.Est_Indv_Transfer_MERC__c = 99;
		update tovForParticipant1Day1;

		Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Individual_Transport_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

		//assert that meeting day 1's food bev estimate rolled up up to the participant total
		System.assertEquals(tovForParticipant1Day1.Est_Indv_Transfer_MERC__c, participant1.Total_Individual_Transport_ToV_MERC__c, 'Est_Indv_Transfer did not rollup as expected.');

		profiler.stopProfiling();
		profiler.debugUsage();
		Test.stopTest();
	}

	@isTest
	static void individualTransferShouldCaptureMultiplePrivateTransfers() {
		setup();

		// get a participant
		Meeting_Participant_MERC__c attendee = participants[0];

		// clear initial trans amount
		for (Meeting_Day_MERC__c m : meetingDays) {
			m.Daily_Ground_Trans_Amount_MERC__c = null;
		}
		MERC_TOVCalculator.runIndividualTransferTovCalculation = true;
		update meetingDays;

		attendee = [SELECT Id, Account_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :attendee.Id LIMIT 1];

		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();

		 	// create new travel itineraries of type Car_MERC
			MERC_TOVCalculator.runIndividualTransferTovCalculation = true;
	 		List<Travel_Itinerary_MERC__c> pvtTransfers = insertPrivateTransferItineraries(new List<Meeting_Participant_MERC__c>{attendee},startDate,startDate,3);
	 		pvtTransfers.addAll(insertPrivateTransferItineraries(new List<Meeting_Participant_MERC__c>{attendee},startDate.addDays(1),startDate.addDays(1),3));

p('start');
			// set participant as "attended"
			MERC_TOVCalculator.runIndividualTransferTovCalculation = true; // why are we resetting this?
			List<Daily_Attendance_TOV_MERC__c> tovs = insertTovs(meetingDays, attendee.Id, 'Attended');
p('finish');
	 	profiler.stopProfiling();
		profiler.debugUsage();
		Test.stopTest();

		Decimal itinerarySum = 0;
		for (Travel_Itinerary_MERC__c ti : pvtTransfers) {
			if (ti.Total_Fare_Amount_MERC__c != null) itinerarySum += ti.Total_Fare_Amount_MERC__c;
		}
		System.assert(itinerarySum>0,'Why is the sum of these fares = '+itinerarySum);

	 	// Individual Travel ToV should be sum of initeraries above
	 	tovs = [SELECT Est_Indv_Transfer_MERC__c 
	 			FROM Daily_Attendance_TOV_MERC__c 
	 			WHERE Meeting_Participant_MERC__c = :attendee.Id AND Meeting_Day_MERC__c in :meetingDays];
		Decimal tovSum = 0;
	 	for (Daily_Attendance_TOV_MERC__c tov : tovs) {
	 		if (tov.Est_Indv_Transfer_MERC__c != null) tovSum += tov.Est_Indv_Transfer_MERC__c;
	 	}

	 	System.assertEquals(itinerarySum,tovSum,'Unexpected total for Daily Transport ToV');
	}

	@isTest
	static void groundShouldCaptureMultipleDailyPrivateTransfersOnItineraryCreateBulk() {

		MERC_TriggerHandlerStateManager.deactivateAll();
		MERC_TriggerHandlerStateManager.activate(MERC_TOVCalculator.class);

		MERC_TestFactory.loadDeclarativeRollupNonAggregateSummaries();

		// MERC_TestFactory has some bugs. Until this is cleaned up, data factory methods moved within class...
		startDate = Date.today();
		durationInDays = 3;
		Date endDate = startDate.addDays(durationInDays);

		accounts = insertAccounts(4);
		meetings = insertMeetings(1,startDate,endDate);
		meetingDays = insertMeetingDays(meetings);
		participants = insertParticipants(meetings,accounts);
		vendors = insertHotels(2,meetings);
		itineraries = insertHotelItineraries(participants,startDate,endDate,vendors[0]);

		MERC_TOVCalculator.runHotelTovCalculation = true;

		p('1.Limits:'+Limits.getQueries()+'/'+Limits.getLimitQueries());
	
		List<String> attendeeIds = new List<String>();
		for(Meeting_Participant_MERC__c participant : participants){
			attendeeIds.add(participant.Id);
		}

		// clear initial trans amount
		for (Meeting_Day_MERC__c m : meetingDays) {
			m.Daily_Ground_Trans_Amount_MERC__c = null;
		}
		update meetingDays;

		// set participant as "attended"
		List<Daily_Attendance_TOV_MERC__c> tovs = insertTovs(meetingDays, attendeeIds, 'Attended');
		participants = [SELECT Id, Account_MERC__c FROM Meeting_Participant_MERC__c WHERE Id in :attendeeIds];

		Test.startTest();
		MERC_ApexProfiler profiler = new MERC_ApexProfiler();
		profiler.startProfiling();
		 	// create new travel itineraries of type Car_MERC
			MERC_TOVCalculator.runIndividualTransferTovCalculation = true;
	 		List<Travel_Itinerary_MERC__c> pvtTransfers = insertDailyPrivateTransferItineraries(participants,startDate,startDate.addDays(durationInDays));
	 	profiler.stopProfiling();
		profiler.debugUsage();
		Test.stopTest();

		Decimal itinerarySum = 0;
		for (Travel_Itinerary_MERC__c ti : pvtTransfers) {
			if (ti.Total_Fare_Amount_MERC__c != null) itinerarySum += ti.Total_Fare_Amount_MERC__c;
		}
		System.assert(itinerarySum>0,'Why is the sum of these fares = '+itinerarySum);

	 	// ground transportation match should be sum of initeraries above
	 	tovs = [SELECT Est_Grnd_Transp_MERC__c 
	 			FROM Daily_Attendance_TOV_MERC__c 
	 			WHERE Meeting_Participant_MERC__c in :attendeeIds AND Meeting_Day_MERC__c in :meetingDays];
		Decimal tovSum = 0;
	 	for (Daily_Attendance_TOV_MERC__c tov : tovs) {
	 		if (tov.Est_Grnd_Transp_MERC__c != null) tovSum += tov.Est_Grnd_Transp_MERC__c;
	 	}

	 	System.assertEquals(itinerarySum,tovSum,'Unexpected total for Daily Transport ToV');
	}

/***** ============================   Data setup methods   ============================ *****/
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

	static Travel_Itinerary_MERC__c insertHotelItinerary(Meeting_Participant_MERC__c mp, Date start_date, Date end_date) {
		return insertHotelItineraries(new List<Meeting_Participant_MERC__c>{mp}, start_date, end_date, null)[0];
	}
	static Travel_Itinerary_MERC__c insertHotelItinerary(Meeting_Participant_MERC__c mp, Date start_date, Date end_date, Meeting_Vendor_MERC__c hotel) {
		return insertHotelItineraries(new List<Meeting_Participant_MERC__c>{mp}, start_date, end_date, hotel)[0];
	}
	static List<Travel_Itinerary_MERC__c> insertHotelItineraries(List<Meeting_Participant_MERC__c> mps, Date start_date, Date end_date, Meeting_Vendor_MERC__c hotel) {
		List<Travel_Itinerary_MERC__c> hotelItineraries = new List<Travel_Itinerary_MERC__c>();
		for (Meeting_Participant_MERC__c mp : mps) {
			Travel_Itinerary_MERC__c ti = new Travel_Itinerary_MERC__c();
			ti.RecordTypeId = hotelItineraryRecordTypeId;
			if (hotel!=null) ti.Meeting_Vendor_MERC__c = hotel.Id;
			ti.Meeting_Participant_MERC__c = mp.Id;
			ti.Account_MERC__c = mp.Account_MERC__c;
			ti.Sgmnt_Bgin_TS_MERC__c = Datetime.newInstance(start_date, Time.newInstance(12, 0, 0, 0));
			ti.Sgmnt_End_TS_MERC__c = Datetime.newInstance(end_date, Time.newInstance(15, 0, 0, 0));
			ti.Status_MERC__c = 'Confirmed';
			hotelItineraries.add(ti);
		}
		insert hotelItineraries;
		return hotelItineraries;
	}

	static List<Travel_Itinerary_MERC__c> insertPrivateTransferItineraries(List<Meeting_Participant_MERC__c> mps, Date start_date, Date end_date) {
		return insertPrivateTransferItineraries(mps, start_date, end_date, 1);
	}
	static List<Travel_Itinerary_MERC__c> insertPrivateTransferItineraries(List<Meeting_Participant_MERC__c> mps, Date start_date, Date end_date, Integer numOfRecords) {
		List<Travel_Itinerary_MERC__c> ptItineraries = new List<Travel_Itinerary_MERC__c>();
		for (Integer i=0; i<numOfRecords; i++) {
			for (Meeting_Participant_MERC__c mp : mps) {
				Travel_Itinerary_MERC__c ti = new Travel_Itinerary_MERC__c();
				ti.RecordTypeId = rentalCarRecordTypeId;
				ti.Individual_Travel_ToV_Applicable_MERC__c = true;
				ti.Total_Fare_Amount_MERC__c = 99;
				ti.Meeting_Participant_MERC__c = mp.Id;
				ti.Account_MERC__c = mp.Account_MERC__c;
				ti.Sgmnt_Bgin_TS_MERC__c = Datetime.newInstance(start_date, Time.newInstance(8, 0, 0, 0));
				ti.Sgmnt_End_TS_MERC__c = Datetime.newInstance(end_date, Time.newInstance(18, 0, 0, 0));
				ti.Status_MERC__c = 'Confirmed';
				ptItineraries.add(ti);
			}
		}
		insert ptItineraries;
		return ptItineraries;
	}
	static List<Travel_Itinerary_MERC__c> insertDailyPrivateTransferItineraries(List<Meeting_Participant_MERC__c> mps, Date start_date, Date end_date) {
		List<Travel_Itinerary_MERC__c> ptItineraries = new List<Travel_Itinerary_MERC__c>();
		for (Date this_date = start_date; this_date.daysBetween(end_date)>-1; this_date = this_date.addDays(1)) {
			for (Meeting_Participant_MERC__c mp : mps) {
				Travel_Itinerary_MERC__c ti = new Travel_Itinerary_MERC__c();
				ti.RecordTypeId = rentalCarRecordTypeId;
				ti.Individual_Travel_ToV_Applicable_MERC__c = true;
				ti.Total_Fare_Amount_MERC__c = 99;
				ti.Meeting_Participant_MERC__c = mp.Id;
				ti.Account_MERC__c = mp.Account_MERC__c;
				ti.Sgmnt_Bgin_TS_MERC__c = Datetime.newInstance(this_date, Time.newInstance(8, 0, 0, 0));
				ti.Sgmnt_End_TS_MERC__c = Datetime.newInstance(this_date, Time.newInstance(18, 0, 0, 0));
				ti.Status_MERC__c = 'Confirmed';
				ptItineraries.add(ti);
			}
		}
		insert ptItineraries;
		return ptItineraries;
	}

	// combined to manage SOQL limits

	static List<Daily_Attendance_TOV_MERC__c> insertTovs(List<Meeting_Day_MERC__c> listOfDays, List<String> meetingParticipantIds, String status) {
		List<String> meetingDayIds = new List<String>();
		for (Meeting_Day_MERC__c day : listOfDays) meetingDayIds.add(day.Id);
		return insertTovs(meetingDayIds, meetingParticipantIds, status);
	}

	static List<Daily_Attendance_TOV_MERC__c> insertTovs(List<Meeting_Day_MERC__c> listOfDays, String meetingParticipantId, String status) {
		List<String> meetingDayIds = new List<String>();
		for (Meeting_Day_MERC__c day : listOfDays) meetingDayIds.add(day.Id);
		return insertTovs(meetingDayIds, meetingParticipantId, status);
	}

	static List<Daily_Attendance_TOV_MERC__c> insertTovs(List<String> meetingDayIds, String meetingParticipantId, String status) {
		return insertTovs(meetingDayIds, new List<String>{meetingParticipantId}, status);
	}

	static List<Daily_Attendance_TOV_MERC__c> insertTovs(List<String> meetingDayIds, List<String> meetingParticipantIds, String status) {
		List<Daily_Attendance_TOV_MERC__c> result = new List<Daily_Attendance_TOV_MERC__c>();
		for(String meetingParticipantId : meetingParticipantIds){
			for (String id : meetingDayIds) {
				Daily_Attendance_TOV_MERC__c tov = new Daily_Attendance_TOV_MERC__c();
				tov.Meeting_Day_MERC__c = id;
				tov.Meeting_Participant_MERC__c = meetingParticipantId;
				tov.Status_MERC__c = status;
				result.add(tov);			
			}
		}
		insert result;
		return result;
	}

	static void p(String m) {
		System.debug(LoggingLevel.WARN,'\n\n\nYYZ - '+m+'\n\n\n\n');
	}
}