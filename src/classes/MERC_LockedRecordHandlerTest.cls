@isTest
private class MERC_LockedRecordHandlerTest {
    
    static List<Meeting_MERC__c> meetings;
    static List<Account> accounts;
    static List<Meeting_Day_MERC__c> meetingDays;
    static List<Meeting_Participant_MERC__c> participants;
    static List<Meeting_Tasks_MERC__c> tasks;

    static {
        accounts = MERC_TestFactory.insertAccounts(5); //insert 5 accounts
        meetings = MERC_TestFactory.insertMeetings(2); //insert 2 meetings
        meetingDays = MERC_TestFactory.insertMeetingDays(meetings.get(0).Id, 3); //insert 3 days
     
    }

    @isTest static void test_should_prevent_meeting_related_updates() {
            Test.startTest();
          participants = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts, 'Accepted'); //insert 5 participants
        tasks = MERC_TestFactory.insertMeetingTask(participants.get(0).Id);
        
    
        Meeting_MERC__c meeting = meetings.get(0);
        meeting.Lock_Meeting_MERC__c = true;
        update meeting;

        meeting.Name = 'a different name';
        try {
            update meeting;
        } catch(System.DmlException e) {
            system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, Operation Failed:  The record is locked due to the meeting being closed.  Please contact Customer Meeting Services for Assistance'));
        }

        Meeting_Participant_MERC__c participant = participants.get(0);
        participant.Status_MERC__c = 'a different status';
        try {
            update participant;
        } catch(System.DmlException e) {
            system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, Operation Failed:  The record is locked due to the meeting being closed.  Please contact Customer Meeting Services for Assistance'));
        }

        Meeting_Tasks_MERC__c task = tasks.get(0);
        task.Name = 'a different name';
        try {
            update task;
        } catch(System.DmlException e) {
            system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, Operation Failed:  The record is locked due to the meeting being closed.  Please contact Customer Meeting Services for Assistance'));
        }
   Test.stopTest();
    }


    @isTest static void test_should_prevent_meeting_related_updates_Participant() {
            Test.startTest();
          participants = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts, 'Accepted'); //insert 5 participants
        tasks = MERC_TestFactory.insertMeetingTask(participants.get(0).Id);
        
    
        Meeting_MERC__c meeting = meetings.get(0);
        meeting.Lock_Meeting_MERC__c = true;
        update meeting;

        Meeting_Participant_MERC__c participant = participants.get(0);
        participant.Status_MERC__c = 'a different status';
        try {
            update participant;
        } catch(System.DmlException e) {
            system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, Operation Failed:  The record is locked due to the meeting being closed.  Please contact Customer Meeting Services for Assistance'));
        }

   Test.stopTest();
    }

@isTest static void test_should_prevent_meeting_related_updates_Task() {
            Test.startTest();
          participants = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts, 'Accepted'); //insert 5 participants
        tasks = MERC_TestFactory.insertMeetingTask(participants.get(0).Id);
        
    
        Meeting_MERC__c meeting = meetings.get(0);
        meeting.Lock_Meeting_MERC__c = true;
        update meeting;

        Meeting_Tasks_MERC__c task = tasks.get(0);
        task.Name = 'a different name';
        try {
            update task;
        } catch(System.DmlException e) {
            system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, Operation Failed:  The record is locked due to the meeting being closed.  Please contact Customer Meeting Services for Assistance'));
        }
   Test.stopTest();
    }

    @isTest static void test_should_successfully_insert_meeting_products() {
      
      
                    Test.startTest();
          participants = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts, 'Accepted'); //insert 5 participants
        tasks = MERC_TestFactory.insertMeetingTask(participants.get(0).Id);
        
    
      
        Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1)[0];
        
        Product_Group_GLBL__c product = new Product_Group_GLBL__c();
        product.Cntry_Cd_GLBL__c = 'ZZ';
        product.Crt_Dt_GLBL__c = Date.today();
        product.Dialect_Nm_GLBL__c = 'Enlgish';
        product.Grp_Prps_Cd_GLBL__c = 'MKTP';
        product.Lst_Pblsh_Dt_GLBL__c = Date.today();
        product.Updt_Dt_GLBL__c = Date.today();
        insert product;


        Meeting_Products_MERC__c products = new Meeting_Products_MERC__c();
        products.Meeting_MERC__c = meeting.Id;
        products.Product_MERC__c = product.Id;
        insert products;
        Test.stopTest();

        //check to makes sure record inserted.
        System.assertEquals(1, [SELECT Id FROM Meeting_Products_MERC__c WHERE Id = :products.Id].size());
    }
}