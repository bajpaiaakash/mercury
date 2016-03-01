@isTest
private class MERC_AccountEmailUpdateHandlerTest {
    @testSetup static void prepareConfiguration(){
        MERC_MarketingCloudTestUtility.insertConfiguration(true);
        MERC_MarketingCloudTestUtility.insertBusinessUnit();
        MERC_MarketingCloudTestUtility.insertSettings();
    }

	@isTest static void test_AccountEmailUpdated_UpdatesInMarketingCloud() {
		
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        System.runAs(testUser){
            MERC_MarketingCloudTestUtility.adjustTime();
           
            
            List<Account> subscriberAccounts = MERC_MarketingCloudTestUtility.getDefaultSubscriberAccounts();
            insert subscriberAccounts;

            List<Id> personContactIds = MERC_MarketingCloudTestUtility.getPersonContactIds(subscriberAccounts);
            subscriberAccounts = MERC_MarketingCloudTestUtility.queryPersonAccounts(subscriberAccounts);

            List<MERC_MarketingCloudClient.Subscriber> subscribers = 
                MERC_MarketingCloudTestUtility.getPersonContactSubscribers(personContactIds);

            List<MERC_MarketingCloudClient.Subscriber> expectedSubscribers = 
                MERC_MarketingCloudTestUtility.getExpectedSubscribers(subscriberAccounts);

            for(Account subscriberAccount : subscriberAccounts){
                subscriberAccount.PersonEmail = 'updated' + subscriberAccount.PersonEmail;
            }

            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
            mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockSubscribersRequest(subscribers, personContactIds));  
            for(MERC_MarketingCloudClient.Subscriber subscriber : expectedSubscribers){
                mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockSubscriberUpdateRequest(
                    subscriber));
            }
            Test.setMock(HttpCalloutMock.class, mockResponseService);
            Test.startTest();
            update subscriberAccounts;
            Test.stopTest();
        }
	}
	
	@isTest static void test_AccountEmailNotUpdated_NoMarketingCloudCallsNeeded() {
		
        User testUser = MERC_MarketingCloudTestUtility.insertUser();
        System.runAs(testUser){
            MERC_MarketingCloudTestUtility.adjustTime();
                
            List<Account> subscriberAccounts = MERC_MarketingCloudTestUtility.getDefaultSubscriberAccounts();
            insert subscriberAccounts;

            List<Id> personContactIds = MERC_MarketingCloudTestUtility.getPersonContactIds(subscriberAccounts);
            subscriberAccounts = MERC_MarketingCloudTestUtility.queryPersonAccounts(subscriberAccounts);

            Test.startTest();
            update subscriberAccounts;
            Test.stopTest();
        }
	}
	
}