/*
    MERC_AccountRollupsTest
    @author : Kyle Thornton, Mavens Consulting
    @created : 3 Sep 2015
    @description : Unit Tests for MERC_AccountRollups
    @modified by :
    @modified date :

*/
@isTest
private class MERC_AccountRollupsTest
{
    private static final Integer DATA_SIZE = 1;
    static List<Account> accounts  = MERC_TestFactory.insertAccounts(DATA_SIZE);
    static Account linkAccount = MERC_TestFactory.insertAccounts(1)[0];
    static Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1)[0];
    static List<Meeting_Participant_MERC__c> participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts, 'Attended');


    @isTest
    static void itShouldRollupAllocatedCapValues()
    {
        MERC_TriggerHandlerStateManager.deactivateAll();
        meeting.Meeting_Status_MERC__c = 'Registered';
        meeting.City_of_Meeting_MERC__c = 'London';
        meeting.Number_of_Expected_Deletgates_MERC__c = 1;
        meeting.Number_of_Expected_Employees_MERC__c = 1;
        meeting.Number_of_Expected_Non_HCP_MERC__c = 1;
        meeting.Number_of_Expected_Speakers_MERC__c = 1;
        meeting.Planned_Budget_MERC__c = 10000;
        update meeting;


        for (Meeting_Participant_MERC__c participant : participants) {
            participant.Final_Fee_Rollup_MERC__c = 0;   //Modification done by Jyoti Gaur on 10 Nov for US-38733
            participant.Status_MERC__c = 'Attended';
            participant.Services_Rendered_MERC__c = 'Yes';
        }
        update participants;
        MERC_TriggerHandlerStateManager.activateAll();

        Test.startTest();
        Map<Id, Account> accountsMap = new Map<Id, Account> (accounts);
        MERC_AccountRollups rollup = new MERC_AccountRollups(accountsMap.keySet());
        System.enqueueJob(rollup);
        Test.stopTest();

        accounts = getAccounts();

        System.assertEquals(accounts.size(), DATA_SIZE);
        for (Account account : accounts) {
            System.assertEquals(0, account.Allocated_CAP_MERC__c);    //Modification done by Jyoti Gaur on 10 Nov for US-38733
        }
    }

    @isTest
    static void itShouldRollupSpeakingCapValues()
    {
        //walk the meeting through proper status chain to avoid validation rule errors
        MERC_TriggerHandlerStateManager.deactivateAll();
        meeting.Meeting_Status_MERC__c = 'Registered';
        meeting.City_of_Meeting_MERC__c = 'London';
        meeting.Number_of_Expected_Deletgates_MERC__c = 1;
        meeting.Number_of_Expected_Employees_MERC__c = 1;
        meeting.Number_of_Expected_Non_HCP_MERC__c = 1;
        meeting.Number_of_Expected_Speakers_MERC__c = 1;
        meeting.Planned_Budget_MERC__c = 10000;
        update meeting;
        meeting.Meeting_Objectives_MERC__c = 'Objectives!';
        meeting.Target_Audience_List_MERC__c = 'Target Audience';
        meeting.Meeting_Status_MERC__c = 'Active';
        update meeting;
        meeting.Meeting_Status_MERC__c = 'Complete';
        meeting.Compliant_MERC__c = 'a value';
        meeting.Budget_is_Final_MERC__c = 'Yes';
        update meeting;

        for (Meeting_Participant_MERC__c participant : participants) {
            participant.Final_Fee_Rollup_MERC__c = 200;
            participant.Services_Rendered_MERC__c = 'Yes';
        }
        update participants;
        MERC_TriggerHandlerStateManager.activateAll();

        Test.startTest();
        Map<Id, Account> accountsMap = new Map<Id, Account> (accounts);
        MERC_AccountRollups rollup = new MERC_AccountRollups(accountsMap.keySet());
        System.enqueueJob(rollup);
        Test.stopTest();

        accounts = getAccounts();

        System.assertEquals(accounts.size(), DATA_SIZE);
        for (Account account : accounts) {
            System.assertEquals(200, account.Speaking_Paid_CAP_MERC__c);
        }
    }

    @isTest
    static void itShouldRollupReservedCapValues()
    {
        MERC_TriggerHandlerStateManager.deactivateAll();
        for (Meeting_Participant_MERC__c participant : participants) {
            participant.Proposed_Final_Fee_Rollup_MERC__c = 50;
            participant.Status_MERC__c = 'Attended';
        }
        update participants;
        MERC_TriggerHandlerStateManager.activateAll();

        Test.startTest();
        Map<Id, Account> accountsMap = new Map<Id, Account> (accounts);
        MERC_AccountRollups rollup = new MERC_AccountRollups(accountsMap.keySet());
        System.enqueueJob(rollup);
        Test.stopTest();

        accounts = getAccounts();

        System.assertEquals(accounts.size(), DATA_SIZE);
        for (Account account : accounts) {
            System.assertEquals(50, account.Reserved_CAP_MERC__c);
        }
    }

    @isTest
    static void testRollupWhenErrorOccurs()
    {
        Test.setReadOnlyApplicationMode(true);
        Test.startTest();
        Boolean didFail = false;
        try {
            Map<Id, Account> accountsMap = new Map<Id, Account> (accounts);

            MERC_AccountRollups rollup = new MERC_AccountRollups(accountsMap.keySet());
            rollup.execute(null);
        } catch (Exception ex) {
            didFail = true;
            System.assert(ex.getMessage().contains('INSERT_UPDATE_DELETE_NOT_ALLOWED_DURING_MAINTENANCE'));
        }
        Test.stopTest();

        System.assert(didFail);
    }

    @isTest
    static void exerciseAddingParentAccountsToParentAccountIds() {
        //we can't test that the queable job was called as that can't be done from a test but we can at least
        //exercise the code that adds the parents to the parentIds list
        for (Account account : accounts) {
            account.HCP_Designated_Individuals_MERC__c = linkAccount.id;
            account.HCP_Contracting_Party_MERC__c = linkAccount.id;
        }
        update accounts;

        Test.startTest();
        Map<Id, Account> accountsMap = new Map<Id, Account> (accounts);
        MERC_AccountRollups rollup = new MERC_AccountRollups(accountsMap.keySet());
        System.enqueueJob(rollup);
        Test.stopTest();
    }

    private static List<Account> getAccounts() {
        return [SELECT Id,
                       Allocated_CAP_MERC__c,
                       Speaking_Paid_CAP_MERC__c,
                       Reserved_CAP_MERC__c,
                       Count_Dietary_Preferences_MERC__c,
                       HCP_Designated_Individuals_MERC__c,
                       HCP_Contracting_Party_MERC__c
                  FROM Account
                 WHERE Id IN :accounts];
    }
}