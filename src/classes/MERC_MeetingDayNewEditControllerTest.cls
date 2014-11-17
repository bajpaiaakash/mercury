@isTest
private class MERC_MeetingDayNewEditControllerTest {

	static List<Meeting_MERC__c> meetings;

	static {
		meetings = MERC_TestFactory.insertMeetings(1);
	}

	@isTest static void test_should_insert_meeting_day() {
		PageReference testPage = Page.MERC_MeetingDayNewEdit;
		Test.setCurrentPage(testPage);

		Id meetingId = meetings.get(0).Id;

		Meeting_Day_MERC__c newMeetingDay = new Meeting_Day_MERC__c(Meeting_MERC__c=meetingId);
		ApexPages.StandardController stdController = new ApexPages.StandardController(newMeetingDay);
		MERC_MeetingDayNewEditController controller = new MERC_MeetingDayNewEditController(stdController);
		controller.setTimeZones();

		newMeetingDay.Name = 'foo';
		newMeetingDay.Date_MERC__c = Date.today();

		controller.save();

		System.assertEquals(1, [SELECT count() FROM Meeting_Day_MERC__c WHERE Meeting_MERC__c = :meetingId]);

	}

	@isTest static void test_should_update_meeting_day() {
		PageReference testPage = Page.MERC_MeetingDayNewEdit;
		Test.setCurrentPage(testPage);

		Id meetingId = meetings.get(0).Id;

		Meeting_Day_MERC__c existingMeetingDay = MERC_TestFactory.insertMeetingDays(meetingId, 1).get(0);

		ApexPages.StandardController stdController = new ApexPages.StandardController(existingMeetingDay);
		MERC_MeetingDayNewEditController controller = new MERC_MeetingDayNewEditController(stdController);
		controller.setTimeZones();

		existingMeetingDay.Name = 'bar123456x';

		controller.save();

		System.assertEquals(1, [SELECT count() FROM Meeting_Day_MERC__c WHERE Meeting_MERC__c = :meetingId AND Name = 'bar123456x']);

	}

	@isTest static void test_should_fail_to_save_meeting_day() {
		PageReference testPage = Page.MERC_MeetingDayNewEdit;
		Test.setCurrentPage(testPage);

		Id meetingId = meetings.get(0).Id;

		Meeting_Day_MERC__c existingMeetingDay = MERC_TestFactory.insertMeetingDays(meetingId, 1).get(0);

		ApexPages.StandardController stdController = new ApexPages.StandardController(existingMeetingDay);
		MERC_MeetingDayNewEditController controller = new MERC_MeetingDayNewEditController(stdController);
		controller.setTimeZones();

		existingMeetingDay.Daily_Food_Beverage_Amount_MERC__c = -10000;
		controller.save();
		System.assert(!ApexPages.getMessages().isEmpty());
		//system.debug(ApexPages.getMessages()[0]);
		System.assert(ApexPages.getMessages()[0].getSummary().contains('You may not enter a value less than zero'));
	}

	@isTest static void testCloneSetsObjectIdToNull() {
		PageReference testPage = Page.MERC_MeetingDayNewEdit;
		testPage.getParameters().put('clone','1');
		Test.setCurrentPage(testPage);

		Id meetingId = meetings.get(0).Id;

		Meeting_Day_MERC__c existingMeetingDay = MERC_TestFactory.insertMeetingDays(meetingId, 1).get(0);
		ApexPages.StandardController stdController = new ApexPages.StandardController(existingMeetingDay);
		MERC_MeetingDayNewEditController controller = new MERC_MeetingDayNewEditController(stdController);
		//can't assert here since the variable is not visible
	}

	@isTest static void testFieldSetLabels() {
		PageReference testPage = Page.MERC_MeetingDayNewEdit;
		Test.setCurrentPage(testPage);

		Id meetingId = meetings.get(0).Id;

		Meeting_Day_MERC__c existingMeetingDay = MERC_TestFactory.insertMeetingDays(meetingId, 1).get(0);
		ApexPages.StandardController stdController = new ApexPages.StandardController(existingMeetingDay);
		MERC_MeetingDayNewEditController controller = new MERC_MeetingDayNewEditController(stdController);
		System.assertNotEquals(null, controller.fieldSetLabels);
	}

}