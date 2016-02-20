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
    static List<Meeting_Participant_MERC__c> participants = MERC_TestFactory.insertParticipants_forLinetems(meeting.Id, accounts, 'Attended');


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
            participant.Final_Fee_Rollup_MERC__c = 100;  
            participant.Status_MERC__c = 'Attended';
            participant.Include_CAP_Roll_Up_MERC__c = True;
            participant.Confirm_Final_Fee_MERC__c = 'Confirmed';
            participant.Proposed_Final_Fee_MERC__c = 10;
            participant.Minimum_Rate_MERC__c = 10;
            participant.Minimum_Fee_MERC__c = 90;
            participant.Maximum_Fee_MERC__c = 110;
            participant.Maximum_Rate_MERC__c = 100;
            
            //participant.Services_Rendered_MERC__c = 'No';  //Modification done by Jyoti Gaur on 17 Nov for US-38733
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
            System.assertEquals(100, account.MERC_Allocated_Fee_for_Current_Year__c);   
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
        /*meeting.Meeting_Status_MERC__c = 'Complete';
        meeting.Compliant_MERC__c = 'a value';
        meeting.Budget_is_Final_MERC__c = 'Yes';
        update meeting;*/
        meeting.Date_of_Event_MERC__c = Date.Today()-365;
        meeting.End_Date_of_Event_MERC__c = Date.Today().adddays(5);
        update meeting;
        
        for (Meeting_Participant_MERC__c participant : participants) {
            participant.Final_Fee_Rollup_MERC__c = 200;
            participant.Services_Rendered_MERC__c = 'Yes';
            participant.Include_CAP_Roll_Up_MERC__c = True;
            participant.Confirm_Final_Fee_MERC__c = 'Confirmed';
            participant.Proposed_Final_Fee_MERC__c = 10;
            participant.Minimum_Rate_MERC__c = 10;
            participant.Minimum_Fee_MERC__c = 90;
            participant.Maximum_Fee_MERC__c = 110;
            participant.Maximum_Rate_MERC__c = 100;
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
            System.assertEquals(200, account.MERC_Allocated_Fee_for_Next_Yr_Cons_Only__c);
        }
    }

    @isTest
    static void itShouldRollupReservedCapValues()
    {
        MERC_TriggerHandlerStateManager.deactivateAll();
        meeting.Meeting_Status_MERC__c = 'Forecasted';
        meeting.Date_of_Event_MERC__c = Date.Today();
        update meeting;
        
        for (Meeting_Participant_MERC__c participant : participants) {
            //participant.Final_Fee_Rollup_MERC__c = 50;
            participant.Status_MERC__c = 'Attended';
            participant.Include_CAP_Roll_Up_MERC__c = True;
            participant.Confirm_Final_Fee_MERC__c = 'Confirmed';
            participant.Proposed_Final_Fee_MERC__c = 10;
            participant.Payment_Required_for_Meeting_MERC__c = 'No';
            participant.Final_Fee_Rollup_MERC__c = 10;
            participant.Minimum_Rate_MERC__c = 10;
            participant.Minimum_Fee_MERC__c = 90;
            participant.Maximum_Fee_MERC__c = 110;
            participant.Maximum_Rate_MERC__c = 100;
            participant.Higher_Fee_Approval__c = 'Not Required';
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
            System.assertEquals(10, account.Reserved_CAP_MERC__c);
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
                       Reserved_CAP_MERC__c,MERC_Allocated_Fee_for_Current_Year__c,
                       MERC_Allocated_Fee_for_Next_Yr_Cons_Only__c,
                       Count_Dietary_Preferences_MERC__c,
                       HCP_Designated_Individuals_MERC__c,
                       HCP_Contracting_Party_MERC__c
                  FROM Account
                 WHERE Id IN :accounts];
    }
}