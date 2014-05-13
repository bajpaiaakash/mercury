@isTest
private class Test_ETDataExtensionProcessor {
/*
    public static testmethod void test_ETDataExtensionProcessor_CreateDataExtension_Success() {
        String authToken = '1234token';
        String deKey = '1234key';
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
            ETDataExtension.DataExtensionResponse deRes = processor.createDataExtensionWithKeyFieldsAndSoapAuth(deKey, fields, authToken);
        Test.stopTest();

        System.assertNotEquals(null, deRes.id);
    }

    public static testmethod void test_ETDataExtensionProcessor_CreateDataExtension_Failure() {
        String authToken = '1234token';
        String deKey = '1234key';
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
            ETDataExtension.DataExtensionResponse deRes = processor.createDataExtensionWithKeyFieldsAndSoapAuth(deKey, fields, authToken);
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
*/
    public static testmethod void test_ETDataExtensionProcessor_CreateDataExtensionForSendEmail_Success() {
        FolderedEmail fe = new FolderedEmail();
        fe.id = 'foldered email id';
        fe.name = 'folder email name';
        fe.title = 'folder email title';

        //List<Meeting_MERC__c> meetings = TestUtils.CreateMeetings(1);
        //for (Meeting_MERC__c m : meetings) {
        //    m.City_of_Meeting_MERC__c = 'test city';
        //    m.Preferred_Venue_MERC__c = 'test venue';
        //    m.Date_of_Event_MERC__c = Date.today();
        //    m.End_Date_of_Event_MERC__c = Date.today().addDays(5);
        //    m.Event_Id_MERC__c = 'test id';
        //}
        //insert meetings;

        List<Account> personAccounts = TestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 5);
        insert personAccounts;

        //List<Meeting_Participant_MERC__c> participants = TestUtils.CreateParticipants(meetings[0], personAccounts);
        //insert participants;

        //SendEmailWrapper sew = new SendEmailWrapper(fe, participants, 'fromAddress@test.com', true, true, 'now');
        SendEmailWrapper sew = new SendEmailWrapper(fe, null, 'fromAddress@test.com', true, true, 'now');

        et4ae5__Configuration__c etConfig = TestUtils.CreateETConfig();
        etConfig.et4ae5__UserName__c = 'testusername';
        etConfig.et4ae5__Password__c = 'testuserpassword';
        etConfig.et4ae5__Auth_API_URL__c = 'www.testauthurl.com/Auth.svc';
        insert etConfig;

        Test.startTest();
            System.debug('test.startTest');
            Test.setMock(HttpCalloutMock.class, new Mock_EndToEndDataExtensionCallouts());
            try {
                ETDataExtensionProcessor processor = new ETDataExtensionProcessor();
                processor.createDataExtensionForSendEmail(sew);
                System.assert(true);
            } catch (Exception e) {
                System.assert(false, 'this method should pass, but the exception is : ' + e);
            }
            System.debug('test.stopTest');
        Test.stopTest();
    }
}