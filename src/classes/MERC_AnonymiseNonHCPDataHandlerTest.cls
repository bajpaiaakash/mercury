/**
 * @author Kyle Thornton
 *
 * test methods for the MERC_AnonymiseNonHCPDataHandler class
 */

@isTest
private class MERC_AnonymiseNonHCPDataHandlerTest {

	static List<Account> nonHcpAccounts    = MERC_TestFactory.insertAccounts(200, Schema.SObjectType.Account.getRecordTypeInfosByName().get('Non-HCP').getRecordTypeId());
	static List<Case> cases                = new List<Case>();
	static List<Address_GLBL__c> addresses = new List<Address_GLBL__c>();
	static User testUser = MERC_TestFactory.getRunningUser();

	static
	{
		for (Account a : nonHcpAccounts)
		{
			cases.add(new Case(AccountId = a.Id));
			addresses.add(new Address_GLBL__c(Account_GLBL__c=a.Id));
		}
		insert cases;
		insert addresses;
	}

	static List<Meeting_MERC__c> meetings                 = MERC_TestFactory.insertMeetings(200);
	static List<Agenda_Item_MERC__c> meetingAgendaItems   = new List<Agenda_Item_MERC__c>();
	static List<Meeting_Participant_MERC__c> participants = new List<Meeting_Participant_MERC__c>();
	static List<Travel_Itinerary_MERC__c> itineraries     = new List<Travel_Itinerary_MERC__c>();
	static List<Participant_Agenda_MERC__c> agendaItems   = new List<Participant_Agenda_MERC__c>();
	static
	{
		for (Integer i=0; i<200; i++)
		{
			participants.add(new Meeting_Participant_MERC__c(Account_MERC__c=nonHcpAccounts[i].Id, Meeting_MERC__c=meetings[i].Id));
			MeetingAgendaItems.add(new Agenda_Item_MERC__c(Meeting_MERC__c=meetings[i].Id));
		}
		insert participants;
		insert meetingAgendaItems;
		for (Integer i=0; i<200; i++)
		{
			itineraries.add(new Travel_Itinerary_MERC__c(Account_MERC__c=participants[i].Account_MERC__c, Meeting_Participant_MERC__c=participants[i].Id));
			agendaItems.add(new Participant_Agenda_MERC__c(Meeting_Participant_MERC__c=participants[i].Id, Session_MERC__c=meetingAgendaItems[i].Id));
		}
		insert itineraries;
		insert agendaItems;
	}

	@isTest static void test_should_set_Anonymise_flag_when_meeting_completed() {
		System.runAs(testUser)
		{
			List<Meeting_MERC__c> meetingsToClose = new List<Meeting_MERC__c>();
			for (Meeting_MERC__c meeting : [SELECT Id, Meeting_Status_MERC__c, Budget_is_Final_MERC__c, MCP_work_MERC__c, Event_Occurred_MERC__c FROM Meeting_MERC__c WHERE Id IN :meetings])
			{
				meeting.Meeting_Status_MERC__c = 'Complete - Closed';
				meeting.Budget_is_Final_MERC__c = 'Yes';
				meeting.MCP_work_MERC__c = 'No';
				meeting.Event_Occurred_MERC__c = 'Yes';
				meetingsToClose.add(meeting);
			}

			Test.startTest();
			update meetingsToClose;
			Test.stopTest();

			System.assertEquals(200, [SELECT COUNT() FROM Account WHERE Id IN :nonHcpAccounts AND Anonymise_Record_MERC__c = true]);
			System.assertEquals(200, [SELECT COUNT() FROM Case WHERE Id IN :cases AND Anonymise_Record_MERC__c = true]);
			System.assertEquals(200, [SELECT COUNT() FROM Address_GLBL__c WHERE Id IN :addresses AND Anonymise_Record_MERC__c = true]);
			System.assertEquals(200, [SELECT COUNT() FROM Meeting_Participant_MERC__c WHERE Id IN :participants AND Anonymise_Record_MERC__c = true]);
			System.assertEquals(200, [SELECT COUNT() FROM Travel_Itinerary_MERC__c WHERE Id IN :itineraries AND Anonymise_Record_MERC__c = true]);
			System.assertEquals(200, [SELECT COUNT() FROM Participant_Agenda_MERC__c WHERE Id IN :agendaItems AND Anonymise_Record_MERC__c = true]);
		}
	}

}