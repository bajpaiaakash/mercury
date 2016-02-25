@isTest
private class MERC_CancelDelegateMgmtProcessTest {
    
    @isTest static void meetingParticipantUpdateTest() {
        Meeting_MERC__c meeting = Merc_TestFactory.insertMeetings(1)[0];
        Account acc = Merc_TestFactory.insertAccounts(1)[0];
        Meeting_Participant_MERC__c participant = Merc_TestFactory.insertParticipants(meeting.Id, new List<Account>{acc})[0];
        
        Meeting_Process_MERC__c process = new Meeting_Process_MERC__c(
            Meeting_Participant_MERC__c = participant.Id,
            Process_Type_MERC__c = 'Registration'
            );

        insert process;

        Meeting_Tasks_MERC__c task = new Meeting_Tasks_MERC__c(
            Meeting_Process_MERC__c = process.Id,
            Task_Status_MERC__c = 'Incomplete'
            );

        insert task;

        participant.Status_MERC__c = 'Cancelled';
        
        System.assertEquals('Cancelled', participant.Status_MERC__c); //Added by Vijay Garg For US-39907 on 24-Feb-2016
        
        test.startTest(); //Added by Vijay Garg For US-39907 on 24-Feb-2016
        update participant;
        test.stopTest(); //Added by Vijay Garg For US-39907 on 24-Feb-2016
      
        Meeting_Tasks_MERC__c postTask = [SELECT Id, Task_Status_MERC__c
                                            FROM Meeting_Tasks_MERC__c
                                           WHERE Id = :task.Id];
        
        System.assertEquals('Completed - Process Cancelled', postTask.Task_Status_MERC__c);
        
        //Start: Added by Vijay Garg; for US-39907 on 25-Feb-2016
        MERC_TriggerHandlerStateManager.deactivateAll();
        meeting.Meeting_Status_MERC__c = 'Complete - Cancelled';
        meeting.Confirm_Meeting_Cancellation_MERC__c = true;
        update meeting;
        //End: Added by Vijay Garg; for US-39907 on 25-Feb-2016

    }
}