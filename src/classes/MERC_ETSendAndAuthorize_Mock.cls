@isTest
global with sharing class MERC_ETSendAndAuthorize_Mock implements HTTPCalloutMock {
    global boolean returnError = false;
    public boolean sendCheckStatusResponseComplete = false;
    
    global HttpResponse respond(HttpRequest req) {
        System.debug('req : ' + req + '\n' + req.getBody());

        HttpResponse res = new HttpResponse();
        MERC_ETSendDefinitionCallout_Mock etSendCallout = new MERC_ETSendDefinitionCallout_Mock();
        etSendCallout.sendCheckStatusResponseComplete = sendCheckStatusResponseComplete;
        
        MERC_ETAuthorizerCallout_Mock etAuthorizerCallout = new MERC_ETAuthorizerCallout_Mock();
        if (returnError == true)
        {
            res.setStatusCode(404);
            res.setStatus('Not Found');
        } else if (req.getEndpoint().containsIgnoreCase('Auth.svc')) {
            res = etAuthorizerCallout.soapAuthResponse(req);
        } else if (req.getEndpoint().containsIgnoreCase('exacttargetapis.com')) {
            res = etAuthorizerCallout.fuelAuthResponse(req);
        }
        else if (req.getEndpoint().containsIgnoreCase('instance/?oauth_token=')) {
            res = etSendCallout.createResponse(req);
        } else if (req.getEndpoint().containsIgnoreCase('?action=start&oauth_token=')) {
            res = etSendCallout.startResponse(req);
        } else if (req.getEndpoint().containsIgnoreCase('sendclassification/?oauth_token')) {
            res = etSendCallout.createSendClassificationResponse(req);
        } else {
            res = etSendCallout.checkStatusResponse(req);
        }

        return res;
    }
}