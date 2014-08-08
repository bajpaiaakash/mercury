/**
 * @author Kyle Thornton
 *
 * test methods for the MERC_AnonymiseNonHCPDataHandler class
 */

@isTest
private class MERC_AnonymiseNonHCPDataHandlerTest {

	static final Integer TEST_DATA_SIZE    = 2;
	static List<Account> nonHcpAccounts    = MERC_TestFactory.insertAccounts(TEST_DATA_SIZE, Schema.SObjectType.Account.getRecordTypeInfosByName().get('Non-HCP').getRecordTypeId());
	static List<Case> cases                = new List<Case>();
	static List<Address_GLBL__c> addresses = new List<Address_GLBL__c>();
	// static User testUser = MERC_TestFactory.getRunningUser();

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

	static List<Meeting_MERC__c> meetings                 = MERC_TestFactory.insertMeetings(TEST_DATA_SIZE);
	static List<Agenda_Item_MERC__c> meetingAgendaItems   = new List<Agenda_Item_MERC__c>();
	static List<Meeting_Participant_MERC__c> participants = new List<Meeting_Participant_MERC__c>();
	static List<Travel_Itinerary_MERC__c> itineraries     = new List<Travel_Itinerary_MERC__c>();
	static List<Participant_Agenda_MERC__c> agendaItems   = new List<Participant_Agenda_MERC__c>();
	//static
	//{
	//	for (Integer i=0; i<TEST_DATA_SIZE; i++)
	//	{
	//		participants.add(new Meeting_Participant_MERC__c(Account_MERC__c=nonHcpAccounts[i].Id, Meeting_MERC__c=meetings[i].Id));
	//		MeetingAgendaItems.add(new Agenda_Item_MERC__c(Meeting_MERC__c=meetings[i].Id));
	//	}
	//	insert participants;
	//	insert meetingAgendaItems;
	//	for (Integer i=0; i<TEST_DATA_SIZE; i++)
	//	{
	//		itineraries.add(new Travel_Itinerary_MERC__c(Account_MERC__c=participants[i].Account_MERC__c, Meeting_Participant_MERC__c=participants[i].Id));
	//		agendaItems.add(new Participant_Agenda_MERC__c(Meeting_Participant_MERC__c=participants[i].Id, Session_MERC__c=meetingAgendaItems[i].Id));
	//	}
	//	System.debug('\n\n\nItineraries: ' + itineraries + '\n\n\n');
	//	insert itineraries;
	//	insert agendaItems;
	//}

	static void p(String m) {
		System.debug(LoggingLevel.INFO,'\n\n\nYYZ - '+m+'\n\n\n\n');
	}

	@isTest 
	static void test_should_set_Anonymise_flag_when_meeting_completed() {
		// System.assertEquals(TEST_DATA_SIZE, [SELECT COUNT() FROM Meeting_MERC__c WHERE Id in :meetings], 'Can\'t see all meetings as system');
		List<Meeting_MERC__c> meetingCheck = [SELECT Id FROM Meeting_MERC__c];
		System.assert(meetingCheck.size()>0, 'Can\'t see any meetings AT ALL!!');			

		User myUser;
Test.startTest();
		myUser = MERC_TestFactory.getRunningUser();
Test.stopTest();
		p('myUser='+myUser);
		System.runAs(myUser)
		{
			Profile p = [SELECT Name from Profile WHERE Id = :myUser.profileId limit 1];
			p('profile='+p);
        	UserRole r =[SELECT Name FROM UserRole WHERE Id = :myUser.userRoleId limit 1];
			p('role='+r);
			List<Group> gs = [SELECT Name FROM Group WHERE Id in (SELECT GroupId FROM GroupMember WHERE UserOrGroupId = :myUser.Id)];
			p('group='+gs);
			meetingCheck = [SELECT Id FROM Meeting_MERC__c];
			System.assert(meetingCheck.size()>0, 'Can\'t see any meetings as '+myUser.username);			
			System.assertEquals(TEST_DATA_SIZE, [SELECT COUNT() FROM Meeting_MERC__c WHERE Id in :meetings], 'Can\'t see meetings as myUser.Name');
		
			List<Meeting_MERC__c> meetingsToClose = new List<Meeting_MERC__c>();
			for (Meeting_MERC__c meeting : [SELECT Id, Meeting_Status_MERC__c, Budget_is_Final_MERC__c, MCP_work_MERC__c, 
											Event_Occurred_MERC__c FROM Meeting_MERC__c WHERE Id IN :meetings])
			{
				meeting.Meeting_Status_MERC__c = 'Complete - Closed';
				meeting.Budget_is_Final_MERC__c = 'Yes';
				meeting.MCP_work_MERC__c = 'No';
				meeting.Event_Occurred_MERC__c = 'Yes';
				meetingsToClose.add(meeting);
			}

			update meetingsToClose;

			System.assertEquals(TEST_DATA_SIZE, [SELECT COUNT() FROM Account WHERE Id IN :nonHcpAccounts AND Anonymise_Record_MERC__c = true]);
			System.assertEquals(TEST_DATA_SIZE, [SELECT COUNT() FROM Case WHERE Id IN :cases AND Anonymise_Record_MERC__c = true]);
			System.assertEquals(TEST_DATA_SIZE, [SELECT COUNT() FROM Address_GLBL__c WHERE Id IN :addresses AND Anonymise_Record_MERC__c = true]);
			System.assertEquals(TEST_DATA_SIZE, [SELECT COUNT() FROM Meeting_Participant_MERC__c WHERE Id IN :participants AND Anonymise_Record_MERC__c = true]);
			System.assertEquals(TEST_DATA_SIZE, [SELECT COUNT() FROM Travel_Itinerary_MERC__c WHERE Id IN :itineraries AND Anonymise_Record_MERC__c = true]);
			System.assertEquals(TEST_DATA_SIZE, [SELECT COUNT() FROM Participant_Agenda_MERC__c WHERE Id IN :agendaItems AND Anonymise_Record_MERC__c = true]);
		}
	}

}