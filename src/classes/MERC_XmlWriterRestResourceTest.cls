@isTest
private class MERC_XmlWriterRestResourceTest {
	
	static List<Account> accounts;
	static List<Meeting_MERC__c> meetings;
	static List<Meeting_Participant_MERC__c> participants;
	static List<Invoice_MERC__c> invoices;

	static {
		accounts = MERC_TestFactory.insertAccounts(1);
		meetings = MERC_TestFactory.insertMeetings(1);
		participants = MERC_TestFactory.insertParticipants(meetings[0].Id, accounts);
		invoices = MERC_TestFactory.insertInvoices(participants);
	}

	@isTest static void assertGoodRequest() {
		List<String> invoiceIds = new List<String>();
		for (Invoice_MERC__c i : invoices)
			invoiceIds.add(i.Id);
		MERC_XmlWriterRestResource.RemoteXmlWriterResponse response = MERC_XmlWriterRestResource.doPost(invoiceIds);
		system.assertEquals(true, response.success);
	}

	@isTest static void assertBadRequest() {
		List<String> invoiceIds = new List<String>{ 'foo' };
		MERC_XmlWriterRestResource.RemoteXmlWriterResponse response = MERC_XmlWriterRestResource.doPost(invoiceIds);
		system.assertEquals(false, response.success);
	}
	
}