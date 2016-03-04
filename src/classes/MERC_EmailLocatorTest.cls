/*
* Authors: 
*   David Helmer
*/
@isTest
public with sharing class MERC_EmailLocatorTest {
    @testSetup static void prepareConfiguration(){
        MERC_MarketingCloudTestUtility.insertConfiguration(true);
        MERC_MarketingCloudTestUtility.insertBusinessUnit();
        MERC_MarketingCloudTestUtility.insertSettings();
    }

    @isTest static void withNoParentFolder_FindEmailFolderInFolder_FindsRootEmailFolder(){
        User testUser = MERC_MarketingCloudTestUtility.insertUser();

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersAllRequest());  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            MERC_MarketingCloudClient.EmailFolder emailFolder = MERC_EmailLocator.findEmailFolderInFolder(null, 'my emails');
            System.assertNotEquals(null, emailFolder);
        }  
        Test.stopTest();
    }

    @isTest static void withNoParentFolderAndWrongName_FindEmailFolderInFolder_ThrowsException(){
        User testUser = MERC_MarketingCloudTestUtility.insertUser();

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersAllRequest());  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            Boolean exceptionThrown = false;
            try{
                MERC_MarketingCloudClient.EmailFolder emailFolder = MERC_EmailLocator.findEmailFolderInFolder(null, 'not my emails');
            } catch (MERC_EmailLocator.FolderNotFoundException folderNotFoundException){
                exceptionThrown = true;
            }
            System.assertEquals(true, exceptionThrown);
        }  
        Test.stopTest();
    }

    @isTest static void withParentFolder_FindEmailFolderInFolder_FindsChildFolder(){
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        String parentFolderId = 'parentFolderId';
        MERC_MarketingCloudClient.EmailFolder parentFolder = new MERC_MarketingCloudClient.EmailFolder();
        parentFolder.Id = parentFolderId;

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersRequest(parentFolderId));  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            MERC_MarketingCloudClient.EmailFolder emailFolder = MERC_EmailLocator.findEmailFolderInFolder(parentFolder, 'my emails');
            System.assertNotEquals(null, emailFolder);
        }  
        Test.stopTest();
    }

    @isTest static void withParentFolderAndWrongName_FindEmailFolderInFolder_ThrowsException(){
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        String parentFolderId = 'parentFolderId';
        MERC_MarketingCloudClient.EmailFolder parentFolder = new MERC_MarketingCloudClient.EmailFolder();
        parentFolder.Id = parentFolderId;

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersRequest(parentFolderId));  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            Boolean exceptionThrown = false;
            try{
                MERC_MarketingCloudClient.EmailFolder emailFolder = MERC_EmailLocator.findEmailFolderInFolder(parentFolder, 'not my emails');
            } catch (MERC_EmailLocator.FolderNotFoundException folderNotFoundException){
                exceptionThrown = true;
            }
            System.assertEquals(true, exceptionThrown);
        }  
        Test.stopTest();
    }

    @isTest static void withNoParentFolder_FindEmailInFolder_ThrowsException(){
        User testUser = MERC_MarketingCloudTestUtility.insertUser();

        Test.startTest();
        System.runAs(testUser){
            Boolean exceptionThrown = false;
            try{
                MERC_MarketingCloudClient.FolderedEmail email = MERC_EmailLocator.findEmailInFolder(null, 'TBD - Text Email for Testing Send');
            } catch (MERC_EmailLocator.FolderNotFoundException folderNotFoundException){
                exceptionThrown = true;
            }
            System.assertEquals(true, exceptionThrown);
        }  
        Test.stopTest();
    }

    @isTest static void withParentFolder_FindEmailInFolder_FindsChildFolder(){
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        String parentFolderId = 'parentFolderId';
        MERC_MarketingCloudClient.EmailFolder parentFolder = new MERC_MarketingCloudClient.EmailFolder();
        parentFolder.Id = parentFolderId;

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailsRequest(parentFolderId));  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            MERC_MarketingCloudClient.FolderedEmail email = MERC_EmailLocator.findEmailInFolder(parentFolder, 'TBD - Text Email for Testing Send');
            System.assertNotEquals(null, email);
        }  
        Test.stopTest();
    }

    @isTest static void withParentFolderAndWrongName_FindEmailInFolder_ThrowsException(){
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        String parentFolderId = 'parentFolderId';
        MERC_MarketingCloudClient.EmailFolder parentFolder = new MERC_MarketingCloudClient.EmailFolder();
        parentFolder.Id = parentFolderId;

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailsRequest(parentFolderId));  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            Boolean exceptionThrown = false;
            try{
                MERC_MarketingCloudClient.FolderedEmail email = MERC_EmailLocator.findEmailInFolder(parentFolder, 'invalid email name');
            } catch (MERC_EmailLocator.EmailNotFoundException emailNotFoundException){
                exceptionThrown = true;
            }
            System.assertEquals(true, exceptionThrown);
        }  
        Test.stopTest();
    }

    @isTest static void withCorrectPathAndName_FindEmailByPath_FindsEmail(){
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        String folderPath = 'my emails/my emails';
        String myEmailsId = '8';
        String emailName = 'TBD - Text Email for Testing Send';

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersAllRequest());  
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersRequest(myEmailsId));  
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailsRequest(myEmailsId));  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            MERC_MarketingCloudClient.FolderedEmail email = MERC_EmailLocator.findEmailByPath(folderPath, emailName);
            System.assertNotEquals(null, email);
        }  
        Test.stopTest();
    }

    @isTest static void withInCorrectPath_FindEmailByPath_ThrowsFolderException(){
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        String folderPath = 'my emails11/my emails';
        String myEmailsId = '8';
        String emailName = 'TBD - Text Email for Testing Send';

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersAllRequest());  
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersRequest(myEmailsId));  
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailsRequest(myEmailsId));  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            Boolean exceptionThrown = false;
            try{
                MERC_MarketingCloudClient.FolderedEmail email = MERC_EmailLocator.findEmailByPath(folderPath, emailName);
            } catch (MERC_EmailLocator.FolderNotFoundException folderNotFoundException){
                exceptionThrown = true;
            }
            System.assertEquals(true, exceptionThrown);
        }  
        Test.stopTest();
    }

    @isTest static void withCorrectPathAndIncorrectEmail_FindEmailByPath_ThrowsEmailException(){
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        String folderPath = 'my emails/my emails';
        String myEmailsId = '8';
        String emailName = 'invalidemailname';

        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersAllRequest());  
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersRequest(myEmailsId));  
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailsRequest(myEmailsId));  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponseService);
        System.runAs(testUser){
            Boolean exceptionThrown = false;
            try{
                MERC_MarketingCloudClient.FolderedEmail email = MERC_EmailLocator.findEmailByPath(folderPath, emailName);
            } catch (MERC_EmailLocator.EmailNotFoundException emailNotFoundException){
                exceptionThrown = true;
            }
            System.assertEquals(true, exceptionThrown);
        }  
        Test.stopTest();
    }
}