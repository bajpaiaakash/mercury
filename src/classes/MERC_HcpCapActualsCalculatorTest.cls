@isTest
private class MERC_HcpCapActualsCalculatorTest {
	
	static List<Meeting_MERC__c> meetings;
	static List<Account> accounts;
	static List<Meeting_Day_MERC__c> meetingDays;
	static List<Meeting_Participant_MERC__c> participants;
	static List<Meeting_Participant_MERC__c> participants2;

	static {
		accounts = MERC_TestFactory.insertAccounts(5); //insert 5 accounts
		meetings = MERC_TestFactory.insertMeetings(2); //insert 2 meetings
		meetingDays = MERC_TestFactory.insertMeetingDays(meetings.get(0).Id, 3); //insert 3 days
		participants = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts); //insert 5 participants
		participants2 = MERC_TestFactory.insertParticipants(meetings.get(1).Id, accounts); //insert 5 participants
		MERC_TestFactory.loadDeclarativeRollupSummaries();
	}

	@isTest static void test_with_one_meeting() {
		Test.startTest();
		
		Meeting_MERC__c m = meetings.get(0);
		m.Meeting_Status_MERC__c = 'Forecasted';
		update m;	

		Meeting_Participant_MERC__c p1 = participants.get(0);
		p1.Final_Fee_MERC__c = 100;
		update p1;

		system.assertEquals(100, [Select Reserved_CAP_MERC__c FROM Account WHERE Id = :p1.Account_MERC__c].Reserved_CAP_MERC__c); 

		m = meetings.get(0);
		m.Number_of_Expected_Employees_MERC__c = 10;
		m.Number_of_Expected_Speakers_MERC__c = 10;
		m.Interaction_Type_MERC__c = 'Virtual';
		m.Meeting_Status_MERC__c = 'Registered';
		m.Preferred_Venue_Addr_1_MERC__c = 'somewhere fun';
		m.Target_Audience_List_MERC__c = 'Nurses';
		update m;
		
		system.assertEquals(100, [Select Allocated_CAP_MERC__c FROM Account WHERE Id = :p1.Account_MERC__c].Allocated_CAP_MERC__c); 

		p1 = participants.get(0);
		p1.Services_Rendered_MERC__c = 'Yes';
		update p1;

		system.assertEquals(100, [Select Speaking_Paid_CAP_MERC__c FROM Account WHERE Id = :p1.Account_MERC__c].Speaking_Paid_CAP_MERC__c); 

		Test.stopTest();
	}

	@isTest static void test_with_multiple_meetings() {
		Test.startTest();
		
		Meeting_MERC__c m1 = meetings.get(0);
		m1.Meeting_Status_MERC__c = 'Forecasted';
		update m1;

		Meeting_MERC__c m2 = meetings.get(1);
		m2.Meeting_Status_MERC__c = 'Not Forecasted';
		update m2;	

		Meeting_Participant_MERC__c p1 = participants.get(0);
		p1.Final_Fee_MERC__c = 100;
		update p1;

		Meeting_Participant_MERC__c p2 = participants2.get(0);
		p2.Final_Fee_MERC__c = 900;
		update p2;

		system.assertEquals(p1.Account_MERC__c, p2.Account_MERC__c);
		system.assertEquals(100, [Select Reserved_CAP_MERC__c FROM Account WHERE Id = :p1.Account_MERC__c].Reserved_CAP_MERC__c); 	

		m2.Meeting_Status_MERC__c = 'Forecasted';
		update m2;

		system.assertEquals(1000, [Select Reserved_CAP_MERC__c FROM Account WHERE Id = :p1.Account_MERC__c].Reserved_CAP_MERC__c); 	
		
		Test.stopTest();
	}
	
}