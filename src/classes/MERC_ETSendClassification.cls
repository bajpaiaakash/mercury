public with sharing class MERC_ETSendClassification {
	public static List<MERC_ETSendClassification> GetSendClassifications(String oauthToken) {
		et4ae5__Configuration__c configInfo = [SELECT et4ae5__Root_Rest_API_URL__c FROM et4ae5__Configuration__c LIMIT 1];
		String url = configInfo.et4ae5__Root_Rest_API_URL__c + '/rest/beta/messaging/sendclassification/?oauth_token=' + oauthToken;
		
		HttpRequest req = new HttpRequest();
		req.setTimeout(120000);
		req.setEndpoint(url);
		req.setMethod('GET');
		req.setHeader('Accept', 'application/json');
		
		Http h = new Http();
		HttpResponse res = h.send(req);
		System.debug('res: ' + res);
		System.debug('res body: ' + res.getBody());
		
		MERC_ETSendClassification.GetSendClassificationResponse response = 
		  (MERC_ETSendClassification.GetSendClassificationResponse)JSON.deserialize(res.getBody(), MERC_ETSendClassification.GetSendClassificationResponse.class);
		
		return response.entry;
	}
	
    public ClassificationTypeElement classificationType { get; set; }
    public DateTime createdDate { get; set; }
    public String deliveryProfileId { get; set; }
    public String description { get; set; }
    public String id { get; set; }
    public String key { get; set; }
    public DateTime lastUpdated { get; set; }
    public String name { get; set; }
    public String senderProfileId { get; set; }
    
    public class ClassificationTypeElement {
    	public String id { get; set; }
    	public String name { get; set; }
    }
    
    public class GetSendClassificationResponse {
    	public integer startIndex { get; set; }
    	public integer itemsPerPage { get; set; }
    	public integer totalResults { get; set; }
    	public List<MERC_ETSendClassification> entry { get; set; }
    }
}