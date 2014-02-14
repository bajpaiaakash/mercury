/**
 * @author Joseph Ferraro
 *
 * Mock class for delete notify service found on the Real-Time Integration listener
 */

@isTest
public class MERC_DeleteNotifyMock implements HttpCalloutMock {
	
	protected Integer code;
	protected String status;
	protected String bodyAsString;
	protected Blob bodyAsBlob;
	protected Map<String, String> responseHeaders;

	public MERC_DeleteNotifyMock(Integer code, String status, String body,
                                     Map<String, String> responseHeaders) {
		this.code = code;
		this.status = status;
		this.bodyAsString = body;
		this.bodyAsBlob = null;
		this.responseHeaders = responseHeaders;
	}

	public MERC_DeleteNotifyMock() {
		this.code = 200;
		this.status = 'OK';
		this.bodyAsString = 'body';
		this.bodyAsBlob = null;
		this.responseHeaders = null;
	}

	public HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse();
		resp.setStatusCode(code);
		resp.setStatus(status);
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
		return resp;
    }
	
}