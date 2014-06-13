@isTest
global class Mock_ETSendDefinitionCallout implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        System.debug('req : ' + req + '\n' + req.getBody());

        HttpResponse res = new HttpResponse();
        if (req.getEndpoint().containsIgnoreCase('instance/?oauth_token=')) {
            res = createResponse(req);
        } else if (req.getEndpoint().containsIgnoreCase('?action=start&oauth_token=')) {
            res = startResponse(req);
        } else {
            res = checkStatusResponse(req);
        }

        return res;
    }

    global HttpResponse createResponse(HttpRequest req) {
        ETSendDefinition.CreateResponse cr = new ETSendDefinition.CreateResponse();
        cr.id = 'testId';

        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        res.setBody(JSON.serializePretty(cr));
        return res;
    }

    global HttpResponse startResponse(HttpRequest req) {
        ETSendDefinition.StartResponse sr = new ETSendDefinition.StartResponse();
        sr.clientId = 'Client Id';
        sr.id = 'id';
        sr.jobId = 'Job Id';
        sr.statusMessage = 'processing';

        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        res.setBody(JSON.serializePretty(sr));
        return res;
    }

    global HttpResponse checkStatusResponse(HttpRequest req) {
        ETSendDefinition.CheckStatusResponse csr = new ETSendDefinition.CheckStatusResponse();
        csr.id = 'id';
        csr.sendStatus = 'Processing';
        csr.jobId = 'Job Id';
        csr.clientId = 'Client Id';

        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        res.setBody(JSON.serializePretty(csr));
        return res;
    }
}