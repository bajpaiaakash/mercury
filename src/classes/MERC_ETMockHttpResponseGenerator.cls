/*
 Allows mock responses to Http callouts in unit tests.

 2014-01-06 Andrew Schilling    - Allow configurable response body
*/
@isTest
global class MERC_ETMockHttpResponseGenerator implements HttpCalloutMock {

    Boolean predefinedBody {get; set;} //body is set as a parameter in constructor.
    String responseBody {get; set;} //body as set by the parameter in the constructor.

    Boolean hasHeader {get; set;}
    String headerContentType {get; set;}

    // status code default is 200, initialized in constructors.
    Integer statusCode {get; set;}

    /* variables to determine if the status (not status code)
     * should be completed on the response.
     */
    Boolean setStatusString {get; set;}
    String statusString {get; set;}

    // identifying different mocks
    Boolean authorizerMock {get; set;}

    // just return a blank response
    Boolean setNothing {get; set;} 

    global Map<String, String> endpointBasedBodies;
    
    // contstructors
    global MERC_ETMockHttpResponseGenerator() {
        responseBody = '{"objectId":"1","key":"test","id":"12321312","name":"hello","integrated":true,"userScoped":true,"jobId":1}';
        predefinedBody = false;
        statusCode = 200;
        initializeVariables();
        endpointBasedBodies = new Map<String, String>();
    }

    global MERC_ETMockHttpResponseGenerator(Integer code) {
        responseBody = '{"objectId":"1","key":"test","id":"12321312","name":"hello","integrated":true,"userScoped":true,"jobId":1}';
        predefinedBody = false;
        statusCode = code;
        initializeVariables();
        endpointBasedBodies = new Map<String, String>();
    }

    global MERC_ETMockHttpResponseGenerator(String bodyString) {
        responseBody = bodyString;
        predefinedBody = true;
        statusCode = 200;
        initializeVariables();
        System.debug('responseBody constructor : ' + responseBody);
    }

    global MERC_ETMockHttpResponseGenerator(String bodyString, Integer code) {
        responseBody = bodyString;
        predefinedBody = true;
        statusCode = code;
        initializeVariables();
        System.debug('responseBody constructor : ' + responseBody);
    }

    //repeatable code initializing variables
    private void initializeVariables () {
        authorizerMock = false;
        setNothing = false;
        hasHeader = false;
        endpointBasedBodies = new Map<String, String>();
    }

    global void whereEndpointContains(String searchString, String responseBody){
        endpointBasedBodies.put(searchString, responseBody);
    }
    
    global HttpResponse respond (HttpRequest req) {

        HttpResponse res = new HttpResponse();
        bodyBuilder(req);

        //DAVID: Do we need this code?
        //Don't see it used anywhere.
        /*if(!endpointBasedBodies.isEmpty()){
            String endpointURL = req.getEndpoint();
            for(String searchString : endpointBasedBodies.keySet()){
                if(endpointURL.containsIgnoreCase(searchString)){
                    return endpointBasedBodies.get(searchString);
                }
            }
        }*/

        if (hasHeader) {
            res.setHeader('Content-Type', headerContentType);
        }

        if (!setNothing) {
            res.setBody(responseBody);
            res.setStatusCode(statusCode);
        }
        
        return res;
    }

    private void bodyBuilder (HttpRequest req) {

        System.debug('#### req body = ' + req.getBody());
        System.debug('#### req header = ' + req.getHeader('Content-Type'));
        System.debug('#### responseBody : ' + responseBody);
        System.debug('#### predefinedBody : ' + predefinedBody);
        System.debug('#### GOING INTO NEW BODY LOGIC');
        System.debug('#### Checking if predefinedBody is true. Answer : ' + predefinedBody);
        if (statusCode == 400) {
            // 400 is an error. Return nothing.
            responseBody = '{"objectId":"1","key":"test","id":null,"name":"hello","integrated":true,"userScoped":true,"jobId":1}';
        } else if (!predefinedBody) {
            // No response body was passed in. 
            System.debug('#### No response body was passed in. Calling genericBodyBuilder. Getting swoll on bread and water.');
            genericBodyBuilder(req);
        } 
    }

    /* genericBodyBuilder
     * No response body was passed in the constructor.
     * Will build a response body based on a variety of factors.
     */
    private void genericBodyBuilder (HttpRequest req) {
        System.debug('#### ENTERING genericBodyBuilder');
        System.debug('#### endpoint is : ' + req.getEndpoint());


        if (req.getEndPoint() == 'https://webservice.s6.exacttarget.com/Service.asmx' && req.getMethod() == 'POST') {
            //This is ET Subscriber Callout.
            subscriberProcessResponse(req);
        } else if (req.getEndpoint().containsIgnoreCase('Auth.svc')) {
            System.debug('#### Endpoint contains Auth.svc. Calling soapAuthResponseBody.');
            authorizerMock = true;
            responseBody = '<a:AccessToken>testSoapToken</a:AccessToken>';
        } else if (req.getEndpoint().containsIgnoreCase('exacttargetapis.com')) {
            // Create a fuel response for MERC_ETAuthorizer.
            System.debug('#### Endpoint is exacttargetapis.com. Calling fuelResponseBody');
            authorizerMock = true;
            fuelResponseBody(req);
        } else if (authorizerMock) {
            /* 
             * This is for tests that require a blank respone be sent back.
             * 
             * Current usage:
             *  1. An authorizer that does not meet any of the if statements above. 
             *     The first authorizer request requires a token this will set the 
             *     AuthorizerMock boolean.
             */
            setNothing = true;
        }
    }

    // This is creating a fuel response for MERC_ETAuthorizer.
    private void fuelResponseBody (HttpRequest req) {

        System.assertEquals('POST', req.getMethod());
        System.assertEquals('application/json', req.getHeader('Content-Type'));

        MERC_ETAuthorizer.FuelResponseBody fuelResponseObject = new MERC_ETAuthorizer.FuelResponseBody();
        fuelResponseObject.accessToken = 'testFuelAccessToken';
        fuelResponseObject.expiresIn = 10000;
        fuelResponseObject.legacyToken = 'testFuelLegacyToken';
        System.debug('#### responseBody set to : ' + JSON.serialize(fuelResponseObject));
        responseBody = JSON.serialize(fuelResponseObject);
        setStatusString = true;

    }

    /* subscriberProcessResponse
     * This craft the body, status and status code of a response befitting of the subsciber process.
     * Currently, the subscriber process responses are required by the following classes: 
     * 1.) MERC_ETAccountEmailTriggerImpl_Test
     * 2.) MERC_ETSubscriberFutureProcessor_Test
     * 3.) MERC_ETSubscriberProcessor_Test
     * 4.) MERC_ETSubscriberProcessorCallout_Mock
     */
    private void subscriberProcessResponse (HttpRequest req) {
        
        String reqBody = req.getBody();

        responseBody = '';
        statusCode = 200;
        setStatusString = true;
        statusString = 'OK';
        
        if (req.getHeader('SOAPAction') == 'Retrieve') {
            responseBody += '<OverallStatus>OK</OverallStatus>';
            
            reqBody = reqBody.subStringBetween('<Filter', '</Filter>');
            List<String> values = reqBody.split('<Value>', 0);
            for (String val : values) {
                if (val.subStringBefore('</Value>') == 'testSubKey') {
                    responseBody += '<Results xsi:type="Subscriber">';
                    responseBody += '<SubscriberKey>testSubKey</SubscriberKey>';
                    responseBody += '<Name>LLYSubscriberKey</Name><Value>testLLYKey</Value>';
                    responseBody += '<EmailAddress>test@testy.com</EmailAddress>';
                    responseBody += '<Name>SubscriberType</Name><Value>testType</Value>';
                    responseBody += '</Results>';
                }
            }
        } else if (req.getHeader('SOAPAction') == 'Update') {
            Pattern emailPattern = Pattern.compile('\\D[^\\@]*@[^\\.\\@]*\\.[^\\.]*');
            Matcher emailMatcher = emailPattern.matcher(reqBody.subStringBetween('<EmailAddress>', '</EmailAddress>'));
            
            if (reqBody.subStringBetween('<SubscriberKey>', '</SubscriberKey>') == 'testSubKey' &&
                emailMatcher.matches()) {
                // return OK result
                responseBody += '<OverallStatus>OK</OverallStatus>';
            } else if (!emailMatcher.matches()){
                // return error result
                responseBody += '<OverallStatus>ERROR</OverallStatus>';
                responseBody += '<StatusMessage>Invalid email</StatusMessage>';
                statusString = 'ERROR';
            } else {
                responseBody += '<OverallStatus>ERROR</OverallStatus>';
                responseBody += '<StatusMessage>Standard error message</StatusMessage>';
                statusString = 'ERROR';
            }
        }
    }
}