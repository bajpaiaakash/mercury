/**
 * @author Sean Harrison
 *
 * Mocks callouts to the Customer Search Tool Endpoint
 */
@isTest
global class GLBL_CustomerSearchToolServiceMock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;


	global GLBL_CustomerSearchToolServiceMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    global GLBL_CustomerSearchToolServiceMock() {
		GLBL_CustomerSearchToolService.AccessTokenResponse tokenRespObj = new GLBL_CustomerSearchToolService.AccessTokenResponse();
		tokenRespObj.access_token = 'To sleep... perchance to dream';
        String tokenResponse = JSON.serialize(tokenRespObj);

        this.code = 200;
        this.status = 'OK';
        this.body = tokenResponse;
        this.responseHeaders = new Map<String, String>{'Content-Type'=>'application/json'};
    }

	global HTTPResponse respond(HttpRequest req) {
        HttpResponse resp = new HttpResponse();
		resp.setStatusCode(code);
		resp.setStatus(status);
		resp.setBody(body);

		if (responseHeaders != null) {
		   	for (String key : responseHeaders.keySet()) {
				resp.setHeader(key, responseHeaders.get(key));
		   	}
		}

        return resp;
	}

	global void setBody(String newBody) {
		this.body = newBody;
	}
}