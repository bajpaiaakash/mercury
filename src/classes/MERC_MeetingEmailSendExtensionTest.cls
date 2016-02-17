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
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getValidMeetingEmailSendExtension();
    }

    private static MERC_MeetingEmailSendExtension getValidMeetingEmailSendExtension(){
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
        return getMeetingEmailSendExtension(meeting);
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

    @isTest static void test_EmailFolderTreeInitializesToNull(){
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getValidMeetingEmailSendExtension();

        System.assertEquals(null, meetingEmailSendExtension.getEmailFolderTree());
    }

    @isTest static void test_OpenEmailChooser_PopulatesEmailFolderTree(){
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getValidMeetingEmailSendExtension();
        User testUser = MERC_MarketingCloudTestUtility.insertUser();

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersAllRequest());  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            meetingEmailSendExtension.openEmailChooser();
            List<MERC_MarketingCloudClient.EmailFolder> emailFolders = meetingEmailSendExtension.getEmailFolderTree();
            System.assertEquals(2, emailFolders.size());
        }  
        Test.stopTest();
    }

    @isTest static void test_OpenEmailChooser_ShowsEmailChooser(){
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getValidMeetingEmailSendExtension();
        User testUser = MERC_MarketingCloudTestUtility.insertUser();

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersAllRequest());  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            meetingEmailSendExtension.openEmailChooser();
            System.assertEquals(true, meetingEmailSendExtension.getShowEmailChooser());
        }  
        Test.stopTest();
    }

    @isTest static void test_AnExceptionDuringOpenEmailChooser_AddsFatalMessage(){
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getValidMeetingEmailSendExtension();
        User testUser = MERC_MarketingCloudTestUtility.insertUser();

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addExceptionResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersAllRequest());  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            meetingEmailSendExtension.openEmailChooser();
            List<MERC_MarketingCloudClient.EmailFolder> emailFolders = meetingEmailSendExtension.getEmailFolderTree();            
        }  
        Test.stopTest();

        assertMessagesContain('An exception occured while retrieving the emails');
    }

    @isTest static void test_NoEmailFoldersAfterOpenEmailChooser_AddsWarningMessage(){
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getValidMeetingEmailSendExtension();
        User testUser = MERC_MarketingCloudTestUtility.insertUser();

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmptyEmailFoldersRequest());  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            meetingEmailSendExtension.openEmailChooser();
            List<MERC_MarketingCloudClient.EmailFolder> emailFolders = meetingEmailSendExtension.getEmailFolderTree();
            System.assertEquals(0, emailFolders.size());
        }  
        Test.stopTest();

        assertMessagesContain('No emails were found.');
    }

    @isTest static void test_CanExpandFolder(){
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getValidMeetingEmailSendExtension();
        User testUser = MERC_MarketingCloudTestUtility.insertUser();

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersAllRequest());  
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersRequest(MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID));  
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailsRequest(MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID));  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            meetingEmailSendExtension.openEmailChooser();
            meetingEmailSendExtension.setEmailFolderIdToExpand(MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID);
            meetingEmailSendExtension.expandEmailFolder();
        }  
        Test.stopTest();

        List<MERC_MarketingCloudClient.EmailFolder> emailFolders = meetingEmailSendExtension.getEmailFolderTree();
        System.assertEquals(2, emailFolders.size());
        System.assertEquals(2, emailFolders.get(1).subfolders.size(), meetingEmailSendExtension.getEmailFolderTree());
    }

    @isTest static void test_GetFolderInfoAddsFatalMessageIfExceptionOccurs(){
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        MERC_MeetingEmailSendExtension meetingEmailSendExtension = getValidMeetingEmailSendExtension();
        User testUser = MERC_MarketingCloudTestUtility.insertUser();

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersAllRequest());  
        mockResponseService.addExceptionResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersRequest(MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID));  
        mockResponseService.addExceptionResponse(MERC_MarketingCloudTestUtility.getMockGetEmailsRequest(MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID));  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            meetingEmailSendExtension.openEmailChooser();
            meetingEmailSendExtension.setEmailFolderIdToExpand(MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID);
            meetingEmailSendExtension.expandEmailFolder();        
        }  
        Test.stopTest();

        assertMessagesContain('An exception occured while expanding the folder');
    }
}