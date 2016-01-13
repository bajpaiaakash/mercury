/**
* MERC_XmlWriterRestResource 
* Created By: Mavens Consulting 
*/
@RestResource(urlMapping='/MERC/Invoice/XmlWriter')
global with sharing class MERC_XmlWriterRestResource {
	
	@HttpPost
	global static RemoteXmlWriterResponse doPost(List<String> invoiceIds) {
		RemoteXmlWriterResponse response = new RemoteXmlWriterResponse();
		try {
			MERC_InvoiceXmlWriter.writeXml(invoiceIds);
	        response.success = true;
	        response.message = 'XML writer job successfully queued '+invoiceIds.size()+' jobs';
		} catch (Exception e) {
			response.success = false;
			response.message = e.getMessage();
		}
		return response;
	}

	global class RemoteXmlWriterResponse {
		public Boolean success;
		public String message;
	}
}