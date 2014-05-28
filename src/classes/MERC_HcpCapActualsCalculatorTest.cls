@isTest
private class MERC_HcpCapActualsCalculatorTest {

	static List<Meeting_MERC__c> meetings;
	static List<Account> accounts;
	static List<Meeting_Participant_MERC__c> participants;
	//static List<Meeting_Participant_MERC__c> participants2;

	static {
		MERC_TestFactory.loadFMVSettings();
		accounts = MERC_TestFactory.insertHcpAccountsInCountry(5, 'GB'); //insert 5 accounts
		meetings = MERC_TestFactory.insertMeetings(2); //insert 2 meetings
		participants = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts); //insert 5 participants
		//participants2 = MERC_TestFactory.insertParticipants(meetings.get(1).Id, accounts); //insert 5 participants
		MERC_TestFactory.loadDeclarativeRollupSummaries();
	}

	@isTest static void test_with_one_meeting() {
		Test.startTest();

		Meeting_MERC__c m = meetings.get(0);
		m.Meeting_Status_MERC__c = 'Forecasted';
		update m;

		Meeting_Participant_MERC__c p1 = participants.get(0);
		p1.Proposed_Final_Fee_MERC__c = 95;
		p1.Minimum_Fee_MERC__c = 90;
		p1.Maximum_Fee_MERC__c = 110;
		p1.Minimum_Rate_MERC__c = 100;
		p1.Maximum_Rate_MERC__c = 100;
		p1.Include_CAP_Roll_Up_MERC__c = true;
		update p1;

		//Meeting_MERC__r.End_Date_of_Event_MERC__c = THIS_YEAR AND Meeting_MERC__r.Meeting_Status_MERC__c = 'Forecasted' AND Include_CAP_Roll_Up_MERC__c = TRUE AND Status_MERC__c NOT IN('Cancelled', 'Rejected', 'Declined')

		system.assertEquals(95, [Select Reserved_CAP_MERC__c FROM Account WHERE Id = :p1.Account_MERC__c].Reserved_CAP_MERC__c);

		m = meetings.get(0);
		m.Number_of_Expected_Employees_MERC__c = 10;
		m.Number_of_Expected_Speakers_MERC__c = 10;
		m.Interaction_Type_MERC__c = 'Virtual';
		m.Meeting_Status_MERC__c = 'Registered';
		m.Preferred_Venue_Addr_1_MERC__c = 'somewhere fun';
		m.Target_Audience_List_MERC__c = 'Nurses';
		m.Number_of_Expected_Non_HCP_MERC__c = 10;
		m.Planned_Budget_MERC__c = 3000;
		m.City_of_Meeting_MERC__c = 'Philadelphia';
		update m;

		p1.Final_Fee_MERC__c = 95;
		update p1;

		system.assertEquals(95, [Select Allocated_CAP_MERC__c FROM Account WHERE Id = :p1.Account_MERC__c].Allocated_CAP_MERC__c);

		//m.Meeting_Status_MERC__c = 'Active';
		//m.Meeting_Objectives_MERC__c = 'some objectives';
		//update m;

		//m.Meeting_Status_MERC__c = 'Complete';
		//m.Compliant_MERC__c = 'Yes';
		//m.Budget_is_Final_MERC__c = 'Yes';
		//update m;

		//p1 = participants.get(0);
		//p1.Services_Rendered_MERC__c = 'Yes';
		//update p1;

		//system.assertEquals(100, [Select Speaking_Paid_CAP_MERC__c FROM Account WHERE Id = :p1.Account_MERC__c].Speaking_Paid_CAP_MERC__c);

		Test.stopTest();
	}

	@istest static void test_speaking_paid_cap() {
		Test.startTest();

		Meeting_MERC__c m = meetings.get(0);
		m.Meeting_Status_MERC__c = 'Forecasted';
		update m;

		Meeting_Participant_MERC__c p1 = participants.get(0);
		p1.Proposed_Final_Fee_MERC__c = 95;
		p1.Final_Fee_MERC__c = 95;
		p1.Minimum_Fee_MERC__c = 90;
		p1.Maximum_Fee_MERC__c = 110;
		p1.Minimum_Rate_MERC__c = 100;
		p1.Maximum_Rate_MERC__c = 100;
		p1.Include_CAP_Roll_Up_MERC__c = true;
		update p1;

		m.Number_of_Expected_Employees_MERC__c = 10;
		m.Number_of_Expected_Speakers_MERC__c = 10;
		m.Interaction_Type_MERC__c = 'Virtual';
		m.Meeting_Status_MERC__c = 'Registered';
		m.Preferred_Venue_Addr_1_MERC__c = 'somewhere fun';
		m.Target_Audience_List_MERC__c = 'Nurses';
		m.Number_of_Expected_Non_HCP_MERC__c = 10;
		m.Planned_Budget_MERC__c = 3000;
		m.City_of_Meeting_MERC__c = 'Philadelphia';
		update m;

		m.Meeting_Status_MERC__c = 'Active';
		m.Meeting_Objectives_MERC__c = 'some objectives';
		update m;

		m.Meeting_Status_MERC__c = 'Complete';
		m.Compliant_MERC__c = 'Yes';
		m.Budget_is_Final_MERC__c = 'Yes';
		update m;

		p1 = participants.get(0);
		p1.Services_Rendered_MERC__c = 'Yes';
		update p1;

		system.assertEquals(95, [Select Speaking_Paid_CAP_MERC__c FROM Account WHERE Id = :p1.Account_MERC__c].Speaking_Paid_CAP_MERC__c);

		Test.stopTest();
	}

	//@isTest static void test_with_multiple_meetings() {
	//	Test.startTest();

	//	Meeting_MERC__c m1 = meetings.get(0);
	//	m1.Meeting_Status_MERC__c = 'Forecasted';
	//	update m1;

	//	Meeting_MERC__c m2 = meetings.get(1);
	//	m2.Meeting_Status_MERC__c = 'Not Forecasted';
	//	update m2;

	//	Meeting_Participant_MERC__c p1 = participants.get(0);
	//	p1.Proposed_Final_Fee_MERC__c = 100;
	//	p1.Minimum_Fee_MERC__c = 90;
	//	p1.Maximum_Fee_MERC__c = 110;
	//	p1.Minimum_Rate_MERC__c = 100;
	//	p1.Maximum_Rate_MERC__c = 100;
	//	p1.Include_CAP_Roll_Up_MERC__c = true;
	//	update p1;

	//	Meeting_Participant_MERC__c p2 = participants2.get(0);
	//	p2.Final_Fee_MERC__c = 900;
	//	p1.Proposed_Final_Fee_MERC__c = 95;
	//	p1.Minimum_Fee_MERC__c = 90;
	//	p1.Maximum_Fee_MERC__c = 110;
	//	p1.Minimum_Rate_MERC__c = 100;
	//	p1.Maximum_Rate_MERC__c = 100;
	//	p1.Include_CAP_Roll_Up_MERC__c = true;
	//	update p2;

	//	system.assertEquals(p1.Account_MERC__c, p2.Account_MERC__c);
	//	system.assertEquals(100, [Select Reserved_CAP_MERC__c FROM Account WHERE Id = :p1.Account_MERC__c].Reserved_CAP_MERC__c);

	//	m2.Meeting_Status_MERC__c = 'Forecasted';
	//	update m2;

	//	system.assertEquals(1000, [Select Reserved_CAP_MERC__c FROM Account WHERE Id = :p1.Account_MERC__c].Reserved_CAP_MERC__c);

	//	Test.stopTest();
	//}

}