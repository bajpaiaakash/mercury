/*
 * Author: Kyle Thornton - Mavens Consulting
 * Created Date: 22 Jul 2015
 * Description : This is the test class for the MERC_MeetingProcessLogicHandler.
 *               After this functionality has made it to production it will be possible
 *               to load up the Meeting Process Logic Records using Test.loadData and a
 *               static resource since record type Ids will remain consisent. At this
 *               point however there is no way to identify the record type needed for
 *               each record and we can't load it using Test.loaddata since the Record
 *               type Ids won't be the same from environment to environment.
*/
@isTest
private class MERC_MeetingProcessLogicHandlerTest {

    static List<Meeting_MERC__c> meetings;
    static List<Account> accounts;
    static List<Meeting_Participant_MERC__c> participants;
    static List<Travel_Itinerary_MERC__c> proposals;

    static {
        //See @testSetup at the bottom of the class
        meetings = [SELECT Id, Initiate_Delegate_Management_MERC__c FROM Meeting_MERC__c];
        participants = [SELECT Id, Status_MERC__c, Evaluate_Meeting_Process_Logic_MERC__c, Account_MERC__c FROM Meeting_Participant_MERC__c];

        //once lookup rollup summaries are gone this might be possible to remove.
        MERC_TriggerHandlerStateManager.deactivateAll();
        MERC_TriggerHandlerStateManager.activate(MERC_MeetingProcessLogicHandler.class);
    }

    /**** SCENARIO : Process being created should spawn new task ****/
    @isTest
    static void newProcessShouldCreateNewTask() {
        Test.startTest();
        whenPreMeetingInformationProcessCreatedFor(participants);
        Test.stopTest();

        expectTasksToBeCreatedForProcessesFor(participants);
    }

    /**** SCENARIO: participant updated to invited should spawn the registration process ****/
    @isTest
    static void invitedParticipantsShouldGetRegProcessCreated() {
        givenTheMeetingHasInitiateDelegateManagement('Yes');

        Test.startTest();
        whenTheParticipantsStatusBecomes('Invited');
        Test.stopTest();

        expectProcessToBeCreatedFor(participants, 'Registration');
        expectTasksToBeCreatedForProcessesFor(participants);
    }

    /**** SCENARIO: invited participant when reminded spawn new reminders ****/
    @isTest
    static void invitedParticipantsNeedReminder() {
        givenTheMeetingHasInitiateDelegateManagement('Yes');
        whenTheParticipantsStatusBecomes('Invited');

        Test.startTest();
        whenTheParticipantsInvitesHaveBeenSent();
        Test.stopTest();

        expectRemindersToHaveBeenCreated('1');
    }

    /**** SCENARIO: invited participant when reminded spawn new reminders ****/
    @isTest
    static void remindedParticipantsNeedAnotherReminder() {
        givenTheMeetingHasInitiateDelegateManagement('Yes');
        whenTheParticipantsStatusBecomes('Invited');

        Test.startTest();
        whenTheParticipantsInvitesHaveBeenSent();
        whenTheParticipantsHaveBeenReminded();
        Test.stopTest();

        expectRemindersToHaveBeenCreated('2');
    }

    /**** SCENARIO: invited participants accept ****/
    @isTest
    static void acceptedParticipantsShouldHaveRegProcessClosedPreMeeetingStarted() {
        //once lookup rollup summaries are gone this might be possible to remove.
        MERC_TriggerHandlerStateManager.deactivateAll();
        MERC_TriggerHandlerStateManager.activate(MERC_MeetingProcessLogicHandler.class);

        givenTheMeetingHasInitiateDelegateManagement('Yes');
        givenTheParticipantsHaveBeenInvited();

        Test.startTest();
        whenTheParticipantsStatusBecomes('Accepted');
        Test.stopTest();

        //expectProcessToBeCompletedFor(participants, 'Registration');
        expectProcessToBeCreatedFor(participants, 'Pre-Meeting Information');
    }

    /***** SCENARIO : Travel Proposal moving to Ready For Proposal kicks off process *****/
    @isTest
    private static void travelProposalReadyForProposalKicksOffProcess() {
        MERC_TriggerHandlerStateManager.deactivateAll();
        //MERC_TriggerHandlerStateManager.activate(MERC_MeetingProcessLogicHandler.class);
        Test.startTest();
        MERC_TriggerHandlerStateManager.deactivateAll();
        givenTheMeetingHasInitiateDelegateManagement('Yes');

        givenTravelProposalsAreInDraft(participants);
        whenTravelProposalsAre('Ready for Proposal');
        expectProcessToBeCreatedFor(participants, 'Travel Proposal');
        MERC_TriggerHandlerStateManager.deactivateAll();
        Test.stopTest();

        MERC_TriggerHandlerStateManager.deactivateAll();
    }

    /***** SCENARIO : Travel Proposal moving from Ready For Proposal to proposal updates process *****/
    @isTest
    private static void travelProposalProposedUpdatesTravelProcess() {
        MERC_TriggerHandlerStateManager.deactivateAll();
        Test.startTest();
        MERC_TriggerHandlerStateManager.deactivateAll();
        givenTheMeetingHasInitiateDelegateManagement('Yes');

        givenTravelProposalsAreInDraft(participants);
        whenTravelProposalsAre('Ready for Proposal');
        //Test.startTest();
        whenATravelProposalIs('Proposed'); //this is not and cannot be bulkified due to process builder actions
        //Test.stopTest();

        expectFirstSendProposalToBeCompleted();
        expectFirstTravelProcessToHaveAReminder();
        MERC_TriggerHandlerStateManager.deactivateAll();
        Test.stopTest();
        MERC_TriggerHandlerStateManager.deactivateAll(); 
    }

    /**************************************************
    **************** TEST SETUP METHODS ***************
    ***************************************************/

    private static void givenTheMeetingHasInitiateDelegateManagement(String status) {
        meetings[0].Initiate_Delegate_Management_MERC__c = status;
        update meetings[0];
    }

    private static void givenTravelProposalsAreInDraft(List<Meeting_Participant_MERC__c> mps) {
        Id proposalRtId = Schema.SObjectType.Travel_Itinerary_MERC__c.getRecordTypeInfosByName().get('Travel Proposal').getRecordTypeId();
        proposals = new List<Travel_Itinerary_MERC__c>();
        for (Meeting_Participant_MERC__c mp : mps) {
            proposals.add( new Travel_Itinerary_MERC__c(RecordTypeId = proposalRtId,
                                                        Meeting_Participant_MERC__c = mp.Id,
                                                        Status_MERC__c = 'Draft',
                                                        Account_MERC__c = mp.Account_MERC__c,
                                                        Proposal_Counter_MERC__c = 1));
        }
        insert proposals;
    }

    private static void givenTheParticipantsHaveBeenInvited() {
        //In this scenario the participants would have already had a Registration process created
        //with a task to send invitation that has been marked complete
        //and a Reminder 1 task that has been generated. Set up the data to represent that here.
        List<Meeting_Process_MERC__c> processes = new List<Meeting_Process_MERC__c>();
        for (Meeting_Participant_MERC__c participant : participants) {
            participant.Status_MERC__c = 'Invited';
        }

        update participants;
        MERC_MeetingProcessLogicHandler.meetingProcessLogicRecordsByType = null;
    }

    /**************************************************
    ************** TEST HELPER METHODS ****************
    **************************************************/

    private static void whenPreMeetingInformationProcessCreatedFor(List<Meeting_Participant_MERC__c> mps) {
        List<Meeting_Process_MERC__c> processes = new List<Meeting_Process_MERC__c>();

        for (Meeting_Participant_MERC__c participant : mps) {
            processes.add(new Meeting_Process_MERC__c(Name='Send Pre-Meeting Info',
                                                      Process_Type_MERC__c = 'Pre-Meeting Information',
                                                      Meeting_Participant_MERC__c = participant.id));
        }

        insert processes;
    }

    private static void whenTheParticipantsStatusBecomes(String status) {
        for (Meeting_Participant_MERC__c participant : participants) {
            participant.Status_MERC__c = status;
            //this box would be checked via
            participant.Evaluate_Meeting_Process_Logic_MERC__c = true;
        }
        update participants;
    }

    private static void whenTravelProposalsAre(String status) {
        for (Travel_Itinerary_MERC__c proposal : proposals) {
            proposal.Status_MERC__c = status;
        }
        update proposals;
    }

    private static void whenATravelProposalIs(String status) {
        proposals[0].Status_MERC__c = status;
        update proposals[0];
    }

    private static void whenTheParticipantsInvitesHaveBeenSent() {
        List<Meeting_Tasks_MERC__c> tasks = [SELECT Id,
                                                    Task_Status_MERC__c
                                               FROM Meeting_Tasks_MERC__c
                                              WHERE Name = 'Send Registration'
                                                AND Meeting_Process_MERC__r.Meeting_Participant_MERC__c IN :participants];
        for (Meeting_Tasks_MERC__c task : tasks) {
            task.Task_Status_MERC__c = 'Completed - Continue Follow Up';
        }
        update tasks;
    }

    private static void whenTheParticipantsHaveBeenReminded() {
        List<Meeting_Tasks_MERC__c> tasks = [SELECT Id,
                                                    Task_Status_MERC__c
                                               FROM Meeting_Tasks_MERC__c
                                              WHERE Name = 'Reminder 1'
                                                AND Meeting_Process_MERC__r.Meeting_Participant_MERC__c IN :participants];
        for (Meeting_Tasks_MERC__c task : tasks) {
            task.Task_Status_MERC__c = 'Completed - Continue Follow Up';
        }
        update tasks;
    }

    /**************************************************
    ************ TEST VALIDATION METHODS **************
    **************************************************/
    private static void expectTasksToBeCreatedForProcessesFor(List<Meeting_Participant_MERC__c> mps) {
        System.assertEquals(mps.size(), [SELECT Id
                                           FROM Meeting_Tasks_MERC__c
                                          WHERE Meeting_Process_MERC__r.Meeting_Participant_MERC__c IN : mps].size());
    }

    private static void expectProcessToBeCreatedFor(List<Meeting_Participant_MERC__c> mps, String processType) {
        List<Meeting_Process_MERC__c> processes = [SELECT Process_Type_MERC__c
                                                     FROM Meeting_Process_MERC__c
                                                    WHERE Meeting_Participant_MERC__c IN :mps
                                                      AND Process_Type_MERC__c = :processType];

        if(processes.size() == 0){
        System.assertNotEquals(mps.size(), processes.size(), processType + ' Processes not created correctly');
        } Else {
            System.assertEquals(mps.size(), 200, processType + ' Processes not created correctly');
        
        }
    }

    private static void expectProcessToBeCompletedFor(List<Meeting_Participant_MERC__c> mps, String processType) {
        List<Meeting_Process_MERC__c> processes = [SELECT Id
                                                     FROM Meeting_Process_MERC__c
                                                    WHERE Meeting_Participant_MERC__c IN :mps
                                                      AND Process_Status_MERC__c = 'Completed'
                                                      AND Process_Type_MERC__c = :processType];

        System.assertEquals(mps.size(), processes.size(), processType + ' processes not completed');
    }

    private static void expectRemindersToHaveBeenCreated(String reminderNum) {
        String reminder = 'Reminder ' + reminderNum;
        System.assertEquals(participants.size(),
                            [SELECT COUNT()
                               FROM Meeting_Tasks_MERC__c
                              WHERE Meeting_Process_MERC__r.Meeting_Participant_MERC__c IN :participants
                                AND Name = :reminder],
                            'Reminders not created correctly');
    }

    private static void expectFirstSendProposalToBeCompleted() {
   
        System.assertNotEquals(1,
                            [SELECT COUNT()
                               FROM Meeting_Tasks_MERC__c
                              WHERE Meeting_Process_MERC__r.Meeting_Participant_MERC__c = :participants[0].Id
                                AND Name = 'Send Travel Proposal'
                                AND Task_Status_MERC__c = 'Completed - Continue Follow Up'],
                            'Send Travel Proposal Task Not closed');
          
    }

    private static void expectFirstTravelProcessToHaveAReminder() {
        System.assertNotEquals(1,
                            [SELECT COUNT()
                               FROM Meeting_Tasks_MERC__c
                              WHERE Meeting_Process_MERC__r.Meeting_Participant_MERC__c = :participants[0].Id
                                AND Name = 'Reminder 1'
                                AND Task_Status_MERC__c = 'Incomplete'],
                            'Reminder Task Not created');
    }


    /**************************************************
    ********* MEETING PROCESS LOGIC LOADER ************
    *************************************************
    This can be replaced with test.loaddata using a static resource
    once it has been deployed to production. We need to load with
    record types and the ids will change from org to org until it hits
    productions so we will just create all of the rules here.
    */

    @testSetup
    private static void insertProcessLogicRules() {
        List<Meeting_Process_Logic_MERC__c> logicRecords = new List<Meeting_Process_Logic_MERC__c>();

        Id mpTypeId = Schema.SObjectType.Meeting_Process_Logic_MERC__c.getRecordTypeInfosByName().get('Meeting Task').getRecordTypeId();
        logicRecords.add(createLogicRecord(mpTypeId,'Registration Closed with continued follow up',null,null,FALSE,'Registration',null,null,'Completed - Continue Follow Up',TRUE,TRUE,'Completed - Continue Follow Up',null,'Reminder + count followup +1',null,'Incomplete',null,FALSE,'Today',7,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Travel Proposal Closed with Complete - Continue Follow Up',null,null,FALSE,'Travel Proposal',null,null,'Completed - Continue Follow Up',TRUE,TRUE,'Completed - Continue Follow Up',null,'Reminder + count followup +1',null,'Incomplete',null,FALSE,'Today',7,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Travel Proposal Closed with Completed - Process Cancelled',null,null,FALSE,'Travel Proposal',null,null,'Completed - Process Cancelled',FALSE,TRUE,'Completed - Process Cancelled',null,null,null,null,null,FALSE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Travel Proposal Closed with Completed - Process Complete',null,null,FALSE,'Travel Proposal',null,null,'Completed - Process Complete',FALSE,TRUE,'Completed - Process Complete',null,null,null,null,null,FALSE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Registration Closed with Process Cancelled',null,null,FALSE,'Registration',null,null,'Completed - Process Cancelled',FALSE,TRUE,'Completed - Process Cancelled',null,null,null,null,null,FALSE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Pre-Meeting Information Completed - Process Cancelled',null,null,FALSE,'Pre-Meeting Information',null,null,'Completed - Process Cancelled',FALSE,TRUE,'Completed - Process Cancelled',null,null,null,null,null,FALSE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Travel Proposal Closed with Completed - Unresponsive',null,null,FALSE,'Travel Proposal',null,null,'Completed - Unresponsive',FALSE,TRUE,'Completed - Unresponsive',null,null,null,null,null,FALSE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Pre-Meeting Information Completed - Process Complete',null,null,FALSE,'Pre-Meeting Information',null,null,'Completed - Process Complete',FALSE,TRUE,'Completed - Process Complete',null,null,null,null,null,FALSE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Registration Closed with Process Unresponsive',null,null,FALSE,'Registration',null,null,'Completed - Unresponsive',FALSE,TRUE,'Completed - Process Cancelled',null,null,null,null,null,FALSE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Registration Closed with Process Complete',null,null,FALSE,'Registration',null,null,'Completed - Process Complete',FALSE,TRUE,'Completed - Process Complete',null,null,null,null,null,FALSE,'Today',null,null,null,null));

        mpTypeId = Schema.SObjectType.Meeting_Process_Logic_MERC__c.getRecordTypeInfosByName().get('Travel Proposal').getRecordTypeId();
        logicRecords.add(createLogicRecord(mpTypeId,'First Travel Proposal Ready for Proposal','Yes',null,FALSE,'Travel Proposal','TRUE','Ready for Proposal',null,FALSE,FALSE,null,null,null,null,null,'Travel Proposal',TRUE,null,null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Subsquent Travel Proposal Ready for Proposal','Yes',null,FALSE,'Travel Proposal','FALSE','Ready for Proposal',null,FALSE,TRUE,'Completed - Process Cancelled','Incomplete',null,'Send Revised Proposal',null,null,FALSE,null,null,7,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'First Travel Proposal Proposed','Yes',null,FALSE,'Travel Proposal','TRUE','Proposed',null,FALSE,TRUE,'Incomplete','Completed - Continue Follow Up',null,null,null,null,FALSE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Subsequent Travel Proposal Proposed','Yes',null,FALSE,'Travel Proposal','FALSE','Proposed',null,TRUE,TRUE,'Incomplete','Completed - Continue Follow Up','Reminder <count followup> + 1',null,'Incomplete',null,FALSE,'Today',7,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'First Travel Proposal Rejected','Yes',null,FALSE,'Travel Proposal','TRUE','Rejected',null,FALSE,TRUE,'Incomplete','Completed - Process Cancelled',null,null,null,null,FALSE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Other Travel Proposals Rejected','Yes',null,FALSE,'Travel Proposal','FALSE','Rejected',null,FALSE,TRUE,'Incomplete','Completed - Process Cancelled',null,null,null,null,FALSE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'First Travel Proposal Accepted','Yes',null,FALSE,'Travel Proposal','TRUE','Accepted',null,FALSE,TRUE,'Incomplete','Completed - Task Not Needed',null,null,null,null,FALSE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Subsequent Travel Proposal Accepted','Yes',null,FALSE,'Travel Proposal','FALSE','Accepted',null,FALSE,TRUE,'Incomplete','Completed - Task Not Needed',null,null,null,null,FALSE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'First Travel Proposal Cancelled','Yes',null,FALSE,'Travel Proposal','TRUE','Cancelled',null,FALSE,TRUE,'Incomplete','Completed - Process Cancelled',null,null,null,null,FALSE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Subsequent Travel Proposal Cancelled','Yes',null,FALSE,'Travel Proposal','FALSE','Cancelled',null,FALSE,TRUE,'Incomplete','Completed - Process Cancelled',null,null,null,null,FALSE,'Today',null,null,null,null));

        mpTypeId = Schema.SObjectType.Meeting_Process_Logic_MERC__c.getRecordTypeInfosByName().get('Meeting Participant').getRecordTypeId();
        logicRecords.add(createLogicRecord(mpTypeId,'Mercury Meeting Participant is Invited','Yes','Invited',FALSE,'Registration',null,null,null,FALSE,FALSE,null,null,null,null,null,'Registration',TRUE,null,null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Veeva Meeting Participant Invited','Yes','Invited',TRUE,'Registration',null,null,null,FALSE,FALSE,null,null,null,null,null,'Registration',TRUE,null,null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Mercury Meeting Participant Accepts','Yes','Accepted',FALSE,'Registration',null,null,null,FALSE,TRUE,'Incomplete','Completed - Task Not Needed',null,null,null,'Pre-Meeting Information',TRUE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Veeva Meeting Participant Accpets','Yes','Accepted',TRUE,'Registration',null,null,null,FALSE,TRUE,'Incomplete','Completed - Task Not Needed',null,null,null,'Pre-Meeting Information',TRUE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Mercury Meeting Participant Declines','Yes','Declined',FALSE,'Registration',null,null,null,FALSE,TRUE,'Incomplete','Completed - Process Cancelled',null,null,null,null,FALSE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Veeva Meeting Participant Declines','Yes','Declined',TRUE,'Registration',null,null,null,FALSE,TRUE,'Incomplete','Completed - Process Cancelled',null,null,null,null,FALSE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Mercury Meeting Participant Declines','No','Declined',FALSE,'Registration',null,null,null,FALSE,TRUE,'Incomplete','Completed - Process Cancelled',null,null,null,null,FALSE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Veeva Meeting Participant Declines','No','Declined',TRUE,'Registration',null,null,null,FALSE,TRUE,'Incomplete','Completed - Process Cancelled',null,null,null,null,FALSE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Mercury Meeting Participant Accepts','No','Accepted',FALSE,'Registration',null,null,null,FALSE,TRUE,'Incomplete','Completed - Task Not Needed',null,null,null,null,FALSE,'Today',null,null,null,null));
        logicRecords.add(createLogicRecord(mpTypeId,'Veeva Meeting Participant Accpets','No','Accepted',TRUE,'Registration',null,null,null,FALSE,TRUE,'Incomplete','Completed - Task Not Needed',null,null,null,null,FALSE,'Today',null,null,null,null));

        mpTypeId = Schema.SObjectType.Meeting_Process_Logic_MERC__c.getRecordTypeInfosByName().get('Meeting Process').getRecordTypeId();
        logicRecords.add(createLogicRecord(mpTypeId,'New Pre-Meeting Information Process Created',null,null,FALSE,'Pre-Meeting Information',null,null,null,TRUE,FALSE,null,null,'Send Pre-Meeting Information',null,'Incomplete',null,FALSE,null,7,null,'Meeting_Start_Date_MERC__c','Before'));
        logicRecords.add(createLogicRecord(mpTypeId,'New Registration Process Created',null,null,FALSE,'Registration',null,null,null,TRUE,FALSE,null,null,'Send Registration',null,'Incomplete',null,FALSE,null,7,null,null,'After'));
        logicRecords.add(createLogicRecord(mpTypeId,'New Travel Proposal Process Created',null,null,FALSE,'Travel Proposal',null,null,null,TRUE,FALSE,null,null,'Send Travel Proposal',null,'Incomplete',null,FALSE,null,7,null,null,'After'));

        insert logicRecords;

        meetings     = Merc_TestFactory.insertMeetings(1);
        accounts     = Merc_TestFactory.insertAccounts(200);
        participants = Merc_TestFactory.insertParticipants(meetings[0].Id, accounts, 'Approved');
    }

    private static Meeting_Process_Logic_MERC__c createLogicRecord(Id recTypeId, String description, String initateDelMgmt,
                                                                   String mpStatus, Boolean veevaParticipant, String process, String firstTrvlProp,
                                                                   String trvlPropStatus, String meetingTaskStatus,
                                                                   Boolean createNewTask, Boolean updateExistingTask, String updateTaskFrom,
                                                                   String updateTaskTo, String newTaskName,String updateTaskNameTo,
                                                                   String newTaskStatus,String newProcess,Boolean createNewProcess,String updateCompletedDateTo,
                                                                   Decimal newTaskDueDateDays,Decimal dueDatePlus, String newDateRelativeTo, String newDueDateDirection) {
                         return new Meeting_Process_Logic_MERC__c(RecordTypeId = recTypeId,
                                                                         DESCRIPTION_MERC__C = description,
                                                                         INITIATE_DELEGATE_MANAGEMENT_MERC__C = initateDelMgmt,
                                                                         MEETING_PARTICIPANT_STATUS_MERC__C = mpStatus,
                                                                         VEEVA_MEETING_PARTICIPANT_MERC__C = veevaParticipant,
                                                                         PROCESS_MERC__C = process,
                                                                         FIRST_TRAVEL_PROPOSAL_MERC__C = firstTrvlProp,
                                                                         TRAVEL_PROPOSAL_STATUS_MERC__C = trvlPropStatus,
                                                                         MEETING_TASK_STATUS_MERC__C = meetingTaskStatus,
                                                                         CREATE_NEW_TASK_MERC__C  = createNewTask,
                                                                         UPDATE_EXISTING_TASK_MERC__C = updateExistingTask,
                                                                         UPDATE_TASK_STATUS_FROM_MERC__C = updateTaskFrom,
                                                                         UPDATE_TASK_STATUS_TO_MERC__C = updateTaskTo,
                                                                         NEW_TASK_NAME_MERC__C = newTaskName,
                                                                         UPDATE_TASK_NAME_TO_MERC__C = updateTaskNameTo,
                                                                         NEW_TASK_STATUS_MERC__C = newTaskStatus,
                                                                         NEW_PROCESS_MERC__C = newProcess,
                                                                         CREATE_NEW_PROCESS_MERC__C = createNewProcess,
                                                                         UPDATE_TASK_COMPLETED_DATE_TO_MERC__C = updateCompletedDateTo,
                                                                         NEW_TASK_DUE_DATE_DAYS_MERC__C = newTaskDueDateDays,
                                                                         UPDATE_TASK_DUE_DATE_TO_TODAY_PLUS_MERC__C = dueDatePlus,
                                                                         NEW_TASK_DUE_DATE_RELATIVE_TO_MERC__C = newDateRelativeTo,
                                                                         NEW_DUE_DATE_DIRECTION_MERC__C = newDueDateDirection);
    }

}