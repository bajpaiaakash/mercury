/*
* MERC_MeetingDateTimesControllerTest
* Description : Test the MERC_MeetingDateTimesController controller.
* Author: Rick Locke (Mavens Consulting)
* Created Date: July 21, 2015
*/

@isTest
private class MERC_MeetingDateTimesControllerTest {
	
	private static Meeting_MERC__c buildData() {
		//create data necessary for MERC_MeetingDateTimesController page.
		//Meeting_MERC__c meeting = Merc_TestFactory.insertMeetings(1)[0];
		
	    Meeting_MERC__c meeting = new Meeting_MERC__c();
        meeting.Date_of_Event_MERC__c = Date.today().addDays(2);
        meeting.End_Date_of_Event_MERC__c = Date.today().addDays(2);
        meeting.Start_Time_of_Meeting_MERC__c = DateTime.newInstance(Date.today().addDays(2), Time.newInstance(10, 0, 0, 0));
        meeting.End_Time_of_Meeting_MERC__c = DateTime.newInstance(Date.today().addDays(2), Time.newInstance(14, 0, 0, 0));
        meeting.Name = 'Event Name';
        meeting.Event_Country_MERC__c = 'GB';
		insert meeting;
		//Account acc = Merc_TestFactory.insertAccounts(1)[0];
		//Meeting_Participant_MERC__c participant = Merc_TestFactory.insertParticipants(meeting.Id, new List<Account>{acc})[0];
		return meeting;
	}

	@isTest static void MeetingDateTimesControllerPositiveTest() {

		Meeting_MERC__c meeting = buildData();
		PageReference pageRef = new PageReference('/apex/MERC_MeetingDateTimesEdit');
		Test.setCurrentPage(pageRef);
		
		ApexPages.StandardController sc = new ApexPages.standardController(meeting);
		MERC_MeetingDateTimesController controller = new MERC_MeetingDateTimesController(sc);

		// run setTimeZones 
		controller.setTimeZones();

		// run cancel method
		PageReference cancel = controller.cancel();

		// run save method
		PageReference save = controller.save();

	}
}