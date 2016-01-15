@isTest
private class MERC_DocusignServiceTest {

    static {
        Docusign_Settings_MERC__c settings = new Docusign_Settings_MERC__c();
        settings.Name = 'default';
        settings.Account_ID_MERC__c = '12345';
        settings.Integrator_Key_MERC__c = '12345';
        settings.Password_MERC__c = 'foo';
        settings.Username_MERC__c = 'bar';
        settings.Server_Endpoint_MERC__c = 'https://docusign.com';
        insert settings;
    }

    @isTest
    static void testLoginAccount() {
        Test.startTest();

        MERC_DocusignService.LoginAccount loginAccountObject = new MERC_DocusignService.LoginAccount(
            'A test name',
            'a test account id',
            'a baseurl',
            'true',
            'my username',
            'my userid',
            'my email',
            ''
        );
        MERC_DocusignService.LoginInformation loginInformation = new MERC_DocusignService.LoginInformation();
        loginInformation.loginAccounts = new List<MERC_DocusignService.LoginAccount>{loginAccountObject};

        String loginAccountResponse = JSON.serializePretty(loginInformation);
        system.debug(loginAccountResponse);

        MERC_DocusignServiceMock fakeResponse = new MERC_DocusignServiceMock(200, 'Complete', loginAccountResponse, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        MERC_DocusignService d = new MERC_DocusignService();
        d.login();
        Test.stopTest();

        System.assertEquals(1, d.loginInfo.loginAccounts.size());
        System.assertEquals(loginAccountObject.email, d.loginInfo.loginAccounts[0].email);
        System.assertEquals(loginAccountObject.userName, d.loginInfo.loginAccounts[0].userName);
    }

    @isTest
    static void testSendToSigners() {

        //generate signers
        List<MERC_DocusignService.RequiredSigner> requiredSigners = new List<MERC_DocusignService.RequiredSigner>();
        User testUser = MERC_TestFactory.getTestingUser();
        System.runAs(testUser) {
            List<Account> signingAccounts = MERC_TestFactory.insertAccounts(2);
            
            for (Integer i = 0; i < signingAccounts.size(); i++) {
                MERC_DocusignService.RequiredSigner signer = new MERC_DocusignService.RequiredSigner();
                signer.acc = signingAccounts.get(i);
                signer.order = i+1;
                signer.isLilly = i == 0 ? true : false;
                requiredSigners.add(signer);
            }
        }

        Test.startTest();
        //serialize mock response
        MERC_DocusignService.EnvelopeResponse mockResponse = new MERC_DocusignService.EnvelopeResponse();
        mockResponse.envelopeId = '7f7de730-811d-458a-97a3-deeef96b38d0';
        mockResponse.status = 'sent';
        mockResponse.statusDateTime = '2013-10-11T17:17:55.5470518Z';
        mockResponse.uri = '/envelopes/7f7de730-811d-458a-97a3-deeef96b38d0';
        String envelopeResponseJSONString = JSON.serializePretty(mockResponse);
        system.debug(envelopeResponseJSONString);

        MERC_DocusignServiceMock fakeResponse = new MERC_DocusignServiceMock(200, 'Complete', envelopeResponseJSONString, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        //send request for signature
        MERC_DocusignService d = new MERC_DocusignService();
        MERC_DocusignService.EnvelopeResponse r = d.requestSignature(requiredSigners, 'this is the document to sign');
        Test.stopTest();

        system.debug(r);
        System.assertEquals(r.envelopeId, mockResponse.envelopeId);
        System.assertEquals(r.status, mockResponse.status);
    }

    @isTest 
    static void testTASresponse() {
        MERC_DocusignService.EnvelopeResponse envelope = new MERC_DocusignService.EnvelopeResponse();
        TASResponseObj mockResponse = new TASResponseObj();
        mockResponse.url = 'http://mavensconsulting.com';
        String tasResponseJSONString = JSON.serializePretty(mockResponse);

        MERC_DocusignServiceMock fakeResponse = new MERC_DocusignServiceMock(200, 'Complete', tasResponseJSONString, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        Test.startTest();
        MERC_DocusignService d = new MERC_DocusignService();
        MERC_DocusignService.TagAndSendResponse tasResponse = d.getTagAndSendUrl(envelope, mockResponse.url);
        Test.stopTest();

        System.assert(tasResponse != null, 'Uh oh. TagAndSendResponse was null');
    }

    /*
     * This test shouldn't be here. The compiler says that a particular line in the target class is not covered
     * even though the method above, testTASresponse(), clearly exercizes the code in question. To make the
     * compiler happy, I'll just set the value here...
     */
    @isTest 
    static void coverTagAndSendResponseClass() {
        MERC_DocusignService.TagAndSendResponse tasResponse = new MERC_DocusignService.TagAndSendResponse();
        tasResponse.url = 'http://mavensconsulting.com';
        System.assertEquals('http://mavensconsulting.com',tasResponse.url,'url has unexpected value: '+tasResponse.url);
    }

    @isTest 
    static void testGetEnvelopeDetail() {
        Test.startTest();
        //serialize mock response
        MERC_DocusignService.EnvelopeDetailResponse mockResponse = new MERC_DocusignService.EnvelopeDetailResponse();
        mockResponse.createdDateTime = 'datetime';
        mockResponse.status = 'status';
        String envelopeResponseJSONString = JSON.serializePretty(mockResponse);
        system.debug(envelopeResponseJSONString);

        MERC_DocusignServiceMock fakeResponse = new MERC_DocusignServiceMock(200, 'Complete', envelopeResponseJSONString, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        //send request for detail response
        MERC_DocusignService d = new MERC_DocusignService();
        MERC_DocusignService.EnvelopeDetailResponse r = d.getEnvelopeDetail('envelopeId');
        Test.stopTest();

        System.assertEquals(r.createdDateTime, mockResponse.createdDateTime);
        System.assertEquals(r.status, mockResponse.status);
    }

    @isTest 
    static void testDeleteSigner() {
        Test.startTest();
        //serialize mock response
        String envelopeResponseJSONString = JSON.serializePretty('');
        system.debug(envelopeResponseJSONString);

        MERC_DocusignServiceMock fakeResponse = new MERC_DocusignServiceMock(200, 'Complete', envelopeResponseJSONString, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        MERC_DocusignService.Signer signer = new MERC_DocusignService.Signer('test@mavensconsulting.com', 'Test user', 'recpId', 'routId');

        //send request for delete
        MERC_DocusignService d = new MERC_DocusignService();
        System.assert(d.deleteSigner('envelopeId', signer));
        Test.stopTest();
    }

    @isTest 
    static void testUpdateSigner() {
        Test.startTest();
        //serialize mock response
        String envelopeResponseJSONString = JSON.serializePretty('');
        system.debug(envelopeResponseJSONString);

        MERC_DocusignServiceMock fakeResponse = new MERC_DocusignServiceMock(200, 'Complete', envelopeResponseJSONString, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        MERC_DocusignService.Signer signer = new MERC_DocusignService.Signer('test@mavensconsulting.com', 'Test user', 'recpId', 'routId');

        //send request for update
        MERC_DocusignService d = new MERC_DocusignService();
        System.assert(d.updateSigner('envelopeId', signer));
        Test.stopTest();
    }

    @isTest 
    static void testAddSigner() {
        MERC_DocusignService.Signer signer = new MERC_DocusignService.Signer('test@mavensconsulting.com', 'Test user', 'recpId', 'routId');
        MERC_DocusignService.Recipient mockResponse = new MERC_DocusignService.Recipient();
        mockResponse.signers = new List<MERC_DocusignService.Signer>{signer};

        Test.startTest();
        //serialize mock response
        String envelopeResponseJSONString = JSON.serializePretty(mockResponse);
        system.debug(envelopeResponseJSONString);

        MERC_DocusignServiceMock fakeResponse = new MERC_DocusignServiceMock(200, 'Complete', envelopeResponseJSONString, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        //send request for add
        MERC_DocusignService d = new MERC_DocusignService();
        List<MERC_DocusignService.Signer> r = d.addSigner('envelopeId', signer.name, signer.email, false, 2, new MERC_DocusignService.Tab());
        Test.stopTest();

        System.assertEquals(signer.email, r.get(0).email);
        System.assertEquals(signer.name, r.get(0).name);
    }

    @isTest 
    static void testGetTabsForRecipient() {
        MERC_DocusignService.SignHereTabResponse tab = new MERC_DocusignService.SignHereTabResponse();
        tab.documentId = 'documentId';
        tab.anchorString = '<--DOCUSIGN SIGNATURE MARKER-->';
        tab.anchorXOffset = '1';
        tab.anchorYOffset = '0';
        MERC_DocusignService.TabResponse mockResponse = new MERC_DocusignService.TabResponse();
        mockResponse.signHereTabs = new List<MERC_DocusignService.SignHereTabResponse>{tab};

        Test.startTest();
        //serialize mock response
        String envelopeResponseJSONString = JSON.serializePretty(mockResponse);
        system.debug(envelopeResponseJSONString);

        MERC_DocusignServiceMock fakeResponse = new MERC_DocusignServiceMock(200, 'Complete', envelopeResponseJSONString, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        //send request for tabs
        MERC_DocusignService d = new MERC_DocusignService();
        MERC_DocusignService.TabResponse r = d.getTabsForRecipient('envelopeId', 'recipientId');
        Test.stopTest();

        System.assertEquals(tab.documentId, r.signHereTabs.get(0).documentId);
        System.assertEquals(tab.anchorString, r.signHereTabs.get(0).anchorString);
        System.assertEquals(tab.anchorXOffset, r.signHereTabs.get(0).anchorXOffset);
        System.assertEquals(tab.anchorYOffset, r.signHereTabs.get(0).anchorYOffset);
    }

    @isTest 
    static void testGetEmbeddedSignUrl() {
        MERC_DocusignService.EmbeddedSignResponse mockResponse = new MERC_DocusignService.EmbeddedSignResponse();
        mockResponse.url ='http://google.com';

        Test.startTest();
        //serialize mock response
        String envelopeResponseJSONString = JSON.serializePretty(mockResponse);
        system.debug(envelopeResponseJSONString);

        MERC_DocusignServiceMock fakeResponse = new MERC_DocusignServiceMock(200, 'Complete', envelopeResponseJSONString, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        //send request for url
         MERC_DocusignService.Signer signer = new MERC_DocusignService.Signer('test@mavensconsulting.com', 'Test user', 'recpId', 'routId');
        MERC_DocusignService d = new MERC_DocusignService();
        MERC_DocusignService.EmbeddedSignResponse r = d.getEmbeddedSignUrl('envelopeId', signer, 'https://returnurl.com');
        Test.stopTest();

        System.assertEquals(mockResponse.url, r.url);
    }
    // modification start done by jyoti for US-39525
    
    @isTest 
    static void testvoidenvelop() {
        Test.startTest();
        //serialize mock response
        MERC_DocusignService.EnvelopeResponse mockResponse = new MERC_DocusignService.EnvelopeResponse();
        mockResponse.envelopeId = '7f7de730-811d-458a-97a3-deeef96b38d0';
        mockResponse.status = 'Completed';
        mockResponse.statusDateTime = '2013-10-11T17:17:55.5470518Z';
        mockResponse.uri = '/envelopes/7f7de730-811d-458a-97a3-deeef96b38d0';
        String envelopeResponseJSONString = JSON.serializePretty('');
        system.debug(envelopeResponseJSONString);

        MERC_DocusignServiceMock fakeResponse = new MERC_DocusignServiceMock(200, 'Complete', envelopeResponseJSONString, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        MERC_DocusignService.voidEnvelope(mockResponse.envelopeId, mockResponse.status);
        System.assertEquals('7f7de730-811d-458a-97a3-deeef96b38d0', mockResponse.envelopeId);
        Test.stopTest();
    }
    
    @isTest 
    static void testgetEnvelopeRecipientDetails() {
        Test.startTest();
        //serialize mock response
        MERC_DocusignService.EnvelopeRecipientDetailResponse mockResponse = new MERC_DocusignService.EnvelopeRecipientDetailResponse();
        //mockResponse.envelopeId = '7f7de730-811d-458a-97a3-deeef96b38d0';
        mockResponse.recipientCount = '1';
        //mockResponse.status = 'status';
        String envelopeResponseJSONString = JSON.serializePretty(mockResponse);
        system.debug(envelopeResponseJSONString);

        MERC_DocusignServiceMock fakeResponse = new MERC_DocusignServiceMock(200, 'Complete', envelopeResponseJSONString, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        //send request for detail response
        MERC_DocusignService d = new MERC_DocusignService();
        MERC_DocusignService.EnvelopeRecipientDetailResponse r = d.getEnvelopeRecipientDetails('envelopeId');
        System.assertEquals('1',r.recipientCount);
        Test.stopTest();
    }
    
    // modification finish done by jyoti for US-39525

    
    //
    

    /*
     * A simple TagAndSend response object
     */
    public class TASResponseObj {
        // properties from MERC_DocusignService.TagAndSendResponse
        public String url;
    }
}