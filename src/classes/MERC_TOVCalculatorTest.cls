@isTest
private class MERC_TOVCalculatorTest {

	static List<Account> accounts;
	static List<Meeting_MERC__c> meetings;
	static List<Meeting_Day_MERC__c> meetingDays;
	static List<Meeting_Participant_MERC__c> participants;
	static List<Meeting_Vendor_MERC__c> meetingVendors;
	static List<Hotel_Allocation_MERC__c> hotelAllocations;

	/*
		Set up 1 meeting with 3 meeting days and 5 participants
	*/
	static {
		MERC_TestFactory.loadDeclarativeRollupSummaries();
		accounts = MERC_TestFactory.insertAccounts(5);
		meetings = MERC_TestFactory.insertMeetings(1);
		meetingDays = MERC_TestFactory.insertMeetingDays(meetings.get(0).Id, 3);
		participants = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts);
		meetingVendors = MERC_TestFactory.insertHotelsForMeeting(1, meetings.get(0).Id);
	}

	@isTest static void testShouldCalculateHotelTovOnRoomRateChange() {
		Test.startTest();
		Id hotelItineraryRecordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = 'Hotel_MERC' AND SObjectType = 'Travel_Itinerary_MERC__c'].Id;

		Meeting_Vendor_MERC__c hotel1 = meetingVendors.get(0);

		Hotel_Allocation_MERC__c hotel1Day1Allocation = new Hotel_Allocation_MERC__c();
		hotel1Day1Allocation.Meeting_Vendor_MERC__c = hotel1.Id;
		hotel1Day1Allocation.Meeting_Day_MERC__c = meetingDays.get(0).Id;
		hotel1Day1Allocation.Total_Rooms_in_Block_MERC__c = 50;
		insert hotel1Day1Allocation;

		Hotel_Allocation_MERC__c hotel1Day2Allocation = new Hotel_Allocation_MERC__c();
		hotel1Day2Allocation.Meeting_Vendor_MERC__c = hotel1.Id;
		hotel1Day2Allocation.Meeting_Day_MERC__c = meetingDays.get(1).Id;
		hotel1Day2Allocation.Total_Rooms_in_Block_MERC__c = 50;
		insert hotel1Day2Allocation;

		Hotel_Allocation_MERC__c hotel1Day3Allocation = new Hotel_Allocation_MERC__c();
		hotel1Day3Allocation.Meeting_Vendor_MERC__c = hotel1.Id;
		hotel1Day3Allocation.Meeting_Day_MERC__c = meetingDays.get(2).Id;
		hotel1Day3Allocation.Total_Rooms_in_Block_MERC__c = 50;
		insert hotel1Day3Allocation;

		Travel_Itinerary_MERC__c t = new Travel_Itinerary_MERC__c();
		t.Meeting_Participant_MERC__c = participants.get(0).Id;
		t.Sgmnt_Bgin_TS_MERC__c = meetingDays.get(0).Date_MERC__c; //check in day 1
		t.Sgmnt_End_TS_MERC__c = meetingDays.get(2).Date_MERC__c; //check out day 3
		t.Account_MERC__c = participants.get(0).Account_MERC__c;
		t.RecordTypeId = hotelItineraryRecordTypeId;
		t.Meeting_Vendor_MERC__c = hotel1.Id;
		insert t;

		//set participant 1 to attending on day 1
		Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id, 'Attended');

		hotel1.Room_Rate_MERC__c = 600;
		update hotel1;



		Meeting_Day_MERC__c day1 = [SELECT Id,
										Daily_Ground_Trans_Amount_MERC__c,
										Daily_Registration_Amount_MERC__c,
										Daily_Food_Beverage_Amount_MERC__c
											FROM Meeting_Day_MERC__c WHERE Id = :meetingDays.get(0).Id];

		Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Hotel_ToV_MERC__c, Total_Hours_of_Service_MERC__c, Total_Ground_Transporation_ToV_MERC__c, Total_Registration_ToV_MERC__c, Total_Food_Beverage_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

		//assert that meeting day 1's food bev estimate rolled up up to the participant total
		System.assertEquals(600, participant1.Total_Hotel_ToV_MERC__c);

		Test.stopTest();

	}

	@isTest static void testShouldEnsureDeletesRecalculateRollups() {
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

		//now remove attendance on day 1
		delete tovForParticipant1Day1;

		participant1 = [SELECT Id, Total_Hours_of_Service_MERC__c, Total_Ground_Transporation_ToV_MERC__c, Total_Registration_ToV_MERC__c, Total_Food_Beverage_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

		//now ensure the rollup re-calculated
		System.assertEquals(null, participant1.Total_Food_Beverage_ToV_MERC__c);

		Test.stopTest();
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
		////set participant 1 to attending on day 2
		//Daily_Attendance_TOV_MERC__c tovForParticipant1Day2 = MERC_TestFactory.insertTov(meetingDays.get(1).Id, participants.get(0).Id);

		//participant1 = [SELECT Id, Total_Hours_of_Service_MERC__c, Total_Ground_Transporation_ToV_MERC__c, Total_Registration_ToV_MERC__c, Total_Food_Beverage_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

		//tovForParticipant1Day2 = [SELECT Id, Est_Grnd_Transp_MERC__c, Est_Reg_Amt_ToV_MERC__c, Est_Food_Bev_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day2.Id];

		////assert that meeting day 1 and meeting day 2 food bev estimate rolled up up to the participant total
		//System.assert((tovForParticipant1Day1.Est_Food_Bev_ToV_MERC__c + tovForParticipant1Day2.Est_Food_Bev_ToV_MERC__c) == participant1.Total_Food_Beverage_ToV_MERC__c);

		//Test.stopTest();
	}
}