@isTest
private class MERC_HcpCapActualsCalculatorTest {

	static List<Meeting_MERC__c> meetings;
	static List<Account> accounts;
	static List<Meeting_Participant_MERC__c> participants;

	static {
		MERC_TestFactory.loadFMVSettings();
		accounts = MERC_TestFactory.insertHcpAccountsInCountry(1, 'GB'); //insert 5 accounts
		meetings = MERC_TestFactory.insertMeetings(1); //insert 2 meetings
		participants = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts); //insert 5 participants
	}

	@isTest
	static void test_should_rollup_reserved_cap_to_account() {
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

		Set<Id> accountIds = new Set<Id>();
		for (Account account : accounts) {
			accountIds.add(account.Id);
		}
		Test.startTest();
		System.enqueueJob(new MERC_AccountRollups(accountIds));
		Test.stopTest();

		system.assertEquals(95, [Select Reserved_CAP_MERC__c FROM Account WHERE Id = :p1.Account_MERC__c].Reserved_CAP_MERC__c);
	}

    @isTest
	static void test_should_rollup_allocated_cap_to_account() {
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

		Set<Id> accountIds = new Set<Id>();
		for (Account account : accounts) {
			accountIds.add(account.Id);
		}
		Test.startTest();
		System.enqueueJob(new MERC_AccountRollups(accountIds));
		Test.stopTest();

		system.assertEquals(95, [Select Allocated_CAP_MERC__c FROM Account WHERE Id = :p1.Account_MERC__c].Allocated_CAP_MERC__c);
	}

	@isTest
	static void test_should_rollup_allocated_cap_multicurrency() {
		p('starting test...');
		p('UserInfo currency = '+UserInfo.getDefaultCurrency());

		for (Account a : accounts) {
			a.CurrencyIsoCode = 'CHF';
		}
		update accounts;

		Meeting_MERC__c m = meetings.get(0);
		m.Meeting_Status_MERC__c = 'Forecasted';
		update m;

		Meeting_Participant_MERC__c p1 = participants.get(0);
		p1.CurrencyIsoCode = 'CHF';
		p1.Proposed_Final_Fee_MERC__c = 95;
		p1.Minimum_Fee_MERC__c = 90;
		p1.Maximum_Fee_MERC__c = 110;
		p1.Minimum_Rate_MERC__c = 100;
		p1.Maximum_Rate_MERC__c = 100;
		p1.Include_CAP_Roll_Up_MERC__c = true;
		update p1;

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

		Set<Id> accountIds = new Set<Id>();
		for (Account account : accounts) {
			accountIds.add(account.Id);
		}
		Test.startTest();
		System.enqueueJob(new MERC_AccountRollups(accountIds));
		Test.stopTest();

		system.assertEquals(95, [Select Allocated_CAP_MERC__c FROM Account WHERE Id = :p1.Account_MERC__c].Allocated_CAP_MERC__c);
	}

	@istest
	static void test_speaking_paid_cap() {
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

		Set<Id> accountIds = new Set<Id>();
		for (Account account : accounts) {
			accountIds.add(account.Id);
		}

		Test.startTest();
		System.enqueueJob(new MERC_AccountRollups(accountIds));
		Test.stopTest();

		system.assertEquals(95, [Select Speaking_Paid_CAP_MERC__c FROM Account WHERE Id = :p1.Account_MERC__c].Speaking_Paid_CAP_MERC__c);
	}

	static void p(String m) {
		System.debug(LoggingLevel.INFO, '\n\n\nYYZ - '+m+'\n\n\n\n');
	}
}