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

	public void handle() {
		if (Trigger.isAfter) {
			if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
		    	Set<Id> invoiceIds = new Set<Id>();
		    	for (Invoice_MERC__c invoice : (List<Invoice_MERC__c>)Trigger.new) {
		    		if (invoice.Submit_for_Payment_MERC__c == 'Yes') invoiceIds.add(invoice.Id);
		    	}
		    	if (invoiceIds.size() > 0)
		    		if (!Test.isRunningTest()) execute(invoiceIds, UserInfo.getSessionId());
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
     	req.setBody(requestBody);

		String authorizationHeader = 'Bearer ' + sid;
		system.debug(authorizationHeader);
		req.setHeader('Authorization', authorizationHeader);
		req.setHeader('Content-Type', 'application/json');
		Http http = new Http();
		HTTPResponse res = http.send(req);
		System.debug(res.getBody());
	}

	public static void writeXml(List<String> invoiceIds) {
		// RestRequest req = RestContext.request;
        // RestResponse res = RestContext.response;
       	String filePrefix = '';
        Mercury_Settings_MERC__c settings = Mercury_Settings_MERC__c.getOrgDefaults();
		if (settings.Id != null) {
			if (settings.Invoice_File_Prefix_MERC__c != null) filePrefix = settings.Invoice_File_Prefix_MERC__c;
		}

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
        delete [SELECT ID FROM ContentDocument WHERE Id in :contentDocumentIds];
	}
}