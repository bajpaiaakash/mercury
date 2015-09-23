@isTest
private class MERC_ETMeetingEmailSendExtension_Test {
    private static MERC_ETMockHttpResponseGenerator mockResponseGenerator;

    static {
        Sonoma_ET_Config__c config = MERC_ETTestUtils.CreateConfig();
        insert config;
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        mockResponseGenerator = new MERC_ETMockHttpResponseGenerator();
        withClassifications();
        Test.setMock(HttpCalloutMock.class, mockResponseGenerator);
    }

    private static void withEnterpriseConfig(){
        et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        etConfig.et4ae5__username__c = 'testusername';
        etConfig.et4ae5__password__c = 'testpassword';
        etConfig.et4ae5__auth_api_url__c = 'www.testauthurl.com';
        etConfig.et4ae5__root_rest_api_url__c = 'www.testresturl.com';
        etConfig.et4ae5__url_root__c = 'urlroot';
        insert etConfig;
    }

    private static void withNormalConfig(){
        System.debug('just an empty method');
        et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        etConfig.et4ae5__username__c = 'testusername';
        etConfig.et4ae5__password__c = 'testpassword';
        etConfig.et4ae5__auth_api_url__c = 'www.testauthurl.com';
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
    public static void Test_Constructor() {
        withNormalConfig();
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

        Test.startTest();
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        simulateFilteringAndSorting(ext);
        Test.stopTest();

        System.assertEquals(false, ext.getHasErrors());
    }

    //@isTest
    public static void Test_Constructor_NoMeeting() {

        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

        Test.startTest();
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        Test.stopTest();

        System.assertEquals(true, ext.getHasErrors());
    }

    @isTest
    public static void Test_SelectAllClicked() {
        withNormalConfig();

        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        List<Account> accts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 49); //can't test 50+ because of pagination
        insert accts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, accts);
        insert participants;
        createChildren(participants);

        Test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        simulateFilteringAndSorting(ext);
        ext.IsAllChecked = true;
        System.assertEquals(accts.size(), ext.Participants.size());
        ext.SelectAllClicked();
        for (MERC_ETMeetingEmailSendExtension.SelectedWrapper p : ext.Participants) {
            System.assert(p.IsSelected);
        }
        PageReference testRef = ext.selectParticipants();
        testRef = ext.backToSendPage();
        Test.stopTest();
    }

    @isTest
    public static void Test_ShowHideGrid() {
        withNormalConfig();
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        List<Account> accts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 49); //can't test 50+ because of pagination
        insert accts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, accts);
        insert participants;
        createChildren(participants);

        Test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        simulateFilteringAndSorting(ext);
        ext.ShowGrid();
        System.assert(ext.ShowParticipantGrid);
        PageReference testRef = ext.selectParticipants();
        ext.HideGrid();
        testRef = ext.backToSendPage();
        System.assert(!ext.ShowParticipantGrid);
        Test.stopTest();

    }

    @isTest
    public static void Test_UrlRoot() {
        withNormalConfig();
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

        Test.startTest();
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        simulateFilteringAndSorting(ext);
        System.assertEquals('urlroot', ext.urlroot); // for whatever reason, that is the default value
        ext = new MERC_ETMeetingEmailSendExtension(controller);
        System.assert(ext.urlroot.containsIgnoreCase('urlroot'));
        Test.stopTest();
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

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        ext.DeDup = true;
        ext.OptIn = true;
        ext.DisableIndividualTracking = true;
        ext.additionalInformationHTML = 'test';
        ext.additionalInformationText = 'test';

        MERC_ETFolderedEmail email = new MERC_ETFolderedEmail();
        email.Id = 'test';
        email.name = 'test email name';
        email.Title = 'test subject';
        ext.email = email;

        System.assertEquals(participants.size(), ext.Participants.size());
        for (MERC_ETMeetingEmailSendExtension.SelectedWrapper w : ext.Participants) {
            w.IsSelected = true;
        }

        try {
            Test.startTest();
            PageReference ref = ext.Send();
            Test.stopTest();

        } catch (Exception e) {
            System.debug('exception : ' + e);
        }

    }

    @isTest
    public static void Test_Send_To_Classification() {
        withEnterpriseConfig();
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

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);
        Test.startTest();
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        ext.DeDup = true;
        ext.OptIn = true;
        ext.DisableIndividualTracking = true;

        MERC_ETFolderedEmail email = new MERC_ETFolderedEmail();
        email.Id = 'test';
        email.name = 'test email name';
        email.Title = 'test subject';
        ext.email = email;

        ext.fromSourceIsEmail = false;
        System.assertEquals(2,ext.fromClassificationOptions.size(), ext.fromClassificationOptions);
        ext.fromClassicationSelected = ext.fromClassificationOptions.get(1).getValue();

        System.assertEquals(participants.size(), ext.Participants.size());
        for (MERC_ETMeetingEmailSendExtension.SelectedWrapper w : ext.Participants) {
            w.IsSelected = true;
        }

        try {
            
            PageReference ref = ext.Send();
            

        } catch (Exception e) {
            System.debug('exception : ' + e);
        }
        Test.stopTest();
    }
    
    @isTest
    static void Folders_Compare_On_Name(){
        withEnterpriseConfig();
        MERC_ETFolderedEmail email = new MERC_ETFolderedEmail();
        email.Id = 'test';
        email.name = 'test email name';
        email.Title = 'test subject';
        

        MERC_ETFolderedEmail sameEmail = new MERC_ETFolderedEmail();
        sameEmail.Id = 'test1';
        sameEmail.name = 'test email name';
        sameEmail.Title = 'test subject1';
        
        MERC_ETFolderedEmail differentEmail = new MERC_ETFolderedEmail();
        differentEmail.Id = 'test2';
        differentEmail.name = 'test email name2';
        differentEmail.Title = 'test subject2';

        System.assertEquals(0, email.compareTo(sameEmail));
        System.assertEquals(-1, email.compareTo(differentEmail));
    }

    @isTest
    public static void Test_Send_NoRecipients() {
        withNormalConfig();
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        simulateFilteringAndSorting(ext);
        ext.SendTime = 'none';

        Test.startTest();
        PageReference ref = ext.Send();
        Test.stopTest();

        System.assertEquals(null, ref);
        System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
    }

    @isTest
    public static void Test_Send_NoSubject() {
        withNormalConfig();
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        simulateFilteringAndSorting(ext);
        MERC_ETFolderedEmail email = new MERC_ETFolderedEmail();
        email.Id = 'test';
        ext.email = email;

        Test.startTest();
        PageReference ref = ext.Send();
        Test.stopTest();

        System.assertEquals(null, ref);
        System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
    }

    @isTest
    public static void Test_GetParticipantCount() {
        withNormalConfig();
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        List<Account> accts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 49); //can't do 50+ because of pagination
        insert accts;
        accts = [SELECT Id, Name FROM Account WHERE Id IN :accts];
        Set<String> accountNames = new Set<String>();
        for (Account a : accts) {
            accountNames.add(a.Name);
        }

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, accts);
        insert participants;
        createChildren(participants);

        Test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        simulateFilteringAndSorting(ext);
        System.assertEquals(accts.size(), ext.Participants.size());
        Integer participantCount = ext.getParticipantCount();
        System.assertEquals(0, participantCount);
        ext.IsAllChecked = true;
        ext.SelectAllClicked();
        ext.collectParticipantIds();
        participantCount = ext.getParticipantCount();
        Test.stopTest();

        System.assertEquals(participants.size(), participantCount);
    }

    @isTest static void Test_Get_Send_Options() {
        withNormalConfig();
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

        Test.startTest();
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        List<SelectOption> sendOptions = ext.getFromSendOptions();        
        Test.stopTest();
        System.assertEquals(2, sendOptions.size());
    }

    @isTest
    public static void Test_GetSyncPayload() {
        withNormalConfig();
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

        Test.startTest();
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        simulateFilteringAndSorting(ext);
        String payload = ext.getSyncPayload();
        System.assertNotEquals(null, payload);
        Test.stopTest();
    }

    @isTest
    public static void Test_ListExactTargetEmails() {
        withEnterpriseConfig();
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        Sonoma_ET_Config__c config = getConfig();

        et4ae5__Business_Unit__c etBU = MERC_ETTestUtils.CreateETBU(config);
        etBU.et4ae5__Business_Unit_ID__c = 'test business unit id';
        insert etBU;

        User u = MERC_ETTestUtils.CreateUser('Standard User');
        u.et4ae5__exacttarget_Oauth_token__c = '';
        insert u;

        ApexPages.StandardController stdController = new ApexPages.StandardController(meeting);
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(stdController);

        MERC_ETObject.emailfolder testFolderA=new MERC_ETObject.emailfolder();
        MERC_ETObject.emailfolder testFolderB=new MERC_ETObject.emailfolder();
        MERC_ETObject.emailfolder testFolderC=new MERC_ETObject.emailfolder();
        MERC_ETObject.emailfolder testFolderD=new MERC_ETObject.emailfolder();
        MERC_ETObject.emailfolder testFolderE=new MERC_ETObject.emailfolder();
        testFolderA.id = 'testFolderA';
        testFolderB.id = 'testFolderB';
        testFolderC.id = 'testFolderC';
        testFolderD.id = 'testFolderD';
        testFolderE.id = 'testFolderE';
        testFolderA.subfolders=new list<MERC_ETObject.emailfolder>();
        testFolderB.subfolders=new list<MERC_ETObject.emailfolder>();
        testFolderC.subfolders=new list<MERC_ETObject.emailfolder>();
        testFolderD.subfolders=new list<MERC_ETObject.emailfolder>();
        testFolderD.subfolders.add(testFolderE);
        testFolderC.subfolders.add(testFolderD);
        testFolderB.subfolders.add(testFolderC);
        testFolderA.subfolders.add(testFolderB);
        ext.emails=new list<MERC_ETObject.emailfolder>();
        ext.emails.add(testFolderA);


        MERC_ETObject.CallEmailFolderResponse cefr= new MERC_ETObject.CallEmailFolderResponse();
        Test.startTest();

        System.runAs(u) {
            cefr.entry = testFolderA.subfolders;
            
            mockResponseGenerator.whereEndpointContains('beta/folder/', JSON.serialize(cefr));
            
            ApexPages.currentPage().getParameters().put('folderId','testFolderA');
            ext.listExactTargetEmails();
            System.assertEquals(null, ext.emails);
        }

        Test.stopTest();
    }

    @isTest
    public static void Test_SelectEmailCancel() {
        withNormalConfig();
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

        Test.startTest();
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        simulateFilteringAndSorting(ext);
        ext.selectEmailCancel();
        System.assertEquals(false, ext.showEmailChooser);
        Test.stopTest();
    }

    @isTest
    public static void testExpandFolder() {
        withEnterpriseConfig();
        MERC_TestFactory.adjustForSFDCSetMockBug = true;

        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        Sonoma_ET_Config__c config = getConfig();

        et4ae5__Business_Unit__c etBU = MERC_ETTestUtils.CreateETBU(config);
        etBU.et4ae5__Business_Unit_ID__c = 'test business unit id';
        insert etBU;

        User u = MERC_ETTestUtils.CreateUser('System Administrator');
        u.et4ae5__exactTarget_OAuth_Token__c='testToken';
        u.et4ae5__exactTargetUsername__c='testUser';
        insert u;

        ApexPages.StandardController stdController = new ApexPages.StandardController(meeting);
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(stdController);

        MERC_ETObject.emailfolder testFolderA=new MERC_ETObject.emailfolder();
        MERC_ETObject.emailfolder testFolderB=new MERC_ETObject.emailfolder();
        MERC_ETObject.emailfolder testFolderC=new MERC_ETObject.emailfolder();
        MERC_ETObject.emailfolder testFolderD=new MERC_ETObject.emailfolder();
        MERC_ETObject.emailfolder testFolderE=new MERC_ETObject.emailfolder();
        testFolderA.id = 'testFolderA';
        testFolderB.id = 'testFolderB';
        testFolderC.id = 'testFolderC';
        testFolderD.id = 'testFolderD';
        testFolderE.id = 'testFolderE';
        testFolderA.subfolders=new list<MERC_ETObject.emailfolder>();
        testFolderB.subfolders=new list<MERC_ETObject.emailfolder>();
        testFolderC.subfolders=new list<MERC_ETObject.emailfolder>();
        testFolderD.subfolders=new list<MERC_ETObject.emailfolder>();
        testFolderD.subfolders.add(testFolderE);
        testFolderC.subfolders.add(testFolderD);
        testFolderB.subfolders.add(testFolderC);
        testFolderA.subfolders.add(testFolderB);
        ext.emails=new list<MERC_ETObject.emailfolder>();
        ext.emails.add(testFolderA);

        MERC_ETObject.CallEmailFolderResponse cefr= new MERC_ETObject.CallEmailFolderResponse();

        System.runAs(u) {
            Test.startTest();
            cefr.entry = testFolderA.subfolders;
            mockResponseGenerator.whereEndpointContains('beta/folder/', JSON.serialize(cefr));

            ApexPages.currentPage().getParameters().put('folderId','testFolderA');
            ext.expandFolder();
            Boolean containsMessage = false;
            for (ApexPages.Message pm : ApexPages.getMessages()) {
                if (pm.getDetail().contains('There are no emails in the')) {
                    containsMessage = true;
                }
            }
            System.assert(!containsMessage);

            cefr.entry = testFolderE.subfolders;
            mockResponseGenerator.whereEndpointContains('beta/folder/', JSON.serialize(cefr));
            ApexPages.currentPage().getParameters().put('folderId','testFolderE');
            ext.expandFolder();
            containsMessage = false;
            for (ApexPages.Message pm : ApexPages.getMessages()) {
                if (pm.getDetail().contains('There are no emails in the')) {
                    containsMessage = true;
                }
            }
            System.assert(containsMessage);
            Test.stopTest();
        }
    }

    @isTest
    public static void Test_SelectEmail() {
        withEnterpriseConfig();
        MERC_TestFactory.adjustForSFDCSetMockBug = true;

        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        Sonoma_ET_Config__c config = getConfig();

        et4ae5__Business_Unit__c etBU = MERC_ETTestUtils.CreateETBU(config);
        etBU.et4ae5__Business_Unit_ID__c = 'test business unit id';
        insert etBU;

        User u = MERC_ETTestUtils.CreateUser('Standard User');
        u.et4ae5__exacttarget_Oauth_token__c = '';
        insert u;

        ApexPages.StandardController stdController = new ApexPages.StandardController(meeting);
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(stdController);

        MERC_ETObject.emailfolder testFolderA=new MERC_ETObject.emailfolder();
        MERC_ETObject.emailfolder testFolderB=new MERC_ETObject.emailfolder();
        MERC_ETObject.emailfolder testFolderC=new MERC_ETObject.emailfolder();
        MERC_ETObject.emailfolder testFolderD=new MERC_ETObject.emailfolder();
        MERC_ETObject.emailfolder testFolderE=new MERC_ETObject.emailfolder();
        testFolderA.id = 'testFolderA';
        testFolderB.id = 'testFolderB';
        testFolderC.id = 'testFolderC';
        testFolderD.id = 'testFolderD';
        testFolderE.id = 'testFolderE';
        testFolderA.subfolders=new list<MERC_ETObject.emailfolder>();
        testFolderB.subfolders=new list<MERC_ETObject.emailfolder>();
        testFolderC.subfolders=new list<MERC_ETObject.emailfolder>();
        testFolderD.subfolders=new list<MERC_ETObject.emailfolder>();
        testFolderD.subfolders.add(testFolderE);
        testFolderC.subfolders.add(testFolderD);
        testFolderB.subfolders.add(testFolderC);
        testFolderA.subfolders.add(testFolderB);
        ext.emails=new list<MERC_ETObject.emailfolder>();
        ext.emails.add(testFolderA);

        MERC_ETObject.CallEmailFolderResponse cefr= new MERC_ETObject.CallEmailFolderResponse();
        Test.startTest();

        String eId = 'testEmailId';
        String eName = 'testEmailName';
        String eSubject = 'testEmailSubject';

        System.runAs(u) {
            cefr.entry = testFolderA.subfolders;
            mockResponseGenerator.whereEndpointContains('beta/folder/', JSON.serialize(cefr));

            /*ext.selectEmail();
            System.assertEquals(null, ext.email.id);
            System.assertEquals(null, ext.email.name);
            System.assertEquals(null, ext.email.title);

            ApexPages.currentPage().getParameters().put('emailId', eId);
            ApexPages.currentPage().getParameters().put('emailName', eName);
            ApexPages.currentPage().getParameters().put('emailSubject', eSubject);

            ext.selectEmail();
            System.assertEquals(eId, ext.email.id);
            System.assertEquals(eName, ext.email.name);
            System.assertEquals(eSubject, ext.email.title);*/
        }

        Test.stopTest();
    }

    @isTest
    private static void testPagination () {
        withNormalConfig();

        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        List<Account> accts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 150, false);
        insert accts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, accts);
        insert participants;
        createChildren(participants);

        Test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        simulateFilteringAndSorting(ext);
        System.assert(!ext.hasPrevious);
        System.assert(ext.hasNext);
        ext.next();
        System.assert(ext.hasPrevious);
        System.assert(ext.hasNext);
        ext.previous();
        System.assert(!ext.hasPrevious);
        System.assert(ext.hasNext);
        ext.last();
        System.assert(ext.hasPrevious);
        System.assert(!ext.hasNext);
        ext.first();
        System.assert(!ext.hasPrevious);
        System.assert(ext.hasNext);
        Test.stopTest();
    }

    @isTest
    private static void testGenerateDocuments() {
        withNormalConfig();
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        List<Account> accts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 100);
        insert accts;
        accts = [SELECT Id, Name FROM Account WHERE Id IN :accts];
        Set<String> accountNames = new Set<String>();
        for (Account a : accts) {
            accountNames.add(a.Name);
        }

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, accts);
        insert participants;
        createChildren(participants);

        PageReference pageRef = Page.MeetingEmailSend;
        pageRef.getParameters().put('id', meeting.id);
        pageRef.getParameters().put('generatedocuments','1');

        Test.setCurrentPage(pageRef);

        ApexPages.StandardController stdController = new ApexPages.StandardController(meeting);
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(stdController);

        Test.startTest();
            System.assert(ext.isGeneratingDocuments, 'Controller does not indicate that it is in document generation mode');

            ext.participants[0].isSelected = true;
            ext.participants[2].isSelected = true;
            ext.participants[4].isSelected = true;

            PageReference returnedRef = ext.generateDocuments();

            String recordsUrlParam = returnedRef.getParameters().get('recordIds');
            System.assert(recordsUrlParam.contains((String)ext.participants[0].participant.Id));
            System.assert(recordsUrlParam.contains((String)ext.participants[2].participant.Id));
            System.assert(recordsUrlParam.contains((String)ext.participants[4].participant.Id));


            System.assert(returnedRef.getParameters().containsKey('retUrl'));
            System.assert(returnedRef.getParameters().containsKey('sessionId'));
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
}