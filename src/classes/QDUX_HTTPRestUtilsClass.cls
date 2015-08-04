/**
 * Created by: Eric Montelibano (PwC)- 21/05/2015
 * Application: Quality in Design User Experience (QDUX)
 * 
 * Description: Utilities class for the QDUX to be handle HTTP Callout. Also includes the Utilities class to handle error message during call out and store within GLBL_Error_Log__c
 * as per GSO Design and Development Guidelines.
*/


public without sharing class QDUX_HTTPRestUtilsClass {
    //HTTP variables that will be used for HTTP Callout.
    public string Auth = 'Authorization';
    public string sessId = UserInfo.getSessionId();
    public String Acc = 'Accept';
    public String appJs = 'application/json';
    public String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
    
    /**
	 * Get JSON response from the HTTP callout
	 * @return stringJSON
	*/
    public String getJSON(String url) {
        Http h = new Http();
        system.debug('session >>>> ' +UserInfo.getSessionId());
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', UserInfo.getSessionId());
        req.setHeader('X-Auth-Provider', label.QDUX_VVXAuth);
        req.setHeader('X-Auth-Host', sfdcBaseURL); 
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(url);
        req.setTimeout(integer.valueof(integer.valueof(label.QDUX_TimeoutSettings)));
        req.setMethod('GET');
        
        system.debug('EP ]]]' +req.getEndpoint()); 
        HttpResponse res = h.send(req);
        system.debug('RESPONSE BODY ' +res.getBody());
        return res.getBody();
    }
    
    /**
	 * insert Exception Error Logs in GLBL_Error_Log__c
	 * @return insert error log record 
	*/
    public PageReference createErrorMessage(String ErrorMessage, String StackTrace, String addInfo ){
        GLBL_Error_Log__c err = new GLBL_Error_Log__c(
            Error_Datetime__c = system.now(),
            Error_Message__c = ErrorMessage,
            Stack_Trace__c = StackTrace,
            Running_User__c = UserInfo.getUserId(),
            Additional_Information__c = addInfo
        );
        insert err;
        system.debug('whats my id DUDE ' +err.id);
        return null;
    }
}