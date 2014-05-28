@isTest
global class Mock_EndToEndDataExtensionCallouts implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();

        if (req.getEndpoint().containsIgnoreCase('Auth.svc')) {
            res = soapAuthResponse(req);
        } else if (req.getEndpoint().containsIgnoreCase('/v1/requestToken?legacy=1')) {
            res = fuelAuthResponse(req);
        } else if (req.getEndpoint().containsIgnoreCase('/rest/beta/object/?oauth_token')) {
            res = createDataExtensionResponse(req);
        } else if (req.getEndpoint().containsIgnoreCase('/hub/v1/dataevents/key')) {
            res = populateDataExtensionResponse(req);
        } else if (req.getEndpoint().containsIgnoreCase('/utilities/ImageThumbnailSecure.ashx/')) {
            res = populateThumbnailDataResponse(req);
        }

        return res;
    }

    global HttpResponse soapAuthResponse(HttpRequest req) {
        Mock_ETAuthorizerCallout mock = new Mock_ETAuthorizerCallout();
        return mock.soapAuthResponse(req);
    }

    global HttpResponse fuelAuthResponse(HttpRequest req) {
        Mock_ETAuthorizerCallout mock = new Mock_ETAuthorizerCallout();
        return mock.fuelAuthResponse(req);
    }

    global HttpResponse createDataExtensionResponse(HttpRequest req) {
        Mock_DataExtensionCallout mock = new Mock_DataExtensionCallout();
        return mock.respond(req);
    }

    global HttpResponse populateDataExtensionResponse(HttpRequest req) {
        Mock_DataExtensionPopulateCallout mock = new Mock_DataExtensionPopulateCallout();
        return mock.respond(req);
    }

    global HttpResponse populateThumbnailDataResponse(HttpRequest req) {
        ETDataExtensionProcessor.ImageThumbnailSecureResponse thumbnailRes = new ETDataExtensionProcessor.ImageThumbnailSecureResponse();
        thumbnailRes.data = EncodingUtil.base64Encode(Blob.valueOf('Test String'));

        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody(JSON.serializePretty(thumbnailRes));

        return res;
    }
}