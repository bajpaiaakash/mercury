@isTest
global class MERC_ETEndToEndDataExtCallouts_Mock implements HttpCalloutMock {
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
        MERC_ETAuthorizerCallout_Mock mock = new MERC_ETAuthorizerCallout_Mock();
        return mock.soapAuthResponse(req);
    }

    global HttpResponse fuelAuthResponse(HttpRequest req) {
        MERC_ETAuthorizerCallout_Mock mock = new MERC_ETAuthorizerCallout_Mock();
        return mock.fuelAuthResponse(req);
    }

    global HttpResponse createDataExtensionResponse(HttpRequest req) {
        MERC_ETDataExtensionCallout_Mock mock = new MERC_ETDataExtensionCallout_Mock();
        return mock.respond(req);
    }

    global HttpResponse populateDataExtensionResponse(HttpRequest req) {
        MERC_ETDataExtensionPopulateCallout_Mock mock = new MERC_ETDataExtensionPopulateCallout_Mock();
        return mock.respond(req);
    }

    global HttpResponse populateThumbnailDataResponse(HttpRequest req) {
        MERC_ETDataExtensionProcessor.ImageThumbnailSecureResponse thumbnailRes = new MERC_ETDataExtensionProcessor.ImageThumbnailSecureResponse();
        thumbnailRes.data = EncodingUtil.base64Encode(Blob.valueOf('Test String'));

        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody(JSON.serializePretty(thumbnailRes));

        return res;
    }
}