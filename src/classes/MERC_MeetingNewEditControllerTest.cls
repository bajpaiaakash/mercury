@isTest
private class MERC_MeetingNewEditControllerTest {
	
	static List<Account> accounts;

	static {
		accounts = MERC_TestFactory.insertAccounts(1); //insert 1 account
	}

	@isTest static void testNewMeeting() {
		system.assertEquals(0, [SELECT count() FROM Meeting_MERC__c]);

		PageReference ref = Page.MERC_MeetingNewEdit;
		Test.setCurrentPage(ref);

		Meeting_MERC__c newMeeting = new Meeting_MERC__c();
		newMeeting.RecordTypeId = [SELECT ID FROM RecordType WHERE SObjectType = 'Meeting_MERC__c' AND DeveloperName = 'Forecasted'].ID;

		ApexPages.StandardController standardController = new ApexPages.StandardController(newMeeting);
		MERC_MeetingNewEditController controller = new MERC_MeetingNewEditController(standardController);

		system.assertEquals(null, (String)controller.mySobject.get('Id'));

		controller.setTimeZones(); //exercise coverage
		Map<String,String> labels = controller.fieldSetLabels; //exercise coverage

		controller.mySobject.put('Id', 'foo');
		controller.save();

		System.assert(!ApexPages.getMessages().isEmpty(),'Error message not passed back to page.');
		System.assert(ApexPages.getMessages()[0].getDetail().contains('Record ID: id value of incorrect type: foo'));
		system.debug(ApexPages.getMessages());

		controller.mySobject.put('Id', null);

		controller.mySobject.put('Name', 'My Cool Meeting');
		controller.mySobject.put('Type_MERC__c', 'Promotional');
		controller.mySobject.put('Meeting_Sub_Type_MERC__c', 'Marketing');
		controller.mySobject.put('Meeting_Scope_MERC__c', 'International');
		controller.mySobject.put('Therapeutic_Area_MERC__c', 'Oncology');
		controller.mySobject.put('Event_Country_MERC__c', 'GB');
		controller.mySobject.put('Start_Time_of_Meeting_MERC__c', DateTime.now().addHours(24));
		controller.mySobject.put('End_Time_of_Meeting_MERC__c', DateTime.now().addHours(28));
		controller.mySobject.put('Meeting_Time_Zone_MERC__c', 'Greenwich Mean Time (GMT)');
		controller.mySobject.put('Number_of_Expected_Deletgates_MERC__c', 5);

		controller.save();

		system.assertEquals(1, [SELECT count() FROM Meeting_MERC__c]);
	}

	@isTest static void testEditMeeting() {
		system.assertEquals(0, [SELECT count() FROM Meeting_MERC__c]);

		List<Meeting_MERC__c> meetings = MERC_TestFactory.insertMeetings(1);

		PageReference ref = Page.MERC_MeetingNewEdit;
		Test.setCurrentPage(ref);

		Meeting_MERC__c existingMeeting = meetings.get(0);

		ApexPages.StandardController standardController = new ApexPages.StandardController(existingMeeting);
		MERC_MeetingNewEditController controller = new MERC_MeetingNewEditController(standardController);

		system.assertNotEquals(null, (String)controller.mySobject.get('Id'));

		controller.setTimeZones();

		controller.mySobject.put('Name', 'My new name');
		
		controller.save();

		system.assertEquals(1, [SELECT count() FROM Meeting_MERC__c]);
		system.assertEquals('My new name', [SELECT Name FROM Meeting_MERC__c WHERE Id = :existingMeeting.Id].Name);

	}

	
}