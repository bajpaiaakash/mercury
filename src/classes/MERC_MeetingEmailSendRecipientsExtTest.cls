/*
* Authors: 
*   David Helmer
*/
@isTest
public with sharing class MERC_MeetingEmailSendRecipientsExtTest {
    @isTest static void test_Constructor(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();       

        Test.startTest();
        MERC_MeetingEmailSendRecipientsExtension sendRecipientsExtension = getSendRecipientsExtension(meeting);
        Test.stopTest();
    }

    private static Meeting_MERC__c getMeeting(){
        String meetingPrefixLike = MERC_MarketingCloudTestUtility.MEETING_NAME_PREFIX + '%';
        return [SELECT Id FROM Meeting_MERC__c WHERE Name LIKE :meetingPrefixLike LIMIT 1][0];
    }

    private static MERC_MeetingEmailSendRecipientsExtension getSendRecipientsExtension(Meeting_MERC__c meeting){
        ApexPages.StandardController standardController = new ApexPages.StandardController(meeting);
        return new MERC_MeetingEmailSendRecipientsExtension(standardController);
    }

    @isTest static void test_OnInitialize_AllOptionsAvailable(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();           
        List<Account> personAccounts  = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
            MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 5);
        insert personAccounts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
        insert participants;
        createMeetingProcessChildren(participants);

        Test.startTest();
        assertNoQueries();
        MERC_MeetingEmailSendRecipientsExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 

        List<SelectOption> processTypeOptions = sendRecipientsExtension.getProcessTypeOptions();
        List<SelectOption> proposalStatusOptions = sendRecipientsExtension.getProposalStatusOptions();
        List<SelectOption> dueDateOptions = sendRecipientsExtension.getDueDateOptions();
        List<SelectOption> nextStepOptions = sendRecipientsExtension.getNextStepOptions();
        List<SelectOption> taskStatusOptions = sendRecipientsExtension.getTaskStatusOptions();

        Test.stopTest();

        System.assertEquals(3, processTypeOptions.size());
        System.assertEquals(3, proposalStatusOptions.size());
        System.assertEquals(2, dueDateOptions.size());
        System.assertEquals(2, nextStepOptions.size());
        System.assertEquals(3, taskStatusOptions.size());
    }

    private static void assertNoQueries(){
        System.assertEquals(0, Limits.getQueries());
    }

    @isTest static void test_SelectProcessType_Has2ProcessTypeOptions(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();           
        List<Account> personAccounts  = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
            MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 5);
        insert personAccounts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
        insert participants;
        createMeetingProcessChildren(participants);

        Test.startTest();
        assertNoQueries();

        MERC_MeetingEmailSendRecipientsExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setProcessTypeSelected(MERC_MarketingCloudTestUtility.PROCESS_TYPE_REGISTRATION);

        Test.stopTest();

        List<SelectOption> processTypeOptions = sendRecipientsExtension.getProcessTypeOptions();

        System.assertEquals(3, processTypeOptions.size());
        System.assertEquals(MERC_MarketingCloudTestUtility.PROCESS_TYPE_REGISTRATION, processTypeOptions.get(1).getValue());
    }

    @isTest static void test_SelectProcessType_Has1ItineraryOption(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();           
        List<Account> personAccounts  = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
            MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 5);
        insert personAccounts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
        insert participants;
        createMeetingProcessChildren(participants);

        Test.startTest();
        assertNoQueries();

        MERC_MeetingEmailSendRecipientsExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setProcessTypeSelected(MERC_MarketingCloudTestUtility.PROCESS_TYPE_REGISTRATION);

        Test.stopTest();

        List<SelectOption> proposalStatusOptions = sendRecipientsExtension.getProposalStatusOptions();

        System.assertEquals(2, proposalStatusOptions.size());
        System.assertEquals(MERC_MarketingCloudTestUtility.ITINERARY_REJECTED, proposalStatusOptions.get(1).getValue());
    }

    private static void createMeetingProcessChildren(List<Meeting_Participant_MERC__c> participants){

        List<Meeting_Process_MERC__c> meetingProcesses = new List<Meeting_Process_MERC__c>();
        meetingProcesses.add(MERC_MarketingCloudTestUtility.getMeetingProcess(participants.get(0).Id, MERC_MarketingCloudTestUtility.PROCESS_TYPE_REGISTRATION));
        meetingProcesses.add(MERC_MarketingCloudTestUtility.getMeetingProcess(participants.get(1).Id, MERC_MarketingCloudTestUtility.PROCESS_TYPE_TRAVEL_PROPOSAL));
        meetingProcesses.add(MERC_MarketingCloudTestUtility.getMeetingProcess(participants.get(2).Id, MERC_MarketingCloudTestUtility.PROCESS_TYPE_TRAVEL_PROPOSAL));
        insert meetingProcesses;

        List<Travel_Itinerary_MERC__c> meetingItineraries = new List<Travel_Itinerary_MERC__c>();
        meetingItineraries.add(MERC_MarketingCloudTestUtility.getItinerary(participants.get(0), MERC_MarketingCloudTestUtility.ITINERARY_REJECTED));
        meetingItineraries.add(MERC_MarketingCloudTestUtility.getItinerary(participants.get(1), MERC_MarketingCloudTestUtility.ITINERARY_ACCEPTED));
        meetingItineraries.add(MERC_MarketingCloudTestUtility.getItinerary(participants.get(2), MERC_MarketingCloudTestUtility.ITINERARY_ACCEPTED));
        insert meetingItineraries;

        List<Meeting_Tasks_MERC__c> meetingTasks = new List<Meeting_Tasks_MERC__c>();
        meetingTasks.add(MERC_MarketingCloudTestUtility.getTask(meetingProcesses.get(1).Id, MERC_MarketingCloudTestUtility.TASK_STATUS_COMPLETED));
        meetingTasks.add(MERC_MarketingCloudTestUtility.getTask(meetingProcesses.get(2).Id, MERC_MarketingCloudTestUtility.TASK_STATUS_CANCELLED));
        insert meetingTasks;
    }
}