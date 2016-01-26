/*
* MERC_MockHttpResponseService
* Description : Interface for classes used by the MERC_MockResponseService
* Author: David Helmer
* Modified By: 
* Modified Date: Dec. 14th 2015
*/
public with sharing class MERC_MockHttpResponseService implements HttpCalloutMock {
    public static final String POST_METHOD = 'POST';
    public static final String GET_METHOD = 'GET';
    public static final String SOAP_ACTION = 'SOAPAction';
    public static final String CONTENT_TYPE_KEY = 'Content-Type';
    public static final String ACCEPT_TYPE_KEY = 'Accept';
    public static final String XML_CHARSET_TYPE = 'text/xml; charset=UTF-8';
    public static final String JSON_TYPE = 'application/json';
    public static final String JSON_CHARSET_TYPE =  'application/json; charset=UTF-8';
    public static final String AUTHORIZATION_KEY = 'authorization';

    private List<MockResponseInterface> mockResponseHandlers;

    public MERC_MockHttpResponseService(){
        mockResponseHandlers = new List<MockResponseInterface>();
    }

    public void addResponse(MockResponseInterface mockResponseHandler){
        mockResponseHandlers.add(mockResponseHandler);
    }

    public HttpResponse respond(HttpRequest httpRequest){
        MockResponseInterface mockResponseHandlerToRun = null;
        Boolean moreThanOneHandler = false;
        String mockResponseHandlerNames = 'Handlers attempting to respond: ';
        for(MockResponseInterface mockResponseHandler : mockResponseHandlers){
            if(mockResponseHandler.shouldRespond(httpRequest)){
                if(mockResponseHandlerToRun != null){
                    moreThanOneHandler = true;
                }
                mockResponseHandlerToRun = mockResponseHandler;
                mockResponseHandlerNames += '\n' + mockResponseHandler.handlerName();
            }
        }

        System.assertEquals(false, moreThanOneHandler, mockResponseHandlerNames);
        System.assertNotEquals(null, mockResponseHandlerToRun, 'Failed to find a handler for request:\n' + httpRequest);
        return mockResponseHandlerToRun.respond();
    }

    public static Boolean endpointContains(HttpRequest request, String targetString){
        System.assertNotEquals(null, request.getEndpoint());
        System.assertNotEquals(null, targetString);
        return request.getEndpoint().contains(targetString);
    }

    public static Boolean endpointMatches(HttpRequest request, String targetPattern){
        String endpointString = request.getEndpoint();
        System.assertNotEquals(null, endpointString);
        System.assertNotEquals(null, targetPattern);

        return Pattern.matches(targetPattern, endpointString);
    }

    public static Boolean bodyEquals(HttpRequest request, String targetString){
        String body = request.getBody();
        System.assertNotEquals(null, body);
        System.assertNotEquals(null, targetString);

        return body == targetString;
    }

    public interface MockResponseInterface {
        Boolean shouldRespond(HttpRequest request);
        HttpResponse respond();
        String handlerName();
    }

    public class BasicMockGetResponse implements MockResponseInterface {
        private String expectedEndpoint;
        private Pattern endpointPattern;
        private String contentType;
        private String acceptType;
        private String responseBody;

        public BasicMockGetResponse(String expectedEndpoint,
                                    String contentType,
                                    String acceptType,
                                    String responseBody) {
            this.expectedEndpoint = expectedEndpoint;
            this.contentType = contentType;
            this.acceptType = acceptType;
            this.responseBody = responseBody;
        }

        public BasicMockGetResponse(Pattern endpointPattern,
                                    String contentType,
                                    String acceptType,
                                    String responseBody) {
            this.endpointPattern = endpointPattern;
            this.contentType = contentType;
            this.acceptType = acceptType;
            this.responseBody = responseBody;
        }

        public Boolean shouldRespond(HttpRequest request) {            
            Boolean methodMatch = request.getMethod() == GET_METHOD;
            Boolean endpointMatch = false;
            String endpoint = request.getEndpoint();

            if(endpointPattern == null){
                endpointMatch = expectedEndpoint.equals(endpoint);
            } else {
                expectedEndpoint = endpointPattern.pattern();
                endpointMatch = endpointPattern.matcher(endpoint).matches();
            }

            if(methodMatch && endpointMatch){
                System.debug(LoggingLevel.FINE, GET_METHOD + ' to ' + expectedEndpoint + ' MATCHES: Checking header');
                Boolean contentTypeMatch = (contentType == null || contentType.equals(request.getHeader(CONTENT_TYPE_KEY)));
                Boolean acceptTypeMatch = (acceptType == null || acceptType.equals(request.getHeader(ACCEPT_TYPE_KEY)));
                if(contentTypeMatch && acceptTypeMatch){
                    System.debug(LoggingLevel.FINE, 'Match found for ' + GET_METHOD + ' to ' + expectedEndpoint);
                    return true;
                } else {
                    if(!contentTypeMatch){
                        System.debug(LoggingLevel.FINE, 'Content-Type mis-matched: ' + contentType + ' vs ' + request.getHeader(CONTENT_TYPE_KEY));
                    }
                    if(!acceptTypeMatch){
                        System.debug(LoggingLevel.FINE, 'Accept-Type mis-matched: ' + acceptType + ' vs ' + request.getHeader(ACCEPT_TYPE_KEY));
                    }
                }
            } else {
                System.debug(LoggingLevel.FINE, request.getMethod() + ' to ' + request.getEndpoint() + 
                    '\ndid not match\n' + GET_METHOD + ' to ' + expectedEndpoint);
            }
            return false;
        }
        
        public HttpResponse respond(){
            HttpResponse mockResponse = new HttpResponse();
            mockResponse.setStatusCode(200);
            mockResponse.setBody(responseBody);
            mockResponse.setHeader(CONTENT_TYPE_KEY, acceptType);
            return mockResponse;
        }

        public String handlerName(){
            return 'BasicGet_' + expectedEndpoint + '_' + contentType + '_' + acceptType;
        }
    }

    public class BasicMockPostResponse implements MockResponseInterface {
        private String expectedEndpoint;
        private String contentType;
        private String acceptType;
        private String expectedBody;
        private String responseBody;
        private String authorization;
        private String action;

        public BasicMockPostResponse(String expectedEndpoint,
                                     String contentType,
                                     String acceptType,
                                     String expectedBody,
                                     String responseBody) {
            this.expectedEndpoint = expectedEndpoint;
            this.contentType = contentType;
            this.acceptType = acceptType;
            this.expectedBody = expectedBody.deleteWhitespace();
            this.responseBody = responseBody;
        }

        public void withAuthorization(String authorization){
            this.authorization = authorization;
        }

        public void withAction(String action){
            this.action = action;
        }

        public Boolean shouldRespond(HttpRequest request) {
            Boolean methodMatch = request.getMethod() == POST_METHOD;
            Boolean endpointMatch = expectedEndpoint.equals(request.getEndpoint());
            if(methodMatch && endpointMatch){
                System.debug(LoggingLevel.FINE, POST_METHOD + ' to ' + expectedEndpoint + ' MATCHES: Checking header');
                Boolean contentTypeMatch = (contentType == null || contentType.equals(request.getHeader(CONTENT_TYPE_KEY)));
                Boolean acceptTypeMatch = (acceptType == null || acceptType.equals(request.getHeader(ACCEPT_TYPE_KEY)));
                Boolean authorizationMatch = (authorization == null || authorization.equals(request.getHeader(AUTHORIZATION_KEY)));
                Boolean actionMatch = (action == null || action.equals(request.getHeader(SOAP_ACTION)));    
                if(contentTypeMatch && acceptTypeMatch && authorizationMatch && actionMatch){
                    System.debug(LoggingLevel.FINE, 'Header MATCHES: Checking body');
                    Boolean bodyMatch = expectedBody.equals(request.getBody().deleteWhitespace());
                    if(bodyMatch){
                        System.debug(LoggingLevel.FINE, 'Match found for ' + POST_METHOD + ' to ' + expectedEndpoint);
                        return true;
                    } else {
                        System.debug(LoggingLevel.FINE, 'Body did not Match:\n\tRequest body:\n\t\t' + request.getBody() +
                            '\n\nExpected body:\n\t\t' + expectedBody);
                    }
                } else {
                    if(!contentTypeMatch){
                        System.debug(LoggingLevel.FINE, 'Content-Type mis-matched: ' + contentType + ' vs ' + request.getHeader(CONTENT_TYPE_KEY));
                    }
                    if(!acceptTypeMatch){
                        System.debug(LoggingLevel.FINE, 'Accept-Type mis-matched: ' + acceptType + ' vs ' + request.getHeader(ACCEPT_TYPE_KEY));
                    }
                    if(!authorizationMatch){
                        System.debug(LoggingLevel.FINE, 'Authorization mis-matched: ' + authorization + ' vs ' + request.getHeader(AUTHORIZATION_KEY));
                    }
                    if(!actionMatch){
                        System.debug(LoggingLevel.FINE, 'Action mis-matched: ' + action + ' vs ' + request.getHeader(SOAP_ACTION));
                    }
                }
            } else {
                System.debug(LoggingLevel.FINE, request.getMethod() + ' to ' + request.getEndpoint() + 
                    '\ndid not match\n' + POST_METHOD + ' to ' + expectedEndpoint);
            }

            return false;
        }
        
        public HttpResponse respond(){
            HttpResponse mockResponse = new HttpResponse();
            mockResponse.setStatusCode(200);
            mockResponse.setBody(responseBody);
            if(acceptType != null){
                mockResponse.setHeader(CONTENT_TYPE_KEY, acceptType);
            }
            return mockResponse;
        }

        public String handlerName(){
            return 'BasicPost_' + expectedEndpoint + '_' + contentType + '_' + acceptType;
        }
    }
}