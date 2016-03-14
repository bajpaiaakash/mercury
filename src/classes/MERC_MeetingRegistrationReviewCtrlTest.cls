/*
* Authors: 
*   David Helmer
*/
@isTest
private class MERC_MeetingRegistrationReviewCtrlTest {

    @testSetup static void setupValidData(){
        MERC_TriggerHandlerStateManager.deactivateAll();
        Meeting_MERC__c meeting = insertMeeting('validMeetingName');
        List<Meeting_Participant_MERC__c> incompleteParticipants = insertMeetingParticipants(meeting, 'Incomplete', 5);
        List<Meeting_Participant_MERC__c> pendingParticipants = insertMeetingParticipants(meeting, 'Pending Review', 5);
    }

    private static Meeting_MERC__c insertMeeting(String name){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.getMeeting();
        meeting.Name = name;
        insert meeting;
        return meeting;
    }

    private static List<Meeting_Participant_MERC__c> insertMeetingParticipants(
        Meeting_MERC__c meeting,
        String registrationStatus,
        Integer participantCount){
        List<Account> personAccounts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
            MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, participantCount);
        for(Integer personIndex = 0; personIndex < personAccounts.size(); personIndex++){
            Account personAccount = personAccounts.get(personIndex);
            personAccount.FirstName = getParticipantFirstName(meeting.Name, registrationStatus, personIndex);
        }
        insert personAccounts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
        for(Meeting_Participant_MERC__c participant : participants){
            participant.Registration_Status_MERC__c = registrationStatus;
        }
        insert participants;

        return participants;
    }

    private static String getParticipantFirstName(String meetingName, String status, Integer index){
        return meetingName + status + index;
    }

    @isTest static void withNoMeeting_AddsErrorMessage(){
        Test.startTest();

        MERC_MeetingRegistrationReviewController controller = new MERC_MeetingRegistrationReviewController();

        Test.stopTest();

        assertMessagesContain(MERC_MeetingRegistrationReviewController.MISSING_MEETING_ID);
        System.assertEquals(null, controller.meeting);
    }

    private static void assertMessagesContain(String message){
        System.assert(containsMessage(message), message + ' not found in ApexPages.getMessages():\n\t' + ApexPages.getMessages());
    }

    private static Boolean containsMessage(String message){
        Boolean containsMessage = false;
        for(ApexPages.Message pageMessage : ApexPages.getMessages()){
            containsMessage = pageMessage.getDetail().contains(message);
            if(containsMessage){
                break;
            }
        }
        return containsMessage;
    }

    @isTest static void withMeeting_HasMeeting(){
        Meeting_MERC__c meeting = getValidMeeting();
        ApexPages.currentPage().getParameters().put('id', meeting.Id);

        Test.startTest();

        MERC_MeetingRegistrationReviewController controller = new MERC_MeetingRegistrationReviewController();

        Test.stopTest();

        System.assertEquals(meeting.Id, controller.meetingId); 
        System.assertNotEquals(null, controller.meeting);
        System.assertEquals(meeting.Name, controller.meeting.Name);
    }

    private static Meeting_MERC__c getValidMeeting(){
        return [SELECT Id, Name FROM Meeting_MERC__c WHERE Name = 'validMeetingName'][0];
    }

    @isTest static void withValidData_HasParticipantsToReview(){
        Meeting_MERC__c meeting = getValidMeeting();
        ApexPages.currentPage().getParameters().put('id', meeting.Id);

        Test.startTest();

        MERC_MeetingRegistrationReviewController controller = new MERC_MeetingRegistrationReviewController();

        Test.stopTest();

        System.assertEquals(expectedParticipantWhereClause(meeting.Id), controller.participantsToReview.baseWhereClause);
    }

    private static String expectedParticipantWhereClause(String meetingId){
        return 'Meeting_MERC__c = \'' + meetingId + '\' AND Registration_Status_MERC__c IN (\'Incomplete\',\'Pending Review\')';
    }

    @isTest static void withValidData_ConfirmIsFalse(){
        Meeting_MERC__c meeting = getValidMeeting();
        ApexPages.currentPage().getParameters().put('id', meeting.Id);

        Test.startTest();

        MERC_MeetingRegistrationReviewController controller = new MERC_MeetingRegistrationReviewController();

        Test.stopTest();

        System.assertEquals(false, controller.isConfirmNecessary);
    }

    @isTest static void withValidData_SelectedParticipantValuesAreNull(){
        Meeting_MERC__c meeting = getValidMeeting();
        ApexPages.currentPage().getParameters().put('id', meeting.Id);

        Test.startTest();

        MERC_MeetingRegistrationReviewController controller = new MERC_MeetingRegistrationReviewController();

        Test.stopTest();

        assertSelectedCleared(controller);
    }

    private static void assertSelectedCleared(MERC_MeetingRegistrationReviewController controller){
        System.assertEquals(null, controller.selectedParticipant);
        System.assertEquals(null, controller.selectedParticipantResponses);
        System.assertEquals(null, controller.selectedParticipantQuestions);
        System.assertEquals(null, controller.selectedParticipantDesignatedIndividuals);
    }

    @isTest static void withValidData_SaveAndSelectParticipant_ConfirmIsFalse(){
        Meeting_MERC__c meeting = getValidMeeting();
        ApexPages.currentPage().getParameters().put('id', meeting.Id);

        Test.startTest();

        MERC_MeetingRegistrationReviewController controller = new MERC_MeetingRegistrationReviewController();
        controller.isConfirmNecessary = true;
        controller.saveAndSelectParticipant();

        Test.stopTest();

        System.assertEquals(false, controller.isConfirmNecessary);
    }

    @isTest static void withValidDataNoSelected_SaveAndSelectParticipant_AddsErrorMessages(){
        Meeting_MERC__c meeting = getValidMeeting();
        ApexPages.currentPage().getParameters().put('id', meeting.Id);

        Test.startTest();

        MERC_MeetingRegistrationReviewController controller = new MERC_MeetingRegistrationReviewController();
        controller.saveAndSelectParticipant();

        Test.stopTest();

        assertMessagesContain(MERC_MeetingRegistrationReviewController.NO_PARTICIPANT_SELECTED_TO_SAVE);
        assertMessagesContain(MERC_MeetingRegistrationReviewController.NO_PARTICIPANT_SELECTED);
    }

    @isTest static void withValidData_SaveAndSelectParticipant_SavesChanges(){
        Meeting_MERC__c meeting = getValidMeeting();
        Meeting_Participant_MERC__c originalParticipant = getValidParticipant();

        ApexPages.currentPage().getParameters().put('id', meeting.Id);

        Test.startTest();

        MERC_MeetingRegistrationReviewController controller = new MERC_MeetingRegistrationReviewController();
        controller.participantsToReview.selectedParticipantId = originalParticipant.Id;
        controller.selectParticipant();
        controller.saveAndSelectParticipant();

        Test.stopTest();

        Meeting_Participant_MERC__c updatedParticipant = getValidParticipant();
        System.assertNotEquals(originalParticipant.LastModifiedDate, updatedParticipant.LastModifiedDate);
    }

    private static Meeting_Participant_MERC__c getValidParticipant(){
        return getParticipant('validMeetingNameIncomplete1');
    }

    private static Meeting_Participant_MERC__c getParticipant(String firstName){
        return [SELECT Id, Registration_Status_MERC__c, LastModifiedDate FROM Meeting_Participant_MERC__c WHERE Account_MERC__r.FirstName = :firstName][0];
    }

    @isTest static void withValidDataAndNewSelection_SaveAndSelectParticipant_SelectsParticipant(){
        Meeting_MERC__c meeting = getValidMeeting();
        Meeting_Participant_MERC__c originalParticipant = getValidParticipant();
        Meeting_Participant_MERC__c secondParticipant = getOtherValidParticipant();

        ApexPages.currentPage().getParameters().put('id', meeting.Id);

        Test.startTest();

        MERC_MeetingRegistrationReviewController controller = new MERC_MeetingRegistrationReviewController();
        controller.participantsToReview.selectedParticipantId = originalParticipant.Id;
        controller.selectParticipant();
        controller.participantsToReview.selectedParticipantId = secondParticipant.Id;
        controller.saveAndSelectParticipant();

        Test.stopTest();

        System.assertNotEquals(null, controller.selectedParticipant);
        System.assertEquals(secondParticipant.Id ,controller.selectedParticipant.Id);
    }

    private static Meeting_Participant_MERC__c getOtherValidParticipant(){
        return getParticipant('validMeetingNamePending Review2');
    }

    @isTest static void withValidDataAndChanges_ConfirmOrSelectParticipant_ConfirmIsTrue(){
        Meeting_MERC__c meeting = getValidMeeting();
        Meeting_Participant_MERC__c originalParticipant = getValidParticipant();
        Meeting_Participant_MERC__c secondParticipant = getOtherValidParticipant();
        String differentStatus = 'Pending Review';

        ApexPages.currentPage().getParameters().put('id', meeting.Id);

        Test.startTest();

        MERC_MeetingRegistrationReviewController controller = new MERC_MeetingRegistrationReviewController();
        controller.participantsToReview.selectedParticipantId = originalParticipant.Id;
        controller.selectParticipant();
        controller.selectedParticipant.Registration_Status_MERC__c = differentStatus;
        controller.participantsToReview.selectedParticipantId = secondParticipant.Id;
        controller.confirmOrSelectParticipant();

        Test.stopTest();

        System.assertEquals(true, controller.isConfirmNecessary);
        System.assertEquals(originalParticipant.Id, controller.selectedParticipant.Id);
    }

    @isTest static void withValidDataAndChanges_ConfirmOrSelectParticipant_DoesNotSaveChanges(){
        Meeting_MERC__c meeting = getValidMeeting();
        Meeting_Participant_MERC__c originalParticipant = getValidParticipant();
        Meeting_Participant_MERC__c secondParticipant = getOtherValidParticipant();
        String differentStatus = 'Pending Review';

        ApexPages.currentPage().getParameters().put('id', meeting.Id);

        Test.startTest();

        MERC_MeetingRegistrationReviewController controller = new MERC_MeetingRegistrationReviewController();
        controller.participantsToReview.selectedParticipantId = originalParticipant.Id;
        controller.selectParticipant();
        controller.selectedParticipant.Registration_Status_MERC__c = differentStatus;
        controller.participantsToReview.selectedParticipantId = secondParticipant.Id;
        controller.confirmOrSelectParticipant();

        Test.stopTest();

        Meeting_Participant_MERC__c afterParticipant = getValidParticipant();
        System.assertEquals(originalParticipant.LastModifiedDate, afterParticipant.LastModifiedDate);
        System.assertEquals(originalParticipant.Registration_Status_MERC__c, afterParticipant.Registration_Status_MERC__c);
    }

    @isTest static void withValidDataNoChanges_ConfirmOrSelectParticipant_DoesNotSaveChanges(){
        Meeting_MERC__c meeting = getValidMeeting();
        Meeting_Participant_MERC__c originalParticipant = getValidParticipant();
        Meeting_Participant_MERC__c secondParticipant = getOtherValidParticipant();

        ApexPages.currentPage().getParameters().put('id', meeting.Id);

        Test.startTest();

        MERC_MeetingRegistrationReviewController controller = new MERC_MeetingRegistrationReviewController();
        controller.participantsToReview.selectedParticipantId = originalParticipant.Id;
        controller.selectParticipant();
        controller.participantsToReview.selectedParticipantId = secondParticipant.Id;
        controller.confirmOrSelectParticipant();

        Test.stopTest();

        Meeting_Participant_MERC__c afterParticipant = getValidParticipant();
        System.assertEquals(originalParticipant.LastModifiedDate, afterParticipant.LastModifiedDate);
        System.assertEquals(originalParticipant.Registration_Status_MERC__c, afterParticipant.Registration_Status_MERC__c);
    }

    @isTest static void withValidDataNoChanges_ConfirmOrSelectParticipant_SelectsParticipant(){
        Meeting_MERC__c meeting = getValidMeeting();
        Meeting_Participant_MERC__c originalParticipant = getValidParticipant();
        Meeting_Participant_MERC__c secondParticipant = getOtherValidParticipant();

        ApexPages.currentPage().getParameters().put('id', meeting.Id);

        Test.startTest();

        MERC_MeetingRegistrationReviewController controller = new MERC_MeetingRegistrationReviewController();
        controller.participantsToReview.selectedParticipantId = originalParticipant.Id;
        controller.selectParticipant();
        controller.participantsToReview.selectedParticipantId = secondParticipant.Id;
        controller.confirmOrSelectParticipant();

        Test.stopTest();

        System.assertEquals(false, controller.isConfirmNecessary);
        System.assertEquals(secondParticipant.Id, controller.selectedParticipant.Id);
    }

    @isTest static void withValidData_RegistrationComplete_StatusIsComplete(){
        Meeting_MERC__c meeting = getValidMeeting();
        Meeting_Participant_MERC__c originalParticipant = getValidParticipant();

        ApexPages.currentPage().getParameters().put('id', meeting.Id);

        Test.startTest();

        MERC_MeetingRegistrationReviewController controller = new MERC_MeetingRegistrationReviewController();
        controller.participantsToReview.selectedParticipantId = originalParticipant.Id;
        controller.selectParticipant();
        controller.registrationComplete();

        Test.stopTest();

        Meeting_Participant_MERC__c afterParticipant = getValidParticipant();
        System.assertNotEquals('Complete', originalParticipant.Registration_Status_MERC__c);
        System.assertEquals('Complete', afterParticipant.Registration_Status_MERC__c);
    }

    @isTest static void withValidData_RegistrationComplete_ClearsSelected(){
        Meeting_MERC__c meeting = getValidMeeting();
        Meeting_Participant_MERC__c originalParticipant = getValidParticipant();

        ApexPages.currentPage().getParameters().put('id', meeting.Id);

        Test.startTest();

        MERC_MeetingRegistrationReviewController controller = new MERC_MeetingRegistrationReviewController();
        controller.participantsToReview.selectedParticipantId = originalParticipant.Id;
        controller.selectParticipant();
        controller.registrationComplete();

        Test.stopTest();

        assertSelectedCleared(controller);
    }

    @isTest static void withValidData_RegistrationInComplete_StatusIsInComplete(){
        Meeting_MERC__c meeting = getValidMeeting();
        Meeting_Participant_MERC__c originalParticipant = getOtherValidParticipant();
        System.assertNotEquals('Incomplete', originalParticipant.Registration_Status_MERC__c);
        ApexPages.currentPage().getParameters().put('id', meeting.Id);

        Test.startTest();

        MERC_MeetingRegistrationReviewController controller = new MERC_MeetingRegistrationReviewController();
        controller.participantsToReview.selectedParticipantId = originalParticipant.Id;
        controller.selectParticipant();
        controller.registrationIncomplete();

        Test.stopTest();

        Meeting_Participant_MERC__c afterParticipant = getValidParticipant();
        System.assertNotEquals('Incomplete', originalParticipant.Registration_Status_MERC__c);
        System.assertEquals('Incomplete', afterParticipant.Registration_Status_MERC__c);
    }

    @isTest static void withValidData_RegistrationInComplete_ClearsSelected(){
        Meeting_MERC__c meeting = getValidMeeting();
        Meeting_Participant_MERC__c originalParticipant = getOtherValidParticipant();

        ApexPages.currentPage().getParameters().put('id', meeting.Id);

        Test.startTest();

        MERC_MeetingRegistrationReviewController controller = new MERC_MeetingRegistrationReviewController();
        controller.participantsToReview.selectedParticipantId = originalParticipant.Id;
        controller.selectParticipant();
        controller.registrationIncomplete();

        Test.stopTest();
        
        assertSelectedCleared(controller);
    }
}