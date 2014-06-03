@isTest
private class MERC_HcpCapYearlyCalculationJobTest {

	static List<Account> accounts = MERC_TestFactory.insertAccounts(200);
	static Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1).get(0);
	static List<Meeting_Participant_MERC__c> participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts);
	static {
		update new Meeting_MERC__c(
					Id                                   =meeting.Id,
					Meeting_Status_MERC__c               ='Registered',
					City_of_Meeting_MERC__c              ='London',
					Number_of_Expected_Employees_MERC__c =10,
					Number_of_Expected_Non_HCP_MERC__c   =10,
					Number_of_Expected_Speakers_MERC__c  =10,
					Interaction_Type_MERC__c             ='Virtual',
					Planned_Budget_MERC__c               =10000
		);

		List<LookupRollupSummary_GLBL__c> lrs = new List<LookupRollupSummary_GLBL__c>();
		lrs.add( new LookupRollupSummary_GLBL__c(
				Active_GLBL__c                    = true,
				AggregateOperation_GLBL__c        = 'Sum',
				AggregateResultField_GLBL__c      = 'Allocated_CAP_MERC__c',
				CalculationMode_GLBL__c           = 'Developer',
				ChildObject_GLBL__c               = 'Meeting_Participant_MERC__c',
				FieldToAggregate_GLBL__c          = 'Final_Fee_MERC__c',
				Name                              = 'Allocated Cap Batch',
				OverrideTriggerValidation_GLBL__c = true,
				ParentObject_GLBL__c              = 'Account',
				RelationshipCriteria_GLBL__c      = 'Meeting_MERC__r.End_Date_of_Event_MERC__c = THIS_YEAR '
				                                  + 'AND Meeting_MERC__r.Meeting_Status_MERC__c IN(\'Registered\', \'Active\') '
				                                  + 'AND Include_CAP_Roll_Up_MERC__c = TRUE '
				                                  + 'AND Status_MERC__c NOT IN(\'Cancelled\', \'Rejected\', \'Declined\')',
				RelationshipField_GLBL__c         = 'Account_MERC__c',
				TreatZeroAsNull_GLBL__c           = false
		));
		insert lrs;
	}

	@isTest static void test_batch_job() {

		for (Meeting_Participant_MERC__c participant : participants) {
			participant.Final_Fee_MERC__c           = 100;
			participant.Include_CAP_Roll_Up_MERC__c = true;
			//participant.Proposed_Final_Fee_MERC__c = 0;
		}
		update participants;

		for (Account a : accounts) {
			a.Allocated_CAP_MERC__c = null;
		}
		update accounts;

		//System.assertEquals(1,[SELECT COUNT() FROM Account WHERE Allocated_CAP_MERC__c=null]);

		Test.startTest();
       	MERC_HcpCapYearlyCalculationJob m = new MERC_HcpCapYearlyCalculationJob();
       	Database.executeBatch(m);
       	Test.stopTest();

       	System.debug([select Allocated_CAP_MERC__c from account]);
       	System.assertEquals(200,[SELECT COUNT() FROM Account WHERE Allocated_CAP_MERC__c=100.0], [select Allocated_CAP_MERC__c from account]);
	}
}


