@isTest
private class MERC_ETSendDefinitionProcessor_Test {
    public static testmethod void test_ETSendDefinitionProcessor_Create() {
        et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        etConfig.et4ae5__Root_Rest_API_URL__c = 's1.qa1';
        insert etConfig;

        MERC_ETSendDefinition sd = new MERC_ETSendDefinition('ExtensionId', true, 'Description', 1234, 'Key', 'Send Definition Name', 'Subject', 'SendClassificationId', 'SenderProfileId');

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MERC_ETSendDefinitionCallout_Mock());

            MERC_ETSendDefinitionProcessor sdp = new MERC_ETSendDefinitionProcessor();
            MERC_ETSendDefinition.CreateResponse cr = sdp.create(sd, 'authToken');
        Test.stopTest();

        System.assertNotEquals(null, cr);
        System.assertNotEquals(null, cr.id);
    }

    public static testmethod void test_ETSendDefinitionProcessor_Start() {
        et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        etConfig.et4ae5__Root_Rest_API_URL__c = 's1.qa1';
        insert etConfig;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MERC_ETSendDefinitionCallout_Mock());

            MERC_ETSendDefinitionProcessor sdp = new MERC_ETSendDefinitionProcessor();
            MERC_ETSendDefinition.StartResponse sr = sdp.start('Id', 'authToken');
        Test.stopTest();

        System.assertNotEquals(null, sr);
        System.assertNotEquals(null, sr.id);
        System.assertNotEquals(null, sr.statusMessage);
        System.assertNotEquals(null, sr.jobId);
        System.assertNotEquals(null, sr.clientId);
    }

    public static testmethod void test_ETSendDefinitionProcessor_CheckStatus() {
        et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        etConfig.et4ae5__Root_Rest_API_URL__c = 's1.qa1';
        insert etConfig;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MERC_ETSendDefinitionCallout_Mock());

            MERC_ETSendDefinitionProcessor sdp = new MERC_ETSendDefinitionProcessor();
            MERC_ETSendDefinition.CheckStatusResponse csr = sdp.checkStatus('Id', 'authToken');
        Test.stopTest();

        System.assertNotEquals(null, csr);
        System.assertNotEquals(null, csr.id);
        System.assertNotEquals(null, csr.sendStatus);
        System.assertNotEquals(null, csr.jobId);
        System.assertNotEquals(null, csr.clientId);
    }
    
    public static testmethod void test_ETSendDefinitionProcessor_GetSendClassification() {
    	et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        etConfig.et4ae5__Root_Rest_API_URL__c = 's1.qa1';
        insert etConfig;
        
        Sonoma_ET_Config__c config = new Sonoma_ET_Config__c(
            Default_From_Email__c = 'test@exmaple.com',
            Default_From_Name__c = 'Test',
            ET_BU_Name__c = 'test',
            Send_Configuration_Key__c = 'testkey'
        );
        insert config;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MERC_ETSendDefinitionCallout_Mock());
            
            MERC_ETSendDefinitionProcessor sdp = new MERC_ETSendDefinitionProcessor();
            MERC_ETSendClassification classification = sdp.getSendClassification('authToken');
        Test.stopTest();
        
        System.assertNotEquals(null, classification);
    }
    
    public static testmethod void test_ETSendDefinitionProcessor_Error() {
        et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        etConfig.et4ae5__Root_Rest_API_URL__c = 's1.qa1';
        insert etConfig;

        MERC_ETSendDefinition sd = new MERC_ETSendDefinition('ExtensionId', true, 'Description', 1234, 'Key', 'Send Definition Name', 'Subject', 'SendClassificationId', 'SenderProfileId');
        boolean threwException = false;
        MERC_ETSendDefinitionCallout_Mock mockCallout = new MERC_ETSendDefinitionCallout_Mock();
        mockCallout.returnError = true;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, mockCallout);

            MERC_ETSendDefinitionProcessor sdp = new MERC_ETSendDefinitionProcessor(); 
            try {
                MERC_ETSendDefinition.CreateResponse cr = sdp.create(sd, 'authToken');
            }
            catch(MERC_ETSendDefinitionProcessor.ETSendDefinitionException e) {
                threwException = true;
            }
        Test.stopTest();

        System.assertEquals(threwException, true);
    }
}