@isTest
private class Test_ETAuthorizer {
    public static testmethod void test_ETAuthorizer_Initialization() {
        et4ae5__configuration__c etConfig = TestUtils.CreateEtConfig();
        etConfig.et4ae5__username__c = 'testusername';
        etConfig.et4ae5__password__c = 'testpassword';
        etConfig.et4ae5__auth_api_url__c = 'www.testauthurl.com';
        etConfig.et4ae5__Root_Rest_API_URL__c = 's1.qa1';
        insert etConfig;

        List<Meeting_MERC__c> meetings = TestUtils.CreateMeetings(1);
        for (Meeting_MERC__c m : meetings) {
            m.City_of_Meeting_MERC__c = 'test city';
            m.Preferred_Venue_MERC__c = 'test venue';
            m.Date_of_Event_MERC__c = Date.today();
            m.End_Date_of_Event_MERC__c = Date.today().addDays(5);
            m.Event_Id_MERC__c = 'test id';
        }
        insert meetings;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Mock_ETAuthorizerCallout());

            ETAuthorizer eta = new ETAuthorizer();

            System.assertNotEquals(null, eta.soapAuthToken);
            System.assertNotEquals(null, eta.fuelAuthToken);
        Test.stopTest();
    }
}