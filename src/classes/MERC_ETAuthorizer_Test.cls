@isTest
private class MERC_ETAuthorizer_Test {
    public static testmethod void test_ETAuthorizer_SuccessfulSoapAuth() {
        et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        etConfig.et4ae5__username__c = 'testusername';
        etConfig.et4ae5__password__c = 'testpassword';
        etConfig.et4ae5__auth_api_url__c = 'www.testauthurl.com/Auth.svc';
        etConfig.et4ae5__Root_Rest_API_URL__c = 's1.qa1';
        insert etConfig;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MERC_ETAuthorizerCallout_Mock());

            MERC_ETAuthorizer eta = new MERC_ETAuthorizer();

            System.assertNotEquals(null, eta.soapAuthToken);
        Test.stopTest();
    }

    public static testmethod void test_ETAuthorizer_SuccessfulFuelAuth_S1QA1() {
        et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        etConfig.et4ae5__username__c = 'testusername';
        etConfig.et4ae5__password__c = 'testpassword';
        etConfig.et4ae5__auth_api_url__c = 'www.testauthurl.com/Auth.svc';
        etConfig.et4ae5__Root_Rest_API_URL__c = 's1.qa1';
        insert etConfig;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MERC_ETAuthorizerCallout_Mock());

            MERC_ETAuthorizer eta = new MERC_ETAuthorizer();

            System.assertNotEquals(null, eta.fuelAuthToken);
        Test.stopTest();
    }

    public static testmethod void test_ETAuthorizer_SuccessfulFuelAuth_S1QA2() {
        et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        etConfig.et4ae5__username__c = 'testusername';
        etConfig.et4ae5__password__c = 'testpassword';
        etConfig.et4ae5__auth_api_url__c = 'www.testauthurl.com/Auth.svc';
        etConfig.et4ae5__Root_Rest_API_URL__c = 's1.qa2';
        insert etConfig;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MERC_ETAuthorizerCallout_Mock());

            MERC_ETAuthorizer eta = new MERC_ETAuthorizer();

            System.assertNotEquals(null, eta.fuelAuthToken);
        Test.stopTest();
    }

    public static testmethod void test_ETAuthorizer_SuccessfulFuelAuth_Prod() {
        et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        etConfig.et4ae5__username__c = 'testusername';
        etConfig.et4ae5__password__c = 'testpassword';
        etConfig.et4ae5__auth_api_url__c = 'www.testauthurl.com/Auth.svc';
        etConfig.et4ae5__Root_Rest_API_URL__c = 'productionurl';
        insert etConfig;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MERC_ETAuthorizerCallout_Mock());

            MERC_ETAuthorizer eta = new MERC_ETAuthorizer();

            System.assertNotEquals(null, eta.fuelAuthToken);
        Test.stopTest();
    }
}