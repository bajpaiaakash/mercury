@isTest
global class Mock_EndToEndDataExtensionCallouts implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();

        if (req.getEndpoint().containsIgnoreCase('Auth.svc')) {
            res = soapAuthResponse(req);
        }

        return res;
    }

    global HttpResponse soapAuthResponse(HttpRequest req) {
        Mock_ETAuthorizerCallout mock = new Mock_ETAuthorizerCallout();
        return mock.soapAuthResponse(req);
    }
}