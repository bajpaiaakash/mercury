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
}