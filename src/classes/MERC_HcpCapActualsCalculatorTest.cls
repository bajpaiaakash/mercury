@isTest
private class MERC_HcpCapActualsCalculatorTest {

    static List<Meeting_MERC__c> meetings;
    static List<Account> accounts;
    static List<Meeting_Participant_MERC__c> participants;

    static {
        MERC_TestFactory.loadFMVSettings();
        final Integer DATA_SIZE = 1;
        accounts  = MERC_TestFactory.insertAccounts(DATA_SIZE);
        meetings = MERC_TestFactory.insertMeetings_CAP(1,NULL,'Forecasted'); 
        participants = MERC_TestFactory.insertParticipants_forLinetems(meetings[0].Id, accounts); 
    }

    @isTest
    static void test_should_rollup_reserved_cap_to_account() {
        
        MERC_TriggerHandlerStateManager.deactivateAll();
        Meeting_MERC__c m = meetings.get(0);
        m.Meeting_Status_MERC__c = 'Forecasted';
        Test.startTest();
        update m;

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
        
        Set<Id> accountIds = new Set<Id>();
        for (Account account : accounts) {
            accountIds.add(account.Id);
        }
       
        System.enqueueJob(new MERC_AccountRollups(accountIds));
        Test.stopTest();
        accounts = getAccounts();

        
        for (Account account : accounts) {
            System.assertEquals(10, account.Reserved_CAP_MERC__c);
        }
        //system.assertEquals(10, [Select Reserved_CAP_MERC__c FROM Account WHERE Id = :participants[0].Account_MERC__c].Reserved_CAP_MERC__c);
    }

    @isTest
    static void test_should_rollup_allocated_cap_to_account() {
        Meeting_MERC__c m = meetings.get(0);
        m.Meeting_Status_MERC__c = 'Forecasted';
        Test.startTest();
        update m;

        Meeting_Participant_MERC__c p1 = participants.get(0);
        p1.Proposed_Final_Fee_MERC__c = 95;
        p1.Minimum_Fee_MERC__c = 90;
        p1.Maximum_Fee_MERC__c = 110;
        p1.Minimum_Rate_MERC__c = 100;
        p1.Higher_Fee_Approval__c = 'Approved';
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
        p1.Services_Rendered_MERC__c = 'No';  //Modification done by Jyoti Gaur on 17 Nov for US-38733
        update p1;

        Set<Id> accountIds = new Set<Id>();
        for (Account account : accounts) {
            accountIds.add(account.Id);
        }
        
        System.enqueueJob(new MERC_AccountRollups(accountIds));
        Test.stopTest();

        system.assertEquals(95, [Select MERC_Allocated_CAP__c FROM Account WHERE Id = :p1.Account_MERC__c].MERC_Allocated_CAP__c);
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
        Test.startTest();
        update m;

        Meeting_Participant_MERC__c p1 = participants.get(0);
        p1.CurrencyIsoCode = 'CHF';
        p1.Proposed_Final_Fee_MERC__c = 95;
        p1.Minimum_Fee_MERC__c = 90;
        p1.Maximum_Fee_MERC__c = 110;
        p1.Higher_Fee_Approval__c = 'Approved';
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
        p1.Services_Rendered_MERC__c = 'No';  //Modification done by Jyoti Gaur on 17 Nov for US-38733
        update p1;

        Set<Id> accountIds = new Set<Id>();
        for (Account account : accounts) {
            accountIds.add(account.Id);
        }
        
        System.enqueueJob(new MERC_AccountRollups(accountIds));
        Test.stopTest();

       system.assertEquals(95, [Select MERC_Allocated_CAP__c FROM Account WHERE Id = :p1.Account_MERC__c].MERC_Allocated_CAP__c);
    }

    
    static void p(String m) {
        System.debug(LoggingLevel.INFO, '\n\n\nYYZ - '+m+'\n\n\n\n');
    }
    
    private static List<Account> getAccounts() {
        return [SELECT Id,
                       Reserved_CAP_MERC__c,MERC_Allocated_Fee_for_Current_Year__c,
                       MERC_Allocated_Fee_for_Next_Yr_Cons_Only__c,
                       Count_Dietary_Preferences_MERC__c,
                       HCP_Designated_Individuals_MERC__c,
                       HCP_Contracting_Party_MERC__c,(SELECT Final_Fee_Rollup_MERC__c,
                                           Proposed_Final_Fee_Rollup_MERC__c,
                                           Status_MERC__c,
                                           Meeting_MERC__r.MERC_Meeting_Complete_Canceled_Clsd_Date__c,
                                           Meeting_MERC__r.MERC_Meeting_End_date_plus_6_months__c,
                                           Meeting_MERC__r.MERC_Meeting_End_Date_Inactive__c,
                                           Services_Rendered_MERC__c,
                                           Meeting_MERC__r.Meeting_Status_MERC__c,
                                           Meeting_MERC__r.Date_of_Event_MERC__c,
                                           Meeting_MERC__r.End_Date_of_Event_MERC__c,
                                           Meeting_MERC__r.RecordType.DeveloperName,RecordType.DeveloperName
                                      FROM Event_Participants__r WHERE Include_CAP_Roll_Up_MERC__c = TRUE
                                       AND Confirm_Final_Fee_MERC__c = 'Confirmed' 
                                       AND RecordType.DeveloperName IN('MERC_Consulting','MERC_Service_Provider')
                                     )
                  FROM Account
                 WHERE Id IN :accounts];
    }
}