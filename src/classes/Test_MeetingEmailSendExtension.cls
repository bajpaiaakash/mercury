@isTest
private class Test_MeetingEmailSendExtension {

    //@isTest
    //public static void Test_Constructor() {
    //    Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];
    //    insert meeting;

    //    Sonoma_ET_Config__c config = TestUtils.CreateConfig();
    //    insert config;

    //    ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

    //    Test.startTest();
    //    MeetingEmailSendExtension ext = new MeetingEmailSendExtension(controller);
    //    Test.stopTest();

    //    System.assertEquals(false, ext.getHasErrors());
    //}

    //@isTest
    //public static void Test_Constructor_NoMeeting() {
    //    Sonoma_ET_Config__c config = TestUtils.CreateConfig();
    //    insert config;

    //    Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];

    //    ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

    //    Test.startTest();
    //    MeetingEmailSendExtension ext = new MeetingEmailSendExtension(controller);
    //    Test.stopTest();

    //    System.assertEquals(true, ext.getHasErrors());
    //}

    //@isTest
    //public static void Test_SelectAllClicked() {
    //    Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];
    //    insert meeting;

    //    Sonoma_ET_Config__c config = TestUtils.CreateConfig();
    //    insert config;


    //    List<Account> accts = TestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 100);
    //    insert accts;

    //    List<Meeting_Participant_MERC__c> participants = TestUtils.CreateParticipants(meeting, accts);
    //    insert participants;

    //    Test.startTest();
    //    ApexPages.StandardController controller = new ApexPages.StandardController(meeting);
    //    MeetingEmailSendExtension ext = new MeetingEmailSendExtension(controller);
    //    ext.IsAllChecked = true;
    //    System.assertEquals(accts.size(), ext.Participants.size());
    //    ext.SelectAllClicked();
    //    for (MeetingEmailSendExtension.SelectedWrapper p : ext.Participants) {
    //        System.assert(p.IsSelected);
    //    }
    //    Test.stopTest();
    //}

    //@isTest
    //public static void Test_ShowHideGrid() {
    //    Sonoma_ET_Config__c config = TestUtils.CreateConfig();
    //    insert config;

    //    Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];

    //    ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

    //    Test.startTest();
    //    MeetingEmailSendExtension ext = new MeetingEmailSendExtension(controller);
    //    ext.ShowGrid();
    //    System.assert(ext.ShowParticipantGrid);
    //    ext.HideGrid();
    //    System.assert(!ext.ShowParticipantGrid);
    //    Test.stopTest();
    //}

    //@isTest
    //public static void Test_UrlRoot() {
    //    Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];
    //    insert meeting;

    //    et4ae5__configuration__c etConfig = TestUtils.CreateEtConfig();
    //    insert etConfig;

    //    ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

    //    Test.startTest();
    //    MeetingEmailSendExtension ext = new MeetingEmailSendExtension(controller);
    //    System.assertEquals('mc', ext.urlroot); // for whatever reason, that is the default value
    //    etConfig = [SELECT Id, et4ae5__url_root__c FROM et4ae5__configuration__c WHERE Id = :etConfig.Id];
    //    etConfig.et4ae5__url_root__c = 'urlroot';
    //    update etConfig;
    //    ext = new MeetingEmailSendExtension(controller);
    //    System.assert(ext.urlroot.containsIgnoreCase('urlroot'));
    //    Test.stopTest();
    //}

    //@isTest
    //public static void Test_Send_NoRecipients() {
    //    Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];
    //    insert meeting;

    //    ApexPages.StandardController controller = new ApexPages.StandardController(meeting);
    //    MeetingEmailSendExtension ext = new MeetingEmailSendExtension(controller);
    //    ext.SendTime = 'none';

    //    Test.startTest();
    //    PageReference ref = ext.Send();
    //    Test.stopTest();

    //    System.assertEquals(null, ref);
    //    System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
    //}

    //@isTest
    //public static void Test_Send_NoSubject() {
    //    Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];
    //    insert meeting;

    //    ApexPages.StandardController controller = new ApexPages.StandardController(meeting);
    //    MeetingEmailSendExtension ext = new MeetingEmailSendExtension(controller);
    //    FolderedEmail email = new FolderedEmail();
    //    email.Id = 'test';
    //    ext.email = email;

    //    Test.startTest();
    //    PageReference ref = ext.Send();
    //    Test.stopTest();

    //    System.assertEquals(null, ref);
    //    System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));   
    //}

    //@isTest
    //public static void Test_Send() {
    //    Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];
    //    insert meeting;

    //    Sonoma_ET_Config__c config = TestUtils.CreateConfig();
    //    insert config;

    //    List<Account> accts = TestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 100);
    //    insert accts;
    //    accts = [SELECT Id, Name FROM Account WHERE Id IN :accts];
    //    Set<String> accountNames = new Set<String>();
    //    for (Account a : accts) {
    //        accountNames.add(a.Name);
    //    }

    //    List<Meeting_Participant_MERC__c> participants = TestUtils.CreateParticipants(meeting, accts);
    //    insert participants;

    //    ApexPages.StandardController controller = new ApexPages.StandardController(meeting);
    //    MeetingEmailSendExtension ext = new MeetingEmailSendExtension(controller);
        
    //    FolderedEmail email = new FolderedEmail();
    //    email.Id = 'test';
    //    email.Title = 'test subject';
    //    ext.email = email;

    //    for (MeetingEmailSendExtension.SelectedWrapper w : ext.Participants) {
    //        w.IsSelected = true;
    //    }

    //    Test.startTest();
    //    PageReference ref = ext.Send();
    //    Test.stopTest();

    //    System.assertNotEquals(null, ref);
    //    System.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR));
    //}

    //@isTest
    //public static void Test_GetParticipantNames() {
    //    Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];
    //    insert meeting;

    //    Sonoma_ET_Config__c config = TestUtils.CreateConfig();
    //    insert config;


    //    List<Account> accts = TestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 100);
    //    insert accts;
    //    accts = [SELECT Id, Name FROM Account WHERE Id IN :accts];
    //    Set<String> accountNames = new Set<String>();
    //    for (Account a : accts) {
    //        accountNames.add(a.Name);
    //    }

    //    List<Meeting_Participant_MERC__c> participants = TestUtils.CreateParticipants(meeting, accts);
    //    insert participants;

    //    Test.startTest();
    //    ApexPages.StandardController controller = new ApexPages.StandardController(meeting);
    //    MeetingEmailSendExtension ext = new MeetingEmailSendExtension(controller);
    //    System.assertEquals(accts.size(), ext.Participants.size());
    //    String participantNames = ext.getParticipantNames();
    //    System.assertEquals('', participantNames);
    //    ext.IsAllChecked = true;
    //    ext.SelectAllClicked();
    //    participantNames = ext.getParticipantNames();
    //    Test.stopTest();

    //    List<String> names = participantNames.split('; ');
    //    System.debug('names : ' + names);
    //    System.debug('accountNames : ' + accountNames);
    //    for (String n : names) {
    //        System.assert(accountNames.contains(n));
    //    }
    //}

    //@isTest
    //public static void Test_GetSyncPayload() {
    //    Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];
    //    insert meeting;

    //    et4ae5__configuration__c etConfig = TestUtils.CreateEtConfig();
    //    insert etConfig;

    //    ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

    //    Test.startTest();
    //    MeetingEmailSendExtension ext = new MeetingEmailSendExtension(controller);
    //    String payload = ext.getSyncPayload();
    //    System.assertNotEquals(null, payload);
    //    Test.stopTest();
    //}

    //@isTest
    //public static void Test_ListExactTargetEmails() {
    //    Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];
    //    insert meeting;

    //    Sonoma_ET_Config__c config = TestUtils.CreateConfig();
    //    insert config;

    //    et4ae5__configuration__c etConfig = TestUtils.CreateEtConfig();
    //    etConfig.et4ae5__username__c = 'testusername';
    //    etConfig.et4ae5__password__c = 'testpassword';
    //    etConfig.et4ae5__auth_api_url__c = 'www.testauthurl.com';
    //    insert etConfig;

    //    et4ae5__Business_Unit__c etBU = TestUtils.CreateETBU(config);
    //    insert etBU;

    //    User u = TestUtils.CreateUser('Standard User');
    //    u.et4ae5__exacttarget_Oauth_token__c = '';
    //    insert u;

    //    ApexPages.StandardController stdController = new ApexPages.StandardController(meeting);
    //    MeetingEmailSendExtension ext = new MeetingEmailSendExtension(stdController);

    //    EtObject.emailfolder testFolderA=new etObject.emailfolder();
    //    EtObject.emailfolder testFolderB=new etObject.emailfolder();
    //    EtObject.emailfolder testFolderC=new etObject.emailfolder();
    //    EtObject.emailfolder testFolderD=new etObject.emailfolder();
    //    EtObject.emailfolder testFolderE=new etObject.emailfolder();
    //    testFolderA.id = 'testFolderA';
    //    testFolderB.id = 'testFolderB';
    //    testFolderC.id = 'testFolderC';
    //    testFolderD.id = 'testFolderD';
    //    testFolderE.id = 'testFolderE';
    //    testFolderA.subfolders=new list<etObject.emailfolder>();
    //    testFolderB.subfolders=new list<etObject.emailfolder>();
    //    testFolderC.subfolders=new list<etObject.emailfolder>();
    //    testFolderD.subfolders=new list<etObject.emailfolder>();
    //    testFolderD.subfolders.add(testFolderE);
    //    testFolderC.subfolders.add(testFolderD);
    //    testFolderB.subfolders.add(testFolderC);
    //    testFolderA.subfolders.add(testFolderB);
    //    ext.emails=new list<etObject.emailfolder>();
    //    ext.emails.add(testFolderA);

    //    EtObject.CallEmailFolderResponse cefr= new EtObject.CallEmailFolderResponse();
    //    Test.startTest();

    //    System.runAs(u) {
    //        cefr.entry = testFolderA.subfolders;
    //        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(JSON.serialize(cefr)));
    //        ApexPages.currentPage().getParameters().put('folderId','testFolderA');
    //        ext.listExactTargetEmails();
    //        System.assertEquals(null, ext.emails);
    //    }

    //    Test.stopTest();
    //}

    //@isTest
    //public static void Test_SelectEmailCancel() {
    //    Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];
    //    insert meeting;

    //    et4ae5__configuration__c etConfig = TestUtils.CreateEtConfig();
    //    insert etConfig;

    //    ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

    //    Test.startTest();
    //    MeetingEmailSendExtension ext = new MeetingEmailSendExtension(controller);
    //    ext.selectEmailCancel();
    //    System.assertEquals(false, ext.showEmailChooser);
    //    Test.stopTest();
    //}

    @isTest
    public static void testExpandFolder() {
        Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];
        insert meeting;

        Sonoma_ET_Config__c config = TestUtils.CreateConfig();
        insert config;

        et4ae5__configuration__c etConfig = TestUtils.CreateEtConfig();
        etConfig.et4ae5__username__c = 'testusername';
        etConfig.et4ae5__password__c = 'testpassword';
        etConfig.et4ae5__auth_api_url__c = 'www.testauthurl.com';
        etConfig.et4ae5__root_rest_api_url__c = 'www.testresturl.com';
        insert etConfig;

        et4ae5__Business_Unit__c etBU = TestUtils.CreateETBU(config);
        insert etBU;

        User u = TestUtils.CreateUser('System Administrator');
        u.et4ae5__exactTargetForAppExchangeAdmin__c=true;
        u.et4ae5__exactTargetForAppExchangeUser__c=true;
        u.et4ae5__exactTarget_OAuth_Token__c='testToken';
        u.et4ae5__exactTargetUsername__c='testUser';
        insert u;

        ApexPages.StandardController stdController = new ApexPages.StandardController(meeting);
        MeetingEmailSendExtension ext = new MeetingEmailSendExtension(stdController);

        EtObject.emailfolder testFolderA=new etObject.emailfolder();
        EtObject.emailfolder testFolderB=new etObject.emailfolder();
        EtObject.emailfolder testFolderC=new etObject.emailfolder();
        EtObject.emailfolder testFolderD=new etObject.emailfolder();
        EtObject.emailfolder testFolderE=new etObject.emailfolder();
        testFolderA.id = 'testFolderA';
        testFolderB.id = 'testFolderB';
        testFolderC.id = 'testFolderC';
        testFolderD.id = 'testFolderD';
        testFolderE.id = 'testFolderE';
        testFolderA.subfolders=new list<etObject.emailfolder>();
        testFolderB.subfolders=new list<etObject.emailfolder>();
        testFolderC.subfolders=new list<etObject.emailfolder>();
        testFolderD.subfolders=new list<etObject.emailfolder>();
        testFolderD.subfolders.add(testFolderE);
        testFolderC.subfolders.add(testFolderD);
        testFolderB.subfolders.add(testFolderC);
        testFolderA.subfolders.add(testFolderB);
        ext.emails=new list<etObject.emailfolder>();
        ext.emails.add(testFolderA);

        EtObject.CallEmailFolderResponse cefr= new EtObject.CallEmailFolderResponse();

        System.runAs(u) {
            Test.startTest();
            cefr.entry = testFolderA.subfolders;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(JSON.serialize(cefr)));

            ApexPages.currentPage().getParameters().put('folderId','testFolderA');
            ext.expandFolder();
            Boolean containsMessage = false;
            for (ApexPages.Message pm : ApexPages.getMessages()) {
                if (pm.getDetail().contains('There are no emails in the')) {
                    containsMessage = true;
                }
            }
            System.assert(!containsMessage);
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

    //@isTest
    //public static void Test_SelectEmail() {
    //    Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];
    //    insert meeting;

    //    Sonoma_ET_Config__c config = TestUtils.CreateConfig();
    //    insert config;

    //    et4ae5__configuration__c etConfig = TestUtils.CreateEtConfig();
    //    etConfig.et4ae5__username__c = 'testusername';
    //    etConfig.et4ae5__password__c = 'testpassword';
    //    etConfig.et4ae5__auth_api_url__c = 'www.testauthurl.com';
    //    insert etConfig;

    //    et4ae5__Business_Unit__c etBU = TestUtils.CreateETBU(config);
    //    insert etBU;

    //    User u = TestUtils.CreateUser('Standard User');
    //    u.et4ae5__exacttarget_Oauth_token__c = '';
    //    insert u;

    //    ApexPages.StandardController stdController = new ApexPages.StandardController(meeting);
    //    MeetingEmailSendExtension ext = new MeetingEmailSendExtension(stdController);

    //    EtObject.emailfolder testFolderA=new etObject.emailfolder();
    //    EtObject.emailfolder testFolderB=new etObject.emailfolder();
    //    EtObject.emailfolder testFolderC=new etObject.emailfolder();
    //    EtObject.emailfolder testFolderD=new etObject.emailfolder();
    //    EtObject.emailfolder testFolderE=new etObject.emailfolder();
    //    testFolderA.id = 'testFolderA';
    //    testFolderB.id = 'testFolderB';
    //    testFolderC.id = 'testFolderC';
    //    testFolderD.id = 'testFolderD';
    //    testFolderE.id = 'testFolderE';
    //    testFolderA.subfolders=new list<etObject.emailfolder>();
    //    testFolderB.subfolders=new list<etObject.emailfolder>();
    //    testFolderC.subfolders=new list<etObject.emailfolder>();
    //    testFolderD.subfolders=new list<etObject.emailfolder>();
    //    testFolderD.subfolders.add(testFolderE);
    //    testFolderC.subfolders.add(testFolderD);
    //    testFolderB.subfolders.add(testFolderC);
    //    testFolderA.subfolders.add(testFolderB);
    //    ext.emails=new list<etObject.emailfolder>();
    //    ext.emails.add(testFolderA);

    //    EtObject.CallEmailFolderResponse cefr= new EtObject.CallEmailFolderResponse();
    //    Test.startTest();

    //    String eId = 'testEmailId';
    //    String eName = 'testEmailName';
    //    String eSubject = 'testEmailSubject';

    //    System.runAs(u) {
    //        cefr.entry = testFolderA.subfolders;
    //        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(JSON.serialize(cefr)));

    //        ext.selectEmail();
    //        System.assertEquals(null, ext.email.id);
    //        System.assertEquals(null, ext.email.name);
    //        System.assertEquals(null, ext.email.title);

    //        ApexPages.currentPage().getParameters().put('emailId', eId);
    //        ApexPages.currentPage().getParameters().put('emailName', eName);
    //        ApexPages.currentPage().getParameters().put('emailSubject', eSubject);

    //        ext.selectEmail();
    //        System.assertEquals(eId, ext.email.id);
    //        System.assertEquals(eName, ext.email.name);
    //        System.assertEquals(eSubject, ext.email.title);
    //    }

    //    Test.stopTest();
    //}

}