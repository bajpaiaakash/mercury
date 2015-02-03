/** 
* @author Joe Ferraro 
* 
* This is a mock callout class for MERC_XmlWriterTest and MERC_InvoiceXmlWriterTest
*/
@isTest
public class MERC_XmlWriterCalloutMock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public MERC_XmlWriterCalloutMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    public HTTPResponse respond(HTTPRequest req) {
        //System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(this.body);
        res.setStatusCode(this.code);

        if(this.code == 999) {
            throw new MERC_Exception('Expected exception');
        }

        return res;
    }

}