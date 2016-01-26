/*
* MERC_MarketingCloudClientTest
* Description : Test for MarketingCloudClient
* Author: David Helmer
* Modified By: 
* Modified Date: Dec. 14th 2015
*/
@isTest
private class MERC_MarketingCloudClientTest {
    @testSetup static void prepareConfiguration(){
        MERC_MarketingCloudTestUtility.insertConfiguration(true);
        MERC_MarketingCloudTestUtility.insertBusinessUnit();
        MERC_MarketingCloudTestUtility.insertSettings();
    }

    @isTest static void test_isAuthorized(){
        User testUser = MERC_MarketingCloudTestUtility.insertUser();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, MERC_MarketingCloudTestUtility.withDefaultMockService(testUser));
        System.runAs(testUser){
            Boolean isAuthorized = MERC_MarketingCloudClient.isAuthorized();
            System.assertEquals(true, isAuthorized);
        }
        Test.stopTest();
    }

    @isTest static void test_getClassifications(){     
        User testUser = MERC_MarketingCloudTestUtility.insertUser();

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getClassificationsRequest());  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            List<MERC_MarketingCloudClient.SendClassification> sendClassifications = MERC_MarketingCloudClient.getClassifications();
            System.assertEquals(3, sendClassifications.size());
        }  
        Test.stopTest();
    }

    @isTest static void test_getSenderProfiles(){     
        User testUser = MERC_MarketingCloudTestUtility.insertUser();

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getSenderProfilesRequest());  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            List<MERC_MarketingCloudClient.SenderProfile> senderProfiles = MERC_MarketingCloudClient.getSenderProfiles();
            System.assertEquals(4, senderProfiles.size());
        }  
        Test.stopTest();
    }

    @isTest static void test_getEmailFolders(){     
        User testUser = MERC_MarketingCloudTestUtility.insertUser();

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersAllRequest());  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            List<MERC_MarketingCloudClient.EmailFolder> emailFolders = MERC_MarketingCloudClient.getEmailFolders();
            System.assertEquals(2, emailFolders.size());
        }  
        Test.stopTest();
    }

    @isTest static void test_getEmailFoldersById(){     
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        String testFolderId = 'testFolderId';

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersRequest(testFolderId));

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            List<MERC_MarketingCloudClient.EmailFolder> emailFolders = MERC_MarketingCloudClient.getEmailFolders(testFolderId);
            System.assertEquals(2, emailFolders.size());
        }  
        Test.stopTest();
    }

    @isTest static void test_getEmails(){     
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        String testFolderId = 'testFolderId';

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailsRequest(testFolderId));

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            List<MERC_MarketingCloudClient.FolderedEmail> emails = MERC_MarketingCloudClient.getEmails(testFolderId);
            System.assertEquals(2, emails.size());
        }
        Test.stopTest();
    }

    @isTest static void test_getThumbnail(){     
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        String emailId = 'testEmailId';
        String height = '302';
        String width = '651';

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getThumbnailRequest(emailId, height, width));

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            String thumbnail = MERC_MarketingCloudClient.getThumbnail(emailId, 302, 651);
            System.assertEquals(true, String.isNotBlank(thumbnail));
        }
        Test.stopTest();
    }

    @isTest static void test_createSendDefinition(){
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        MERC_MarketingCloudClient.SendDefinition sendDefinition = MERC_MarketingCloudTestUtility.getSendDefinition();

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getCreateSendDefinitionRequest(sendDefinition));

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            MERC_MarketingCloudClient.CreateSendDefinitionResponse response = MERC_MarketingCloudClient.createSendDefinition(sendDefinition);
            System.assertEquals(true, String.isNotBlank(response.id));
        }
        Test.stopTest();
    }

    @isTest static void test_startSendDefinition(){
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        String sendDefinitionId = 'testsenddefinitionid';

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getStartSendDefinitionRequest(sendDefinitionId));

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            MERC_MarketingCloudClient.StartSendDefinitionResponse response = MERC_MarketingCloudClient.startSendDefinition(sendDefinitionId);
            System.assertEquals(true, String.isNotBlank(response.id));
        }
        Test.stopTest();
    }

    @isTest static void test_getSendDefinitionStatus(){
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        String sendDefinitionId = 'testsenddefinitionid';

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getSendDefinitionStatusRequest(sendDefinitionId));

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            MERC_MarketingCloudClient.CheckSendDefinitionStatusResponse response = MERC_MarketingCloudClient.sendDefinitionStatus(sendDefinitionId);
            System.assertEquals(true, String.isNotBlank(response.id));
        }
        Test.stopTest();
    }

    @isTest static void test_createDataExtension(){
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        MERC_MarketingCloudClient.DataExtension dataExtension = MERC_MarketingCloudTestUtility.getDataExtension();

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getCreateDataExtensionRequest(dataExtension));

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            MERC_MarketingCloudClient.DataExtensionResponse response = MERC_MarketingCloudClient.createDataExtension(dataExtension);
            System.assertEquals(true, String.isNotBlank(response.id));
        }
        Test.stopTest();
    }

    @isTest static void test_createDataExtensionEntries(){
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        User testUser = MERC_MarketingCloudTestUtility.getUser();
        insert testUser;

        
        Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.getMeeting();
        insert meeting;

        List<Account> personAccounts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
            MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 5);
        insert personAccounts;

        Map<Id, Account> personAccountMap = MERC_MarketingCloudTestUtility.getPersonAccountMap(personAccounts);
        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
        insert participants;

        MERC_MarketingCloudClient.DataExtension dataExtension = MERC_MarketingCloudTestUtility.getDataExtension();

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getCreateDataExtensionEntriesRequest(
            dataExtension,
            meeting.Id,
            MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_HTML,
            MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_TEXT,
            participants,
            personAccountMap));

        List<MERC_MarketingCloudClient.DataExtensionEntry> dataExtensionEntries = MERC_MarketingCloudTestUtility.getDataExtensionEntries(
            meeting.Id,
            MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_HTML,
            MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_TEXT,
            participants,
            personAccountMap,
            dataExtension);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            MERC_MarketingCloudClient.createDataExtensionEntries(dataExtension, dataExtensionEntries);
        }
        Test.stopTest();
    }

    @isTest static void test_getSubscribers(){     
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        List<MERC_MarketingCloudClient.Subscriber> subscribers = MERC_MarketingCloudTestUtility.getSubscribers(6);
        List<String> subscriberKeys = MERC_MarketingCloudTestUtility.getSubscriberKeys(subscribers);

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockSubscribersRequest(subscribers, subscriberKeys));

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            List<MERC_MarketingCloudClient.Subscriber> retrievedSubscribers = MERC_MarketingCloudClient.getSubscribers(subscriberKeys);
            System.assertEquals(subscribers.size(), retrievedSubscribers.size());
        }
        Test.stopTest();
    }

    @isTest static void test_updateSubscriber(){     
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        MERC_MarketingCloudClient.Subscriber subscriber = MERC_MarketingCloudTestUtility.getSubscriber();

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockSubscriberUpdateRequest(subscriber));

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            String response = MERC_MarketingCloudClient.updateSubscriber(subscriber);
            System.assertEquals(true, String.isBlank(response)); // a successful update returns a blank response otherwise a failure has an error message
        }
        Test.stopTest();
    }
}