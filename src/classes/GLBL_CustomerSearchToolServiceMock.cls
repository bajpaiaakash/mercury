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
        GLBL_CustomerSearchToolService.SearchIdResult searchIdResult = new GLBL_CustomerSearchToolService.SearchIdResult();

        searchIdResult.Search_Id='01234556789';
        this.code = 200;
        this.status = 'OK';
        this.body = JSON.serialize(searchIdResult);
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