/**
* MERC_XmlWriterRestResourceTest
* Created By: Mavens Consulting
* Description: Tests the MERC_XmlWriterRestResource class.
*/
@isTest
private class MERC_XmlWriterRestResourceTest {
    
    static List<Account> accounts;
    static List<Meeting_MERC__c> meetings;
    static List<Meeting_Participant_MERC__c> participants;
    static List<Invoice_MERC__c> invoices;
    

    @isTest static void assertGoodRequest() {
    MERC_TriggerHandlerStateManager.deactivateAll();
    accounts = MERC_TestFactory.insertAccounts(1);
        meetings = MERC_TestFactory.insertMeetings(1);
        participants = MERC_TestFactory.insertParticipants(meetings[0].Id, accounts);
        invoices = MERC_TestFactory.insertInvoices(participants);
        List<String> invoiceIds = new List<String>();
        for (Invoice_MERC__c i : invoices)
            invoiceIds.add(i.Id);
            Test.startTest();   
        MERC_XmlWriterRestResource.RemoteXmlWriterResponse response = MERC_XmlWriterRestResource.doPost(invoiceIds);
        Test.stopTest();
        //system.assertEquals(true, response.success);
    }

    @isTest static void assertBadRequest() {
        MERC_TriggerHandlerStateManager.deactivateAll();
        accounts = MERC_TestFactory.insertAccounts(1);
        meetings = MERC_TestFactory.insertMeetings(1);
        participants = MERC_TestFactory.insertParticipants(meetings[0].Id, accounts);
        invoices = MERC_TestFactory.insertInvoices(participants);
        List<String> invoiceIds = new List<String>{ 'foo' };
        Test.startTest();                
        MERC_XmlWriterRestResource.RemoteXmlWriterResponse response = MERC_XmlWriterRestResource.doPost(invoiceIds);
        system.assertEquals(false, response.success);
       Test.stopTest();
    }
    
}