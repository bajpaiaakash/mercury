@isTest
private class DocusignServiceTest {
	
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

        DocusignService.LoginAccount loginAccountObject = new DocusignService.LoginAccount(
        	'A test name', 
        	'a test account id', 
        	'a baseurl', 
        	'true', 
        	'my username', 
        	'my userid', 
        	'my email', 
        	''
        );
        DocusignService.LoginInformation loginInformation = new DocusignService.LoginInformation();
        loginInformation.loginAccounts = new List<DocusignService.LoginAccount>{ loginAccountObject};

        String loginAccountResponse = JSON.serializePretty(loginInformation);
        system.debug(loginAccountResponse);

        DocusignServiceMock fakeResponse = new DocusignServiceMock(200, 'Complete', loginAccountResponse, null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);
        DocusignService d = new DocusignService();
        d.login();
        Test.stopTest();

        System.assertEquals(1, d.loginInfo.loginAccounts.size());
        System.assertEquals(loginAccountObject.email, d.loginInfo.loginAccounts[0].email);
        System.assertEquals(loginAccountObject.userName, d.loginInfo.loginAccounts[0].userName);
    }

}