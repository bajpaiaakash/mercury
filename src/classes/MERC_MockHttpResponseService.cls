/*
* MERC_MockHttpResponseService
* Description : Interface for classes used by the MERC_MockResponseService
* Author: David Helmer
* Modified By: 
* Modified Date: Dec. 14th 2015
*/
public with sharing class MERC_MockHttpResponseService implements HttpCalloutMock {
    private static final String POST_METHOD = 'POST';
    private static final String GET_METHOD = 'GET';
    private static final String SOAP_ACTION = 'SOAPAction';
    private static final String CONTENT_TYPE_KEY = 'Content-Type';
    private static final String ACCEPT_TYPE_KEY = 'Accept';
    private static final String XML_CHARSET_TYPE = 'text/xml; charset=UTF-8';
    private static final String JSON_TYPE = 'application/json';
    private static final String JSON_CHARSET_TYPE =  'application/json; charset=UTF-8';
    private static final String AUTHORIZATION_KEY = 'authorization';

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

        public Boolean shouldRespond(HttpRequest request) {
            return  request.getMethod() == GET_METHOD &&
                    request.getEndpoint() == expectedEndpoint &&
                    (contentType == null || request.getHeader(CONTENT_TYPE_KEY) == contentType) &&
                    (acceptType == null || request.getHeader(ACCEPT_TYPE_KEY) == acceptType);
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

        public Boolean shouldRespond(HttpRequest request) {
            return  request.getMethod() == POST_METHOD &&
                    request.getEndpoint() == expectedEndpoint &&
                    (contentType == null || request.getHeader(CONTENT_TYPE_KEY) == contentType) &&
                    (acceptType == null || request.getHeader(ACCEPT_TYPE_KEY) == acceptType) &&
                    request.getBody().deleteWhitespace() == expectedBody;
        }
        
        public HttpResponse respond(){
            HttpResponse mockResponse = new HttpResponse();
            mockResponse.setStatusCode(200);
            mockResponse.setBody(responseBody);
            mockResponse.setHeader(CONTENT_TYPE_KEY, acceptType);
            return mockResponse;
        }

        public String handlerName(){
            return 'BasicPost_' + expectedEndpoint + '_' + expectedBody + '_' + contentType + '_' + acceptType;
        }
    }
}