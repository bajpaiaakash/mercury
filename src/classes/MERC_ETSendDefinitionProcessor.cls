public class MERC_ETSendDefinitionProcessor{
    public MERC_ETSendClassification getSendClassification(String authToken) {
    	List<MERC_ETSendClassification> classifications = MERC_ETSendClassification.GetSendClassifications(authToken);
    	Sonoma_ET_Config__c config = Sonoma_ET_Config__c.getInstance();
    	
    	for (MERC_ETSendClassification classification : classifications) {
    		if (String.isNotBlank(classification.key) && classification.key == config.Send_Configuration_Key__c) {
    			return classification;
    		}
    	}
    	
    	return null;
    }

    public MERC_ETSendDefinition.CreateResponse create(MERC_ETSendDefinition sendDefinition, String authToken) {
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
        checkIfResponseIsError(res);
        
        MERC_ETSendDefinition.CreateResponse response = (MERC_ETSendDefinition.CreateResponse)JSON.deserialize(res.getBody(), MERC_ETSendDefinition.CreateResponse.class);
        return response;
    }

    public MERC_ETSendDefinition.StartResponse start(string id, string authToken){
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
        checkIfResponseIsError(res);
        
        MERC_ETSendDefinition.StartResponse response = (MERC_ETSendDefinition.StartResponse)JSON.deserialize(res.getBody(), MERC_ETSendDefinition.StartResponse.class);
        return response;
    }

    public MERC_ETSendDefinition.CheckStatusResponse checkStatus(string id, string authToken){
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
        checkIfResponseIsError(res);
        
        MERC_ETSendDefinition.CheckStatusResponse response = (MERC_ETSendDefinition.CheckStatusResponse)JSON.deserialize(res.getBody(), MERC_ETSendDefinition.CheckStatusResponse.class);
        return response;
    }
    
    private static void checkIfResponseIsError(HttpResponse res){
        if (!(res.getStatusCode() >= 200 && res.getStatusCode() < 300)) {
            throw new EtSendDefinitionException('An error occurred communicating with the ET Server : ' +  res.getBody());
        }
    }
    
    public class EtSendDefinitionException extends Exception {}
}