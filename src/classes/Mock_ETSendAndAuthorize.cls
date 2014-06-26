@isTest
global with sharing class Mock_ETSendAndAuthorize implements HTTPCalloutMock {
    global boolean returnError = false;
    public boolean sendCheckStatusResponseComplete = false;
    
    global HttpResponse respond(HttpRequest req) {
        System.debug('req : ' + req + '\n' + req.getBody());

        HttpResponse res = new HttpResponse();
        Mock_ETSendDefinitionCallout etSendCallout = new Mock_ETSendDefinitionCallout();
        etSendCallout.sendCheckStatusResponseComplete = sendCheckStatusResponseComplete;
        
        Mock_ETAuthorizerCallout etAuthorizerCallout = new Mock_ETAuthorizerCallout();
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
        } else if (req.getEndpoint().containsIgnoreCase('senderpolicy/?oauth_token')) {
            res = etSendCallout.createSenderProfileResponse(req);
        } else {
            res = etSendCallout.checkStatusResponse(req);
        }

        return res;
    }
}