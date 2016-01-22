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
        update participant;
      
        Meeting_Tasks_MERC__c postTask = [SELECT Id, Task_Status_MERC__c
                                            FROM Meeting_Tasks_MERC__c
                                           WHERE Id = :task.Id];

        System.assertEquals('Completed - Process Cancelled', postTask.Task_Status_MERC__c);

    }
}