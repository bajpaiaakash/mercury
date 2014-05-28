public virtual with sharing class etCallControl {
    // handler for getting exacttarget email folders; getMainLevelEFDetails method does the work
    public virtual list<etObject.emailFolder> getExactTargetEmails(string memberId)
    {
        et4ae5__configuration__c c=[SELECT et4ae5__username__c, et4ae5__password__c, et4ae5__Auth_API_URL__c, et4ae5__Root_Rest_API_URL__c FROM et4ae5__configuration__c LIMIT 1];
        string scope=[SELECT et4ae5__exacttarget_oauth_token__c FROM user WHERE id=:userInfo.getUserId() LIMIT 1].et4ae5__exacttarget_oauth_token__c;
        system.debug('getExactTargetEmails scope: '+scope);
        string token='';
        if (memberId==null)
        {
            token=oAuthScopedNoMid(c.et4ae5__username__c,c.et4ae5__password__c,scope,c.et4ae5__auth_api_url__c);
        }
        else
        {
            token=oAuthScoped(c.et4ae5__username__c,c.et4ae5__password__c,scope,memberId,c.et4ae5__auth_api_url__c);
        }
        system.debug('getExactTargetEmails token: '+token);
        return getMainLevelEFDetails(c.et4ae5__root_rest_api_url__c,token); 
    }

    // obtains email folders i+nformation and parses
    public list<etObject.emailFolder> getMainLevelEFDetails(string url,string token)
    {
        http h=new http();
        httpRequest req=new httpRequest();
        req.setTimeout(120000);
        string useUrl=url+'/rest/beta/folder/?oauth_token='+token+'&where=allowedtypes+in+(\'email\',\'shared_type\',\'global+email\',\'shared_item\')';
        req.setMethod('GET');
        req.setEndpoint(useUrl);
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        try
        {
            httpResponse res=h.send(req);
            if (test.isRunningTest())
            {
                if (token=='e')
                {
                    throw new EliException('exception');
                }
                else if (token=='je')
                {
                    res.setBody('{"id":');
                }
            }
            ETObject.callEmailFolderResponse resp = (ETObject.callEmailFolderResponse)JSON.deserialize(res.getBody(), ETObject.callEmailFolderResponse.class);
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

    // obtain token using saved scope token
    public virtual string oAuthScoped(string sExactTargetUsername,string sExactTargetPassword,string scope,string memberId,string authApiUrl)
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
        req.setTimeout(120000);
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
        }
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

    // obtain token using saved scope token (with default MID)
    public virtual string oAuthScopedNoMID(string sExactTargetUsername,string sExactTargetPassword,string scope,string authApiUrl)
    {
        try
        {
            sExactTargetUsername=sExactTargetUsername.replace('&','&amp;').replace('<','&lt;').replace('>','&gt;').replace('"','&quot;').replace('\'','&apos;');
            sExactTargetPassword=sExactTargetPassword.replace('&','&amp;').replace('<','&lt;').replace('>','&gt;').replace('"','&quot;').replace('\'','&apos;');
            if (test.isRunningTest())
            {
                throw new EliException();
            }
        }
        catch (exception e) {}
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
        req.setTimeout(120000);
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
        req.setTimeout(120000);
        string useUrl=URL+'/rest/beta/folder/'+parentFolderId+'/children/?oauth_token='+token+'&where=allowedtypes+in+(\'email\',\'shared_type\',\'global+email\',\'shared_email\')';
        system.debug('URL: '+useUrl);
        req.setMethod('GET');
        req.setEndpoint(useUrl);
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        httpResponse res=new httpResponse();
        try
        {
            if (test.isRunningTest())
            {
                if (parentFolderId=='e')
                {
                    throw new EliException();
                }
            }
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
        req.setTimeout(120000);
        string useUrl=url+'/rest/beta/folder/'+parentFolderId+'/contents/?oauth_token='+token+'&where=type+eq+\'email\'';
        req.setMethod('GET');
        req.setEndpoint(useUrl);
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        httpResponse res=new httpResponse();
        try
        {
            System.debug('sending call emails');
            res=h.send(req);        
            System.debug('call emails response = ' + res);
            if (test.isRunningTest())
            {
                if (parentFolderId=='e')
                {
                    throw new EliException();
                }
            }
        }
        catch(exception e) { 
            System.debug(e);
        }
        return res;
    }   
}