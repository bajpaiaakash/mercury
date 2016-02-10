@isTest
private class MERC_ETCallControlTest {
	
	@isTest static void test_getExactTargetEmails() {

		insertConfig();


		Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator());
		Test.startTest();

		MERC_ETCallControl callControl = new MERC_ETCallControl();
		List<MERC_ETObject.emailFolder> emailFolders = callControl.getExactTargetEmails(null);

		Test.stopTest();
	}

	@isTest static void test_getClassifications() {

		insertConfig();

		Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator());
		Test.startTest();

		MERC_ETCallControl callControl = new MERC_ETCallControl();
		List<MERC_ETObject.SendClassification> sendClassifications = callControl.getClassifications(null);

		Test.stopTest();
	}

	@isTest static void test_getSenders() {

		insertConfig();

		Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator());
		Test.startTest();

		MERC_ETCallControl callControl = new MERC_ETCallControl();
		List<MERC_ETObject.SenderProfile> senderProfiles = callControl.getSenders(null, null);

		Test.stopTest();
	}

	@isTest static void test_httpResponses() {
		insertConfig();

		Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator());
		Test.startTest();

		MERC_ETCallControl callControl = new MERC_ETCallControl();
		HttpResponse res0 = callControl.callEmailFolders(null, null, null);
		HttpResponse res1 = callControl.callEmails(null, null, null);

		Test.stopTest();
	}

	static void insertConfig() {
		et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        etConfig.et4ae5__username__c = 'testusername';
        etConfig.et4ae5__password__c = 'testpassword';
        etConfig.et4ae5__auth_api_url__c = 'www.testauthurl.com/Auth.svc';
        etConfig.et4ae5__root_rest_api_url__c = 'www.testresturl.com';
        etConfig.et4ae5__url_root__c = 'urlroot';
        insert etConfig;
	}
}