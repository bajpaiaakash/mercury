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

	public static Id hcpRecordTypeId = 				[SELECT ID FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'HCP_GLBL' LIMIT 1].Id;
	public static Id vendorRecordTypeId = 			[SELECT ID FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Vendor_GLBL' LIMIT 1].Id;
	public static Id hotelItineraryRecordTypeId = 	[SELECT ID FROM RecordType WHERE SObjectType = 'Travel_Itinerary_MERC__c' AND DeveloperName = 'Hotel_MERC' LIMIT 1].Id;
	public static Id rentalCarRecordTypeId = 		[SELECT ID FROM RecordType WHERE SObjectType = 'Travel_Itinerary_MERC__c' AND DeveloperName = 'Car_MERC' LIMIT 1].Id;

	static {
		MERC_TriggerHandlerStateManager.deactivateAll();
		MERC_TriggerHandlerStateManager.activate(MERC_TOVCalculator.class);

		MERC_TestFactory.loadDeclarativeRollupSummaries();

		// MERC_TestFactory has some bugs. Until this is cleaned up, data factory methods moved within class...
		startDate = Date.today();
		durationInDays = 2;
		Date endDate = startDate.addDays(durationInDays);

		accounts = insertAccounts(1);
		meetings = insertMeetings(1,startDate,endDate);
		meetingDays = insertMeetingDays(meetings);
		participants = insertParticipants(meetings,accounts);

		MERC_TOVCalculator.runHotelTovCalculation = true;
	}
	
	@isTest static void testRoundingValue() {

		Double conversionRate = [SELECT ConversionRate, IsoCode, isActive FROM CurrencyType WHERE IsoCode = 'GBP' AND isActive = true LIMIT 1].ConversionRate;

		Test.startTest();

		//This is the value of 99.99 EUR (the org's and user's base currency) converted into GBP (the meeting currency) and set to 4 d.p. Uses the default
		//HALF_EVEN rounding mode.
		Decimal transferCost = (Decimal)(99.99*conversionRate).setScale(4);

		MERC_TOVCalculator.runIndividualTransferTovCalculation = true;
		System.debug('Running test actions');
		Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Ground_Transporation_ToV_MERC__c, Account_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];
		insertPrivateTransferItineraries(new List<Meeting_Participant_MERC__c>{participant1}, Date.today(), Date.today().addDays(1), 1, transferCost);

		//set participant 1 to attending on day 1
		Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

		participant1 = [SELECT Id, Total_Ground_Transporation_ToV_MERC__c, Total_Ground_Transport_ToV_Rollup_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

		tovForParticipant1Day1 = [SELECT Id, Est_Grp_Grnd_Transp_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day1.Id];

		//assert that meeting day 1's food bev estimate rolled up up to the participant total
		System.assertEquals(transferCost, participant1.Total_Ground_Transporation_ToV_MERC__c, 'Est_Grp_Grnd_Transp did not rollup as expected.');
		System.assertEquals(tovForParticipant1Day1.Est_Grp_Grnd_Transp_MERC__c, participant1.Total_Ground_Transport_ToV_Rollup_MERC__c, 'Est_Grp_Grnd_Transp Rollup did not rollup as expected.');
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
				p.Status_MERC__c = 'Accepted';   // ?? impact of this status on ToV?
				p.Services_Rendered_MERC__c = 'Yes';
				p.Alliance_MERC__c = 'Not Applicable';
				mps.add(p);
			}
		}
		insert mps;
		return mps;
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
	
}