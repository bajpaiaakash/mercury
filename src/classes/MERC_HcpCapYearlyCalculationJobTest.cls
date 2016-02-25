@isTest
private class MERC_HcpCapYearlyCalculationJobTest {

    static User runningUser = MERC_TestFactory.getRunningUser();
    static User testUser = MERC_TestFactory.getTestingUser();
    static List<Account> accounts;
    static Meeting_MERC__c meeting;
    static List<Meeting_Participant_MERC__c> participants;

    static {
        System.runAs(runningUser) {
            accounts = MERC_TestFactory.insertAccounts(200);
            meeting = MERC_TestFactory.insertMeetings_CAP(1,NULL,'Registered')[0];
            participants = MERC_TestFactory.insertParticipants_forLinetems(meeting.Id, accounts);

            /*update new Meeting_MERC__c(
                        Id                                   =meeting.Id,
                        Meeting_Status_MERC__c               ='Registered',
                        City_of_Meeting_MERC__c              ='London',
                        Number_of_Expected_Employees_MERC__c =10,
                        Number_of_Expected_Non_HCP_MERC__c   =10,
                        Number_of_Expected_Speakers_MERC__c  =10,
                        Interaction_Type_MERC__c             ='Virtual',
                        Planned_Budget_MERC__c               =10000
            );*/
        }
    }

    @isTest static void test_batch_job() {
        System.runAs(testUser) {
        for (Meeting_Participant_MERC__c participant : participants) {
            participant.Final_Fee_Rollup_MERC__c = 100;  
            participant.Status_MERC__c = 'Attended';
            participant.Proposed_Final_Fee_MERC__c = 10;
            participant.Minimum_Rate_MERC__c = 10;
            participant.Minimum_Fee_MERC__c = 90;
            participant.Maximum_Fee_MERC__c = 110;
            participant.Maximum_Rate_MERC__c = 100;
            }
        Test.startTest();
        update participants;
        
        for (Account a : accounts) {
            a.MERC_Allocated_Fee_for_Current_Year__c = null;
        }
        update accounts;

        System.assertEquals(200,[SELECT COUNT() FROM Account WHERE MERC_Allocated_Fee_for_Current_Year__c=null]);

        
            
            MERC_HcpCapYearlyCalculationJob m = new MERC_HcpCapYearlyCalculationJob();
            Database.executeBatch(m);
            Test.stopTest();
        }

    }
}