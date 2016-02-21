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

    private static MERC_MeetingEmailSendRecipientsExtension getSendRecipientsExtension(Meeting_MERC__c meeting){
        ApexPages.StandardController standardController = new ApexPages.StandardController(meeting);
        return new MERC_MeetingEmailSendRecipientsExtension(standardController);
    }

    @isTest static void test_OnInitialize_AllOptionsAvailable(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
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

    private static Meeting_MERC__c insertMeetingAndChildren(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();           
        List<Account> personAccounts  = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
            MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 5);
        updateAccountWith(personAccounts.get(1), 'Phone', 'US', null, 'French');
        insert personAccounts;


        //communicationChannelSelected = ANY_OPTION;
        //countryOfResidenceSelected = ANY_OPTION;
        //hasEmailSelected = ANY_OPTION;
        //participantStatusSelected = ANY_OPTION;
        //preferredLanguageSelected = ANY_OPTION;
        //recordTypeSelected = ANY_OPTION;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
        updateParticipantWith(participants.get(1), 'Rejected', MERC_MarketingCloudTestUtility.PARTICIPANT_RECORD_TYPE_DELEGATE);
        insert participants;
        createMeetingProcessChildren(participants);
        return meeting;
    }

    private static void updateAccountWith(Account accountToUpdate, String channel, String country, String email, String language){
        accountToUpdate.Communication_Channel_MERC__c = channel;
        accountToUpdate.Country_of_Residence_GLBL__c = country;
        accountToUpdate.PersonEmail = email;
        accountToUpdate.Prfrd_Lang_Cd_GLBL__c = language;
    }

    private static void updateParticipantWith(Meeting_Participant_MERC__c participant, String status, String recordTypeDevName){
        participant.Status_MERC__c = status;
        participant.RecordTypeId = MERC_ETTestUtils.GetRecordType(recordTypeDevName, 'Meeting_Participant_MERC__c').Id;
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

    @isTest static void test_OnInitialize_AllParticipantsFound(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendRecipientsExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 

        List<MERC_MeetingEmailSendRecipientsExtension.SelectableParticipant> participants = sendRecipientsExtension.getCurrentPageOfSelectableParticipants();

        Test.stopTest();

        System.assertEquals(5, participants.size());
    }

    @isTest static void test_SelectProcessType_Has2ProcessTypeOptions(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendRecipientsExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setProcessTypeSelected(MERC_MarketingCloudTestUtility.PROCESS_TYPE_REGISTRATION);

        List<SelectOption> processTypeOptions = sendRecipientsExtension.getProcessTypeOptions();
        
        Test.stopTest();


        System.assertEquals(3, processTypeOptions.size());
        System.assertEquals(MERC_MarketingCloudTestUtility.PROCESS_TYPE_REGISTRATION, processTypeOptions.get(1).getValue());
    }

    @isTest static void test_SelectProcessType_Has1ItineraryOption(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendRecipientsExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setProcessTypeSelected(MERC_MarketingCloudTestUtility.PROCESS_TYPE_REGISTRATION);

        List<SelectOption> proposalStatusOptions = sendRecipientsExtension.getProposalStatusOptions();

        Test.stopTest();


        System.assertEquals(2, proposalStatusOptions.size());
        System.assertEquals(MERC_MarketingCloudTestUtility.ITINERARY_REJECTED, proposalStatusOptions.get(1).getValue());
    }

    @isTest static void test_SelectProcessType_Has0DueDateOptions(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendRecipientsExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setProcessTypeSelected(MERC_MarketingCloudTestUtility.PROCESS_TYPE_REGISTRATION);
        List<SelectOption> dueDateOptions = sendRecipientsExtension.getDueDateOptions();

        Test.stopTest();

        System.assertEquals(1, dueDateOptions.size());
    }

    @isTest static void test_SelectProcessType_Has1NextStepOption(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendRecipientsExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setProcessTypeSelected(MERC_MarketingCloudTestUtility.PROCESS_TYPE_TRAVEL_PROPOSAL);
        List<SelectOption> nextStepOptions = sendRecipientsExtension.getNextStepOptions();

        Test.stopTest();

        System.assertEquals(2, nextStepOptions.size());
    }

    @isTest static void test_SelectProcessType_Has0NextStepOption(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendRecipientsExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setProcessTypeSelected(MERC_MarketingCloudTestUtility.PROCESS_TYPE_REGISTRATION);
        List<SelectOption> nextStepOptions = sendRecipientsExtension.getNextStepOptions();

        Test.stopTest();

        System.assertEquals(1, nextStepOptions.size());
    }

    @isTest static void test_SelectProcessType_Has0TaskStatusOptions(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendRecipientsExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setProcessTypeSelected(MERC_MarketingCloudTestUtility.PROCESS_TYPE_REGISTRATION);
        List<SelectOption> taskStatusOptions = sendRecipientsExtension.getTaskStatusOptions();

        Test.stopTest();

        System.assertEquals(1, taskStatusOptions.size());
    }

    @isTest static void test_SelectProcessType_Has2TaskStatusOptions(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendRecipientsExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setProcessTypeSelected(MERC_MarketingCloudTestUtility.PROCESS_TYPE_TRAVEL_PROPOSAL);
        List<SelectOption> taskStatusOptions = sendRecipientsExtension.getTaskStatusOptions();

        Test.stopTest();

        System.assertEquals(3, taskStatusOptions.size());
    }

    @isTest static void test_SelectProcessTypeNotTravelProposal_ProposalStatusIsAny(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendRecipientsExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setProcessTypeSelected(MERC_MarketingCloudTestUtility.PROCESS_TYPE_TRAVEL_PROPOSAL);

        Test.stopTest();

        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.getProposalStatusSelected());
    }

    @isTest static void test_SelectAllProcessFilters_FiltersRecords(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendRecipientsExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 

        sendRecipientsExtension.setProcessTypeSelected(MERC_MarketingCloudTestUtility.PROCESS_TYPE_TRAVEL_PROPOSAL);
        sendRecipientsExtension.setProposalStatusSelected(MERC_MarketingCloudTestUtility.ITINERARY_ACCEPTED);
        sendRecipientsExtension.setDueDateSelected(sendRecipientsExtension.getDueDateOptions().get(1).getValue());
        sendRecipientsExtension.setNextStepSelected(sendRecipientsExtension.getNextStepOptions().get(1).getValue());
        sendRecipientsExtension.setTaskStatusSelected(MERC_MarketingCloudTestUtility.TASK_STATUS_COMPLETED);

        List<SelectOption> processTypeOptions = sendRecipientsExtension.getProcessTypeOptions();
        List<MERC_MeetingEmailSendRecipientsExtension.SelectableParticipant> participants = sendRecipientsExtension.getCurrentPageOfSelectableParticipants();
        Test.stopTest();


        System.assertEquals(2, processTypeOptions.size());
        System.assertEquals(1, participants.size());
    }

    @isTest static void test_SelectAllProcessFiltersThenSetProcessTypeAny_ClearsProcessFilters(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendRecipientsExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 

        sendRecipientsExtension.setProcessTypeSelected(MERC_MarketingCloudTestUtility.PROCESS_TYPE_TRAVEL_PROPOSAL);
        sendRecipientsExtension.setProposalStatusSelected(MERC_MarketingCloudTestUtility.ITINERARY_ACCEPTED);
        sendRecipientsExtension.setDueDateSelected(sendRecipientsExtension.getDueDateOptions().get(1).getValue());
        sendRecipientsExtension.setNextStepSelected(sendRecipientsExtension.getNextStepOptions().get(1).getValue());
        sendRecipientsExtension.setTaskStatusSelected(MERC_MarketingCloudTestUtility.TASK_STATUS_COMPLETED);
        sendRecipientsExtension.setProcessTypeSelected(sendRecipientsExtension.ANY_OPTION);

        Test.stopTest();

        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.getProcessTypeSelected());
        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.getProposalStatusSelected());
        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.getDueDateSelected());
        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.getNextStepSelected());
        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.getTaskStatusSelected());
    }
}