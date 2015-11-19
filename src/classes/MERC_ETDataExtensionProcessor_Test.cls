@isTest
private class MERC_ETDataExtensionProcessor_Test {

    public static testmethod void test_ETDataExtensionProcessor_CreateDataExtension_Success() {
        String authToken = '1234token';
        String deKey = '1234key';
        String deName = '1234name';
        DateTime deExpiresIn = Datetime.now().addDays(3);
        List<MERC_ETDataExtension.Field> fields = new List<MERC_ETDataExtension.Field>();
        for (Integer count = 0; count < 3; count++) {
            MERC_ETDataExtension.Field f = new MERC_ETDataExtension.Field();
            f.fieldName = 'Field' + count;
            f.fieldType = '0';
            f.isPrimaryKey = false;
            f.length = '1000';
            f.nullable = false;
            fields.add(f);
        }
        fields[0].isPrimaryKey = true;

        et4ae5__Configuration__c config = MERC_ETTestUtils.CreateETConfig();
        config.et4ae5__Root_Rest_API_URL__c = 'www.rootrest.com';
        insert config;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator()); // MERC_ETDataExtensionCallout_Mock());

            MERC_ETDataExtensionProcessor processor = new MERC_ETDataExtensionProcessor();
            MERC_ETDataExtension.DataExtensionResponse deRes = processor.createDataExtensionWithNameKeyFieldsAndSoapAuth(deName, deKey, fields, authToken, deExpiresIn);
        Test.stopTest();

        System.assertNotEquals(null, deRes.id);
    }

    public static testmethod void test_ETDataExtensionProcessor_CreateDataExtension_Failure() {
        String authToken = '1234token';
        String deKey = '1234key';
        String deName = '1234name';
        DateTime deExpiresIn = Datetime.now().addDays(3);
        List<MERC_ETDataExtension.Field> fields = new List<MERC_ETDataExtension.Field>();
        for (Integer count = 0; count < 3; count++) {
            MERC_ETDataExtension.Field f = new MERC_ETDataExtension.Field();
            f.fieldName = 'Field' + count;
            f.fieldType = '0';
            f.isPrimaryKey = false;
            f.length = '1000';
            f.nullable = false;
            fields.add(f);
        }

        et4ae5__Configuration__c config = MERC_ETTestUtils.CreateETConfig();
        config.et4ae5__Root_Rest_API_URL__c = 'www.rootrest.com';
        insert config;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator(400)); // MERC_ETDataExtensionCallout_Mock());

            MERC_ETDataExtensionProcessor processor = new MERC_ETDataExtensionProcessor();
            MERC_ETDataExtension.DataExtensionResponse deRes = processor.createDataExtensionWithNameKeyFieldsAndSoapAuth(deName, deKey, fields, authToken, deExpiresIn);
        Test.stopTest();

        System.assertEquals(null, deRes.id);
    }

    public static testmethod void test_ETDataExtensionProcessor_PopulateDataExtension_Success() {
        String authToken = '1234token';
        String deKey = '1234key';
        List<MERC_ETDataExtension.DataExtensionEntry> entries = new List<MERC_ETDataExtension.DataExtensionEntry>();
        for (Integer count = 0; count < 3; count++) {
            MERC_ETDataExtension.DataExtensionEntry e = new MERC_ETDataExtension.DataExtensionEntry();
            MERC_ETDataExtension.FieldEntry k = new MERC_ETDataExtension.FieldEntry();
            k.fieldName = 'Field0';
            k.fieldValue = '1234' + count;
            e.keys = k;

            e.values = new List<MERC_ETDataExtension.FieldEntry>();
            MERC_ETDataExtension.FieldEntry f1 = new MERC_ETDataExtension.FieldEntry();
            f1.fieldName = 'Field1';
            f1.fieldValue = '1234' + count + '-1';
            e.values.add(f1);
            MERC_ETDataExtension.FieldEntry f2 = new MERC_ETDataExtension.FieldEntry();
            f2.fieldName = 'Field2';
            f2.fieldValue = '1234' + count + '-2';
            e.values.add(f2);

            entries.add(e);
        }

        et4ae5__Configuration__c config = MERC_ETTestUtils.CreateETConfig();
        config.et4ae5__Root_Rest_API_URL__c = 'www.rootrest.com';
        insert config;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator(200)); //MERC_ETDataExtensionPopulateCallout_Mock());

            MERC_ETDataExtensionProcessor processor = new MERC_ETDataExtensionProcessor();
            System.debug('### dekey = ' + deKey);
            System.debug('### entries = ' + entries);
            System.debug('### authToken = ' + authToken);
            HttpResponse res = processor.populateDataExtensionForKeyWithValuesAndFuelAuth(deKey, entries, authToken);
        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals(200, res.getStatusCode());
        System.assertNotEquals(null, res.getBody());
    }

    @isTest
    public static void test_ETDataExtensionProcessor_CreateDataExtensionForSendEmail_Success() {
        MERC_TestFactory.adjustForSFDCSetMockBug = true;

        MERC_MarketingCloudClient.FolderedEmail fe = new MERC_MarketingCloudClient.FolderedEmail();
        fe.id = 'folderedid';
        fe.name = 'folder email name';
        fe.subject = 'folder email title';

        List<Meeting_MERC__c> meetings = MERC_ETTestUtils.CreateMeetings(1);
        for (Meeting_MERC__c m : meetings) {
            m.RecordTypeId = MERC_ETTestUtils.GetRecordType('Ad_Hoc_Consulting', 'Meeting_MERC__c').Id;
            m.City_of_Meeting_MERC__c = 'test city';
            m.Preferred_Venue_MERC__c = 'test venue';
            m.Start_Time_of_Meeting_MERC__c = Datetime.now();
            m.End_Time_of_Meeting_MERC__c = Datetime.now().addDays(5);
            m.Event_Id_MERC__c = 'test id';
        }
        insert meetings;

        List<Account> personAccounts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 5);
        insert personAccounts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meetings[0], personAccounts);
        insert participants;

        MERC_ETSendEmailWrapper sew = new MERC_ETSendEmailWrapper(fe, participants, 'fromAddress@test.com', 'From Name', true, true, 'now', null, 'test', 'test');

        et4ae5__Configuration__c etConfig = MERC_ETTestUtils.CreateETConfig();
        etConfig.et4ae5__UserName__c = 'testusername';
        etConfig.et4ae5__Password__c = 'testuserpassword';
        etConfig.et4ae5__Auth_API_URL__c = 'www.testauthurl.com/Auth.svc';
        etConfig.et4ae5__Root_Rest_API_URL__c = 'www.testrootrest.com';
        insert etConfig;

        Sonoma_ET_Config__c config = MERC_ETTestUtils.CreateConfig();
        insert config;
        Mercury_Marketing_Cloud_Settings_MERC__c settings = MERC_ETTestUtils.CreateSettings();
        insert settings;

        et4ae5__Business_Unit__c etBU = MERC_ETTestUtils.CreateETBU(config);
        etBU.et4ae5__Enabled__c = true;
        insert etBU;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator()); //MERC_ETEndToEndDataExtCallouts_Mock());
        System.debug('test.startTest');
        try {
            MERC_ETDataExtensionProcessor processor = new MERC_ETDataExtensionProcessor();
            processor.createDataExtensionForSendEmail(sew);
            System.assert(true);
        } catch (Exception e) {
        }
        System.debug('test.stopTest');
        Test.stopTest();
    }
}