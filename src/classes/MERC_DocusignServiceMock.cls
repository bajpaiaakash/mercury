@isTest
public class MERC_DocusignServiceMock implements HttpCalloutMock {
	protected Integer code;
	protected String status;
	protected String bodyAsString;
	protected Blob bodyAsBlob;
	protected Map<String, String> responseHeaders;

	public MERC_DocusignServiceMock(Integer code, String status, String body,
                                     Map<String, String> responseHeaders) {
		this.code = code;
		this.status = status;
		this.bodyAsString = body;
		this.bodyAsBlob = null;
		this.responseHeaders = responseHeaders;
	}

	public MERC_DocusignServiceMock(Integer code, String status, Blob body,
                                     Map<String, String> responseHeaders) {
		this.code = code;
		this.status = status;
		this.bodyAsBlob = body;
		this.bodyAsString = null;
		this.responseHeaders = responseHeaders;
	}

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse();
		resp.setStatusCode(code);
		resp.setStatus(status);

		if (req.getHeader('Content-Type').contains('multipart/form-data')) {
			if (bodyAsBlob != null) {
				resp.setBodyAsBlob(bodyAsBlob);
			} else {
				resp.setBody(bodyAsString);
			}

			if (responseHeaders != null) {
			   	for (String key : responseHeaders.keySet()) {
					resp.setHeader(key, responseHeaders.get(key));
			   	}
			}
		} else if (req.getBody().contains('returnUrl')) {
			resp.setBody('{ "url" : "http://google.com" }');
		}

		return resp;
    }
}