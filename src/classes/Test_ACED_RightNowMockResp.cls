/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=false)
Global class Test_ACED_RightNowMockResp implements HttpCalloutMock{

    // Implement this interface method
	global HTTPResponse respond(HTTPRequest req) {
				 
		// Optionally, only send a mock response for a specific endpoint
		// and method.
		System.assertEquals('POST', req.getMethod());
		// Create a fake response
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'text/xml');
		String content = '<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\">'+
						 '  <soapenv:Header/>'+
						 '  <soapenv:Body>'+
						 '     <n0:RunAnalyticsReportResponse xmlns:n0="urn:messages.ws.rightnow.com/v1_2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
						 '        <n0:CSVTableSet>'+
						 '           <n0:CSVTables>'+
						 '              <n0:CSVTable>'+
						 '                 <n0:Name>ace_dd_mailing_statistics</n0:Name>'+
						 '                 <n0:Columns>Year,Month,Name,Sent,Delivered,Opened,Total Clicked,Bounced,Unsubscribed</n0:Columns>'+
						 '                 <n0:Rows>'+
						 '                    <n0:Row>2014,03,Lilly Februray Oncology Adhoc,1701,1659,336,122,42,1</n0:Row>'+
						 '                    <n0:Row>2014,03,ZypAdhera-invitation|DE-782709,391,387,114,103,4,0</n0:Row>'+
						 '                 </n0:Rows>'+
						 '              </n0:CSVTable>'+
						 '           </n0:CSVTables>'+
						 '       </n0:CSVTableSet>'+
						 '     </n0:RunAnalyticsReportResponse>'+
						 ' </soapenv:Body>'+
						 '</soapenv:Envelope>';
		res.setBody(content);
		res.setStatusCode(200);
		return res;
	}
}