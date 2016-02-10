@isTest
public class MERC_ETSubscriberProcessor_Test {
	
    @isTest
    static void Test_SubProcessor_SingleAccount_SubscriberExists() {
        MERC_ETSubscriberProcessor subProcessor = new MERC_ETSubscriberProcessor();
        List<String> testSubscriberKeys = new List<String>();
        testSubscriberKeys.add('testSubKey');
        
        Test.setMock(HttpCalloutMock.class, new MERC_ETSubscriberProcessorCallout_Mock());
        Test.startTest();
			List<MERC_ETSubscriber> testSubs = subProcessor.RetrieveSubscribers(testSubscriberKeys);
			System.assert(testSubs != null, 'testSubs should not be null');
            System.assert(testSubs.size() != 0, 'testSubs should not be empty');
            
            String result;
            for (MERC_ETSubscriber sub : testSubs) {
	            System.assert(sub.SubscriberKey == 'testSubKey', 'SubscriberKey should be "testSubKey"');
	            System.assert(sub.EmailAddress == 'test@testy.com', 'EmailAddress should be "test@testy.com"');
	            System.assert(sub.LLYSubscriberKey == 'testLLYKey', 'LLYSubscriberKey should be "testLLYKey"');
	            System.assert(sub.SubscriberType == 'testType', 'SubscriberType should be "testType"');
                result = subProcessor.UpdateSubscriberEmail(sub);
                System.assert(result == '', 'Error returned from UpdateSubscriberEmail: ' + result);
            }
        Test.stopTest();
    }
    
    @isTest
    static void Test_SubProcessor_SingleAccount_InvalidEmail() {
        MERC_ETSubscriberProcessor subProcessor = new MERC_ETSubscriberProcessor();
        List<String> testSubscriberKeys = new List<String>();
        testSubscriberKeys.add('testSubKey');
        
        Test.setMock(HttpCalloutMock.class, new MERC_ETSubscriberProcessorCallout_Mock());
        Test.startTest();
            List<MERC_ETSubscriber> testSubs = subProcessor.RetrieveSubscribers(testSubscriberKeys);
            System.assert(testSubs != null, 'testSubs should not be null');
            System.assert(testSubs.size() != 0, 'testSubs should not be empty');
            
            String result;
            List<String> invalidEmails = new List<String>{ 'invalidEmail@test..com', '1@test.com', '@', 'test@@test.test' };
            for (MERC_ETSubscriber sub : testSubs) {
                System.assert(sub.SubscriberKey == 'testSubKey', 'SubscriberKey should be "testSubKey"');
                System.assert(sub.EmailAddress == 'test@testy.com', 'EmailAddress should be "test@testy.com"');
                System.assert(sub.LLYSubscriberKey == 'testLLYKey', 'LLYSubscriberKey should be "testLLYKey"');
                System.assert(sub.SubscriberType == 'testType', 'SubscriberType should be "testType"');
                
                for (String email : invalidEmails) {
                	result = '';
	                sub.EmailAddress = email;
	                System.assert(sub.EmailAddress == email, 'EmailAddress should be ' + email + ', not ' + sub.EmailAddress);
	                System.Debug('BLANK RESULT: ' + result);
	                result = subProcessor.UpdateSubscriberEmail(sub);
	                System.Debug('SHOULD BE NON BLANK RESULT: ' + result);
	                System.assert(result == 'Invalid email', 'Expected "Invalid email" from UpdateSubscriberEmail, got: ' + result);
                }
            }
        Test.stopTest();
    }
    
    @isTest
    static void Test_SubProcessor_SingleAccount_SubscriberDoesntExist() {
        MERC_ETSubscriberProcessor subProcessor = new MERC_ETSubscriberProcessor();
        List<String> testSubscriberKeys = new List<String>();
        testSubscriberKeys.add('testWrongSubKey');
        
        Test.setMock(HttpCalloutMock.class, new MERC_ETSubscriberProcessorCallout_Mock());
        Test.startTest();
            List<MERC_ETSubscriber> testSubs = subProcessor.RetrieveSubscribers(testSubscriberKeys);
            System.assert(testSubs != null, 'testSubs should not be null');
            System.assert(testSubs.size() == 0, 'testSubs should be empty');
        Test.stopTest();
    }
    
    @isTest
    static void Test_SubProcessor_OneBatch_AllSubscribersExist() {
        MERC_ETSubscriberProcessor subProcessor = new MERC_ETSubscriberProcessor();
        List<String> testSubscriberKeys = new List<String>();
        for (Integer i = 0; i < 25; i += 1) {
            testSubscriberKeys.add('testSubKey');
        }
        
        Test.setMock(HttpCalloutMock.class, new MERC_ETSubscriberProcessorCallout_Mock());
        Test.startTest();
            List<MERC_ETSubscriber> testSubs = subProcessor.RetrieveSubscribers(testSubscriberKeys);
            System.assert(testSubs != null, 'testSubs should not be null');
            System.assert(testSubs.size() != 0, 'testSubs should not be empty');
            
            String result;
            for (MERC_ETSubscriber sub : testSubs) {
                System.assert(sub.SubscriberKey == 'testSubKey', 'SubscriberKey should be "testSubKey"');
                System.assert(sub.EmailAddress == 'test@testy.com', 'EmailAddress should be "test@testy.com"');
                System.assert(sub.LLYSubscriberKey == 'testLLYKey', 'LLYSubscriberKey should be "testLLYKey"');
                System.assert(sub.SubscriberType == 'testType', 'SubscriberType should be "testType"');
                result = subProcessor.UpdateSubscriberEmail(sub);
                System.assert(result == '', 'Error returned from UpdateSubscriberEmail: ' + result);
            }
        Test.stopTest();
    }
    
    @isTest
    static void Test_SubProcessor_OneBatch_SomeSubscribersExist() {
        MERC_ETSubscriberProcessor subProcessor = new MERC_ETSubscriberProcessor();
        List<String> testSubscriberKeys = new List<String>();
        for (Integer i = 0; i < 13; i += 1) {
            testSubscriberKeys.add('testSubKey');
        }
        for (Integer i = 0; i < 12; i += 1) {
            testSubscriberKeys.add('testWrongSubKey');
        }
        
        Test.setMock(HttpCalloutMock.class, new MERC_ETSubscriberProcessorCallout_Mock());
        Test.startTest();
            List<MERC_ETSubscriber> testSubs = subProcessor.RetrieveSubscribers(testSubscriberKeys);
            System.assert(testSubs != null, 'testSubs should not be null');
            System.assert(testSubs.size() != 0, 'testSubs should not be empty');
            
            String result;
            for (MERC_ETSubscriber sub : testSubs) {
                System.assert(sub.SubscriberKey == 'testSubKey', 'SubscriberKey should be "testSubKey"');
                System.assert(sub.EmailAddress == 'test@testy.com', 'EmailAddress should be "test@testy.com"');
                System.assert(sub.LLYSubscriberKey == 'testLLYKey', 'LLYSubscriberKey should be "testLLYKey"');
                System.assert(sub.SubscriberType == 'testType', 'SubscriberType should be "testType"');
                result = subProcessor.UpdateSubscriberEmail(sub);
                System.assert(result == '', 'Error returned from UpdateSubscriberEmail: ' + result);
            }
        Test.stopTest();
    }
    
    @isTest
    static void Test_SubProcessor_OneBatch_NoSubscribersExist() {
        MERC_ETSubscriberProcessor subProcessor = new MERC_ETSubscriberProcessor();
        List<String> testSubscriberKeys = new List<String>();
        for (Integer i = 0; i < 25; i += 1) {
            testSubscriberKeys.add('testWrongSubKey');
        }
        
        Test.setMock(HttpCalloutMock.class, new MERC_ETSubscriberProcessorCallout_Mock());
        Test.startTest();
            List<MERC_ETSubscriber> testSubs = subProcessor.RetrieveSubscribers(testSubscriberKeys);
            System.assert(testSubs != null, 'testSubs should not be null');
            System.assert(testSubs.size() == 0, 'testSubs should be empty');
        Test.stopTest();
    }
}