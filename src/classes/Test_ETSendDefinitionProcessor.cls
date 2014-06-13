@isTest
private class Test_ETSendDefinitionProcessor {
    public static testmethod void test_ETSendDefinitionProcessor_Create() {
        et4ae5__configuration__c etConfig = TestUtils.CreateEtConfig();
        etConfig.et4ae5__Root_Rest_API_URL__c = 's1.qa1';
        insert etConfig;

        ETSendDefinition sd = new ETSendDefinition('ExtensionId', true, 'Description', 1234, 'Key', 'Send Definition Name', 'Subject');

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Mock_ETSendDefinitionCallout());

            ETSendDefinitionProcessor sdp = new ETSendDefinitionProcessor();
            ETSendDefinition.CreateResponse cr = sdp.create(sd, 'authToken');
        Test.stopTest();

        System.assertNotEquals(null, cr);
        System.assertNotEquals(null, cr.id);
    }

    public static testmethod void test_ETSendDefinitionProcessor_Start() {
        et4ae5__configuration__c etConfig = TestUtils.CreateEtConfig();
        etConfig.et4ae5__Root_Rest_API_URL__c = 's1.qa1';
        insert etConfig;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Mock_ETSendDefinitionCallout());

            ETSendDefinitionProcessor sdp = new ETSendDefinitionProcessor();
            ETSendDefinition.StartResponse sr = sdp.start('Id', 'authToken');
        Test.stopTest();

        System.assertNotEquals(null, sr);
        System.assertNotEquals(null, sr.id);
        System.assertNotEquals(null, sr.statusMessage);
        System.assertNotEquals(null, sr.jobId);
        System.assertNotEquals(null, sr.clientId);
    }

    public static testmethod void test_ETSendDefinitionProcessor_CheckStatus() {
        et4ae5__configuration__c etConfig = TestUtils.CreateEtConfig();
        etConfig.et4ae5__Root_Rest_API_URL__c = 's1.qa1';
        insert etConfig;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Mock_ETSendDefinitionCallout());

            ETSendDefinitionProcessor sdp = new ETSendDefinitionProcessor();
            ETSendDefinition.CheckStatusResponse csr = sdp.checkStatus('Id', 'authToken');
        Test.stopTest();

        System.assertNotEquals(null, csr);
        System.assertNotEquals(null, csr.id);
        System.assertNotEquals(null, csr.sendStatus);
        System.assertNotEquals(null, csr.jobId);
        System.assertNotEquals(null, csr.clientId);
    }
}