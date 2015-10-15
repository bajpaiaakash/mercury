/*
 Allows mock responses to http callouts in unit tests.

 2014-01-06 Andrew Schilling    - Allow configurable response body
*/
@isTest
global class MERC_ETMockHttpResponseGenerator implements httpCalloutMock
{
    global String myBody;

    global Map<String, String> endpointBasedBodies;
    
    global MERC_ETMockHttpResponseGenerator() {
        myBody = '{"objectId":"1","key":"test","id":"12321312","name":"hello","integrated":true,"userScoped":true,"jobId":1}';
        endpointBasedBodies = new Map<String, String>();
    }
    
    global MERC_ETMockHttpResponseGenerator(String bodyString) {
        myBody = bodyString;
        endpointBasedBodies = new Map<String, String>();
        System.debug('myBody constructor : ' + myBody);
    }

    global void whereEndpointContains(String searchString, String responseBody){
        endpointBasedBodies.put(searchString, responseBody);
    }
    
    global httpResponse respond(httpRequest req) {

        httpResponse res = new httpResponse();
        res.setHeader('Content-Type', 'application/json');
        String responseBody = '';

        if(!endpointBasedBodies.isEmpty()){
            String endpointURL = req.getEndpoint();
            for(String searchString : endpointBasedBodies.keySet()){
                if(endpointURL.containsIgnoreCase(searchString)){
                    responseBody = endpointBasedBodies.get(searchString);
                }
            }
        } 

        if(String.isBlank(responseBody)){
            System.debug('myBody : ' + myBody);
            responseBody = myBody; 
        }
        
        //string bodyString='{"objectId":"1","key":"test","id":"12321312","name":"hello","integrated":true,"userScoped":true,"jobId":1}';
        //string bodyString='{"objectId":"1"}"id"15646546546546"key"<a:AccessToken>564654654654</a:AccessToken><a:RefreshToken>564654654654</a:RefreshToken>"id":"12321312","name":"hello"';
        //bodyString+='"jobId":1312321332,}{"id":"123123"}';
        res.setBody(responseBody);
        res.setStatusCode(200);
        return res;
    }
}