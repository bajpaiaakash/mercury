public class ETSendDefinitionProcessor{
    public ETSendDefinition.CreateSenderProfileResponse createSenderProfile(ETSendDefinition.SenderProfileCreate senderProfile, String authToken) {
        et4ae5__Configuration__c configInfo = [SELECT et4ae5__Root_Rest_API_URL__c FROM et4ae5__Configuration__c LIMIT 1];
        String endPoint = configInfo.et4ae5__Root_Rest_API_URL__c + '/rest/beta/messaging/senderpolicy/?oauth_token=' + authToken;

        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setHeader('Accept', 'application/json');
        req.setBody(JSON.serialize(senderProfile));
        System.debug('create sendProfile req body : ' + req.getBody());

        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug('create sendProfile res : ' + res);
        System.debug('create sendProfile res body : ' + res.getBody());

        ETSendDefinition.CreateSenderProfileResponse response = (ETSendDefinition.CreateSenderProfileResponse)JSON.deserialize(res.getBody(), ETSendDefinition.CreateSenderProfileResponse.class);
        return response;
    }

    public ETSendDefinition.CreateResponse create(ETSendDefinition sendDefinition, String authToken) {
        et4ae5__Configuration__c configInfo = [SELECT et4ae5__Root_Rest_API_URL__c FROM et4ae5__Configuration__c LIMIT 1];
        String endPoint = configInfo.et4ae5__Root_Rest_API_URL__c + '/rest/beta/messaging/senddefinition/instance/?oauth_token=' + authToken;

        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setHeader('Accept', 'application/json');
        req.setBody(JSON.serialize(sendDefinition));
        System.debug('create sendDef req body : ' + req.getBody());

        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug('create sendDef res : ' + res);
        System.debug('create sendDef res body : ' + res.getBody());

        ETSendDefinition.CreateResponse response = (ETSendDefinition.CreateResponse)JSON.deserialize(res.getBody(), ETSendDefinition.CreateResponse.class);
        return response;
    }

    public ETSendDefinition.StartResponse start(string id, string authToken){
        et4ae5__Configuration__c configInfo = [SELECT et4ae5__Root_Rest_API_URL__c FROM et4ae5__Configuration__c LIMIT 1];
        String endPoint = configInfo.et4ae5__Root_Rest_API_URL__c + '/rest/beta/messaging/senddefinition/instance/' + EncodingUtil.urlEncode(id,'UTF-8') + '/?action=start&oauth_token=' + authToken;

        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');

        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug('res : ' + res);
        System.debug('res body : ' + res.getBody());

        ETSendDefinition.StartResponse response = (ETSendDefinition.StartResponse)JSON.deserialize(res.getBody(), ETSendDefinition.StartResponse.class);
        return response;
    }

    public ETSendDefinition.CheckStatusResponse checkStatus(string id, string authToken){
        et4ae5__Configuration__c configInfo = [SELECT et4ae5__Root_Rest_API_URL__c FROM et4ae5__Configuration__c LIMIT 1];
        String endPoint = configInfo.et4ae5__Root_Rest_API_URL__c + '/rest/beta/messaging/senddefinition/instance/' + EncodingUtil.urlEncode(id,'UTF-8') + '/job/?oauth_token=' + authToken;


        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');

        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug('res : ' + res);
        System.debug('res body : ' + res.getBody());

        ETSendDefinition.CheckStatusResponse response = (ETSendDefinition.CheckStatusResponse)JSON.deserialize(res.getBody(), ETSendDefinition.CheckStatusResponse.class);
        return response;
    }
}