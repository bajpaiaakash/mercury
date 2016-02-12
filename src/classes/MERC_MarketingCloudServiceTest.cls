/*
* MERC_MarketingCloudServiceTest
* Description : Test for MarketingCloudService
* Author: David Helmer
* Modified By: 
* Modified Date: Jan. 14th 2016
*/
@isTest
public with sharing class MERC_MarketingCloudServiceTest {
    private static MERC_ETMockHttpResponseGenerator mockResponseGenerator;

    static {
        Sonoma_ET_Config__c config = MERC_ETTestUtils.CreateConfig();
        insert config;
        Mercury_Marketing_Cloud_Settings_MERC__c settings = MERC_ETTestUtils.CreateSettings();
        insert settings;
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        mockResponseGenerator = new MERC_ETMockHttpResponseGenerator();
        withClassifications();
        Test.setMock(HttpCalloutMock.class, mockResponseGenerator);
        mockResponseGenerator.whereEndpointContains('Auth.svc', '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><s:Body> <OAuthLoginResponse         xmlns="urn:authentication.exacttarget.com/2010/06/11">  <OAuthLoginResult xmlns:i="http://www.w3.org/2001/XMLSchema-instance"> <OAuthToken xmlns:a="urn:authentication.exacttarget.com/2011/03/11"> <a:AccessToken>testSoapToken</a:AccessToken> </OAuthToken> </OAuthLoginResult> </OAuthLoginResponse></s:Body></s:Envelope>');
    }

    private static void withEnterpriseConfig(){
        et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        etConfig.et4ae5__username__c = 'testusername';
        etConfig.et4ae5__password__c = 'testpassword';
        etConfig.et4ae5__auth_api_url__c = 'www.testauthurl.com/Auth.svc';
        etConfig.et4ae5__root_rest_api_url__c = 'www.testresturl.com';
        etConfig.et4ae5__url_root__c = 'urlroot';
        insert etConfig;
    }

    private static void withNormalConfig(){
        System.debug('just an empty method');
        et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        etConfig.et4ae5__username__c = 'testusername';
        etConfig.et4ae5__password__c = 'testpassword';
        etConfig.et4ae5__auth_api_url__c = 'www.testauthurl.com/Auth.svc';
        etConfig.et4ae5__root_rest_api_url__c = 'www.testresturl.com';
        etConfig.et4ae5__url_root__c = 'urlroot';
        etConfig.et4ae5__integration_type__c = '';
        insert etConfig;
    }

    private static void withClassifications(){
        MERC_ETObject.SendClassificationResponse sendClassificationResponse = new MERC_ETObject.SendClassificationResponse();
        MERC_ETObject.SendClassification sendClassification = new MERC_ETObject.SendClassification();
        sendClassification.name = 'Mercury Transactional';
        sendClassification.key = 'Mercury Transactional';
        sendClassification.honorListLevelOptOut = false;
        sendClassification.senderProfileId = 'sender 1';
        sendClassification.deliveryProfileId = 'delivery 1';
        sendClassification.classificationType = null;

        List<MERC_ETObject.SendClassification> sendClassifications = new List<MERC_ETObject.SendClassification>();
        sendClassifications.add(sendClassification);
        sendClassificationResponse.entry = sendClassifications;
        mockResponseGenerator.whereEndpointContains('messaging/sendclassification',
            JSON.serialize(sendClassificationResponse));

        MERC_ETObject.SenderProfileResponse senderProfileResponse = new MERC_ETObject.SenderProfileResponse();
        MERC_ETObject.SenderProfile senderProfile = new MERC_ETObject.SenderProfile();
        senderProfile.id = 'sender 1';
        senderProfile.key = 'sender 1';
        senderProfile.profileName = 'sender 1';
        senderProfile.fromEmail = 'sender1@email.com';
        senderProfile.fromName = 'sender 1';
        
        List<MERC_ETObject.SenderProfile> senderProfiles = new List<MERC_ETObject.SenderProfile>();
        senderProfiles.add(senderProfile);
        senderProfileResponse.entry = senderProfiles;
        mockResponseGenerator.whereEndpointContains('messaging/senderprofile',
            JSON.serialize(senderProfileResponse));
    }

    @isTest
    public static void Test_Send() {
        withEnterpriseConfig();
        Test.setMock(HttpCalloutMock.class, new MERC_ETEndToEndDataExtCallouts_Mock());
        MERC_TestFactory.adjustForSFDCSetMockBug = true;

        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        meeting.RecordTypeId = MERC_ETTestUtils.GetRecordType('Ad_Hoc_Consulting', 'Meeting_MERC__c').Id;
        meeting.City_of_Meeting_MERC__c = 'test city';
        meeting.Preferred_Venue_MERC__c = 'test venue';
        meeting.Start_Time_of_Meeting_MERC__c = Datetime.now();
        meeting.End_Time_of_Meeting_MERC__c = Datetime.now().addDays(5);
        meeting.Event_Id_MERC__c = 'test id';
        insert meeting;

        List<Account> accts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 5);
        insert accts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, accts);
        insert participants;
        createChildren(participants);

        Sonoma_ET_Config__c config = getConfig();

        et4ae5__Business_Unit__c etBU = MERC_ETTestUtils.CreateETBU(config);
        etBU.et4ae5__Business_Unit_ID__c = 'test business unit id';
        etBU.et4ae5__Enabled__c = true;
        insert etBU;


        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        ext.DeDup = true;
        ext.OptIn = true;
        ext.DisableIndividualTracking = true;
        ext.additionalInformationHTML = 'test';
        ext.additionalInformationText = 'test';

        MERC_MarketingCloudClient.FolderedEmail email = new MERC_MarketingCloudClient.FolderedEmail();
        email.Id = 'test';
        email.name = 'test email name';
        email.Subject = 'test subject';
        ext.email = email;
        
        System.assertEquals(participants.size(), ext.Participants.size());
        for (MERC_ETMeetingEmailSendExtension.SelectedWrapper w : ext.Participants) {
            w.IsSelected = true;
        }
        PageReference ref = ext.Send();
        Test.stopTest();
    }

    public static void simulateFilteringAndSorting(MERC_ETMeetingEmailSendExtension ext) {
        PageReference testRef = ext.goToSelectParticipants();

        List<SelectOption> testSOlist;
        testSOlist = ext.communicationChannel;
        testSOlist = ext.countryOfResidence;
        testSOlist = ext.dueDate;
        testSOlist = ext.hasEmail;
        testSOlist = ext.nextStep;
        testSOlist = ext.participantStatus;
        testSOlist = ext.preferredLanguage;
        testSOlist = ext.processType;
        testSOlist = ext.proposalStatus;
        testSOlist = ext.recordType;
        testSOlist = ext.taskStatus;

        String testSuffix = '';

        System.assert(!ext.proposalStatusRender);
        System.assert(!ext.taskStatusRender);

        ext.processTypeSelected = 'Registration';
        ext.updateParticipants();
        PageReference ref = ext.clearFilters();

        System.assert(!ext.proposalStatusRender);
        System.assert(!ext.taskStatusRender);

        ext.communicationChannelSelected = 'E-mail';
        ext.countryOfResidenceSelected = 'GB';
        ext.hasEmailSelected = 'Yes';
        ext.participantStatusSelected = 'Accepted';
        ext.preferredLanguageSelected = 'English';
        ext.processTypeSelected = 'Travel Proposal';
        ext.proposalStatusSelected = 'Accepted';
        ext.taskStatusSelected = 'Completed - Process Complete';
        ext.updateParticipants();

        System.assert(ext.proposalStatusRender);
        System.assert(ext.taskStatusRender);

        ext.dueDateSelected = 'Overdue/Due Today';
        ext.nextStepSelected = 'Follow Up Queue';
        ext.hasEmailSelected = 'No';
        ext.updateParticipants();

        ref = ext.clearFilters();

        System.assert(!ext.proposalStatusRender);
        System.assert(!ext.taskStatusRender);

        System.assertEquals(' ',ext.headerTitleSuffix);
        ext.sortField = 'Account_MERC__r.Title_Desc_GLBL__c';
        System.assertEquals('^',ext.headerTitleSuffix);
        ext.sortField = 'Account_MERC__r.Title_Desc_GLBL__c';
        System.assertEquals('v',ext.headerTitleSuffix);
        ext.sortField = 'Account_MERC__r.Title_Desc_GLBL__c';
        System.assertEquals('^',ext.headerTitleSuffix);

        System.assertEquals(' ',ext.headerFirstNameSuffix);
        ext.sortField = 'Account_MERC__r.FirstName';
        System.assertEquals('^',ext.headerFirstNameSuffix);
        ext.sortField = 'Account_MERC__r.FirstName';
        System.assertEquals('v',ext.headerFirstNameSuffix);

        System.assertEquals(' ',ext.headerLastNameSuffix);
        ext.sortField = 'Account_MERC__r.LastName';
        System.assertEquals('^',ext.headerLastNameSuffix);
        ext.sortField = 'Account_MERC__r.LastName';
        System.assertEquals('v',ext.headerLastNameSuffix);

        System.assertEquals(' ',ext.headerSuffixSuffix);
        ext.sortField = 'Account_MERC__r.Sfx_Nm_GLBL__c';
        System.assertEquals('^',ext.headerSuffixSuffix);
        ext.sortField = 'Account_MERC__r.Sfx_Nm_GLBL__c';
        System.assertEquals('v',ext.headerSuffixSuffix);

        System.assertEquals(' ',ext.headerEmailSuffix);
        ext.sortField = 'Account_MERC__r.PersonEmail';
        System.assertEquals('^',ext.headerEmailSuffix);
        ext.sortField = 'Account_MERC__r.PersonEmail';
        System.assertEquals('v',ext.headerEmailSuffix);

        System.assertEquals(' ',ext.headerStatusSuffix);
        ext.sortField = 'Status_MERC__c';
        System.assertEquals('^',ext.headerStatusSuffix);
        ext.sortField = 'Status_MERC__c';
        System.assertEquals('v',ext.headerStatusSuffix);

        System.assertEquals(' ',ext.headerRecordTypeSuffix);
        ext.sortField = 'Record_Type_MERC__c';
        System.assertEquals('^',ext.headerRecordTypeSuffix);
        ext.sortField = 'Record_Type_MERC__c';
        System.assertEquals('v',ext.headerRecordTypeSuffix);

        System.assertEquals(' ',ext.headerCommPrefSuffix);
        ext.sortField = 'Account_MERC__r.Communication_Preference_MERC__c';
        System.assertEquals('^',ext.headerCommPrefSuffix);
        ext.sortField = 'Account_MERC__r.Communication_Preference_MERC__c';
        System.assertEquals('v',ext.headerCommPrefSuffix);

        System.assertEquals(' ',ext.headerPrefLangSuffix);
        ext.sortField = 'Account_MERC__r.Prfrd_Lang_Cd_GLBL__c';
        System.assertEquals('^',ext.headerPrefLangSuffix);
        ext.sortField = 'Account_MERC__r.Prfrd_Lang_Cd_GLBL__c';
        System.assertEquals('v',ext.headerPrefLangSuffix);

        System.assertEquals(' ',ext.headerCountrySuffix);
        ext.sortField = 'Account_MERC__r.Country_of_Residence_GLBL__c';
        System.assertEquals('^',ext.headerCountrySuffix);
        ext.sortField = 'Account_MERC__r.Country_of_Residence_GLBL__c';
        System.assertEquals('v',ext.headerCountrySuffix);
    }

    public static void createChildren(List<Meeting_Participant_MERC__c> participants) {
        List<Travel_Itinerary_MERC__c> itineraries = new List<Travel_Itinerary_MERC__c>();
        List<Meeting_Process_MERC__c> processes = new List<Meeting_Process_MERC__c>();
        List<Meeting_Tasks_MERC__c> tasks = new List<Meeting_Tasks_MERC__c>();

        for(Meeting_Participant_MERC__c p : participants) {
            Meeting_Process_MERC__c process = new Meeting_Process_MERC__c();
            process.Meeting_Participant_MERC__c = p.Id;
            process.Process_Type_MERC__c = 'Travel Proposal';
            processes.add(process);

            Travel_Itinerary_MERC__c itinerary = new Travel_Itinerary_MERC__c();
            itinerary.Meeting_Participant_MERC__c = p.Id;
            itinerary.Account_MERC__c = p.Account_MERC__c;
            itinerary.Status_MERC__c = 'Accepted';
            itineraries.add(itinerary);
        }
        insert itineraries;
        insert processes;

        for(Meeting_Process_MERC__c p : processes) {
            Meeting_Tasks_MERC__c task = new Meeting_Tasks_MERC__c();
            task.Meeting_Process_MERC__c = p.Id;
            task.Task_Status_MERC__c = 'Completed - Process Complete';
            task.Due_Date_MERC__c = Date.today();
            tasks.add(task);
        }
        insert tasks;
    }

    public static Sonoma_ET_Config__c getConfig () {
        return [SELECT Default_From_Email__c, ET_BU_Name__c, Send_Configuration_Key__c FROM Sonoma_ET_Config__c LIMIT 1];
    }
    //@testSetup static void prepareConfiguration(){
    //    MERC_MarketingCloudTestUtility.insertConfiguration(true);
    //    MERC_MarketingCloudTestUtility.insertBusinessUnit();
    //    MERC_MarketingCloudTestUtility.insertSettings();
    //}

    //@isTest static void test_getEmailFolders(){
    //    User testUser = MERC_MarketingCloudTestUtility.insertUser();

    //    MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
    //    mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersAllRequest());  

    //    Test.startTest();
    //    Test.setMock(HttpCalloutMock.class, mockResponseService);
    //    System.runAs(testUser){
    //        List<MERC_MarketingCloudClient.EmailFolder> emailFolders = MERC_MarketingCloudService.getEmailFolders();
    //        System.assertEquals(2, emailFolders.size());
    //    }  
    //    Test.stopTest();
    //}

    //@isTest static void test_updateForFolder(){
    //    User testUser = MERC_MarketingCloudTestUtility.insertUser();
    //    List<MERC_MarketingCloudClient.EmailFolder> emailFolders = MERC_MarketingCloudTestUtility.getEmailFolders();

    //    MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
    //    mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersRequest(MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID));  
    //    mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailsRequest(MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID));  

    //    Test.startTest();
    //    Test.setMock(HttpCalloutMock.class, mockResponseService);
    //    System.runAs(testUser){
    //        System.assertEquals(0, emailFolders.get(2).subfolders.get(2).subfolders.size());
    //        emailFolders = MERC_MarketingCloudService.updateForFolder(emailFolders, MERC_MarketingCloudTestUtility.EMAIL_FOLDER_VALID_EXPAND_ID);
    //        System.assertEquals(2, emailFolders.get(2).subfolders.get(2).subfolders.size());
    //    }  
    //    Test.stopTest();
    //}

    //@isTest static void test_getSenderProfileSelectOptions(){
    //    User testUser = MERC_MarketingCloudTestUtility.insertUser();

    //    MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
    //    mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getSenderProfilesRequest());  

    //    Test.startTest();
    //    Test.setMock(HttpCalloutMock.class, mockResponseService);
    //    System.runAs(testUser){
    //        List<SelectOption> senderProfiles = MERC_MarketingCloudService.getSenderProfileSelectOptions();
    //        System.assertEquals(3, senderProfiles.size());
    //        for(SelectOption selectOption : senderProfiles){
    //            MERC_MarketingCloudTestUtility.assertSenderProfileLabelById(selectOption.getValue(), selectOption.getLabel());
    //        }
    //    }
    //    Test.stopTest();
    //}

    //@isTest static void test_getThumbnail(){
    //    User testUser = MERC_MarketingCloudTestUtility.insertUser();
    //    String emailId = 'testEmailId';

    //    MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
    //    mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getThumbnailRequest(
    //        emailId, MERC_MarketingCloudTestUtility.THUMBNAIL_HEIGHT, MERC_MarketingCloudTestUtility.THUMBNAIL_WIDTH));

    //    Test.startTest();
    //    Test.setMock(HttpCalloutMock.class, mockResponseService);
    //    System.runAs(testUser){
    //        String thumbnail = MERC_MarketingCloudService.getThumbnail(emailId);
    //        System.assertEquals(true, String.isNotBlank(thumbnail));
    //    }
    //    Test.stopTest();
    //}

    //@isTest static void test_prepareMeetingEmailSendForAttempts(){
    //    User testUser = MERC_MarketingCloudTestUtility.getUser();
    //    insert testUser;
    //    Meeting_MERC__c meeting = null;
    //    List<Account> personAccounts = null;
    //    Map<Id, Account> personAccountMap = null;
    //    List<Meeting_Participant_MERC__c> participants = null;
    //    MERC_MarketingCloudClient.DataExtension dataExtension = null;

    //    System.runAs(testUser){
    //        MERC_TestFactory.adjustForSFDCSetMockBug = true;
    //        MERC_MarketingCloudTestUtility.adjustTime();
    //        meeting = MERC_MarketingCloudTestUtility.getMeeting();
    //        insert meeting;

    //        personAccounts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
    //            MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 5);
    //        insert personAccounts;

    //        personAccountMap = MERC_MarketingCloudTestUtility.getPersonAccountMap(personAccounts);

    //        participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
    //        insert participants;

    //        dataExtension = MERC_MarketingCloudTestUtility.getDataExtension(meeting.Id);
    //        System.debug('dataExtension.retentionPolicy.get(0).RetainUntil:\n' + dataExtension.retentionPolicy.get(0).RetainUntil);
        
    //        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
    //        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getThumbnailRequest(
    //            MERC_MarketingCloudTestUtility.THUMBNAIL_HEIGHT, MERC_MarketingCloudTestUtility.THUMBNAIL_WIDTH));
    //        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getCreateDataExtensionRequest(dataExtension));
    //        System.debug(participants);
    //        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getCreateDataExtensionEntriesRequest(
    //            dataExtension,
    //            meeting.Id,
    //            MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_HTML,
    //            MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_TEXT,
    //            participants,
    //            personAccountMap));
    //        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getCreateSendDefinitionRequest(
    //            MERC_MarketingCloudTestUtility.SEND_DEFINITION_ID));
    //        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getStartSendDefinitionRequest(
    //            MERC_MarketingCloudTestUtility.SEND_DEFINITION_ID));
    //        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getSendDefinitionStatusRequest(
    //            MERC_MarketingCloudTestUtility.SEND_DEFINITION_ID,
    //            MERC_MarketingCloudService.StatusCompleted));
    //        Test.setMock(HttpCalloutMock.class, mockResponseService);

    //        Test.startTest();
    //        MERC_MarketingCloudService.prepareMeetingEmailSendForAttempts(
    //            meeting.Id,
    //            MERC_MarketingCloudTestUtility.getFolderedEmail(), 
    //            participants, 
    //            MERC_MarketingCloudTestUtility.EMAIL_SEND_DEDUPE, 
    //            false, 
    //            MERC_MarketingCloudTestUtility.EMAIL_SEND_TIME, 
    //            MERC_MarketingCloudTestUtility.BASIC_DATE_TIME, 
    //            MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_HTML,
    //            MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_TEXT,
    //            MERC_MarketingCloudTestUtility.SEND_DEFINITION_SENDER_PROFILE_ID,
    //            MERC_MarketingCloudTestUtility.SEND_DEFINITION_CLASSIFICATION_ID);
    //        Test.stopTest();

    //        Meeting_Email_Send_MERC__c meetingEmailSend = [SELECT Id,
    //                                                              Send_Status__c 
    //                                                         FROM Meeting_Email_Send_MERC__c
    //                                                        WHERE Meeting_MERC__c = :meeting.Id
    //                                                        LIMIT 1][0];
    //        System.assertEquals(MERC_MarketingCloudService.EmailSendCreated, meetingEmailSend.Send_Status__c);
    //    }
    //}

    //@isTest static void test_prepareMeetingEmailSendForRetry(){
    //    MERC_TestFactory.adjustForSFDCSetMockBug = true;
    //    User testUser = MERC_MarketingCloudTestUtility.insertUser();
    //    Meeting_MERC__c meeting = null;

    //    System.runAs(testUser){
    //        MERC_MarketingCloudTestUtility.adjustTime();
    //        meeting = MERC_MarketingCloudTestUtility.getMeeting();
    //        insert meeting;

    //        Meeting_Email_Send_MERC__c meetingEmailSend = MERC_MarketingCloudTestUtility.getEmailSend(meeting.Id);
    //        meetingEmailSend.Retry_Count__c = 0;
    //        Decimal retryCountBefore = meetingEmailSend.Retry_Count__c;
    //        DateTime retryDateLowerBound = DateTime.now();
    //        DateTime retryDateUpperBound = DateTime.now().addMinutes(2);

    //        Test.startTest();

    //        MERC_MarketingCloudService.prepareMeetingEmailSendForRetry(meetingEmailSend, 3);

    //        System.assertEquals(retryCountBefore + 1, meetingEmailSend.Retry_Count__c);
    //        System.assertNotEquals(null, meetingEmailSend.Retry_Date__c);
    //        System.assert(retryDateLowerBound < meetingEmailSend.Retry_Date__c);
    //        System.assert(meetingEmailSend.Retry_Date__c < retryDateUpperBound);

    //        Test.stopTest();
    //    }
    //}

    //@isTest static void test_updateSubscribersWithContacts(){
    //    User testUser = MERC_MarketingCloudTestUtility.insertUser();
    //    System.runAs(testUser){
    //        MERC_MarketingCloudTestUtility.adjustTime();
           
            
    //        List<Account> subscriberAccounts = MERC_MarketingCloudTestUtility.getDefaultSubscriberAccounts();
    //        insert subscriberAccounts;

    //        List<Id> personContactIds = MERC_MarketingCloudTestUtility.getPersonContactIds(subscriberAccounts);
    //        subscriberAccounts = MERC_MarketingCloudTestUtility.queryPersonAccounts(subscriberAccounts);
    //        System.assert(!String.isBlank(subscriberAccounts.get(0).PersonContactId),subscriberAccounts.get(0));

    //        List<MERC_MarketingCloudClient.Subscriber> subscribers = 
    //            MERC_MarketingCloudTestUtility.getPersonContactSubscribers(personContactIds);

    //        List<MERC_MarketingCloudClient.Subscriber> expectedSubscribers = 
    //            MERC_MarketingCloudTestUtility.getExpectedSubscribers(subscriberAccounts);

    //        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
    //        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockSubscribersRequest(subscribers, personContactIds));  
    //        for(MERC_MarketingCloudClient.Subscriber subscriber : expectedSubscribers){
    //            mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockSubscriberUpdateRequest(
    //                subscriber));
    //        }
    //        Test.setMock(HttpCalloutMock.class, mockResponseService);
    //        Test.startTest();
    //        MERC_MarketingCloudService.updateSubscribersWithContacts(personContactIds);
    //        Test.stopTest();
    //    }
    //}
}