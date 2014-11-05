@isTest
global class MERC_ETSendDefinitionCallout_Mock implements HttpCalloutMock {
    
    global boolean returnError = false;
    public boolean sendCheckStatusResponseComplete = false;
    
    global HttpResponse respond(HttpRequest req) {
        System.debug('req : ' + req + '\n' + req.getBody());

        HttpResponse res = new HttpResponse();
        
        if (returnError == true)
        {
            res.setStatusCode(404);
            res.setStatus('Not Found');
        } else if (req.getEndpoint().containsIgnoreCase('instance/?oauth_token=')) {
            res = createResponse(req);
        } else if (req.getEndpoint().containsIgnoreCase('?action=start&oauth_token=')) {
            res = startResponse(req);
        } else if (req.getEndpoint().containsIgnoreCase('sendclassification/?oauth_token')) {
        	res = createSendClassificationResponse(req);
        } else {
            res = checkStatusResponse(req);
        }

        return res;
    }
    
    global HttpResponse createSendClassificationResponse(HttpRequest req) {
    	MERC_ETSendClassification.GetSendClassificationResponse response = new MERC_ETSendClassification.GetSendClassificationResponse();
    	response.startIndex = 0;
    	response.itemsPerPage = 50;
    	response.totalResults = 2;
    	response.entry = new List<MERC_ETSendClassification>();
    	
    	MERC_ETSendClassification cls = new MERC_ETSendClassification();
    	cls.key = 'testkey';
    	response.entry.add(cls);
    	
    	cls = new MERC_ETSendClassification();
    	cls.key = 'anotherkey';
    	response.entry.add(cls);
    	
    	HttpResponse res = new HttpResponse();
    	res.setStatusCode(200);
    	res.setStatus('OK');
    	res.setBody(JSON.serialize(response));
    	return res;
    }

    global HttpResponse createResponse(HttpRequest req) {
        MERC_ETSendDefinition.CreateResponse cr = new MERC_ETSendDefinition.CreateResponse();
        cr.id = 'testId';

        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        res.setBody(JSON.serializePretty(cr));
        return res;
    }

    global HttpResponse startResponse(HttpRequest req) {
        MERC_ETSendDefinition.StartResponse sr = new MERC_ETSendDefinition.StartResponse();
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
        MERC_ETSendDefinition.CheckStatusResponse csr = new MERC_ETSendDefinition.CheckStatusResponse();
        csr.id = 'id';
        csr.sendStatus = sendCheckStatusResponseComplete == false
                         ?'Processing'
                         : 'Completed';
        csr.jobId = 'Job Id';
        csr.clientId = 'Client Id';

        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        res.setBody(JSON.serializePretty(csr));
        return res;
    }
}