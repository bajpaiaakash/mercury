/** 
 * @author Joseph Ferraro, Mavens Consulting
 * 
 */
@isTest
private class MERC_XmlWriterTest {
	
	@isTest static void test_invalid_request() {
		MERC_XmlWriterRestResource.RemoteXmlWriterResponse response = new MERC_XmlWriterRestResource.RemoteXmlWriterResponse();
		response.success = false;
		response.message = 'Id value  is not valid for the Invoice_MERC__c standard controller';	
		String responseString = JSON.serialize(response);	
		MERC_XmlWriterCalloutMock invalidResponse = new MERC_XmlWriterCalloutMock(200, 'OK', responseString, null);
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, invalidResponse);
		MERC_InvoiceXmlWriter.execute(new Set<Id>{UserInfo.getUserId()}, 'a bad sessionid');
		Test.stopTest();
	}
}