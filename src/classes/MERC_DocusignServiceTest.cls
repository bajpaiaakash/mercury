@isTest
private class MERC_DocusignServiceTest {
	
	static {
		Docusign_Settings_EVNT__c settings = new Docusign_Settings_EVNT__c();
		settings.Name = 'default';
		settings.Account_ID_EVNT_MVN__c = '12345';
		settings.Integrator_Key_EVNT_MVN__c = '12345';
		settings.Password_EVNT_MVN__c = 'foo';
		settings.Username_EVNT_MVN__c = 'bar';
		insert settings;
	}

	@isTest static void testLoginAccount() {
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
        loginInformation.loginAccounts = new List<MERC_DocusignService.LoginAccount>{ loginAccountObject};

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

    @isTest static void testSendToSigners() {
        Test.startTest();
        
        //generate signers
        List<Account> signingAccounts = MERC_TestFactory.insertAccounts(2);
        List<MERC_DocusignService.RequiredSigner> requiredSigners = new List<MERC_DocusignService.RequiredSigner>();
        for (Integer i = 0; i < signingAccounts.size(); i++) {
            MERC_DocusignService.RequiredSigner signer = new MERC_DocusignService.RequiredSigner();
            signer.acc = signingAccounts.get(i);
            signer.order = i+1;
            requiredSigners.add(signer);
        }

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
        
        //send requesr for signature
        MERC_DocusignService d = new MERC_DocusignService();
        MERC_DocusignService.EnvelopeResponse r = d.requestSignature(requiredSigners, 'this is the document to sign');
        Test.stopTest();

        system.debug(r);
        System.assertEquals(r.envelopeId, mockResponse.envelopeId);
        System.assertEquals(r.status, mockResponse.status);
    }

}