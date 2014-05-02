public virtual with sharing class etCallControl {
    // handler for getting exacttarget email folders; getMainLevelEFDetails method does the work
    public virtual list<etObject.emailFolder> getExactTargetEmails(string memberId)
    {
        //configuration__c c=[SELECT username__c,password__c,Auth_API_URL__c,Root_Rest_API_URL__c FROM configuration__c LIMIT 1];
        //string scope=[SELECT exacttarget_oauth_token__c FROM user WHERE id=:userInfo.getUserId() LIMIT 1].exacttarget_oauth_token__c;
        //system.debug('getExactTargetEmails scope: '+scope);
        //string token='';
        //if (memberId==null)
        //{
        //    token=oAuthScopedNoMid(c.username__c,c.password__c,scope,c.auth_api_url__c);
        //}
        //else
        //{
        //    token=oAuthScoped(c.username__c,c.password__c,scope,memberId,c.auth_api_url__c);
        //}
        //system.debug('getExactTargetEmails token: '+token);
        //return getMainLevelEFDetails(c.root_rest_api_url__c,token); 
        return null;
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
}