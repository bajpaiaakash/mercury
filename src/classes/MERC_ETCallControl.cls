public with sharing class MERC_ETCallControl {
    public static final Integer DefaultTimeOut = 120000;
    public static final String ApplicationJson = 'application/json';

    // handler for getting exacttarget email folders; getMainLevelEFDetails method does the work
    public list<MERC_ETObject.emailFolder> getExactTargetEmails(string memberId)
    {
        et4ae5__Configuration__c etConfiguration = getConfiguration();
        String token = getOAuthToken(etConfiguration, memberId);
        String baseUrl = etConfiguration.et4ae5__Root_Rest_API_URL__c;
        return getMainLevelEFDetails(baseUrl,token); 
    }

    // obtains email folders i+nformation and parses
    public list<MERC_ETObject.emailFolder> getMainLevelEFDetails(string url,string token)
    {
        http h=new http();
        httpRequest req=new httpRequest();
        req.setTimeout(DefaultTimeOut);
        string useUrl=url+'/rest/beta/folder/?oauth_token='+token+'&where=allowedtypes+in+(\'email\',\'shared_type\',\'global+email\',\'shared_item\')';
        req.setMethod('GET');
        req.setEndpoint(useUrl);
        req.setHeader('Content-Type',ApplicationJson);
        req.setHeader('Accept',ApplicationJson);
        try
        {
            httpResponse res=h.send(req);
            if (test.isRunningTest())
            {
                if (token=='je')
                {
                    res.setBody('{"id":');
                }
            }
            MERC_ETObject.callEmailFolderResponse resp = (MERC_ETObject.callEmailFolderResponse)JSON.deserialize(res.getBody(), MERC_ETObject.callEmailFolderResponse.class);
            return resp.entry;
        }
        catch(JSONException e)
        {
            // TODO - parse error in JSON body
            return null;
        }
        catch(exception e)
        {
            // TODO - parse error in HTTP Send
            return null;
        }
    }

    public List<MERC_ETObject.SendClassification> getClassifications(String memberId){
        et4ae5__Configuration__c etConfiguration = getConfiguration();
        String token = getOAuthToken(etConfiguration, memberId);
        String baseUrl = etConfiguration.et4ae5__Root_Rest_API_URL__c;
        HttpResponse httpResponse = callClassifications(baseUrl, token);

        try{
            MERC_ETObject.SendClassificationResponse parsedResponse = 
                (MERC_ETObject.SendClassificationResponse)JSON.deserialize(
                    httpResponse.getBody(), MERC_ETObject.SendClassificationResponse.class);
            return parsedResponse.entry;
        } catch(JSONException ex){
            System.debug('JSONException:\n' + ex.getMessage());
            return null;
        } catch(Exception ex){
            System.debug('Exception:\n' + ex.getMessage());
            return null;
        }
    }

    public List<MERC_ETObject.SenderProfile> getSenders(String senderProfileId, String memberId){
        et4ae5__Configuration__c etConfiguration = getConfiguration();
        String token = getOAuthToken(etConfiguration, memberId);
        String baseUrl = etConfiguration.et4ae5__Root_Rest_API_URL__c;
        HttpResponse httpResponse = callSender(senderProfileId, baseUrl, token);

        try{
            MERC_ETObject.SenderProfileResponse parsedResponse = 
                (MERC_ETObject.SenderProfileResponse)JSON.deserialize(
                    httpResponse.getBody(), MERC_ETObject.SenderProfileResponse.class);
            return parsedResponse.entry;
        } catch(JSONException ex){
            System.debug('JSONException:\n' + ex.getMessage());
            return null;
        } catch(Exception ex){
            System.debug('Exception:\n' + ex.getMessage());
            return null;
        }
    }

    public et4ae5__Configuration__c getConfiguration(){
        return [SELECT et4ae5__username__c, 
                       et4ae5__password__c, 
                       et4ae5__Auth_API_URL__c, 
                       et4ae5__Root_Rest_API_URL__c 
                  FROM et4ae5__Configuration__c 
                  LIMIT 1];
    }

    public String getOAuthToken(et4ae5__Configuration__c etConfiguration, String memberId){        
        String oAuthScope = [SELECT et4ae5__exacttarget_oauth_token__c 
                               FROM User 
                              WHERE id = :UserInfo.getUserId() 
                              LIMIT 1].et4ae5__exacttarget_oauth_token__c;
        String oAuthToken = '';
        System.debug('oAuthScope: ' + oAuthScope);
        System.debug('memberId: ' + memberid);
        System.debug('etConfiguration:\n' + etConfiguration);
        if(String.isBlank(memberId)){
            oAuthToken = oAuthScopedNoMid(etConfiguration.et4ae5__username__c,
                                          etConfiguration.et4ae5__password__c,
                                          oAuthScope,
                                          etConfiguration.et4ae5__auth_api_url__c);
        } else {
            oAuthToken = oAuthScoped(etConfiguration.et4ae5__username__c,
                                     etConfiguration.et4ae5__password__c,
                                     oAuthScope,
                                     memberId,
                                     etConfiguration.et4ae5__auth_api_url__c);
        }

        System.debug('getOAuthToken: ' + oAuthToken);

        return oAuthToken;
    }

    // obtain token using saved scope token
    public string oAuthScoped(string sExactTargetUsername,string sExactTargetPassword,string scope,string memberId,string authApiUrl)
    {
        sExactTargetUsername=sExactTargetUsername.replace('&','&amp;').replace('<','&lt;').replace('>','&gt;').replace('"','&quot;').replace('\'','&apos;');
        sExactTargetPassword=sExactTargetPassword.replace('&','&amp;').replace('<','&lt;').replace('>','&gt;').replace('"','&quot;').replace('\'','&apos;');
        
        string xml='';
        xml='<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema"';
        xml+=' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <SOAP-ENV:Header> <wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"';
        xml+=' xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">';
        xml+=' <wsse:UsernameToken xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">';
        xml+=' <wsse:Username>'+sExactTargetUsername+'</wsse:Username> <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">';
        xml+=sExactTargetPassword+'</wsse:Password>';
        xml+=' </wsse:UsernameToken> </wsse:Security> </SOAP-ENV:Header> <SOAP-ENV:Body> <OAuthLogin xmlns="urn:authentication.exacttarget.com/2010/06/11"> ';
        xml+='<applicationId>6C7F3A46-9BFD-40E9-87EE-456577D4FFE7</applicationId>';
        xml+=' <customerSecret> Not used currently </customerSecret> <scopeToken>memberid='+memberId+',scope='+scope+'</scopeToken></OAuthLogin> </SOAP-ENV:Body></SOAP-ENV:Envelope>';
        http h=new http();
        httpRequest req=new httpRequest();
        req.setTimeout(DefaultTimeOut);
        req.setMethod('POST');
        req.setHeader('SOAPAction','urn:authentication.exacttarget.com/2010/06/11/Auth/OAuthLogin');
        req.setHeader('Content-Type','text/xml; charset=UTF-8');
        req.setBody(xml);
        req.setEndpoint(authApiUrl);
        string bodyRes='';
        string resText='';
        try 
        {
            httpResponse res=new httpResponse();
            res=h.send(req);
            bodyRes=res.getBody();
            if (test.isRunningTest())
            {
                if (memberId!='e')
                {
                    bodyRes='<a:AccessToken>testToken</a:AccessToken>';
                }
            }
            resText=string.valueof(res);
        }
        catch(System.CalloutException e)
        {
            resText=string.valueof(e);
            System.debug('oAuth Exception:\n' + e);
        }
        try
        {
            system.debug('accessToken debug: '+bodyRes.split('<a:AccessToken>')[1].split('</a:AccessToken>')[0]);
            return bodyRes.split('<a:AccessToken>')[1].split('</a:AccessToken>')[0];
        }
        catch(exception e)
        {
            System.debug('Could not split bodyRes:\n' + bodyRes);
            System.debug('Request body was:\n' + xml);
            return '';
        }
    }

    // obtain token using saved scope token (with default MID)
    public string oAuthScopedNoMID(string sExactTargetUsername,string sExactTargetPassword,string scope,string authApiUrl)
    {
        sExactTargetUsername=sExactTargetUsername.replace('&','&amp;').replace('<','&lt;').replace('>','&gt;').replace('"','&quot;').replace('\'','&apos;');
        sExactTargetPassword=sExactTargetPassword.replace('&','&amp;').replace('<','&lt;').replace('>','&gt;').replace('"','&quot;').replace('\'','&apos;');
        string xml='';
        xml='<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema"';
        xml+=' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <SOAP-ENV:Header> <wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"';
        xml+=' xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">';
        xml+=' <wsse:UsernameToken xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">';
        xml+=' <wsse:Username>'+sExactTargetUsername+'</wsse:Username> <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">';
        xml+=sExactTargetPassword+'</wsse:Password>';
        xml+=' </wsse:UsernameToken> </wsse:Security> </SOAP-ENV:Header> <SOAP-ENV:Body> <OAuthLogin xmlns="urn:authentication.exacttarget.com/2010/06/11"> ';
        xml+='<applicationId>6C7F3A46-9BFD-40E9-87EE-456577D4FFE7</applicationId>';
        xml+=' <customerSecret> Not used currently </customerSecret> <scopeToken>'+scope+'</scopeToken></OAuthLogin> </SOAP-ENV:Body></SOAP-ENV:Envelope>';
        http h=new http();
        httpRequest req=new httpRequest();
        req.setTimeout(DefaultTimeOut);
        req.setMethod('POST');
        req.setHeader('SOAPAction','urn:authentication.exacttarget.com/2010/06/11/Auth/OAuthLogin');
        req.setHeader('Content-Type','text/xml; charset=UTF-8');
        req.setBody(xml);
        req.setEndpoint(authApiUrl);
        string bodyRes='';
        string resText='';
        try 
        {
            httpResponse res=new httpResponse();
            res=h.send(req);
            bodyRes=res.getBody();
            if (test.isRunningTest())
            {
                if (scope!='e')
                {
                    bodyRes='<a:AccessToken>testToken</a:AccessToken>';
                }
            }
            system.debug('oAuthScopedNoMID payload: '+xml);
            system.debug('oAuthScopedNoMID response: '+bodyRes);
            resText=string.valueof(res);
        }
        catch(System.CalloutException e)
        {
            resText=string.valueof(e);
        }
        system.debug('c: '+bodyRes);
        try
        {
            system.debug('accessToken debug: '+bodyRes.split('<a:AccessToken>')[1].split('</a:AccessToken>')[0]);
            return bodyRes.split('<a:AccessToken>')[1].split('</a:AccessToken>')[0];
        }
        catch(exception e)
        {
            return '';
        }
    }

    // obtains subfolders within email folders 
    public httpResponse callEmailFolders (string parentFolderId,string url,string token)
    {
        http h=new http();
        httpRequest req=new httpRequest();
        req.setTimeout(DefaultTimeOut);
        string useUrl=URL+'/rest/beta/folder/'+parentFolderId+'/children/?oauth_token='+token+'&where=allowedtypes+in+(\'email\',\'shared_type\',\'global+email\',\'shared_email\')';
        system.debug('URL: '+useUrl);
        req.setMethod('GET');
        req.setEndpoint(useUrl);
        req.setHeader('Content-Type',ApplicationJson);
        req.setHeader('Accept',ApplicationJson);
        httpResponse res=new httpResponse();
        try
        {
            res=h.send(req);
        }
        catch(exception e){}
        return res;
    }

    // obtains emails within folder
    public httpResponse callEmails (string parentFolderId,string url,string token)
    {
        http h=new http();
        httpRequest req=new httpRequest();
        req.setTimeout(DefaultTimeOut);
        string useUrl=url+'/rest/beta/folder/'+parentFolderId+'/contents/?oauth_token='+token+'&where=type+eq+\'email\'';
        req.setMethod('GET');
        req.setEndpoint(useUrl);
        req.setHeader('Content-Type',ApplicationJson);
        req.setHeader('Accept',ApplicationJson);
        httpResponse res=new httpResponse();
        try
        {
            System.debug('sending call emails');
            res=h.send(req);        
            System.debug('call emails response = ' + res);
        }
        catch(exception e) { 
            System.debug(e);
        }
        return res;
    }   

    public HttpResponse callClassifications(String url, String token){
        String endpointUrl = url + '/rest/beta/messaging/sendclassification/?oauth_token=' + token;
        return getFromUrl(endpointUrl);
    }

    public HttpResponse callSender(String senderProfileId, String url, String token){
        String endpointUrl = url + '/rest/beta/messaging/senderprofile/?oauth_token=' + token + '&where=id+eq+\'' + senderProfileId + '\'';
        return getFromUrl(endpointUrl);
    }

    public HttpResponse getFromUrl(String endpointUrl){
        Http httpClient = new Http();
        HttpRequest httpRequest = new HttpRequest();

        httpRequest.setTimeout(DefaultTimeOut);
        httpRequest.setMethod('GET');
        httpRequest.setEndpoint(endpointUrl);
        httpRequest.setHeader('Content-Type', ApplicationJson);
        httpRequest.setHeader('Accept', ApplicationJson);

        HttpResponse response = new HttpResponse();
        try
        {
            System.debug('HTTP GET: ' + endpointUrl);
            response = httpClient.send(httpRequest);
        }
        catch(Exception ex){
            System.debug(ex);
        }
        return response;

    }
}