@isTest
private class MERC_DocusignEmbeddedSignatureSrvcTest {

	@isTest static void test_method_one() {
		RestRequest req = new RestRequest();
    	RestResponse res = new RestResponse();

    	req.requestURI = 'https://salesforce.com/001000000000123';
    	req.httpMethod = 'GET';
    	RestContext.request = req;
    	RestContext.response = res;

		MERC_DocusignEmbeddedSignatureService.doGET();
	}
}