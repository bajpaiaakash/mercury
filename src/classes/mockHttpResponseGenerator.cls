/*
 Allows mock responses to http callouts in unit tests.

 2014-01-06 Andrew Schilling    - Allow configurable response body
*/
@isTest
global class mockHttpResponseGenerator implements httpCalloutMock
{
    global String myBody;
    
    global mockHttpResponseGenerator() {
        myBody = '{"objectId":"1","key":"test","id":"12321312","name":"hello","integrated":true,"userScoped":true,"jobId":1}';
    }
    
    global mockHttpResponseGenerator(String bodyString) {
        myBody = bodyString;
        System.debug('myBody constructor : ' + myBody);
    }
    
    global httpResponse respond(httpRequest req) {
        httpResponse res = new httpResponse();
        res.setHeader('Content-Type', 'application/json');
        System.debug('myBody : ' + myBody);
        string bodyString = myBody;
        //string bodyString='{"objectId":"1","key":"test","id":"12321312","name":"hello","integrated":true,"userScoped":true,"jobId":1}';
        //string bodyString='{"objectId":"1"}"id"15646546546546"key"<a:AccessToken>564654654654</a:AccessToken><a:RefreshToken>564654654654</a:RefreshToken>"id":"12321312","name":"hello"';
        //bodyString+='"jobId":1312321332,}{"id":"123123"}';
        res.setBody(bodyString);
        res.setStatusCode(200);
        return res;
    }
}