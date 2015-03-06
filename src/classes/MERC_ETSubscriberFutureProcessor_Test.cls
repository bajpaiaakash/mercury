@isTest
public class MERC_ETSubscriberFutureProcessor_Test {
    
    @isTest
    static void Test_SubFutureProcessor_SingleAccount() {
        MERC_ETSubscriberFutureProcessor subFutureProcessor = new MERC_ETSubscriberFutureProcessor();
        
        List<Account> testAccts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType('PersonAccount', 1);
        insert testAccts;
        
        List<Id> acctIds = new List<Id>(new Map<Id, Account>([SELECT Id FROM Account]).keySet());
        
        Test.setMock(HttpCalloutMock.class, new MERC_ETSubscriberProcessorCallout_Mock());
        Test.startTest();
            subFutureProcessor.batchFutureEmailUpdates(acctIds);
        Test.stopTest();
    }
    
    @isTest
    static void Test_SubFutureProcessor_OneBatch() {
        MERC_ETSubscriberFutureProcessor subFutureProcessor = new MERC_ETSubscriberFutureProcessor();
        
        List<Account> testAccts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType('PersonAccount', 25);
        insert testAccts;
        
        List<Id> acctIds = new List<Id>(new Map<Id, Account>([SELECT Id FROM Account]).keySet());
        
        Test.setMock(HttpCalloutMock.class, new MERC_ETSubscriberProcessorCallout_Mock());
        Test.startTest();
            subFutureProcessor.batchFutureEmailUpdates(acctIds);
        Test.stopTest();
    }
    
    @isTest
    static void Test_SubFutureProcessor_MultipleBatches() {
        MERC_ETSubscriberFutureProcessor subFutureProcessor = new MERC_ETSubscriberFutureProcessor();
        
        List<Account> testAccts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType('PersonAccount', 40);
        insert testAccts;
        
        List<Id> acctIds = new List<Id>(new Map<Id, Account>([SELECT Id FROM Account]).keySet());
        
        Test.setMock(HttpCalloutMock.class, new MERC_ETSubscriberProcessorCallout_Mock());
        Test.startTest();
            subFutureProcessor.batchFutureEmailUpdates(acctIds);
        Test.stopTest();
    }
    
}