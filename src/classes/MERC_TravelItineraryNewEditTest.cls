@isTest
private class MERC_TravelItineraryNewEditTest {
	
	static List<Meeting_MERC__c> meetings;
	static List<Account> accounts;
	static List<Meeting_Day_MERC__c> meetingDays;
	static List<Meeting_Participant_MERC__c> participants;

	static {
		accounts = MERC_TestFactory.insertAccounts(1); //insert 5 accounts
		meetings = MERC_TestFactory.insertMeetings(1); //insert 2 meetings
		participants = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts);
	}

	@isTest static void testNewTravelItinerary() {
		system.assertEquals(0, [SELECT count() FROM Travel_Itinerary_MERC__c WHERE Meeting_Participant_MERC__c = :participants.get(0).Id]);

		PageReference ref = Page.MERC_TravelItineraryNewEdit;
		Test.setCurrentPage(ref);

		Travel_Itinerary_MERC__c newItinerary = new Travel_Itinerary_MERC__c();
		newItinerary.Meeting_Participant_MERC__c = participants.get(0).Id;
		newItinerary.RecordTypeId = [SELECT ID FROM RecordType WHERE SObjectType = 'Travel_Itinerary_MERC__c' AND DeveloperName = 'Air_MERC'].ID;

		ApexPages.StandardController standardController = new ApexPages.StandardController(newItinerary);
		MERC_TravelItineraryNewEditController controller = new MERC_TravelItineraryNewEditController(standardController);

		system.assertEquals(null, (String)controller.mySobject.get('Id'));
		system.assertEquals(accounts.get(0).Id, (String)controller.mySobject.get('Account_MERC__c'));

		String userTimeZone = String.valueOf(UserInfo.getTimeZone());
		String segmentBeginTimeZone = (String)controller.mySobject.get('Segment_Begin_Timezone_MERC__c');
		String segmentEndTimeZone = (String)controller.mySobject.get('Segment_End_Timezone_MERC__c');
		system.assert(segmentBeginTimeZone.contains(userTimeZone));
		system.assert(segmentEndTimeZone.contains(userTimeZone));

		controller.setTimeZones();

		try {
			controller.mySobject.put('Name', 'foo');
			controller.save();
		} catch(System.SObjectException e) {
			system.assert(e.getMessage().contains('Field Name is not editable'));
		}

		controller.mySobject.put('Vendor_Code_MERC__c', '12345');
		controller.mySobject.put('Sgmnt_Bgin_TS_MERC__c', DateTime.now().addHours(10));
		controller.mySobject.put('Sgmnt_End_TS_MERC__c', DateTime.now().addHours(12));
		controller.mySobject.put('Segment_Begin_Timezone_MERC__c', 'Central European Time (Europe/Paris)');
		controller.mySobject.put('Segment_End_Timezone_MERC__c', 'Central European Time (Europe/Paris)');

		controller.save();

		system.assertEquals(1, [SELECT count() FROM Travel_Itinerary_MERC__c WHERE Meeting_Participant_MERC__c = :participants.get(0).Id]);
	}

	@isTest static void testEditTravelItinerary() {
		List<Travel_Itinerary_MERC__c> existingTravelItineraries = MERC_TestFactory.insertHotelItineraries(participants, Date.today(), Date.today().addDays(1));

		system.assertEquals(1, [SELECT count() FROM Travel_Itinerary_MERC__c WHERE Meeting_Participant_MERC__c = :participants.get(0).Id]);

		PageReference ref = Page.MERC_TravelItineraryNewEdit;
		Test.setCurrentPage(ref);

		ApexPages.StandardController standardController = new ApexPages.StandardController(existingTravelItineraries.get(0));
		MERC_TravelItineraryNewEditController controller = new MERC_TravelItineraryNewEditController(standardController);

		system.assertEquals(existingTravelItineraries.get(0).Id, (String)controller.mySobject.get('Id'));
		system.assertEquals(accounts.get(0).Id, (String)controller.mySobject.get('Account_MERC__c'));

		String userTimeZone = String.valueOf(UserInfo.getTimeZone());
		String segmentBeginTimeZone = (String)controller.mySobject.get('Segment_Begin_Timezone_MERC__c');
		String segmentEndTimeZone = (String)controller.mySobject.get('Segment_End_Timezone_MERC__c');
		system.assert(segmentBeginTimeZone.contains(userTimeZone));
		system.assert(segmentEndTimeZone.contains(userTimeZone));

		controller.setTimeZones();

		controller.mySobject.put('Vendor_Code_MERC__c', '9999');
		controller.mySobject.put('Sgmnt_Bgin_TS_MERC__c', DateTime.now().addHours(10));
		controller.mySobject.put('Sgmnt_End_TS_MERC__c', DateTime.now().addHours(12));
		controller.mySobject.put('Segment_Begin_Timezone_MERC__c', 'Central European Time (Europe/Paris)');
		controller.mySobject.put('Segment_End_Timezone_MERC__c', 'Central European Time (Europe/Paris)');

		controller.save();

		system.assertEquals(1, [SELECT count() FROM Travel_Itinerary_MERC__c WHERE Meeting_Participant_MERC__c = :participants.get(0).Id]);
		system.assertEquals('9999', [SELECT Vendor_Code_MERC__c FROM Travel_Itinerary_MERC__c WHERE Meeting_Participant_MERC__c = :participants.get(0).Id].Vendor_Code_MERC__c);

	}

}