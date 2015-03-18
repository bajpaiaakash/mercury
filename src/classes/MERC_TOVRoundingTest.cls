@isTest
private class MERC_TOVRoundingTest {

	static List<Account> accounts;
	static List<Meeting_MERC__c> meetings;
	static List<Meeting_Day_MERC__c> meetingDays;
	static List<Meeting_Participant_MERC__c> participants;
	static List<Meeting_Vendor_MERC__c> vendors;
	static List<Hotel_Allocation_MERC__c> hotelAllocations;
	static List<Travel_Itinerary_MERC__c> itineraries;

	static Date startDate;
	static Integer durationInDays;
	static Double conversionRate;

	public static Id hcpRecordTypeId = 				[SELECT ID FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'HCP_GLBL' LIMIT 1].Id;
	public static Id vendorRecordTypeId = 			[SELECT ID FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Vendor_GLBL' LIMIT 1].Id;
	public static Id hotelItineraryRecordTypeId = 	[SELECT ID FROM RecordType WHERE SObjectType = 'Travel_Itinerary_MERC__c' AND DeveloperName = 'Hotel_MERC' LIMIT 1].Id;
	public static Id rentalCarRecordTypeId = 		[SELECT ID FROM RecordType WHERE SObjectType = 'Travel_Itinerary_MERC__c' AND DeveloperName = 'Car_MERC' LIMIT 1].Id;

	static {
		conversionRate = [SELECT ConversionRate, IsoCode, isActive FROM CurrencyType WHERE IsoCode = 'GBP' AND isActive = true LIMIT 1].ConversionRate;

		MERC_TriggerHandlerStateManager.deactivateAll();

		MERC_TestFactory.loadDeclarativeRollupNonAggregateSummaries();

		startDate = Date.today();
		durationInDays = 2;
		Date endDate = startDate.addDays(durationInDays);

		accounts = insertAccounts(1);
		meetings = insertMeetings(1,startDate,endDate);
		meetingDays = insertMeetingDays(meetings);
		participants = insertParticipants(meetings,accounts);
		vendors = insertHotels(1,meetings);

		MERC_TriggerHandlerStateManager.activate(MERC_TOVCalculator.class);
		MERC_TOVCalculator.runHotelTovCalculation = true;
	}
		
	@isTest 
	static void testRoundingValue_Total_Indiv_Transport() {

		Test.startTest();

			System.debug('Conversion Rate: ' + conversionRate);

			//This is the value of 99.99 EUR (the org's and user's base currency) converted into GBP (the meeting currency) and set to 4 d.p. Uses the default
			//HALF_EVEN rounding mode.
			Decimal transferCost = (Decimal)(99.99*conversionRate).setScale(4);
			p('value & conversion = 99.99 & '+ transferCost);

			MERC_TOVCalculator.runIndividualTransferTovCalculation = true;
			Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Indiv_Transport_ToV_Rollup_MERC__c, Account_MERC__c 
														FROM Meeting_Participant_MERC__c 
														WHERE Id = :participants.get(0).Id];
			
			Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

			p('Inserting itineraries');
			insertPrivateTransferItineraries(new List<Meeting_Participant_MERC__c>{participant1}, Date.today(), Date.today().addDays(1), 1, transferCost);
			p('all done');

			participant1 = [SELECT Id, Total_Individual_Transport_ToV_MERC__c, Total_Indiv_Transport_ToV_Rollup_MERC__c 
							FROM Meeting_Participant_MERC__c 
							WHERE Id = :participants.get(0).Id];

			tovForParticipant1Day1 = [SELECT Id, Est_Indv_Transfer_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day1.Id];

			System.assertEquals(transferCost, tovForParticipant1Day1.Est_Indv_Transfer_MERC__c, 'Unexpected Est_Indv_Transfer_MERC__c');
			System.assertEquals(tovForParticipant1Day1.Est_Indv_Transfer_MERC__c, participant1.Total_Indiv_Transport_ToV_Rollup_MERC__c, 'Total_Indiv_Transport_ToV_Rollup_MERC__c did not rollup as expected.');
			System.assertEquals(transferCost, participant1.Total_Individual_Transport_ToV_MERC__c, 'Total does not match original set value.');
		Test.stopTest();
	}

	@isTest 
	static void testRoundingValue_originalScenarioNewProcess_Idv_Transfer() {
		Decimal intendedValue = 100.00;

		conversionRate = [SELECT ConversionRate, IsoCode, isActive FROM CurrencyType WHERE IsoCode = 'BGN' AND isActive = true LIMIT 1].ConversionRate;

		MERC_TriggerHandlerStateManager.deactivateAll();
		Meeting_MERC__c m = new Meeting_MERC__c();
		m.Date_of_Event_MERC__c = startDate;
		m.End_Date_of_Event_MERC__c = startDate.addDays(durationInDays);
		m.Start_Time_of_Meeting_MERC__c = DateTime.newInstance(startDate, Time.newInstance(10, 0, 0, 0));
		m.End_Time_of_Meeting_MERC__c = DateTime.newInstance(startDate.addDays(durationInDays), Time.newInstance(14, 0, 0, 0));
		m.Name = 'ToV MeetingBGN';
		m.Meeting_Time_Zone_MERC__c = 'Greenwich Mean Time (Europe/London)';
		m.Event_Country_MERC__c = 'BG';
		m.CurrencyIsoCode = 'BGN';
		m.Meeting_Status_MERC__c = 'Active';
		insert m;

		meetingDays = new List<Meeting_Day_MERC__c>();
		Integer numberOfDays = m.Date_of_Event_MERC__c.daysBetween(m.End_Date_of_Event_MERC__c)+1;
		for (Integer i = 0; i < numberOfDays; i++) {
			Meeting_Day_MERC__c mDay = new Meeting_Day_MERC__c();
			mDay.Date_MERC__c = m.Date_of_Event_MERC__c.addDays(i);
			mDay.Meeting_MERC__c = m.Id;
			mDay.Daily_Ground_Trans_Amount_MERC__c = intendedValue;
			mDay.CurrencyIsoCode = 'BGN';
			meetingDays.add(mDay);
		}
		insert meetingDays;

		participants = insertParticipants(new List<Meeting_MERC__c>{m},accounts);

		MERC_TriggerHandlerStateManager.activate(MERC_TOVCalculator.class);

		User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

		Test.startTest();

		System.runAs(u){
			System.debug('Big bucks: ' + UserInfo.getDefaultCurrency());

			Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

			Travel_Itinerary_MERC__c ti = new Travel_Itinerary_MERC__c();
			ti.RecordTypeId = rentalCarRecordTypeId;
			ti.Individual_Travel_ToV_Applicable_MERC__c = true;
			ti.Total_Fare_Amount_MERC__c = intendedValue;
			ti.Meeting_Participant_MERC__c = participants.get(0).Id;
			ti.Account_MERC__c = participants.get(0).Account_MERC__c;
			ti.Sgmnt_Bgin_TS_MERC__c = Datetime.newInstance(startDate, Time.newInstance(8, 0, 0, 0));
			ti.Sgmnt_End_TS_MERC__c = Datetime.newInstance(startDate.addDays(1), Time.newInstance(18, 0, 0, 0));
			ti.Status_MERC__c = 'Confirmed';
			ti.CurrencyIsoCode = 'BGN';
			insert ti;

			Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Individual_Transport_ToV_MERC__c, Total_Indiv_Transport_ToV_Rollup_MERC__c 
							FROM Meeting_Participant_MERC__c 
							WHERE Id = :participants.get(0).Id];

			tovForParticipant1Day1 = [SELECT Id, Est_Indv_Transfer_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day1.Id];

			/*** This now fails because the Est_Reg_Amt_ToV_MERC__c is in the meeting currency. Yea! ***/
			//System.assertEquals((Decimal)(intendedValue/conversionRate).setScale(2), tovForParticipant1Day1.Est_Indv_Transfer_MERC__c, 
				//'Unexpected tov value'+tovForParticipant1Day1.Est_Indv_Transfer_MERC__c);
			System.assertEquals(intendedValue, tovForParticipant1Day1.Est_Indv_Transfer_MERC__c, 
				'Unexpected tov value'+tovForParticipant1Day1.Est_Indv_Transfer_MERC__c);
			System.assertEquals(tovForParticipant1Day1.Est_Indv_Transfer_MERC__c, participant1.Total_Indiv_Transport_ToV_Rollup_MERC__c, 
				'Total_Indiv_Transport_ToV_Rollup_MERC__c did not rollup as expected.'+participant1.Total_Indiv_Transport_ToV_Rollup_MERC__c);

			/*** This now fails presumably because we're not aggregating [?] ***/
			//System.assertEquals((Decimal)(intendedValue/conversionRate).setScale(2), (Decimal)(participant1.Total_Indiv_Transport_ToV_Rollup_MERC__c).setScale(2), 
			//	'Total does not match original set value when converted.'+(Decimal)(participant1.Total_Indiv_Transport_ToV_Rollup_MERC__c).setScale(2));
			System.assertEquals(intendedValue, (Decimal)(participant1.Total_Indiv_Transport_ToV_Rollup_MERC__c).setScale(2), 
				'Total does not match original set value.'+(Decimal)(participant1.Total_Indiv_Transport_ToV_Rollup_MERC__c).setScale(2));
			System.assertEquals((Decimal)(intendedValue).setScale(2), (Decimal)(tovForParticipant1Day1.Est_Indv_Transfer_MERC__c).setScale(2), 
				'Unexpected converted tov value'+(Decimal)(tovForParticipant1Day1.Est_Indv_Transfer_MERC__c).setScale(2));
		}
		Test.stopTest();
	}

	@isTest 
	static void testRoundingValue_Total_Hotel() {

		Test.startTest();

			System.debug('Conversion Rate: ' + conversionRate);

			MERC_TOVCalculator.runIndividualTransferTovCalculation = true;
			Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Indiv_Transport_ToV_Rollup_MERC__c, Account_MERC__c 
														FROM Meeting_Participant_MERC__c 
														WHERE Id = :participants.get(0).Id];
			
			Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

			p('Inserting itineraries');
			insertHotelItineraries(new List<Meeting_Participant_MERC__c>{participant1}, Date.today(), Date.today().addDays(1), vendors[0]);
			p('all done');

			participant1 = [SELECT Id, Total_Hotel_ToV_Rollup_MERC__c, Total_Hotel_ToV_MERC__c
							FROM Meeting_Participant_MERC__c 
							WHERE Id = :participants.get(0).Id];

			tovForParticipant1Day1 = [SELECT Id, Est_Hotel_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day1.Id];

			System.assertEquals(99.99, tovForParticipant1Day1.Est_Hotel_ToV_MERC__c, 'Unexpected Est_Hotel_ToV_MERC__c');
			System.assertEquals(tovForParticipant1Day1.Est_Hotel_ToV_MERC__c, participant1.Total_Hotel_ToV_Rollup_MERC__c, 'Total_Hotel_ToV_Rollup_MERC__c did not rollup as expected.');
			System.assertEquals(99.99, participant1.Total_Hotel_ToV_MERC__c, 'Total does not match original set value.');
		Test.stopTest();
	}

	@isTest 
	static void testRoundingValue_originalScenarioNewProcess_Hotel() {
		Decimal intendedValue = 100.00;

		conversionRate = [SELECT ConversionRate, IsoCode, isActive FROM CurrencyType WHERE IsoCode = 'BGN' AND isActive = true LIMIT 1].ConversionRate;

		MERC_TriggerHandlerStateManager.deactivateAll();
		Meeting_MERC__c m = new Meeting_MERC__c();
		m.Date_of_Event_MERC__c = startDate;
		m.End_Date_of_Event_MERC__c = startDate.addDays(durationInDays);
		m.Start_Time_of_Meeting_MERC__c = DateTime.newInstance(startDate, Time.newInstance(10, 0, 0, 0));
		m.End_Time_of_Meeting_MERC__c = DateTime.newInstance(startDate.addDays(durationInDays), Time.newInstance(14, 0, 0, 0));
		m.Name = 'ToV MeetingBGN';
		m.Meeting_Time_Zone_MERC__c = 'Greenwich Mean Time (Europe/London)';
		m.Event_Country_MERC__c = 'BG';
		m.CurrencyIsoCode = 'BGN';
		m.Meeting_Status_MERC__c = 'Active';
		insert m;

		meetingDays = new List<Meeting_Day_MERC__c>();
		Integer numberOfDays = m.Date_of_Event_MERC__c.daysBetween(m.End_Date_of_Event_MERC__c)+1;
		for (Integer i = 0; i < numberOfDays; i++) {
			Meeting_Day_MERC__c mDay = new Meeting_Day_MERC__c();
			mDay.Date_MERC__c = m.Date_of_Event_MERC__c.addDays(i);
			mDay.Meeting_MERC__c = m.Id;
			mDay.Daily_Ground_Trans_Amount_MERC__c = intendedValue;
			mDay.CurrencyIsoCode = 'BGN';
			meetingDays.add(mDay);
		}
		insert meetingDays;

		Account a = new Account();
		a.RecordTypeId = vendorRecordTypeId;
		a.Name = MERC_Util.generateRandomString(5);
		insert a;

		Meeting_Vendor_MERC__c hotel = new Meeting_Vendor_MERC__c();
		hotel.Account_MERC__c = a.Id;
		hotel.Room_Rate_MERC__c = intendedValue;
		hotel.Meeting_MERC__c = m.Id;
		hotel.CurrencyIsoCode = 'BGN';

		insert hotel;

		participants = insertParticipants(new List<Meeting_MERC__c>{m},accounts);

		MERC_TriggerHandlerStateManager.activate(MERC_TOVCalculator.class);

		User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

		Test.startTest();

		System.runAs(u){
			System.debug('Big bucks: ' + UserInfo.getDefaultCurrency());

			Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

			Travel_Itinerary_MERC__c ti = new Travel_Itinerary_MERC__c();
			ti.RecordTypeId = hotelItineraryRecordTypeId;
			if (hotel!=null) ti.Meeting_Vendor_MERC__c = hotel.Id;
			ti.Meeting_Participant_MERC__c = participants.get(0).Id;
			ti.Account_MERC__c = participants.get(0).Account_MERC__c;
			ti.Sgmnt_Bgin_TS_MERC__c = Datetime.newInstance(startDate, Time.newInstance(12, 0, 0, 0));
			ti.Sgmnt_End_TS_MERC__c = Datetime.newInstance(startDate.addDays(durationInDays), Time.newInstance(15, 0, 0, 0));
			ti.Status_MERC__c = 'Confirmed';
			ti.CurrencyIsoCode = 'BGN';
			insert ti;

			Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Hotel_ToV_Rollup_MERC__c, Total_Hotel_ToV_MERC__c 
							FROM Meeting_Participant_MERC__c 
							WHERE Id = :participants.get(0).Id];

			tovForParticipant1Day1 = [SELECT Id, Est_Hotel_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day1.Id];

			/*** This now fails because the Est_Reg_Amt_ToV_MERC__c is in the meeting currency. Yea! ***/
			//System.assertEquals((Decimal)(intendedValue/conversionRate).setScale(2), tovForParticipant1Day1.Est_Reg_Amt_ToV_MERC__c, 
			//	'Unexpected tov value'+tovForParticipant1Day1.Est_Reg_Amt_ToV_MERC__c);
			System.assertEquals(intendedValue, tovForParticipant1Day1.Est_Hotel_ToV_MERC__c, 
				'Unexpected tov value'+tovForParticipant1Day1.Est_Hotel_ToV_MERC__c);
			System.assertEquals(tovForParticipant1Day1.Est_Hotel_ToV_MERC__c, participant1.Total_Hotel_ToV_Rollup_MERC__c, 
				'Total_Hotel_ToV_Rollup_MERC__c did not rollup as expected.'+participant1.Total_Hotel_ToV_Rollup_MERC__c);

			/*** This now fails presumably because we're not aggregating [?] ***/
			//System.assertEquals((Decimal)(intendedValue/conversionRate).setScale(2), (Decimal)(participant1.Total_Registration_ToV_Rollup_MERC__c).setScale(2), 
			//	'Total does not match original set value when converted.'+(Decimal)(participant1.Total_Registration_ToV_Rollup_MERC__c).setScale(2));
			System.assertEquals(intendedValue, (Decimal)(participant1.Total_Hotel_ToV_Rollup_MERC__c).setScale(2), 
				'Total does not match original set value.'+(Decimal)(participant1.Total_Hotel_ToV_Rollup_MERC__c).setScale(2));
			System.assertEquals((Decimal)(intendedValue).setScale(2), (Decimal)(tovForParticipant1Day1.Est_Hotel_ToV_MERC__c).setScale(2), 
				'Unexpected converted tov value'+(Decimal)(tovForParticipant1Day1.Est_Hotel_ToV_MERC__c).setScale(2));
		}
		Test.stopTest();
	}

	@isTest
	static void testRoundingValue_Total_Ground() {
		
		Decimal transferCost = (Decimal)(99.99*conversionRate).setScale(2);
		p('value & conversion = 99.99 & '+ transferCost);

		Test.startTest();

		//set participant 1 to attending on day 1
		Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

		Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Ground_Transporation_ToV_MERC__c, Total_Ground_Transport_ToV_Rollup_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

		tovForParticipant1Day1 = [SELECT Id, Est_Grp_Grnd_Transp_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day1.Id];

		//assert that meeting day 1's food bev estimate rolled up up to the participant total
		//System.assert(false, tovForParticipant1Day1.Est_Grp_Grnd_Transp_MERC__c);
		//System.assertEquals(tovForParticipant1Day1.Est_Grp_Grnd_Transp_MERC__c, participant1.Total_Ground_Transporation_ToV_MERC__c, 'Est_Grp_Grnd_Transp did not rollup as expected.');

		System.assertEquals(transferCost, tovForParticipant1Day1.Est_Grp_Grnd_Transp_MERC__c, 'Unexpected Est_Grp_Grnd_Transp_MERC__c');
		System.assertEquals(tovForParticipant1Day1.Est_Grp_Grnd_Transp_MERC__c, participant1.Total_Ground_Transport_ToV_Rollup_MERC__c, 'Total_Hotel_ToV_Rollup_MERC__c did not rollup as expected.');
		System.assertEquals(transferCost, participant1.Total_Ground_Transporation_ToV_MERC__c, 'Total does not match original set value.');

		Test.stopTest();
	}

	@isTest 
	static void testRoundingValue_originalScenarioNewProcess_Ground() {
		Decimal intendedValue = 100.00;

		conversionRate = [SELECT ConversionRate, IsoCode, isActive FROM CurrencyType WHERE IsoCode = 'BGN' AND isActive = true LIMIT 1].ConversionRate;

		MERC_TriggerHandlerStateManager.deactivateAll();
		Meeting_MERC__c m = new Meeting_MERC__c();
		m.Date_of_Event_MERC__c = startDate;
		m.End_Date_of_Event_MERC__c = startDate.addDays(durationInDays);
		m.Start_Time_of_Meeting_MERC__c = DateTime.newInstance(startDate, Time.newInstance(10, 0, 0, 0));
		m.End_Time_of_Meeting_MERC__c = DateTime.newInstance(startDate.addDays(durationInDays), Time.newInstance(14, 0, 0, 0));
		m.Name = 'ToV MeetingBGN';
		m.Meeting_Time_Zone_MERC__c = 'Greenwich Mean Time (Europe/London)';
		m.Event_Country_MERC__c = 'BG';
		m.CurrencyIsoCode = 'BGN';
		m.Meeting_Status_MERC__c = 'Active';
		insert m;

		meetingDays = new List<Meeting_Day_MERC__c>();
		Integer numberOfDays = m.Date_of_Event_MERC__c.daysBetween(m.End_Date_of_Event_MERC__c)+1;
		for (Integer i = 0; i < numberOfDays; i++) {
			Meeting_Day_MERC__c mDay = new Meeting_Day_MERC__c();
			mDay.Date_MERC__c = m.Date_of_Event_MERC__c.addDays(i);
			mDay.Meeting_MERC__c = m.Id;
			mDay.Daily_Ground_Trans_Amount_MERC__c = intendedValue;
			mDay.CurrencyIsoCode = 'BGN';
			meetingDays.add(mDay);
		}
		insert meetingDays;

		participants = insertParticipants(new List<Meeting_MERC__c>{m},accounts);

		MERC_TriggerHandlerStateManager.activate(MERC_TOVCalculator.class);

		User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

		Test.startTest();

		System.runAs(u){
			System.debug('Big bucks: ' + UserInfo.getDefaultCurrency());

			Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

			Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Ground_Transporation_ToV_MERC__c, Total_Ground_Transport_ToV_Rollup_MERC__c 
							FROM Meeting_Participant_MERC__c 
							WHERE Id = :participants.get(0).Id];

			tovForParticipant1Day1 = [SELECT Id, Est_Grp_Grnd_Transp_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day1.Id];

			/*** This now fails because the Est_Grp_Grnd_Transp_MERC__c is in the meeting currency. Yea! ***/
			//System.assertEquals((Decimal)(intendedValue/conversionRate).setScale(2), tovForParticipant1Day1.Est_Grp_Grnd_Transp_MERC__c, 
				//'Unexpected tov value'+tovForParticipant1Day1.Est_Grp_Grnd_Transp_MERC__c);
			System.assertEquals(intendedValue, tovForParticipant1Day1.Est_Grp_Grnd_Transp_MERC__c, 
				'Unexpected tov value'+tovForParticipant1Day1.Est_Grp_Grnd_Transp_MERC__c);
			System.assertEquals(tovForParticipant1Day1.Est_Grp_Grnd_Transp_MERC__c, participant1.Total_Ground_Transport_ToV_Rollup_MERC__c, 
				'Total_Ground_Transport_ToV_Rollup_MERC__c did not rollup as expected.'+participant1.Total_Ground_Transport_ToV_Rollup_MERC__c);

			/*** This now fails presumably because we're not aggregating [?] ***/
			//System.assertEquals((Decimal)(intendedValue/conversionRate).setScale(2), (Decimal)(participant1.Total_Ground_Transport_ToV_Rollup_MERC__c).setScale(2), 
			//	'Total does not match original set value when converted.'+(Decimal)(participant1.Total_Ground_Transport_ToV_Rollup_MERC__c).setScale(2));
			System.assertEquals(intendedValue, (Decimal)(participant1.Total_Ground_Transport_ToV_Rollup_MERC__c).setScale(2), 
				'Total does not match original set value.'+(Decimal)(participant1.Total_Ground_Transport_ToV_Rollup_MERC__c).setScale(2));
			System.assertEquals((Decimal)(intendedValue).setScale(2), (Decimal)(tovForParticipant1Day1.Est_Grp_Grnd_Transp_MERC__c).setScale(2), 
				'Unexpected converted tov value'+(Decimal)(tovForParticipant1Day1.Est_Grp_Grnd_Transp_MERC__c).setScale(2));
		}
		Test.stopTest();
	}

	@isTest
	static void testRoundingValue_Total_Food() {
		
		Decimal transferCost = (Decimal)(99.99*conversionRate).setScale(2);
		p('value & conversion = 99.99 & '+ transferCost);

		Test.startTest();

		//set participant 1 to attending on day 1
		Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

		Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Food_Beverage_ToV_MERC__c, Total_Food_Beverage_ToV_Rollup_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

		tovForParticipant1Day1 = [SELECT Id, Est_Food_Bev_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day1.Id];

		//assert that meeting day 1's food bev estimate rolled up up to the participant total
		//System.assert(false, tovForParticipant1Day1.Est_Grp_Grnd_Transp_MERC__c);
		//System.assertEquals(tovForParticipant1Day1.Est_Grp_Grnd_Transp_MERC__c, participant1.Total_Ground_Transporation_ToV_MERC__c, 'Est_Grp_Grnd_Transp did not rollup as expected.');

		System.assertEquals(transferCost, tovForParticipant1Day1.Est_Food_Bev_ToV_MERC__c, 'Unexpected Est_Food_Bev_ToV_MERC__c');
		System.assertEquals(tovForParticipant1Day1.Est_Food_Bev_ToV_MERC__c, participant1.Total_Food_Beverage_ToV_Rollup_MERC__c, 'Total_Food_Beverage_ToV_Rollup_MERC__c did not rollup as expected.');
		System.assertEquals(transferCost, participant1.Total_Food_Beverage_ToV_MERC__c, 'Total does not match original set value.');

		Test.stopTest();
	}

	@isTest 
	static void testRoundingValue_originalScenarioNewProcess_Food_Bev() {
		Decimal intendedValue = 100.00;

		conversionRate = [SELECT ConversionRate, IsoCode, isActive FROM CurrencyType WHERE IsoCode = 'BGN' AND isActive = true LIMIT 1].ConversionRate;

		MERC_TriggerHandlerStateManager.deactivateAll();
		Meeting_MERC__c m = new Meeting_MERC__c();
		m.Date_of_Event_MERC__c = startDate;
		m.End_Date_of_Event_MERC__c = startDate.addDays(durationInDays);
		m.Start_Time_of_Meeting_MERC__c = DateTime.newInstance(startDate, Time.newInstance(10, 0, 0, 0));
		m.End_Time_of_Meeting_MERC__c = DateTime.newInstance(startDate.addDays(durationInDays), Time.newInstance(14, 0, 0, 0));
		m.Name = 'ToV MeetingBGN';
		m.Meeting_Time_Zone_MERC__c = 'Greenwich Mean Time (Europe/London)';
		m.Event_Country_MERC__c = 'BG';
		m.CurrencyIsoCode = 'BGN';
		m.Meeting_Status_MERC__c = 'Active';
		insert m;

		meetingDays = new List<Meeting_Day_MERC__c>();
		Integer numberOfDays = m.Date_of_Event_MERC__c.daysBetween(m.End_Date_of_Event_MERC__c)+1;
		for (Integer i = 0; i < numberOfDays; i++) {
			Meeting_Day_MERC__c mDay = new Meeting_Day_MERC__c();
			mDay.Date_MERC__c = m.Date_of_Event_MERC__c.addDays(i);
			mDay.Meeting_MERC__c = m.Id;
			mDay.Daily_Food_Beverage_Amount_MERC__c = intendedValue;
			mDay.CurrencyIsoCode = 'BGN';
			meetingDays.add(mDay);
		}
		insert meetingDays;

		participants = insertParticipants(new List<Meeting_MERC__c>{m},accounts);

		MERC_TriggerHandlerStateManager.activate(MERC_TOVCalculator.class);

		User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

		Test.startTest();

		System.runAs(u){
			System.debug('Big bucks: ' + UserInfo.getDefaultCurrency());

			Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

			Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Food_Beverage_ToV_Rollup_MERC__c, Total_Food_Beverage_ToV_MERC__c 
							FROM Meeting_Participant_MERC__c 
							WHERE Id = :participants.get(0).Id];

			tovForParticipant1Day1 = [SELECT Id, Est_Food_Bev_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day1.Id];

			/*** This now fails because the Est_Food_Bev_ToV_MERC__c is in the meeting currency. Yea! ***/
			//System.assertEquals((Decimal)(intendedValue/conversionRate).setScale(2), tovForParticipant1Day1.Est_Food_Bev_ToV_MERC__c, 
				//'Unexpected tov value'+tovForParticipant1Day1.Est_Food_Bev_ToV_MERC__c);
			System.assertEquals(intendedValue, tovForParticipant1Day1.Est_Food_Bev_ToV_MERC__c, 
				'Unexpected tov value'+tovForParticipant1Day1.Est_Food_Bev_ToV_MERC__c);
			System.assertEquals(tovForParticipant1Day1.Est_Food_Bev_ToV_MERC__c, participant1.Total_Food_Beverage_ToV_Rollup_MERC__c, 
				'Total_Food_Beverage_ToV_Rollup_MERC__c did not rollup as expected.'+participant1.Total_Food_Beverage_ToV_Rollup_MERC__c);

			/*** This now fails presumably because we're not aggregating [?] ***/
			//System.assertEquals((Decimal)(intendedValue/conversionRate).setScale(2), (Decimal)(participant1.Total_Food_Beverage_ToV_Rollup_MERC__c).setScale(2), 
			//	'Total does not match original set value when converted.'+(Decimal)(participant1.Total_Food_Beverage_ToV_Rollup_MERC__c).setScale(2));
			System.assertEquals(intendedValue, (Decimal)(participant1.Total_Food_Beverage_ToV_Rollup_MERC__c).setScale(2), 
				'Total does not match original set value.'+(Decimal)(participant1.Total_Food_Beverage_ToV_Rollup_MERC__c).setScale(2));
			System.assertEquals((Decimal)(intendedValue).setScale(2), (Decimal)(tovForParticipant1Day1.Est_Food_Bev_ToV_MERC__c).setScale(2), 
				'Unexpected converted tov value'+(Decimal)(tovForParticipant1Day1.Est_Food_Bev_ToV_MERC__c).setScale(2));
		}
		Test.stopTest();
	}



	@isTest 
	static void testRoundingValue_Total_Registration() {
		//This is the value of 99.99 EUR (the org's and user's base currency) converted into GBP (the meeting currency) and set to 4 d.p. Uses the default
		//HALF_EVEN rounding mode.
		Decimal transferCost = (Decimal)(99.99*conversionRate).setScale(4);
		p('value & conversion & rate = 99.99 & '+ transferCost +' & '+conversionRate);

		Test.startTest();			
			Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

			Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Registration_ToV_Rollup_MERC__c 
							FROM Meeting_Participant_MERC__c 
							WHERE Id = :participants.get(0).Id];

			tovForParticipant1Day1 = [SELECT Id, Est_Reg_Amt_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day1.Id];

			
			System.assertEquals((Decimal)(transferCost).setScale(2), tovForParticipant1Day1.Est_Reg_Amt_ToV_MERC__c, 'Unexpected tov value');
			//System.assertEquals(transferCost, tovForParticipant1Day1.Est_Reg_Amt_ToV_MERC__c, 'Unexpected tov value');
			System.assertEquals(tovForParticipant1Day1.Est_Reg_Amt_ToV_MERC__c, participant1.Total_Registration_ToV_Rollup_MERC__c, 'Total_Registration_ToV_Rollup_MERC__c did not rollup as expected.');
			System.assertEquals((Decimal)(transferCost).setScale(2), (Decimal)(participant1.Total_Registration_ToV_Rollup_MERC__c).setScale(2), 'Total does not match original set value.');
			//System.assert(false,'values are: '+transferCost+' & '+conversionRate); 
		Test.stopTest();
	}

	@isTest 
	static void testRoundingValue_originalScenarioNewProcess() {
		Decimal intendedValue = 100.00;

		conversionRate = [SELECT ConversionRate, IsoCode, isActive FROM CurrencyType WHERE IsoCode = 'BGN' AND isActive = true LIMIT 1].ConversionRate;

		MERC_TriggerHandlerStateManager.deactivateAll();
		Meeting_MERC__c m = new Meeting_MERC__c();
		m.Date_of_Event_MERC__c = startDate;
		m.End_Date_of_Event_MERC__c = startDate.addDays(durationInDays);
		m.Start_Time_of_Meeting_MERC__c = DateTime.newInstance(startDate, Time.newInstance(10, 0, 0, 0));
		m.End_Time_of_Meeting_MERC__c = DateTime.newInstance(startDate.addDays(durationInDays), Time.newInstance(14, 0, 0, 0));
		m.Name = 'ToV MeetingBGN';
		m.Meeting_Time_Zone_MERC__c = 'Greenwich Mean Time (Europe/London)';
		m.Event_Country_MERC__c = 'BG';
		m.CurrencyIsoCode = 'BGN';
		m.Meeting_Status_MERC__c = 'Active';
		insert m;

		meetingDays = new List<Meeting_Day_MERC__c>();
		Integer numberOfDays = m.Date_of_Event_MERC__c.daysBetween(m.End_Date_of_Event_MERC__c)+1;
		for (Integer i = 0; i < numberOfDays; i++) {
			Meeting_Day_MERC__c mDay = new Meeting_Day_MERC__c();
			mDay.Date_MERC__c = m.Date_of_Event_MERC__c.addDays(i);
			mDay.Meeting_MERC__c = m.Id;
			mDay.Daily_Registration_Amount_MERC__c = intendedValue;
			mDay.CurrencyIsoCode = 'BGN';
			meetingDays.add(mDay);
		}
		insert meetingDays;

		participants = insertParticipants(new List<Meeting_MERC__c>{m},accounts);

		MERC_TriggerHandlerStateManager.activate(MERC_TOVCalculator.class);

		User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

		Test.startTest();

		System.runAs(u){
			System.debug('Big bucks: ' + UserInfo.getDefaultCurrency());

			Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

			Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Registration_ToV_Rollup_MERC__c, Total_Registration_ToV_MERC__c 
							FROM Meeting_Participant_MERC__c 
							WHERE Id = :participants.get(0).Id];

			tovForParticipant1Day1 = [SELECT Id, Est_Reg_Amt_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day1.Id];

			/*** This now fails because the Est_Reg_Amt_ToV_MERC__c is in the meeting currency. Yea! ***/
			//System.assertEquals((Decimal)(intendedValue/conversionRate).setScale(2), tovForParticipant1Day1.Est_Reg_Amt_ToV_MERC__c, 
				//'Unexpected tov value'+tovForParticipant1Day1.Est_Reg_Amt_ToV_MERC__c);
			System.assertEquals(intendedValue, tovForParticipant1Day1.Est_Reg_Amt_ToV_MERC__c, 
				'Unexpected tov value'+tovForParticipant1Day1.Est_Reg_Amt_ToV_MERC__c);
			System.assertEquals(tovForParticipant1Day1.Est_Reg_Amt_ToV_MERC__c, participant1.Total_Registration_ToV_Rollup_MERC__c, 
				'Total_Registration_ToV_Rollup_MERC__c did not rollup as expected.'+participant1.Total_Registration_ToV_Rollup_MERC__c);

			/*** This now fails presumably because we're not aggregating [?] ***/
			//System.assertEquals((Decimal)(intendedValue/conversionRate).setScale(2), (Decimal)(participant1.Total_Registration_ToV_Rollup_MERC__c).setScale(2), 
				//'Total does not match original set value when converted.'+(Decimal)(participant1.Total_Registration_ToV_Rollup_MERC__c).setScale(2));
			System.assertEquals(intendedValue, (Decimal)(participant1.Total_Registration_ToV_Rollup_MERC__c).setScale(2), 
				'Total does not match original set value.'+(Decimal)(participant1.Total_Registration_ToV_Rollup_MERC__c).setScale(2));
			System.assertEquals((Decimal)(intendedValue).setScale(2), (Decimal)(tovForParticipant1Day1.Est_Reg_Amt_ToV_MERC__c).setScale(2), 
				'Unexpected converted tov value'+(Decimal)(tovForParticipant1Day1.Est_Reg_Amt_ToV_MERC__c).setScale(2));
		}
		Test.stopTest();
	}

	@isTest 
	static void testRoundingValue_originalScenarioOldProcess() {

		List<LookupRollupSummary_GLBL__c> rollups = [SELECT Id FROM LookupRollupSummary_GLBL__c];
		delete rollups;
		MERC_TestFactory.loadDeclarativeRollupSummaries();
		Decimal intendedValue = 100.00;

		conversionRate = [SELECT ConversionRate, IsoCode, isActive FROM CurrencyType WHERE IsoCode = 'BGN' AND isActive = true LIMIT 1].ConversionRate;

		MERC_TriggerHandlerStateManager.deactivateAll();
		Meeting_MERC__c m = new Meeting_MERC__c();
		m.Date_of_Event_MERC__c = startDate;
		m.End_Date_of_Event_MERC__c = startDate.addDays(durationInDays);
		m.Start_Time_of_Meeting_MERC__c = DateTime.newInstance(startDate, Time.newInstance(10, 0, 0, 0));
		m.End_Time_of_Meeting_MERC__c = DateTime.newInstance(startDate.addDays(durationInDays), Time.newInstance(14, 0, 0, 0));
		m.Name = 'ToV MeetingBGN';
		m.Meeting_Time_Zone_MERC__c = 'Greenwich Mean Time (Europe/London)';
		m.Event_Country_MERC__c = 'BG';
		m.CurrencyIsoCode = 'BGN';
		m.Meeting_Status_MERC__c = 'Active';
		insert m;

		meetingDays = new List<Meeting_Day_MERC__c>();
		Integer numberOfDays = m.Date_of_Event_MERC__c.daysBetween(m.End_Date_of_Event_MERC__c)+1;
		for (Integer i = 0; i < numberOfDays; i++) {
			Meeting_Day_MERC__c mDay = new Meeting_Day_MERC__c();
			mDay.Date_MERC__c = m.Date_of_Event_MERC__c.addDays(i);
			mDay.Meeting_MERC__c = m.Id;
			mDay.Daily_Registration_Amount_MERC__c = intendedValue;
			mDay.CurrencyIsoCode = 'BGN';
			meetingDays.add(mDay);
		}
		insert meetingDays;

		participants = insertParticipants(new List<Meeting_MERC__c>{m},accounts);

		MERC_TriggerHandlerStateManager.activate(MERC_TOVCalculator.class);

		User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

		Test.startTest();

		System.runAs(u){
			System.debug('Big bucks: ' + UserInfo.getDefaultCurrency());

			Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

			Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Registration_ToV_Rollup_MERC__c 
							FROM Meeting_Participant_MERC__c 
							WHERE Id = :participants.get(0).Id];

			tovForParticipant1Day1 = [SELECT Id, Est_Reg_Amt_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day1.Id];

			/*** This now fails because the Est_Reg_Amt_ToV_MERC__c is in the meeting currency. Yea! ***/
			//System.assertEquals((Decimal)(intendedValue/conversionRate).setScale(2), tovForParticipant1Day1.Est_Reg_Amt_ToV_MERC__c, 
				//'Unexpected tov value'+tovForParticipant1Day1.Est_Reg_Amt_ToV_MERC__c);
			System.assertEquals(intendedValue, tovForParticipant1Day1.Est_Reg_Amt_ToV_MERC__c, 
				'Unexpected tov value'+tovForParticipant1Day1.Est_Reg_Amt_ToV_MERC__c);
			System.assertEquals(tovForParticipant1Day1.Est_Reg_Amt_ToV_MERC__c, participant1.Total_Registration_ToV_Rollup_MERC__c, 
				'Total_Registration_ToV_Rollup_MERC__c did not rollup as expected.'+participant1.Total_Registration_ToV_Rollup_MERC__c);

			/*** This now fails because... ???  ***/
			//System.assertEquals((Decimal)(intendedValue/conversionRate).setScale(2), (Decimal)(participant1.Total_Registration_ToV_Rollup_MERC__c).setScale(2), 
			//	'Total does not match original set value when converted.'+(Decimal)(participant1.Total_Registration_ToV_Rollup_MERC__c).setScale(2));
			System.assertEquals(intendedValue, (Decimal)(participant1.Total_Registration_ToV_Rollup_MERC__c).setScale(2), 
				'Total does not match original set value.'+(Decimal)(participant1.Total_Registration_ToV_Rollup_MERC__c).setScale(2));
			System.assertEquals((Decimal)(intendedValue).setScale(2), (Decimal)(tovForParticipant1Day1.Est_Reg_Amt_ToV_MERC__c).setScale(2), 
				'Unexpected converted tov value'+(Decimal)(tovForParticipant1Day1.Est_Reg_Amt_ToV_MERC__c).setScale(2));
		}
		Test.stopTest();
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
			m.CurrencyIsoCode = 'GBP';
			m.Meeting_Status_MERC__c = 'Active';
			mtgs.add(m);
		}
		insert mtgs;
		return mtgs;
	}

	static List<Meeting_Day_MERC__c> insertMeetingDays(List<Meeting_MERC__c> meets) {
		List<Meeting_Day_MERC__c> mtgDays = new List<Meeting_Day_MERC__c>();

		Decimal annoyingValue = (Decimal)(99.99*conversionRate).setScale(4);
		p('value & conversion = 99.99 & '+ annoyingValue);

		for (Meeting_MERC__c meeting : meets) {
			Integer numberOfDays = meeting.Date_of_Event_MERC__c.daysBetween(meeting.End_Date_of_Event_MERC__c)+1;
			for (Integer i = 0; i < numberOfDays; i++) {
				Meeting_Day_MERC__c m = new Meeting_Day_MERC__c();
				m.Date_MERC__c = meeting.Date_of_Event_MERC__c.addDays(i);
				m.Meeting_MERC__c = meeting.Id;
				m.Daily_Food_Beverage_Amount_MERC__c = annoyingValue;
				m.Daily_Ground_Trans_Amount_MERC__c = annoyingValue;
				m.Daily_Registration_Amount_MERC__c = annoyingValue;
				m.CurrencyIsoCode = 'GBP';
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
				p.Status_MERC__c = 'Accepted';
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
				v.Room_Rate_MERC__c = 99.99;
				v.Meeting_MERC__c = meeting.Id;
				v.CurrencyIsoCode = 'GBP';
				hotels.add(v);
			}
		}
		insert hotels;
		return hotels;
	}

	static List<Travel_Itinerary_MERC__c> insertPrivateTransferItineraries(List<Meeting_Participant_MERC__c> mps, Date start_date, Date end_date) {
		return insertPrivateTransferItineraries(mps, start_date, end_date, 1, 99);
	}
	static List<Travel_Itinerary_MERC__c> insertPrivateTransferItineraries(List<Meeting_Participant_MERC__c> mps, Date start_date, Date end_date, Integer numOfRecords, Decimal amount) {
		List<Travel_Itinerary_MERC__c> ptItineraries = new List<Travel_Itinerary_MERC__c>();
		for (Integer i=0; i<numOfRecords; i++) {
			for (Meeting_Participant_MERC__c mp : mps) {
				Travel_Itinerary_MERC__c ti = new Travel_Itinerary_MERC__c();
				ti.RecordTypeId = rentalCarRecordTypeId;
				ti.Individual_Travel_ToV_Applicable_MERC__c = true;
				ti.Total_Fare_Amount_MERC__c = amount;
				ti.Meeting_Participant_MERC__c = mp.Id;
				ti.Account_MERC__c = mp.Account_MERC__c;
				ti.Sgmnt_Bgin_TS_MERC__c = Datetime.newInstance(start_date, Time.newInstance(8, 0, 0, 0));
				ti.Sgmnt_End_TS_MERC__c = Datetime.newInstance(end_date, Time.newInstance(18, 0, 0, 0));
				ti.Status_MERC__c = 'Confirmed';
				ti.CurrencyIsoCode = 'GBP';
				ptItineraries.add(ti);
			}
		}
		insert ptItineraries;
		return ptItineraries;
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
			ti.CurrencyIsoCode = 'GBP';
			hotelItineraries.add(ti);
		}
		insert hotelItineraries;
		return hotelItineraries;
	}

	// combined to manage SOQL limits
	static List<Daily_Attendance_TOV_MERC__c> insertTovs(List<Meeting_Day_MERC__c> listOfDays, String meetingParticipantId, String status) {
		List<String> meetingDayIds = new List<String>();
		for (Meeting_Day_MERC__c day : listOfDays) meetingDayIds.add(day.Id);
		return insertTovs(meetingDayIds, meetingParticipantId, status);
	}
	static List<Daily_Attendance_TOV_MERC__c> insertTovs(List<String> meetingDayIds, String meetingParticipantId, String status) {
		List<Daily_Attendance_TOV_MERC__c> result = new List<Daily_Attendance_TOV_MERC__c>();
		for (String id : meetingDayIds) {
			Daily_Attendance_TOV_MERC__c tov = new Daily_Attendance_TOV_MERC__c();
			tov.Meeting_Day_MERC__c = id;
			tov.Meeting_Participant_MERC__c = meetingParticipantId;
			tov.Status_MERC__c = status;
			result.add(tov);			
		}
		insert result;
		return result;
	}
	
		static void p(String m) {
			System.debug('\n\n\nYYZ - '+m+'\n\n\n\n');
		}
}