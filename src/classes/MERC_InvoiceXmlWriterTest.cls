/** 
* @author Sean Harrison 
* 
* This is a unit test class for MERC_InvoiceXmlWriter.cls which is intended 
* as a trigger on Invoice_MERC__c
*/
@isTest
private class MERC_InvoiceXmlWriterTest {
	
	static List<Account> accounts;
	static List<Meeting_MERC__c> meetings;
	static List<Meeting_Participant_MERC__c> participants;
	static List<Invoice_MERC__c> invoices;
	static List<Invoice_Line_Item_MERC__c> lineItems;
	static Integer numOfLineItems;

	static {
		accounts = MERC_TestFactory.insertAccounts(1);
		meetings = MERC_TestFactory.insertMeetings(1);
		participants = MERC_TestFactory.insertParticipants(meetings[0].Id, accounts);
		invoices = MERC_TestFactory.insertInvoices(participants);

		numOfLineItems = 2;
		for (Meeting_Participant_MERC__c p : participants) {
			p.Services_Rendered_MERC__c = 'Yes';
		}
		update participants;
		lineItems = MERC_TestFactory.insertInvoiceLineItems(invoices[0].Id,numOfLineItems);
	}

	// exercise the addition (and deletion) of xml files to associated content
	@isTest 
	static void createXMLFiles() {
		RecordType rt = [SELECT Id FROM RecordType WHERE Sobjecttype = 'Invoice_Line_Item_MERC__c' AND DeveloperName = 'Consulting_Project_MERC'];
		lineitems = [SELECT Id, Amount_MERC__c, Consulting_Amount_MERC__c, Invoice_MERC__c FROM Invoice_Line_Item_MERC__c WHERE Id in :lineItems];
		for (Invoice_Line_Item_MERC__c item : lineitems) {
			item.Amount_MERC__c = 100;
			// Fulfill conditions for Populate Ad Hoc Amount_MERC workflow
			item.Consulting_Amount_MERC__c = 99;
			item.RecordTypeId = rt.Id;
		}
		update lineItems;

		Test.startTest();
		List<String> invoiceIds = new List<String>();
		invoices = [SELECT Id, Invoice_Attached_MERC__c, Submit_for_Payment_MERC__c FROM Invoice_MERC__c WHERE Id in :invoices];
		for (Invoice_MERC__c invoice : invoices) {
			invoiceIds.add(invoice.Id);
			invoice.Submit_for_Payment_MERC__c = 'Yes';
			invoice.Invoice_Attached_MERC__c = true;  // tell it a PDF is already present.  "Lie to me and tell me everything is all right" - Jonny Lang 		
		}
		update invoices;

		MERC_InvoiceXmlWriter.writeXml(invoiceIds);

		List<ContentVersion> contentVers = new List<ContentVersion>(
			[SELECT ContentDocumentId From ContentVersion WHERE Invoice_MERC__c in :invoices AND Title like '%.xml%']
			);
		System.assert(!contentVers.isEmpty(), 'no XML files in ContentVersion table');
		System.assertEquals(contentVers.size(),invoices.size(),
			'There seem to be different number of xml files ('+contentVers.size()+') and invoices ('+invoices.size()+')');

		// adding another should delete the old one...
		invoices = [SELECT Cost_Center_MERC__c FROM Invoice_MERC__c WHERE Id in :invoices];
		for (Invoice_MERC__c invoice : invoices) {
			invoice.Cost_Center_MERC__c = '7654321';
		}
		update invoices;

		MERC_InvoiceXmlWriter.writeXml(invoiceIds);

		contentVers = [SELECT ContentDocumentId From ContentVersion WHERE Invoice_MERC__c in :invoices AND Title like '%.xml%'];
		System.assert(!contentVers.isEmpty(), 'no XML files in ContentVersion table');
		System.assertEquals(contentVers.size(),invoices.size(),
			'There seem to be different number of xml files ('+contentVers.size()+') and invoices ('+invoices.size()+')');
	}

	// exercise callout in  MERC_InvoiceXmlWriter.execute()
	@isTest 
	static void testCallout() {

		Set<Id> invoiceIds = new Set<Id>();
		for (Invoice_MERC__c invoice : invoices) {
			invoiceIds.add(invoice.Id);
		}

		MERC_XmlWriterRestResource.RemoteXmlWriterResponse response = new MERC_XmlWriterRestResource.RemoteXmlWriterResponse();
		response.success = true;
		response.message = 'XML writer job successfully queued '+invoiceIds.size()+' jobs';	
		String responseString = JSON.serialize(response);	
		MERC_XmlWriterCalloutMock mock = new MERC_XmlWriterCalloutMock(200, 'OK', responseString, null);

		Test.setMock(HttpCalloutMock.class, mock);
		Test.startTest();
		MERC_InvoiceXmlWriter.execute(invoiceIds, UserInfo.getSessionId());
		Test.stopTest();
	}
}