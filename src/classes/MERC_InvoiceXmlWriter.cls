/* MERC_InvoiceXmlWriter
 *
 * Author: Sean Harrison
 *
 * To be run via a trigger on Mercury invoice records. When submitted for payment, an XML file reflecting
 * this invoice's data & related line items is created in a future call to MERC_XmlWriterRestResource
 * and based on the template at MERC_InvoiceAFIXML.page.
 * <br />
 * Be sure to add a self-referencing Remote Site Setting so the org knows it can callout to itself.
 */ 
public with sharing class MERC_InvoiceXmlWriter implements GLBL_TriggerHandler.HandlerInterface {

	private final Id ACTIVE_INVOICE = [SELECT Id FROM RecordType WHERE SObjectType = 'Invoice_MERC__c' AND DeveloperName = 'Invoice_MERC' LIMIT 1].Id;
	private final Id ACTIVE_CNOTE = [SELECT Id FROM RecordType WHERE SObjectType = 'Invoice_MERC__c' AND DeveloperName = 'Credit_Note_MERC' LIMIT 1].Id;

	public Boolean isActive() {
	    return true;
	}

	public void handle() {
		if (Trigger.isAfter) {
			if (Trigger.isInsert || Trigger.isUpdate) {
		    	Set<Id> invoiceIds = new Set<Id>();
		    	for (Invoice_MERC__c invoice : (List<Invoice_MERC__c>)Trigger.new) {
		    		Boolean createXML = invoice.Submit_for_Payment_MERC__c == 'Yes';
		    		if (Trigger.isUpdate) {
			    		Invoice_MERC__c oldInvoice = (Invoice_MERC__c) Trigger.oldMap.get(invoice.Id);
		    			createXML = createXML && 
		    				oldInvoice.Submitted_for_Payment_Date_MERC__c == null && 
		    				(oldInvoice.RecordTypeId == ACTIVE_INVOICE || oldInvoice.RecordTypeId == ACTIVE_CNOTE);
		    		}
		    		if (createXML) invoiceIds.add(invoice.Id);
		    	}
		    	if (invoiceIds.size() > 0)
		    		if (!Test.isRunningTest()) 
		    			execute(invoiceIds, UserInfo.getSessionId());
		   	}
		}
	}

	@Future(callout=true)
	public static void execute(Set<Id> invoiceIds, String sid) { 
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeObjectField('invoiceIds', invoiceIds);
		gen.writeEndObject();

		String requestBody = gen.getAsString();

		HttpRequest req = new HttpRequest();
     	req.setEndpoint('https://' + System.URL.getSalesforceBaseURL().getHost()+'/services/apexrest/MERC/Invoice/XmlWriter');
     	req.setMethod('POST');
     	req.setTimeout(120000);
     	req.setBody(requestBody);

		String authorizationHeader = 'Bearer ' + sid;
		system.debug(authorizationHeader);
		req.setHeader('Authorization', authorizationHeader);
		req.setHeader('Content-Type', 'application/json');
		Http http = new Http();
		HTTPResponse res;
		try {
			res = http.send(req);  // TODO - trap timeouts and other errors and let admin know
			System.debug(res.getBody());
		} catch (Exception e) {
			String msg = 'Invoice submitted but XML data was not created successfully. Invoice records affected: '+invoiceIds;
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			List<String> toAddresses = new List<String>{'mercury@mavensconsulting.com'};
			mail.setToAddresses(toAddresses);
			mail.setSubject('SAP Invoice error');
			mail.setHtmlBody(msg+ '<br/><br/>Errors:<br />'+e);
			mail.setPlainTextBody(msg+ '\n\nErrors:\n\n'+e);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });			
		}
	}

	public static void writeXml(List<String> invoiceIds) {
		// RestRequest req = RestContext.request;
        // RestResponse res = RestContext.response;
       	String filePrefix = '';
        Mercury_Settings_MERC__c settings = Mercury_Settings_MERC__c.getOrgDefaults();
		if (settings.Id != null && settings.Invoice_File_Prefix_MERC__c != null) filePrefix = settings.Invoice_File_Prefix_MERC__c;

       	Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Invoice_MERC' And SobjectType = 'ContentVersion'].Id;
       	Id workspaceId = [SELECT Id FROM ContentWorkspace WHERE Name = 'Mercury' Limit 1].Id;
       	List<ContentVersion> xmlFiles = new List<ContentVersion>();
       	for (String invoiceId : invoiceIds) {
       		PageReference xmlFile = Page.MERC_InvoiceAFIXML;
       		xmlFile.getParameters().put('id', invoiceId);
       		Blob b = (!Test.isRunningTest()) ? xmlFile.getContent() : Blob.valueOf('<blah></blah>');
       		
       		ContentVersion invoiceXml = new ContentVersion();
       		invoiceXml.Title = filePrefix+invoiceId.substring(0, 15)+'.xml';
       		invoiceXml.PathOnClient = filePrefix+invoiceId.substring(0, 15)+'.xml';
       		invoiceXml.FirstPublishLocationId = workspaceId;
       		invoiceXml.Document_Type_MERC__c = 'Invoices';  // TODO - Custom Settings! Align with LOOP
       		invoiceXml.RecordTypeId = recordTypeId;
       		invoiceXml.Invoice_MERC__c = invoiceId;
       		invoiceXml.VersionData = b; 
       		xmlFiles.add(invoiceXml);
       	}
        insert xmlFiles;

        //delete any other xml-related documents on this invoice
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentVersion cv : [SELECT ContentDocumentId From ContentVersion WHERE Invoice_MERC__c in :invoiceIds AND Title like '%.xml%' AND Id not in :xmlFiles])
            contentDocumentIds.add(cv.ContentDocumentId);
        try {
        	delete [SELECT ID FROM ContentDocument WHERE Id in :contentDocumentIds];
        } catch (Exception e) {
        	System.debug('\n\n\nMERC_InvoiceXmlWriter - '+e.getMessage()+'\n\n\n\n');
        }
	}
}