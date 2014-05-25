@isTest
private class Test_ETDataExtensionProcessor {

    public static testmethod void test_ETDataExtensionProcessor_CreateDataExtension_Success() {
        String authToken = '1234token';
        String deKey = '1234key';
        String deName = '1234name';
        DateTime deExpiresIn = Datetime.now().addDays(3);
        List<ETDataExtension.Field> fields = new List<ETDataExtension.Field>();
        for (Integer count = 0; count < 3; count++) {
            ETDataExtension.Field f = new ETDataExtension.Field();
            f.fieldName = 'Field' + count;
            f.fieldType = '0';
            f.isPrimaryKey = false;
            f.length = '1000';
            f.nullable = false;
            fields.add(f);
        }
        fields[0].isPrimaryKey = true;

        et4ae5__Configuration__c config = TestUtils.CreateETConfig();
        config.et4ae5__Root_Rest_API_URL__c = 'www.rootrest.com';
        insert config;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Mock_DataExtensionCallout());

            ETDataExtensionProcessor processor = new ETDataExtensionProcessor();
            ETDataExtension.DataExtensionResponse deRes = processor.createDataExtensionWithNameKeyFieldsAndSoapAuth(deName, deKey, fields, authToken, deExpiresIn);
        Test.stopTest();

        System.assertNotEquals(null, deRes.id);
    }

    public static testmethod void test_ETDataExtensionProcessor_CreateDataExtension_Failure() {
        String authToken = '1234token';
        String deKey = '1234key';
        String deName = '1234name';
        DateTime deExpiresIn = Datetime.now().addDays(3);
        List<ETDataExtension.Field> fields = new List<ETDataExtension.Field>();
        for (Integer count = 0; count < 3; count++) {
            ETDataExtension.Field f = new ETDataExtension.Field();
            f.fieldName = 'Field' + count;
            f.fieldType = '0';
            f.isPrimaryKey = false;
            f.length = '1000';
            f.nullable = false;
            fields.add(f);
        }

        et4ae5__Configuration__c config = TestUtils.CreateETConfig();
        config.et4ae5__Root_Rest_API_URL__c = 'www.rootrest.com';
        insert config;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Mock_DataExtensionCallout());
            
            ETDataExtensionProcessor processor = new ETDataExtensionProcessor();
            ETDataExtension.DataExtensionResponse deRes = processor.createDataExtensionWithNameKeyFieldsAndSoapAuth(deName, deKey, fields, authToken, deExpiresIn);
        Test.stopTest();

        System.assertEquals(null, deRes.id);
    }

    public static testmethod void test_ETDataExtensionProcessor_PopulateDataExtension_Success() {
        String authToken = '1234token';
        String deKey = '1234key';
        List<ETDataExtension.DataExtensionEntry> entries = new List<ETDataExtension.DataExtensionEntry>();
        for (Integer count = 0; count < 3; count++) {
            ETDataExtension.DataExtensionEntry e = new ETDataExtension.DataExtensionEntry();
            ETDataExtension.FieldEntry k = new ETDataExtension.FieldEntry();
            k.fieldName = 'Field0';
            k.fieldValue = '1234' + count;
            e.keys = k;

            e.values = new List<ETDataExtension.FieldEntry>();
            ETDataExtension.FieldEntry f1 = new ETDataExtension.FieldEntry();
            f1.fieldName = 'Field1';
            f1.fieldValue = '1234' + count + '-1';
            e.values.add(f1);
            ETDataExtension.FieldEntry f2 = new ETDataExtension.FieldEntry();
            f2.fieldName = 'Field2';
            f2.fieldValue = '1234' + count + '-2';
            e.values.add(f2);

            entries.add(e);
        }

        et4ae5__Configuration__c config = TestUtils.CreateETConfig();
        config.et4ae5__Root_Rest_API_URL__c = 'www.rootrest.com';
        insert config;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Mock_DataExtensionPopulateCallout());
            
            ETDataExtensionProcessor processor = new ETDataExtensionProcessor();
            HttpResponse res = processor.populateDataExtensionForKeyWithValuesAndFuelAuth(deKey, entries, authToken);
        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals(200, res.getStatusCode());
        System.assertEquals('OK', res.getStatus());
        System.assertNotEquals(null, res.getBody());
    }

    @isTest
    public static void test_ETDataExtensionProcessor_CreateDataExtensionForSendEmail_Success() {
        Test.setMock(HttpCalloutMock.class, new Mock_EndToEndDataExtensionCallouts());
        MERC_TestFactory.adjustForSFDCSetMockBug = true;

        FolderedEmail fe = new FolderedEmail();
        fe.id = 'folderedid';
        fe.name = 'folder email name';
        fe.title = 'folder email title';

        List<Meeting_MERC__c> meetings = TestUtils.CreateMeetings(1);
        for (Meeting_MERC__c m : meetings) {
            m.RecordTypeId = TestUtils.GetRecordType('Ad_Hoc_Consulting', 'Meeting_MERC__c').Id;
            m.City_of_Meeting_MERC__c = 'test city';
            m.Preferred_Venue_MERC__c = 'test venue';
            m.Start_Time_of_Meeting_MERC__c = Datetime.now();
            m.End_Time_of_Meeting_MERC__c = Datetime.now().addDays(5);
            m.Event_Id_MERC__c = 'test id';
        }
        insert meetings;

        List<Account> personAccounts = TestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 5);
        insert personAccounts;

        List<Meeting_Participant_MERC__c> participants = TestUtils.CreateParticipants(meetings[0], personAccounts);
        insert participants;

        SendEmailWrapper sew = new SendEmailWrapper(fe, participants, 'fromAddress@test.com', true, true, 'now', null);

        et4ae5__Configuration__c etConfig = TestUtils.CreateETConfig();
        etConfig.et4ae5__UserName__c = 'testusername';
        etConfig.et4ae5__Password__c = 'testuserpassword';
        etConfig.et4ae5__Auth_API_URL__c = 'www.testauthurl.com/Auth.svc';
        etConfig.et4ae5__Root_Rest_API_URL__c = 'www.testrootrest.com';
        insert etConfig;

        Sonoma_ET_Config__c config = TestUtils.CreateConfig();
        insert config;

        et4ae5__Business_Unit__c etBU = TestUtils.CreateETBU(config);
        etBU.et4ae5__Enabled__c = true;
        insert etBU;

        /**
         * The entire test must be wrapped in a try/catch.  The reason being that when we insert the
         * et4ae5__SendDefinition__c object at the end of our process, the ET integration sets up a future method that
         * makes a web service callout.  However, the ET integration does not expose a webservice mock or method to set
         * up a mock for us to properly catch this callout.  As such, SFDC throws 
         * "System.TypeException: Methods defined as TestMethod do not support Web service callouts, test skipped" when
         * the web service call is not sent to a mock.  Therefore, we are just catching and ensuring that happens.
         */
        try {
            Test.startTest();
                System.debug('test.startTest');
                try {
                    ETDataExtensionProcessor processor = new ETDataExtensionProcessor();
                    processor.createDataExtensionForSendEmail(sew);
                    System.assert(true);
                } catch (Exception e) {
                    System.assert(false, 'this method should pass, but the exception is : ' + e.getMessage() + '\n' + e.getStackTraceString());
                }
                System.debug('test.stopTest');
            Test.stopTest();
        } catch (Exception e) {
            System.debug('exception : ' + e);
            System.assert(e.getMessage().containsIgnoreCase('Methods defined as TestMethod do not support Web service callouts, test skipped'));
        }
    }
}