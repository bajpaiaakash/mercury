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
            meetingEmailSendExtension.setEmailFolderIdToExpand(MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID);
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
            meetingEmailSendExtension.setEmailFolderIdToExpand(MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID);
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
            meetingEmailSendExtension.selectedEmailId = emailIdAsString;
            meetingEmailSendExtension.selectedEmailName = MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT;
            meetingEmailSendExtension.selectedEmailSubject = MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT;
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
            meetingEmailSendExtension.selectedEmailId = emailIdAsString;
            meetingEmailSendExtension.selectedEmailName = MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT;
            meetingEmailSendExtension.selectedEmailSubject = MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT;
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
            meetingEmailSendExtension.selectedEmailId = emailIdAsString;
            meetingEmailSendExtension.selectedEmailName = MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT;
            meetingEmailSendExtension.selectedEmailSubject = MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT;
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

        meetingEmailSendExtension.selectedEmailId = MERC_MarketingCloudTestUtility.EMAIL_ID;

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

            meetingEmailSendExtension.setSelectedParticipantIds(participantIds);

            Test.stopTest();

            System.assertEquals(participantIds, meetingEmailSendExtension.getSelectedParticipantIds());
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
        meetingEmailSendExtension.selectedEmailId = MERC_MarketingCloudTestUtility.EMAIL_ID;
        meetingEmailSendExtension.selectedEmailName = null;
        meetingEmailSendExtension.selectedEmailSubject = null;
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
            meetingEmailSendExtension.selectedEmailId = MERC_MarketingCloudTestUtility.EMAIL_ID;
            meetingEmailSendExtension.selectedEmailName = MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT;
            meetingEmailSendExtension.selectedEmailSubject = MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT;
            meetingEmailSendExtension.selectEmail();
            meetingEmailSendExtension.setSelectedParticipantIds(participantIds);
            meetingEmailSendExtension.dedupeSubscribers = MERC_MarketingCloudTestUtility.EMAIL_SEND_DEDUPE;
            meetingEmailSendExtension.disableIndividualLevelTracking = MERC_MarketingCloudTestUtility.EMAIL_SEND_TRACKING_DISABLED;
            meetingEmailSendExtension.setSendInFuture(MERC_MarketingCloudTestUtility.EMAIL_SEND_TIME);
            meetingEmailSendExtension.additionalInformationHTML = MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_HTML;
            meetingEmailSendExtension.additionalInformationText = MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_TEXT;
            meetingEmailSendExtension.selectedEmailId = MERC_MarketingCloudTestUtility.SEND_DEFINITION_SENDER_PROFILE_ID;
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
            meetingEmailSendExtension.selectedEmailId = MERC_MarketingCloudTestUtility.EMAIL_ID;
            meetingEmailSendExtension.selectedEmailName = MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT;
            meetingEmailSendExtension.selectedEmailSubject = MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT;
            meetingEmailSendExtension.selectEmail();
            meetingEmailSendExtension.setSelectedParticipantIds(participantIds);
            meetingEmailSendExtension.dedupeSubscribers = MERC_MarketingCloudTestUtility.EMAIL_SEND_DEDUPE;
            meetingEmailSendExtension.disableIndividualLevelTracking = MERC_MarketingCloudTestUtility.EMAIL_SEND_TRACKING_DISABLED;
            meetingEmailSendExtension.setSendInFuture(MERC_MarketingCloudTestUtility.EMAIL_SEND_TIME);
            meetingEmailSendExtension.additionalInformationHTML = MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_HTML;
            meetingEmailSendExtension.additionalInformationText = MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_TEXT;
            meetingEmailSendExtension.selectedEmailId = MERC_MarketingCloudTestUtility.SEND_DEFINITION_SENDER_PROFILE_ID;
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
}