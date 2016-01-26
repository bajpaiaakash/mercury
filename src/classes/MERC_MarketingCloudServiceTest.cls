/*
* MERC_MarketingCloudServiceTest
* Description : Test for MarketingCloudService
* Author: David Helmer
* Modified By: 
* Modified Date: Jan. 14th 2016
*/
@isTest
public with sharing class MERC_MarketingCloudServiceTest {
    @testSetup static void prepareConfiguration(){
        MERC_MarketingCloudTestUtility.insertConfiguration(true);
        MERC_MarketingCloudTestUtility.insertBusinessUnit();
        MERC_MarketingCloudTestUtility.insertSettings();
    }

    @isTest static void test_getEmailFolders(){     
        User testUser = MERC_MarketingCloudTestUtility.insertUser();

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersAllRequest());  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            List<MERC_MarketingCloudClient.EmailFolder> emailFolders = MERC_MarketingCloudService.getEmailFolders();
            System.assertEquals(2, emailFolders.size());
        }  
        Test.stopTest();
    }

    @isTest static void test_updateForFolder(){     
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        List<MERC_MarketingCloudClient.EmailFolder> emailFolders = MERC_MarketingCloudTestUtility.getEmailFolders();

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersRequest(MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID));  
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailsRequest(MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID));  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            System.assertEquals(0, emailFolders.get(2).subfolders.get(2).subfolders.size());
            emailFolders = MERC_MarketingCloudService.updateForFolder(emailFolders, MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID);
            System.assertEquals(2, emailFolders.get(2).subfolders.get(2).subfolders.size());
        }  
        Test.stopTest();
    }

    @isTest static void test_getSenderProfileSelectOptions(){     
        User testUser = MERC_MarketingCloudTestUtility.insertUser();

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getSenderProfilesRequest());  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            List<SelectOption> senderProfiles = MERC_MarketingCloudService.getSenderProfileSelectOptions();
            System.assertEquals(3, senderProfiles.size());
            for(SelectOption selectOption : senderProfiles){
                MERC_MarketingCloudTestUtility.assertSenderProfileLabelById(selectOption.getValue(), selectOption.getLabel());
            }
        }
        Test.stopTest();
    }

    @isTest static void test_getThumbnail(){     
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        String emailId = 'testEmailId';

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getThumbnailRequest(
            emailId, MERC_MarketingCloudTestUtility.THUMBNAIL_HEIGHT, MERC_MarketingCloudTestUtility.THUMBNAIL_WIDTH));

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            String thumbnail = MERC_MarketingCloudService.getThumbnail(emailId);
            System.assertEquals(true, String.isNotBlank(thumbnail));
        }
        Test.stopTest();
    }

    @isTest static void test_prepareMeetingEmailSendForAttempts(){     
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        Meeting_MERC__c meeting = null;
        List<Account> personAccounts = null;
        Map<Id, Account> personAccountMap = null;
        List<Meeting_Participant_MERC__c> participants = null;
        MERC_MarketingCloudClient.DataExtension dataExtension = null;

        System.runAs(testUser){
            meeting = MERC_MarketingCloudTestUtility.getMeeting();
            insert meeting;

            personAccounts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
                MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 5);
            insert personAccounts;

            personAccountMap = MERC_MarketingCloudTestUtility.getPersonAccountMap(personAccounts);

            participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
            insert participants;

            dataExtension = MERC_MarketingCloudTestUtility.getDataExtension(meeting.Id);
        }
        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getThumbnailRequest(
            MERC_MarketingCloudTestUtility.THUMBNAIL_HEIGHT, MERC_MarketingCloudTestUtility.THUMBNAIL_WIDTH));
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getCreateDataExtensionEntriesRequest(
            dataExtension,
            meeting.Id,
            MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_HTML,
            MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_TEXT,
            participants,
            personAccountMap));


        Test.startTest();
        System.runAs(testUser){
            Test.setMock(HttpCalloutMock.class, mockResponseService);

            
        }
        Test.stopTest();
    }

    @isTest static void test_updateSubscribersWithContacts(){     
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        System.runAs(testUser){
            
            
            List<Account> subscriberAccounts = MERC_MarketingCloudTestUtility.getDefaultSubscriberAccounts();
            insert subscriberAccounts;

            List<Id> personContactIds = MERC_MarketingCloudTestUtility.getPersonContactIds(subscriberAccounts);
            subscriberAccounts = MERC_MarketingCloudTestUtility.queryPersonAccounts(subscriberAccounts);
            System.assert(!String.isBlank(subscriberAccounts.get(0).PersonContactId),subscriberAccounts.get(0));

            List<MERC_MarketingCloudClient.Subscriber> subscribers = 
                MERC_MarketingCloudTestUtility.getPersonContactSubscribers(personContactIds);

            List<MERC_MarketingCloudClient.Subscriber> expectedSubscribers = 
                MERC_MarketingCloudTestUtility.getExpectedSubscribers(subscriberAccounts);

            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
            mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockSubscribersRequest(subscribers, personContactIds));  
            for(MERC_MarketingCloudClient.Subscriber subscriber : expectedSubscribers){
                mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockSubscriberUpdateRequest(
                    subscriber));
            }
            Test.setMock(HttpCalloutMock.class, mockResponseService);
            Test.startTest();
            MERC_MarketingCloudService.updateSubscribersWithContacts(personContactIds);
            Test.stopTest();
        }
    }
}