@isTest
private class MERC_ETMeetingEmailSendExtension_Test {

    @isTest
    public static void Test_Constructor() {
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        Sonoma_ET_Config__c config = MERC_ETTestUtils.CreateConfig();
        insert config;

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

        Test.startTest();
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        Test.stopTest();

        System.assertEquals(false, ext.getHasErrors());
    }

    @isTest
    public static void Test_Constructor_NoMeeting() {
        Sonoma_ET_Config__c config = MERC_ETTestUtils.CreateConfig();
        insert config;

        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

        Test.startTest();
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        Test.stopTest();

        System.assertEquals(true, ext.getHasErrors());
    }

    @isTest
    public static void Test_SelectAllClicked() {
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        Sonoma_ET_Config__c config = MERC_ETTestUtils.CreateConfig();
        insert config;


        List<Account> accts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 100);
        insert accts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, accts);
        insert participants;

        Test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        ext.IsAllChecked = true;
        System.assertEquals(accts.size(), ext.Participants.size());
        ext.SelectAllClicked();
        for (MERC_ETMeetingEmailSendExtension.SelectedWrapper p : ext.Participants) {
            System.assert(p.IsSelected);
        }
        Test.stopTest();
    }

    @isTest
    public static void Test_ShowHideGrid() {
        Sonoma_ET_Config__c config = MERC_ETTestUtils.CreateConfig();
        insert config;

        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

        Test.startTest();
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        ext.ShowGrid();
        System.assert(ext.ShowParticipantGrid);
        ext.HideGrid();
        System.assert(!ext.ShowParticipantGrid);
        Test.stopTest();
    }

    @isTest
    public static void Test_UrlRoot() {
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        insert etConfig;

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

        Test.startTest();
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        System.assertEquals('mc', ext.urlroot); // for whatever reason, that is the default value
        etConfig = [SELECT Id, et4ae5__url_root__c FROM et4ae5__configuration__c WHERE Id = :etConfig.Id];
        etConfig.et4ae5__url_root__c = 'urlroot';
        update etConfig;
        ext = new MERC_ETMeetingEmailSendExtension(controller);
        System.assert(ext.urlroot.containsIgnoreCase('urlroot'));
        Test.stopTest();
    }

    @isTest
    public static void Test_Send_NoRecipients() {
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        ext.SendTime = 'none';

        Test.startTest();
        PageReference ref = ext.Send();
        Test.stopTest();

        System.assertEquals(null, ref);
        System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
    }

    @isTest
    public static void Test_Send_NoSubject() {
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
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
    public static void Test_Send() {
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

        Sonoma_ET_Config__c config = MERC_ETTestUtils.CreateConfig();
        insert config;

        et4ae5__Configuration__c etConfig = MERC_ETTestUtils.CreateETConfig();
        etConfig.et4ae5__UserName__c = 'testusername';
        etConfig.et4ae5__Password__c = 'testuserpassword';
        etConfig.et4ae5__Auth_API_URL__c = 'www.testauthurl.com/Auth.svc';
        etConfig.et4ae5__Root_Rest_API_URL__c = 'www.testrootrest.com';
        insert etConfig;

        et4ae5__Business_Unit__c etBU = MERC_ETTestUtils.CreateETBU(config);
        etBU.et4ae5__Enabled__c = true;
        insert etBU;

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        ext.DeDup = true;
        ext.OptIn = true;
        ext.DisableIndividualTracking = true;

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
    public static void Test_GetParticipantCount() {
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        Sonoma_ET_Config__c config = MERC_ETTestUtils.CreateConfig();
        insert config;


        List<Account> accts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 100);
        insert accts;
        accts = [SELECT Id, Name FROM Account WHERE Id IN :accts];
        Set<String> accountNames = new Set<String>();
        for (Account a : accts) {
            accountNames.add(a.Name);
        }

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meeting, accts);
        insert participants;

        Test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        System.assertEquals(accts.size(), ext.Participants.size());
        Integer participantCount = ext.getParticipantCount();
        System.assertEquals(0, participantCount);
        ext.IsAllChecked = true;
        ext.SelectAllClicked();
        participantCount = ext.getParticipantCount();
        Test.stopTest();

        System.assertEquals(participants.size(), participantCount);
    }

    @isTest
    public static void Test_GetSyncPayload() {
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        insert etConfig;

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

        Test.startTest();
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        String payload = ext.getSyncPayload();
        System.assertNotEquals(null, payload);
        Test.stopTest();
    }

    @isTest
    public static void Test_ListExactTargetEmails() {
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        Sonoma_ET_Config__c config = MERC_ETTestUtils.CreateConfig();
        insert config;

        et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        etConfig.et4ae5__username__c = 'testusername';
        etConfig.et4ae5__password__c = 'testpassword';
        etConfig.et4ae5__auth_api_url__c = 'www.testauthurl.com';
        insert etConfig;

        et4ae5__Business_Unit__c etBU = MERC_ETTestUtils.CreateETBU(config);
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
            Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator(JSON.serialize(cefr)));
            ApexPages.currentPage().getParameters().put('folderId','testFolderA');
            ext.listExactTargetEmails();
            System.assertEquals(null, ext.emails);
        }

        Test.stopTest();
    }

    @isTest
    public static void Test_SelectEmailCancel() {
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        insert etConfig;

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

        Test.startTest();
        MERC_ETMeetingEmailSendExtension ext = new MERC_ETMeetingEmailSendExtension(controller);
        ext.selectEmailCancel();
        System.assertEquals(false, ext.showEmailChooser);
        Test.stopTest();
    }

    @isTest
    public static void testExpandFolder() {
        MERC_TestFactory.adjustForSFDCSetMockBug = true;

        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        Sonoma_ET_Config__c config = MERC_ETTestUtils.CreateConfig();
        insert config;

        et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        etConfig.et4ae5__username__c = 'testusername';
        etConfig.et4ae5__password__c = 'testpassword';
        etConfig.et4ae5__auth_api_url__c = 'www.testauthurl.com';
        etConfig.et4ae5__root_rest_api_url__c = 'www.testresturl.com';
        insert etConfig;

        et4ae5__Business_Unit__c etBU = MERC_ETTestUtils.CreateETBU(config);
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
            Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator(JSON.serialize(cefr)));

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
            Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator(JSON.serialize(cefr)));
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
        MERC_TestFactory.adjustForSFDCSetMockBug = true;

        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        Sonoma_ET_Config__c config = MERC_ETTestUtils.CreateConfig();
        insert config;

        et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        etConfig.et4ae5__username__c = 'testusername';
        etConfig.et4ae5__password__c = 'testpassword';
        etConfig.et4ae5__auth_api_url__c = 'www.testauthurl.com';
        insert etConfig;

        et4ae5__Business_Unit__c etBU = MERC_ETTestUtils.CreateETBU(config);
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
            Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator(JSON.serialize(cefr)));

            ext.selectEmail();
            System.assertEquals(null, ext.email.id);
            System.assertEquals(null, ext.email.name);
            System.assertEquals(null, ext.email.title);

            ApexPages.currentPage().getParameters().put('emailId', eId);
            ApexPages.currentPage().getParameters().put('emailName', eName);
            ApexPages.currentPage().getParameters().put('emailSubject', eSubject);

            ext.selectEmail();
            System.assertEquals(eId, ext.email.id);
            System.assertEquals(eName, ext.email.name);
            System.assertEquals(eSubject, ext.email.title);
        }

        Test.stopTest();
    }

    @isTest
    private static void testGenerateDocuments() {
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

}