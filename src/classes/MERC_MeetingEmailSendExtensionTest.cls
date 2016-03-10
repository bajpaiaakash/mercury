/*
* Authors: 
*   David Helmer
*/
@isTest
public with sharing class MERC_MeetingEmailSendExtensionTest {
    @testSetup static void prepareBaseTestData(){        
        MERC_MarketingCloudTestUtility.insertConfiguration(true);
        MERC_MarketingCloudTestUtility.insertBusinessUnit();
        MERC_MarketingCloudTestUtility.insertSettings();
    }

    @isTest static void test_Constructor(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);
    }

    private static MERC_MeetingEmailSendExtension getMeetingEmailSendExtension(Meeting_MERC__c meeting){
        ApexPages.StandardController standardController = new ApexPages.StandardController(meeting);
        return new MERC_MeetingEmailSendExtension(standardController);
    }

    @isTest static void test_ContructorAddsFatalMessageIfNoMeeting(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.getMeeting();
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

        assertMessagesContain('No meeting was found.');
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

    private static void assertMessagesDoNotContain(String message){
        System.assert(!containsMessage(message), message + ' was found in ApexPages.getMessages():\n\t' + ApexPages.getMessages());

    }

    @isTest static void test_CanGetHasFatalMessages(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.getMeeting();
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

        System.assertEquals(true, meetingEmailSendExtension.getHasFatalMessages());
    }

    @isTest static void test_EmailFolderTreeInitializes(){
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        User testUser = MERC_MarketingCloudTestUtility.insertUser();

        System.runAs(testUser){
            Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting(); 

            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
            mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersAllRequest());  

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mockResponseService);

            MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

            Test.stopTest();            

            List<MERC_MarketingCloudClient.EmailFolder> emailFolders = meetingEmailSendExtension.getEmailFolderTree();
            System.assertEquals(2, emailFolders.size());
        }  
    }

    @isTest static void test_AnExceptionDuringTreeInitialization_AddsFatalMessage(){
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        System.runAs(testUser){
            Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting(); 

            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
            mockResponseService.addExceptionResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersAllRequest());  

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mockResponseService);

            MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

            Test.stopTest();

            assertMessagesContain('An exception occured while retrieving the emails');
        }  
    }

    @isTest static void test_NoEmailFoldersAfterInitialization_AddsWarningMessage(){
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        System.runAs(testUser){
            Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting(); 

            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
            mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmptyEmailFoldersRequest());  

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mockResponseService);

            MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);
            List<MERC_MarketingCloudClient.EmailFolder> emailFolders = meetingEmailSendExtension.getEmailFolderTree();
            System.assertEquals(0, emailFolders.size());
            Test.stopTest();

            assertMessagesContain('No emails were found.');
        }  
    }

    @isTest static void test_FromEmailOptionsInitializes(){
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        User testUser = MERC_MarketingCloudTestUtility.insertUser();

        System.runAs(testUser){
            Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting(); 

            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
            mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getSenderProfilesRequest()); 

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mockResponseService);

            MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

            Test.stopTest();            

            List<SelectOption> fromEmailOptions = meetingEmailSendExtension.getFromEmailOptions();
            System.assertEquals(3, fromEmailOptions.size());
            for(SelectOption selectOption : fromEmailOptions){
                MERC_MarketingCloudTestUtility.assertSenderProfileLabelById(selectOption.getValue(), selectOption.getLabel());
            }
        }
    }

    @isTest static void test_AnExceptionDuringFromEmailOptionsInitialization_AddsFatalMessage(){
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        System.runAs(testUser){
            Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting(); 

            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
            mockResponseService.addExceptionResponse(MERC_MarketingCloudTestUtility.getSenderProfilesRequest());  

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mockResponseService);

            MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

            Test.stopTest();

            assertMessagesContain('An exception occured while retrieving From Email Options');
        }  
    }

    @isTest static void test_NoFromEmailOptionsAfterInitialization_AddsWarningMessage(){
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        System.runAs(testUser){
            Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting(); 

            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
            mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getEmptySenderProfilesRequest());  

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mockResponseService);

            MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);
            List<SelectOption> fromEmailOptions = meetingEmailSendExtension.getFromEmailOptions();
            System.assertEquals(0, fromEmailOptions.size());
            Test.stopTest();

            assertMessagesContain('No From Emails were found.');
        }  
    }

    @isTest static void test_OpenEmailChooser_ShowsEmailChooser(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

        meetingEmailSendExtension.openEmailChooser();
        System.assertEquals(true, meetingEmailSendExtension.getShowEmailChooser());
    }

    @isTest static void test_CloseEmailChooser_HidesEmailChooser(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

        meetingEmailSendExtension.closeEmailChooser();
        System.assertEquals(false, meetingEmailSendExtension.getShowEmailChooser());
    }

    @isTest static void test_CanExpandFolder(){
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        System.runAs(testUser){
            Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting(); 
       

            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
            mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersAllRequest());
            mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersRequest(MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID));
            mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailsRequest(MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID));

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mockResponseService);

            MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);
            ApexPages.currentPage().getParameters().put('emailFolderIdToExpand', MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID);
            meetingEmailSendExtension.expandEmailFolder();

            Test.stopTest();

            List<MERC_MarketingCloudClient.EmailFolder> emailFolders = meetingEmailSendExtension.getEmailFolderTree();
            System.assertEquals(2, emailFolders.size());
            System.assertEquals(2, emailFolders.get(1).subfolders.size(), meetingEmailSendExtension.getEmailFolderTree());
        }  

    }

    @isTest static void test_GetFolderInfoAddsFatalMessageIfExceptionOccurs(){
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        System.runAs(testUser){
            Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting(); 

            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
            mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersAllRequest());  
            mockResponseService.addExceptionResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersRequest(MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID));  
            mockResponseService.addExceptionResponse(MERC_MarketingCloudTestUtility.getMockGetEmailsRequest(MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID));  

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mockResponseService);

            MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);
            meetingEmailSendExtension.openEmailChooser();
            ApexPages.currentPage().getParameters().put('emailFolderIdToExpand', MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID);
            meetingEmailSendExtension.expandEmailFolder();

            Test.stopTest();

            assertMessagesContain('An exception occured while expanding the folder');
        }  
    }

    @isTest static void test_CanSelectEmail(){
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        System.runAs(testUser){
            Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
            String emailIdAsString = String.valueOf(MERC_MarketingCloudTestUtility.EMAIL_SEND_EMAIL_ID);

            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mockResponseService);

            MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);
            ApexPages.currentPage().getParameters().put('selectedEmailId', emailIdAsString);
            ApexPages.currentPage().getParameters().put('selectedEmailName', MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT);
            ApexPages.currentPage().getParameters().put('selectedEmailSubject', MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT);
            meetingEmailSendExtension.selectEmail();

            Test.stopTest();

            MERC_MarketingCloudClient.FolderedEmail selectedEmail = meetingEmailSendExtension.selectedEmail;
            System.assertEquals(emailIdAsString, selectedEmail.id);
            System.assertEquals(MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT, selectedEmail.subject);
            System.assertEquals(MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT, selectedEmail.name);
        }  
    }

    @isTest static void test_CanSelectEmail_ThumbnailGetsSet(){
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        System.runAs(testUser){
            Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
            String emailIdAsString = String.valueOf(MERC_MarketingCloudTestUtility.EMAIL_SEND_EMAIL_ID);

            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
            mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getThumbnailRequest(
                emailIdAsString, 
                MERC_MarketingCloudTestUtility.THUMBNAIL_HEIGHT, 
                MERC_MarketingCloudTestUtility.THUMBNAIL_WIDTH));

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mockResponseService);

            MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);
            ApexPages.currentPage().getParameters().put('selectedEmailId', emailIdAsString);
            ApexPages.currentPage().getParameters().put('selectedEmailName', MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT);
            ApexPages.currentPage().getParameters().put('selectedEmailSubject', MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT);
            meetingEmailSendExtension.selectEmail();

            Test.stopTest();

            System.assertEquals(MERC_MarketingCloudTestUtility.getThumbnail(), meetingEmailSendExtension.getSelectedEmailThumbnail());
        }  
    }

    @isTest static void test_CanSelectEmailAndUpdateSubject(){
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        System.runAs(testUser){
            Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
            String emailIdAsString = String.valueOf(MERC_MarketingCloudTestUtility.EMAIL_SEND_EMAIL_ID);
            String updatedSubject = MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT + 'updated';

            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mockResponseService);

            MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);
            ApexPages.currentPage().getParameters().put('selectedEmailId', emailIdAsString);
            ApexPages.currentPage().getParameters().put('selectedEmailName', MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT);
            ApexPages.currentPage().getParameters().put('selectedEmailSubject', MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT);
            meetingEmailSendExtension.selectEmail();

            meetingEmailSendExtension.selectedEmail.subject = updatedSubject;

            Test.stopTest();

            MERC_MarketingCloudClient.FolderedEmail selectedEmail = meetingEmailSendExtension.selectedEmail;
            System.assertEquals(emailIdAsString, selectedEmail.id);
            System.assertEquals(updatedSubject, selectedEmail.subject);
            System.assertEquals(MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT, selectedEmail.name);
        }  
    }

    @isTest static void test_CanSelectFromEmail(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

        Test.startTest();

        ApexPages.currentPage().getParameters().put('selectedEmailId', MERC_MarketingCloudTestUtility.EMAIL_ID);

        Test.stopTest();
    }

    @isTest static void test_AccessToParticipants(){
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        System.runAs(testUser){
            Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
            List<Account> personAccounts  = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
                MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 5);
            insert personAccounts;

            List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
            insert participants;

            Set<Id> participantIds = MERC_MarketingCloudTestUtility.getParticipantIdsAsSet(participants);

            MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

            Test.startTest();

            meetingEmailSendExtension.selectedParticipantIds = participantIds;

            Test.stopTest();

            System.assertEquals(participantIds, meetingEmailSendExtension.selectedParticipantIds);
        }
    }

    @isTest static void test_CanSetSendInFutureToNow(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

        Test.startTest();

        meetingEmailSendExtension.setSendInFuture('now');

        Test.stopTest();

        System.assertEquals('now', meetingEmailSendExtension.getSendInFuture());
    }

    @isTest static void test_CanSetSendInFutureToFuture(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

        Test.startTest();

        meetingEmailSendExtension.setSendInFuture('future');

        Test.stopTest();

        System.assertEquals('future', meetingEmailSendExtension.getSendInFuture());
    }

    @isTest static void test_CanSetSendInFutureToWhat_HasWarning(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

        Test.startTest();

        meetingEmailSendExtension.setSendInFuture('now');
        meetingEmailSendExtension.setSendInFuture('what');

        Test.stopTest();

        System.assertEquals('none', meetingEmailSendExtension.getSendInFuture());
        assertMessagesContain('what is not a valid value for sending in future');
    }

    @isTest static void test_AccessToSendInFutureDate(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);
        Datetime testDate = DateTime.now();
        Event sendInFutureDate = new Event();
        sendInFutureDate.ActivityDateTime = testDate;

        Test.startTest();

        meetingEmailSendExtension.setSendInFutureDate(sendInFutureDate);

        Test.stopTest();

        System.assertEquals(testDate, meetingEmailSendExtension.getSendInFutureDate().ActivityDateTime);
    }

    @isTest static void test_SendInFutureDate_Initializes(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();

        Test.startTest();

        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

        Test.stopTest();

        System.assertNotEquals(null, meetingEmailSendExtension.getSendInFutureDate());
    }

    @isTest static void test_AccessToDeDupeSubscribers(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

        Test.startTest();

        meetingEmailSendExtension.dedupeSubscribers = true;

        Test.stopTest();

        System.assertEquals(true, meetingEmailSendExtension.dedupeSubscribers);
    }

    @isTest static void test_AccessToDisableIndividualLevelTracking(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

        Test.startTest();

        meetingEmailSendExtension.disableIndividualLevelTracking = true;

        Test.stopTest();

        System.assertEquals(true, meetingEmailSendExtension.disableIndividualLevelTracking);
    }

    @isTest static void test_AccessToAdditionalInformationText(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

        Test.startTest();

        meetingEmailSendExtension.additionalInformationText = MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_TEXT;

        Test.stopTest();

        System.assertEquals(MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_TEXT, meetingEmailSendExtension.additionalInformationText);
    }

    @isTest static void test_AccessToAdditionalInformationHTML(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

        Test.startTest();

        meetingEmailSendExtension.additionalInformationHTML = MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_HTML;

        Test.stopTest();

        System.assertEquals(MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_HTML, meetingEmailSendExtension.additionalInformationHTML);
    }

    @isTest static void test_InvalidSend_HasErrorMessages(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

        Test.startTest();

        meetingEmailSendExtension.send();

        Test.stopTest();

        assertMessagesContain('You must select at least 1 Recipient.');
        assertMessagesContain('You must select a send date and time.');
        assertMessagesContain('You must select an email template.');
    }

    @isTest static void test_InvalidSendWithSelectedEmailButNoSubject_HasErrorMessage(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);
        ApexPages.currentPage().getParameters().put('selectedEmailId', MERC_MarketingCloudTestUtility.EMAIL_ID);
        ApexPages.currentPage().getParameters().put('selectedEmailName', null);
        ApexPages.currentPage().getParameters().put('selectedEmailSubject', null);
        meetingEmailSendExtension.selectEmail();
        Test.startTest();

        meetingEmailSendExtension.send();

        Test.stopTest();

        assertMessagesContain('The subject must be filled in.');
    }

    @isTest static void test_InvalidSendWithSendInFutureButNoDate_HasErrorMessage(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);
        meetingEmailSendExtension.setSendInFuture('future');
        Test.startTest();

        meetingEmailSendExtension.send();

        Test.stopTest();

        assertMessagesContain('The send date must be in the future.');
    }

    @isTest static void test_InvalidSendWithSendInFutureButOldDate_HasErrorMessage(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
        Event eventDate = new Event();
        eventDate.ActivityDateTime = DateTime.now().addHours(-1);

        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);
        meetingEmailSendExtension.setSendInFuture('future');
        meetingEmailSendExtension.setSendInFutureDate(eventDate);

        Test.startTest();

        meetingEmailSendExtension.send();

        Test.stopTest();

        assertMessagesContain('The send date must be in the future.');
    }

    @isTest static void test_ValidSend(){
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        System.runAs(testUser){
            MERC_TestFactory.adjustForSFDCSetMockBug = true;
            MERC_MarketingCloudTestUtility.adjustTime();
            Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
            List<Account> personAccounts  = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
                MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 5);
            insert personAccounts;

            List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
            insert participants;

            Set<Id> participantIds = MERC_MarketingCloudTestUtility.getParticipantIdsAsSet(participants);

            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.MockRequestsForEmailSendAttempt(
                testUser,
                meeting,
                participants,
                personAccounts);
            Test.setMock(HttpCalloutMock.class, mockResponseService);

            Test.startTest();

            MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);
            ApexPages.currentPage().getParameters().put('selectedEmailId', MERC_MarketingCloudTestUtility.EMAIL_ID);
            ApexPages.currentPage().getParameters().put('selectedEmailName', MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT);
            ApexPages.currentPage().getParameters().put('selectedEmailSubject', MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT);
            meetingEmailSendExtension.selectEmail();
            meetingEmailSendExtension.selectedParticipantIds = participantIds;
            meetingEmailSendExtension.dedupeSubscribers = MERC_MarketingCloudTestUtility.EMAIL_SEND_DEDUPE;
            meetingEmailSendExtension.disableIndividualLevelTracking = MERC_MarketingCloudTestUtility.EMAIL_SEND_TRACKING_DISABLED;
            meetingEmailSendExtension.setSendInFuture(MERC_MarketingCloudTestUtility.EMAIL_SEND_TIME);
            meetingEmailSendExtension.additionalInformationHTML = MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_HTML;
            meetingEmailSendExtension.additionalInformationText = MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_TEXT;
            ApexPages.currentPage().getParameters().put('selectedEmailId', MERC_MarketingCloudTestUtility.SEND_DEFINITION_SENDER_PROFILE_ID);
            PageReference pageReference = meetingEmailSendExtension.send();


            Test.stopTest();
            assertMessagesDoNotContain('An exception occured while sending the email.');
            System.assertEquals('/' + meeting.Id, pageReference.getUrl());
        }
    }

    @isTest static void test_ValidSendWithException(){
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        System.runAs(testUser){
            MERC_TestFactory.adjustForSFDCSetMockBug = true;
            MERC_MarketingCloudTestUtility.adjustTime();
            Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
            List<Account> personAccounts  = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
                MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 5);
            insert personAccounts;

            List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
            insert participants;

            Set<Id> participantIds = MERC_MarketingCloudTestUtility.getParticipantIdsAsSet(participants);

            Test.startTest();

            MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);
            ApexPages.currentPage().getParameters().put('selectedEmailId', MERC_MarketingCloudTestUtility.EMAIL_ID);
            ApexPages.currentPage().getParameters().put('selectedEmailName', MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT);
            ApexPages.currentPage().getParameters().put('selectedEmailSubject', MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT);
            meetingEmailSendExtension.selectEmail();
            meetingEmailSendExtension.selectedParticipantIds = participantIds;
            meetingEmailSendExtension.dedupeSubscribers = MERC_MarketingCloudTestUtility.EMAIL_SEND_DEDUPE;
            meetingEmailSendExtension.disableIndividualLevelTracking = MERC_MarketingCloudTestUtility.EMAIL_SEND_TRACKING_DISABLED;
            meetingEmailSendExtension.setSendInFuture(MERC_MarketingCloudTestUtility.EMAIL_SEND_TIME);
            meetingEmailSendExtension.additionalInformationHTML = MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_HTML;
            meetingEmailSendExtension.additionalInformationText = MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_TEXT;
            ApexPages.currentPage().getParameters().put('selectedEmailId', MERC_MarketingCloudTestUtility.SEND_DEFINITION_SENDER_PROFILE_ID);
            PageReference pageReference = meetingEmailSendExtension.send();


            Test.stopTest();
            assertMessagesContain('An exception occured while sending the email.');
        }
    }

    @isTest static void test_ParticipantsHaveOptedIn(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

        Test.startTest();

        meetingEmailSendExtension.participantsHaveOptedIn = true;

        Test.stopTest();

        System.assertEquals(true, meetingEmailSendExtension.participantsHaveOptedIn);
    }
        private static MERC_MeetingEmailSendExtension getSendRecipientsExtension(Meeting_MERC__c meeting){
        ApexPages.StandardController standardController = new ApexPages.StandardController(meeting);
        return new MERC_MeetingEmailSendExtension(standardController);
    }

    @isTest static void test_createMeetingAndChildren_DoesNotThrowSOQLLimit(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();
    }

    @isTest static void test_OnInitialize_AllOptionsAvailable(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 

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

    @isTest static void test_OnInitialize_IsGeneratingDocumentsIsFalse(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 

        Test.stopTest();

        System.assertEquals(false, sendRecipientsExtension.isGeneratingDocuments);
    }

    @isTest static void test_OnInitializeWithGeneratingDocuments_IsGeneratingDocumentsIsTrue(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        ApexPages.currentPage().getParameters().put('generatedocuments', '1');
        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 

        Test.stopTest();

        System.assertEquals(true, sendRecipientsExtension.isGeneratingDocuments);
    }

    private static Meeting_MERC__c insertMeetingAndChildren(){
        MERC_TriggerHandlerStateManager.deactivateAll();
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();           
        List<Account> personAccounts  = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
            MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 5);
        updateAccountWith(personAccounts.get(1), 'Phone', 'US', null, 'French');
        insert personAccounts;

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
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 

        List<MERC_MeetingEmailSendExtension.SelectableParticipant> participants = sendRecipientsExtension.currentPageOfSelectableParticipants;

        Test.stopTest();

        System.assertEquals(5, participants.size());
    }

    @isTest static void test_OnInitialize_ShouldNotRenderTaskFilter(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 

        Boolean shouldRender = sendRecipientsExtension.getShouldRenderTaskFilters();

        Test.stopTest();

        System.assertEquals(false, shouldRender);
    }

    @isTest static void test_SelectProcessType_ShouldRenderTaskFilter(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.processTypeSelected = MERC_MarketingCloudTestUtility.PROCESS_TYPE_REGISTRATION;

        Boolean shouldRender = sendRecipientsExtension.getShouldRenderTaskFilters();

        Test.stopTest();

        System.assertEquals(true, shouldRender);
    }

    @isTest static void test_OnInitialize_ShouldNotRenderProposalFilter(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 

        Boolean shouldRender = sendRecipientsExtension.getShouldRenderProposalFilter();

        Test.stopTest();

        System.assertEquals(false, shouldRender);
    }

    @isTest static void test_SelectProcessType_ShouldRenderProposalFilter(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.processTypeSelected = MERC_MarketingCloudTestUtility.PROCESS_TYPE_TRAVEL_PROPOSAL;

        Boolean shouldRender = sendRecipientsExtension.getShouldRenderProposalFilter();

        Test.stopTest();

        System.assertEquals(true, shouldRender);
    }

    @isTest static void test_SelectProcessType_Has2ProcessTypeOptions(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.processTypeSelected = MERC_MarketingCloudTestUtility.PROCESS_TYPE_REGISTRATION;

        List<SelectOption> processTypeOptions = sendRecipientsExtension.getProcessTypeOptions();

        Test.stopTest();


        System.assertEquals(3, processTypeOptions.size());
        System.assertEquals(MERC_MarketingCloudTestUtility.PROCESS_TYPE_REGISTRATION, processTypeOptions.get(1).getValue());
    }

    @isTest static void test_SelectProcessType_Has1ItineraryOption(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.processTypeSelected = MERC_MarketingCloudTestUtility.PROCESS_TYPE_REGISTRATION;

        List<SelectOption> proposalStatusOptions = sendRecipientsExtension.getProposalStatusOptions();

        Test.stopTest();


        System.assertEquals(2, proposalStatusOptions.size());
        System.assertEquals(MERC_MarketingCloudTestUtility.ITINERARY_REJECTED, proposalStatusOptions.get(1).getValue());
    }

    @isTest static void test_SelectProcessType_Has0DueDateOptions(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.processTypeSelected = MERC_MarketingCloudTestUtility.PROCESS_TYPE_REGISTRATION;
        List<SelectOption> dueDateOptions = sendRecipientsExtension.getDueDateOptions();

        Test.stopTest();

        System.assertEquals(1, dueDateOptions.size());
    }

    @isTest static void test_SelectProcessType_Has1NextStepOption(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.processTypeSelected = MERC_MarketingCloudTestUtility.PROCESS_TYPE_TRAVEL_PROPOSAL;
        List<SelectOption> nextStepOptions = sendRecipientsExtension.getNextStepOptions();

        Test.stopTest();

        System.assertEquals(2, nextStepOptions.size());
    }

    @isTest static void test_SelectProcessType_Has0NextStepOption(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.processTypeSelected = MERC_MarketingCloudTestUtility.PROCESS_TYPE_REGISTRATION;
        List<SelectOption> nextStepOptions = sendRecipientsExtension.getNextStepOptions();

        Test.stopTest();

        System.assertEquals(1, nextStepOptions.size());
    }

    @isTest static void test_SelectProcessType_Has0TaskStatusOptions(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.processTypeSelected = MERC_MarketingCloudTestUtility.PROCESS_TYPE_REGISTRATION;
        List<SelectOption> taskStatusOptions = sendRecipientsExtension.getTaskStatusOptions();

        Test.stopTest();

        System.assertEquals(1, taskStatusOptions.size());
    }

    @isTest static void test_SelectProcessType_Has2TaskStatusOptions(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.processTypeSelected = MERC_MarketingCloudTestUtility.PROCESS_TYPE_TRAVEL_PROPOSAL;
        List<SelectOption> taskStatusOptions = sendRecipientsExtension.getTaskStatusOptions();

        Test.stopTest();

        System.assertEquals(3, taskStatusOptions.size());
    }

    @isTest static void test_SelectProcessTypeNotTravelProposal_ProposalStatusIsAny(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();

        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.processTypeSelected = MERC_MarketingCloudTestUtility.PROCESS_TYPE_TRAVEL_PROPOSAL;

        Test.stopTest();

        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.proposalStatusSelected);
    }

    @isTest static void test_SelectAllProcessFilters_FiltersRecords(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 

        sendRecipientsExtension.processTypeSelected = MERC_MarketingCloudTestUtility.PROCESS_TYPE_TRAVEL_PROPOSAL;
        sendRecipientsExtension.proposalStatusSelected = MERC_MarketingCloudTestUtility.ITINERARY_ACCEPTED;
        sendRecipientsExtension.dueDateSelected = sendRecipientsExtension.getDueDateOptions().get(1).getValue();
        sendRecipientsExtension.nextStepSelected = sendRecipientsExtension.getNextStepOptions().get(1).getValue();
        sendRecipientsExtension.taskStatusSelected = MERC_MarketingCloudTestUtility.TASK_STATUS_COMPLETED;

        List<SelectOption> processTypeOptions = sendRecipientsExtension.getProcessTypeOptions();
        List<MERC_MeetingEmailSendExtension.SelectableParticipant> participants = sendRecipientsExtension.currentPageOfSelectableParticipants;
        Test.stopTest();


        System.assertEquals(2, processTypeOptions.size());
        System.assertEquals(1, participants.size());
    }

    @isTest static void test_SelectAllProcessFiltersThenSetProcessTypeAny_ClearsProcessFilters(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 

        sendRecipientsExtension.processTypeSelected = MERC_MarketingCloudTestUtility.PROCESS_TYPE_TRAVEL_PROPOSAL;
        sendRecipientsExtension.proposalStatusSelected = MERC_MarketingCloudTestUtility.ITINERARY_ACCEPTED;
        sendRecipientsExtension.dueDateSelected = sendRecipientsExtension.getDueDateOptions().get(1).getValue();
        sendRecipientsExtension.nextStepSelected = sendRecipientsExtension.getNextStepOptions().get(1).getValue();
        sendRecipientsExtension.taskStatusSelected = MERC_MarketingCloudTestUtility.TASK_STATUS_COMPLETED;
        sendRecipientsExtension.processTypeSelected = sendRecipientsExtension.ANY_OPTION;

        Test.stopTest();

        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.processTypeSelected);
        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.proposalStatusSelected);
        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.dueDateSelected);
        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.nextStepSelected);
        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.taskStatusSelected);
    }

    @isTest static void test_SelectAllFiltersThenClearFilters_ClearsFilters(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 

        sendRecipientsExtension.processTypeSelected = MERC_MarketingCloudTestUtility.PROCESS_TYPE_TRAVEL_PROPOSAL;
        sendRecipientsExtension.proposalStatusSelected = MERC_MarketingCloudTestUtility.ITINERARY_ACCEPTED;
        sendRecipientsExtension.dueDateSelected = sendRecipientsExtension.getDueDateOptions().get(1).getValue();
        sendRecipientsExtension.nextStepSelected = sendRecipientsExtension.getNextStepOptions().get(1).getValue();
        sendRecipientsExtension.taskStatusSelected = MERC_MarketingCloudTestUtility.TASK_STATUS_COMPLETED;
        sendRecipientsExtension.communicationChannelSelected = 'Phone';
        sendRecipientsExtension.countryOfResidenceSelected = 'US';
        sendRecipientsExtension.hasEmailSelected = 'No';
        sendRecipientsExtension.participantStatusSelected = 'Rejected';
        sendRecipientsExtension.preferredLanguageSelected = 'French';
        sendRecipientsExtension.recordTypeSelected = MERC_ETTestUtils.GetRecordType(MERC_MarketingCloudTestUtility.PARTICIPANT_RECORD_TYPE_DELEGATE, 'Meeting_Participant_MERC__c').Id;
        List<MERC_MeetingEmailSendExtension.SelectableParticipant> filteredParticipants = sendRecipientsExtension.currentPageOfSelectableParticipants;

        sendRecipientsExtension.clearFilters();

        List<MERC_MeetingEmailSendExtension.SelectableParticipant> unFilteredParticipants = sendRecipientsExtension.currentPageOfSelectableParticipants;

        Test.stopTest();

        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.processTypeSelected);
        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.proposalStatusSelected);
        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.dueDateSelected);
        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.nextStepSelected);
        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.taskStatusSelected);
        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.communicationChannelSelected);
        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.countryOfResidenceSelected);
        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.hasEmailSelected);
        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.participantStatusSelected);
        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.preferredLanguageSelected);
        System.assertEquals(sendRecipientsExtension.ANY_OPTION, sendRecipientsExtension.recordTypeSelected);

        System.assertEquals(1, filteredParticipants.size());
        System.assertEquals(5, unFilteredParticipants.size());
    }

    @isTest static void test_HasEmailYes_FiltersParticipants(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 

        sendRecipientsExtension.hasEmailSelected = 'Yes';

        List<MERC_MeetingEmailSendExtension.SelectableParticipant> filteredParticipants = sendRecipientsExtension.currentPageOfSelectableParticipants;

        sendRecipientsExtension.clearFilters();

        List<MERC_MeetingEmailSendExtension.SelectableParticipant> unFilteredParticipants = sendRecipientsExtension.currentPageOfSelectableParticipants;

        Test.stopTest();

        System.assertEquals(4, filteredParticipants.size());
        System.assertEquals(5, unFilteredParticipants.size());
    }

    @isTest static void test_OnInitialize_Has2CommunicationOptions(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        List<SelectOption> communicationChannelOptions = sendRecipientsExtension.getCommunicationChannelOptions();

        Test.stopTest();

        System.assertEquals(3, communicationChannelOptions.size());
    }

    @isTest static void test_OnInitialize_Has2CountryOptions(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        List<SelectOption> countryOptions = sendRecipientsExtension.getCountryOptions();

        Test.stopTest();

        System.assertEquals(3, countryOptions.size());
    }

    @isTest static void test_OnInitialize_Has2ParticipantStatusOptions(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        List<SelectOption> participantStatusOptions = sendRecipientsExtension.getParticipantStatusOptions();

        Test.stopTest();

        System.assertEquals(3, participantStatusOptions.size());
    }

    @isTest static void test_OnInitialize_Has2LanguageOptions(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        List<SelectOption> languageOptions = sendRecipientsExtension.getLanguageOptions();

        Test.stopTest();

        System.assertEquals(3, languageOptions.size());
    }

    @isTest static void test_OnInitialize_Has2HasEmailOptions(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        List<SelectOption> hasEmailOptions = sendRecipientsExtension.getHasEmailOptions();

        Test.stopTest();

        System.assertEquals(3, hasEmailOptions.size());
    }

    @isTest static void test_OnInitialize_Has2RecordTypeOptions(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        List<SelectOption> recordTypeOptions = sendRecipientsExtension.getRecordTypeOptions();

        Test.stopTest();

        System.assertEquals(3, recordTypeOptions.size());
    }

    @isTest static void test_OnInitialize_SortPropertiesDefault(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        List<MERC_MeetingEmailSendExtension.SelectableParticipant> participants = sendRecipientsExtension.currentPageOfSelectableParticipants;

        Test.stopTest();

        String participantLastName = null;
        for(MERC_MeetingEmailSendExtension.SelectableParticipant participant : participants){
            if(participantLastName != null){
                System.assert(participantLastName < participant.Participant.Account_MERC__r.LastName, participantLastName + ' < ' + participant.Participant.Account_MERC__r.LastName + ' not true');
            }
            participantLastName = participant.Participant.Account_MERC__r.LastName;
        }
    }

    @isTest static void test_SetSortFieldLastName_ReversesOrder(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Account_MERC__r.LastName');
        List<MERC_MeetingEmailSendExtension.SelectableParticipant> participants = sendRecipientsExtension.currentPageOfSelectableParticipants;

        Test.stopTest();

        String participantLastName = null;
        for(MERC_MeetingEmailSendExtension.SelectableParticipant participant : participants){
            if(participantLastName != null){
                System.assert(participantLastName >= participant.Participant.Account_MERC__r.LastName, participantLastName + ' >= ' + participant.Participant.Account_MERC__r.LastName + ' not true');
            }
            participantLastName = participant.Participant.Account_MERC__r.LastName;
        }
    }

    @isTest static void test_SetSortFieldStatus_EnforcesStatusOrder(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Status_MERC__c');
        List<MERC_MeetingEmailSendExtension.SelectableParticipant> participants = sendRecipientsExtension.currentPageOfSelectableParticipants;

        Test.stopTest();
        Map<String, Integer> statusValues = getListOfStatusPicklistValues();

        String participantLastStatus = null;
        for(MERC_MeetingEmailSendExtension.SelectableParticipant participant : participants){
            if(participantLastStatus != null){
                System.assert(statusValues.get(participantLastStatus) <= statusValues.get(participant.Participant.Status_MERC__c), 
                    participantLastStatus + '(' + statusValues.get(participantLastStatus) + ') <= ' + participant.Participant.Status_MERC__c + '(' + statusValues.get(participant.Participant.Status_MERC__c) + ') not true');
            }
            participantLastStatus = participant.Participant.Status_MERC__c;
        }
    }

    @isTest static void test_SetSortFieldStatusTwice_EnforcesReverseStatusOrder(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Status_MERC__c');
        sendRecipientsExtension.setSortField('Status_MERC__c');
        List<MERC_MeetingEmailSendExtension.SelectableParticipant> participants = sendRecipientsExtension.currentPageOfSelectableParticipants;

        Test.stopTest();
        Map<String, Integer> statusValues = getListOfStatusPicklistValues();

        String participantLastStatus = null;
        for(MERC_MeetingEmailSendExtension.SelectableParticipant participant : participants){
            if(participantLastStatus != null){
                System.assert(statusValues.get(participantLastStatus) >= statusValues.get(participant.Participant.Status_MERC__c), 
                    participantLastStatus + '(' + statusValues.get(participantLastStatus) + ') >= ' + participant.Participant.Status_MERC__c + '(' + statusValues.get(participant.Participant.Status_MERC__c) + ') not true ' + statusValues);
            }
            participantLastStatus = participant.Participant.Status_MERC__c;
        }
    }

    private static Map<String, Integer> getListOfStatusPicklistValues(){
        List<Schema.PicklistEntry> entries = Meeting_Participant_MERC__c.Status_MERC__c.getDescribe().getPicklistValues();
        Map<String, Integer> values = new Map<String, Integer>();
        Integer index = 0;
        for(Schema.PicklistEntry entry : entries){
            values.put(entry.getValue(), index);
            index++;
        }
        return values;
    }

    @isTest static void test_SetSortFieldToTitle_TitleSuffixHasDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Account_MERC__r.Title_Desc_GLBL__c');

        Test.stopTest();

        System.assertEquals('^', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCountrySuffix());
    }

    @isTest static void test_SetSortFieldToTitleTwice_TitleSuffixHasDownDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Account_MERC__r.Title_Desc_GLBL__c');
        sendRecipientsExtension.setSortField('Account_MERC__r.Title_Desc_GLBL__c');

        Test.stopTest();

        System.assertEquals('v', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCountrySuffix());
    }



    @isTest static void test_SetSortFieldToFirstName_FirstNameSuffixHasDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Account_MERC__r.FirstName');

        Test.stopTest();

        System.assertEquals(' ', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals('^', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCountrySuffix());
    }

    @isTest static void test_SetSortFieldToFirstNameTwice_FirstNameSuffixHasDownDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Account_MERC__r.FirstName');
        sendRecipientsExtension.setSortField('Account_MERC__r.FirstName');

        Test.stopTest();

        System.assertEquals(' ', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals('v', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCountrySuffix());
    }



    @isTest static void test_SetSortFieldToLastName_LastNameSuffixHasDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 

        Test.stopTest();

        System.assertEquals(' ', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals('^', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCountrySuffix());
    }

    @isTest static void test_SetSortFieldToLastNameTwice_LastNameSuffixHasDownDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Account_MERC__r.LastName');

        Test.stopTest();

        System.assertEquals(' ', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals('v', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCountrySuffix());
    }



    @isTest static void test_SetSortFieldToSuffix_SuffixSuffixHasDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Account_MERC__r.Sfx_Nm_GLBL__c');

        Test.stopTest();

        System.assertEquals(' ', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals('^', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCountrySuffix());
    }

    @isTest static void test_SetSortFieldToSuffixTwice_SuffixSuffixHasDownDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Account_MERC__r.Sfx_Nm_GLBL__c');
        sendRecipientsExtension.setSortField('Account_MERC__r.Sfx_Nm_GLBL__c');

        Test.stopTest();

        System.assertEquals(' ', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals('v', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCountrySuffix());
    }



    @isTest static void test_SetSortFieldToEmail_EmailSuffixHasDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Account_MERC__r.PersonEmail');

        Test.stopTest();

        System.assertEquals(' ', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals('^', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCountrySuffix());
    }

    @isTest static void test_SetSortFieldToEmailTwice_EmailSuffixHasDownDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Account_MERC__r.PersonEmail');
        sendRecipientsExtension.setSortField('Account_MERC__r.PersonEmail');

        Test.stopTest();

        System.assertEquals(' ', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals('v', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCountrySuffix());
    }



    @isTest static void test_SetSortFieldToStatus_StatusSuffixHasDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Status_MERC__c');

        Test.stopTest();

        System.assertEquals(' ', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals('^', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCountrySuffix());
    }

    @isTest static void test_SetSortFieldToStatusTwice_StatusSuffixHasDownDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Status_MERC__c');
        sendRecipientsExtension.setSortField('Status_MERC__c');

        Test.stopTest();

        System.assertEquals(' ', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals('v', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCountrySuffix());
    }



    @isTest static void test_SetSortFieldToRecordType_RecordTypeSuffixHasDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Record_Type_MERC__c');

        Test.stopTest();

        System.assertEquals(' ', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals('^', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCountrySuffix());
    }

    @isTest static void test_SetSortFieldToRecordTypeTwice_RecordTypeSuffixHasDownDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Record_Type_MERC__c');
        sendRecipientsExtension.setSortField('Record_Type_MERC__c');

        Test.stopTest();

        System.assertEquals(' ', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals('v', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCountrySuffix());
    }



    @isTest static void test_SetSortFieldToCommunicationPreference_CommunicationPreferenceSuffixHasDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Account_MERC__r.Communication_Preference_MERC__c');

        Test.stopTest();

        System.assertEquals(' ', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals('^', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCountrySuffix());
    }

    @isTest static void test_SetSortFieldToCommunicationPreferenceTwice_CommunicationPreferenceSuffixHasDownDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Account_MERC__r.Communication_Preference_MERC__c');
        sendRecipientsExtension.setSortField('Account_MERC__r.Communication_Preference_MERC__c');

        Test.stopTest();

        System.assertEquals(' ', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals('v', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCountrySuffix());
    }



    @isTest static void test_SetSortFieldToLanguage_LanguageSuffixHasDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Account_MERC__r.Prfrd_Lang_Cd_GLBL__c');

        Test.stopTest();

        System.assertEquals(' ', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals('^', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCountrySuffix());
    }

    @isTest static void test_SetSortFieldToLanguageTwice_LanguageSuffixHasDownDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Account_MERC__r.Prfrd_Lang_Cd_GLBL__c');
        sendRecipientsExtension.setSortField('Account_MERC__r.Prfrd_Lang_Cd_GLBL__c');

        Test.stopTest();

        System.assertEquals(' ', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals('v', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCountrySuffix());
    }



    @isTest static void test_SetSortFieldToCountry_CountrySuffixHasDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Account_MERC__r.Country_of_Residence_GLBL__c');

        Test.stopTest();

        System.assertEquals(' ', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals('^', sendRecipientsExtension.getHeaderCountrySuffix());
    }

    @isTest static void test_SetSortFieldToCountryTwice_CountrySuffixHasDownDirection(){
        Meeting_MERC__c meeting = insertMeetingAndChildren();

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.setSortField('Account_MERC__r.Country_of_Residence_GLBL__c');
        sendRecipientsExtension.setSortField('Account_MERC__r.Country_of_Residence_GLBL__c');

        Test.stopTest();

        System.assertEquals(' ', sendRecipientsExtension.getHeaderTitleSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderFirstNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderLastNameSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderSuffixSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderEmailSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderStatusSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderRecordTypeSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderCommPrefSuffix());
        System.assertEquals(' ', sendRecipientsExtension.getHeaderPrefLangSuffix());
        System.assertEquals('v', sendRecipientsExtension.getHeaderCountrySuffix());
    }

    @isTest static void test_NextPage_GetsNextPage(){
        MERC_TriggerHandlerStateManager.deactivateAll();
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();           
        List<Account> personAccounts  = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
            MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 149);
        insert personAccounts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
        insert participants;

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.goToNextPage();
        List<MERC_MeetingEmailSendExtension.SelectableParticipant> selectableParticipants = sendRecipientsExtension.currentPageOfSelectableParticipants;
        Test.stopTest();

        System.assertEquals(50, selectableParticipants.size());
        System.assertEquals(2, sendRecipientsExtension.getPageNumber());
        System.assertEquals(3, sendRecipientsExtension.getMaxPageNumber());
        System.assertEquals(true, sendRecipientsExtension.getHasNext());
        System.assertEquals(true, sendRecipientsExtension.getHasPrevious());
    }

    @isTest static void test_NextPageThenFirstPage_GetsFirstPage(){
        MERC_TriggerHandlerStateManager.deactivateAll();
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();           
        List<Account> personAccounts  = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
            MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 149);
        insert personAccounts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
        insert participants;

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.goToNextPage();
        sendRecipientsExtension.goToFirstPage();
        List<MERC_MeetingEmailSendExtension.SelectableParticipant> selectableParticipants = sendRecipientsExtension.currentPageOfSelectableParticipants;
        Test.stopTest();

        System.assertEquals(50, selectableParticipants.size());
        System.assertEquals(1, sendRecipientsExtension.getPageNumber());
        System.assertEquals(3, sendRecipientsExtension.getMaxPageNumber());
        System.assertEquals(personAccounts.get(0).LastName, selectableParticipants.get(0).Participant.Account_MERC__r.LastName);
        System.assertEquals(true, sendRecipientsExtension.getHasNext());
        System.assertEquals(false, sendRecipientsExtension.getHasPrevious());
    }

    @isTest static void test_NextPageThenPreviousPage_GetsFirstPage(){
        MERC_TriggerHandlerStateManager.deactivateAll();
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();           
        List<Account> personAccounts  = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
            MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 149);
        insert personAccounts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
        insert participants;

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.goToNextPage();
        sendRecipientsExtension.goToPreviousPage();
        List<MERC_MeetingEmailSendExtension.SelectableParticipant> selectableParticipants = sendRecipientsExtension.currentPageOfSelectableParticipants;
        Test.stopTest();

        System.assertEquals(50, selectableParticipants.size());
        System.assertEquals(1, sendRecipientsExtension.getPageNumber());
        System.assertEquals(3, sendRecipientsExtension.getMaxPageNumber());
        System.assertEquals(personAccounts.get(0).LastName, selectableParticipants.get(0).Participant.Account_MERC__r.LastName);
        System.assertEquals(true, sendRecipientsExtension.getHasNext());
        System.assertEquals(false, sendRecipientsExtension.getHasPrevious());
    }

    @isTest static void test_LastPage_GetsLastPage(){
        MERC_TriggerHandlerStateManager.deactivateAll();
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();           
        List<Account> personAccounts  = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
            MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 149);
        insert personAccounts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
        insert participants;

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.goToLastPage();
        List<MERC_MeetingEmailSendExtension.SelectableParticipant> selectableParticipants = sendRecipientsExtension.currentPageOfSelectableParticipants;
        Test.stopTest();

        System.assertEquals(49, selectableParticipants.size());   
        System.assertEquals(3, sendRecipientsExtension.getPageNumber());
        System.assertEquals(3, sendRecipientsExtension.getMaxPageNumber());     
        System.assertEquals(false, sendRecipientsExtension.getHasNext());
        System.assertEquals(true, sendRecipientsExtension.getHasPrevious());
    }

    @isTest static void test_PagingFor150(){
        MERC_TriggerHandlerStateManager.deactivateAll();
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();           
        List<Account> personAccounts  = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
            MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 150);
        insert personAccounts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
        insert participants;

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting); 
        sendRecipientsExtension.goToLastPage();
        List<MERC_MeetingEmailSendExtension.SelectableParticipant> selectableParticipants = sendRecipientsExtension.currentPageOfSelectableParticipants;
        Test.stopTest();

        System.assertEquals(50, selectableParticipants.size());   
        System.assertEquals(3, sendRecipientsExtension.getPageNumber());
        System.assertEquals(3, sendRecipientsExtension.getMaxPageNumber());     
        System.assertEquals(false, sendRecipientsExtension.getHasNext());
        System.assertEquals(true, sendRecipientsExtension.getHasPrevious());
    }

    @isTest static void test_SelectingParticipant_PersistsAcrossPages(){
        MERC_TriggerHandlerStateManager.deactivateAll();
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();           
        List<Account> personAccounts  = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
            MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 149);
        insert personAccounts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
        insert participants;

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting);
        sendRecipientsExtension.currentPageOfSelectableParticipants.get(0).IsSelected = true;
        sendRecipientsExtension.goToLastPage();
        sendRecipientsExtension.currentPageOfSelectableParticipants.get(1).IsSelected = true;
        sendRecipientsExtension.goToFirstPage();
        List<MERC_MeetingEmailSendExtension.SelectableParticipant> selectableParticipants = sendRecipientsExtension.currentPageOfSelectableParticipants;
        Test.stopTest();

        System.assertEquals(true, sendRecipientsExtension.currentPageOfSelectableParticipants.get(0).IsSelected);
        System.assertEquals(false, sendRecipientsExtension.currentPageOfSelectableParticipants.get(1).IsSelected);
        System.assertEquals(0, sendRecipientsExtension.selectedParticipantIds.size());
    }

    @isTest static void test_SelectingParticipantsAndSaving_SetsSelectedParticipantIds(){
        MERC_TriggerHandlerStateManager.deactivateAll();
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();           
        List<Account> personAccounts  = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
            MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 149);
        insert personAccounts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
        insert participants;

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting);
        sendRecipientsExtension.currentPageOfSelectableParticipants.get(0).IsSelected = true;
        sendRecipientsExtension.goToLastPage();
        sendRecipientsExtension.currentPageOfSelectableParticipants.get(1).IsSelected = true;
        PageReference pageReference = sendRecipientsExtension.updateSelectedParticipantIdsAndReturn();
        Test.stopTest();
        System.assertEquals(2, sendRecipientsExtension.selectedParticipantIds.size());
        System.assert(pageReference.getUrl().startsWithIgnoreCase(Page.MeetingEmailSend.getUrl()), pageReference.getUrl() + ' does not start with ' + Page.MeetingEmailSend.getUrl());
        System.assertEquals(meeting.Id, pageReference.getParameters().get('id'));
    }

    @isTest static void test_SelectingParticipantsAndCancelling_DoesNotSetSelectedParticipantIds(){
        MERC_TriggerHandlerStateManager.deactivateAll();
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();           
        List<Account> personAccounts  = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
            MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 149);
        insert personAccounts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
        insert participants;

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting);
        sendRecipientsExtension.currentPageOfSelectableParticipants.get(0).IsSelected = true;
        sendRecipientsExtension.goToLastPage();
        sendRecipientsExtension.currentPageOfSelectableParticipants.get(1).IsSelected = true;
        PageReference pageReference = sendRecipientsExtension.cancelAndReturn();
        Test.stopTest();
        System.assertEquals(0, sendRecipientsExtension.selectedParticipantIds.size());
        System.assert(pageReference.getUrl().startsWithIgnoreCase(Page.MeetingEmailSend.getUrl()), pageReference.getUrl() + ' does not start with ' + Page.MeetingEmailSend.getUrl());
        System.assertEquals(meeting.Id, pageReference.getParameters().get('id'));
    }

    @isTest static void test_GenerateDocuments_SetsSelectedParticipantIds(){
        MERC_TriggerHandlerStateManager.deactivateAll();
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();           
        List<Account> personAccounts  = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
            MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 149);
        insert personAccounts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
        insert participants;

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting);
        sendRecipientsExtension.currentPageOfSelectableParticipants.get(0).IsSelected = true;
        sendRecipientsExtension.goToLastPage();
        sendRecipientsExtension.currentPageOfSelectableParticipants.get(1).IsSelected = true;
        PageReference pageReference = sendRecipientsExtension.generateDocuments();
        Test.stopTest();
        System.assertEquals(2, sendRecipientsExtension.selectedParticipantIds.size());
    }

    @isTest static void test_GenerateDocuments_RedirectsToDrawloop(){

        MERC_TriggerHandlerStateManager.deactivateAll();
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();           
        List<Account> personAccounts  = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
            MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 149);
        insert personAccounts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
        insert participants;

        Test.startTest();
        MERC_MeetingEmailSendExtension sendRecipientsExtension = getSendRecipientsExtension(meeting);
        sendRecipientsExtension.currentPageOfSelectableParticipants.get(0).IsSelected = true;
        sendRecipientsExtension.goToLastPage();
        sendRecipientsExtension.currentPageOfSelectableParticipants.get(1).IsSelected = true;
        PageReference pageReference = sendRecipientsExtension.generateDocuments();
        Test.stopTest();

        System.assert(pageReference.getUrl().startsWithIgnoreCase('/apex/loop__masslooplus'), pageReference.getUrl() + ' does not start with /apex/loop__masslooplus');
        System.assertEquals(meeting.Id, pageReference.getParameters().get('retUrl'), pageReference.getUrl());

        String[] selectedIds = pageReference.getParameters().get('recordIds').split(',');
        List<Meeting_Participant_MERC__c> selectedParticipants = [SELECT Id FROM Meeting_Participant_MERC__c WHERE Id IN :selectedIds];
        System.assertEquals(2, selectedParticipants.size());
    }
}