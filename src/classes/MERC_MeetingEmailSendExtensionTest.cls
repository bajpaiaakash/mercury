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
        Boolean containsMessage = false;
        for(ApexPages.Message pageMessage : ApexPages.getMessages()){
            containsMessage = pageMessage.getDetail().contains(message);
            if(containsMessage){
                break;
            }
        }
        System.assert(containsMessage, message + ' not found in ApexPages.getMessages():\n\t' + ApexPages.getMessages());
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

    @isTest static void test_OpenEmailChooser_ShowsEmailChooser(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getMeetingEmailSendExtension(meeting);

        meetingEmailSendExtension.openEmailChooser();
        System.assertEquals(true, meetingEmailSendExtension.getShowEmailChooser());
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
            meetingEmailSendExtension.setSelectedEmailId(emailIdAsString);
            meetingEmailSendExtension.setSelectedEmailName(MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT);
            meetingEmailSendExtension.setSelectedEmailSubject(MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT);
            meetingEmailSendExtension.selectEmail();

            Test.stopTest();

            MERC_MarketingCloudClient.FolderedEmail selectedEmail = meetingEmailSendExtension.getSelectedEmail();
            System.assertEquals(emailIdAsString, selectedEmail.id);
            System.assertEquals(MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT, selectedEmail.subject);
            System.assertEquals(MERC_MarketingCloudTestUtility.EMAIL_SEND_SUBJECT, selectedEmail.name);
        }  
    }
}