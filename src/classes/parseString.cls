public virtual with sharing class parseString
{
    public virtual string accessTokenFromXml(string xml)
    {
        string returnString='';
        try
        {
            returnString=xml.split('<a:AccessToken>')[1].split('</a:AccessToken>')[0];
        }
        catch(exception e){}
        return returnString;
    }

    public virtual string soapUrlFromXml(string xml)
    {
        string returnString='';
        try
        {
            integer listSplit=xml.split('<Name>SoapSync</Name>')[0].split('<Url>').size();
            system.debug('listSplit: '+string.valueOf(listSplit));
            returnString=xml.split('<Name>SoapSync</Name>')[0].split('<Url>')[xml.split('<Name>SoapSync</Name>')[0].split('<Url>').size()-1].split('<')[0];
        }
        catch(exception e){}
        return returnString;
    }    
    
    public virtual string authApiUrlFromXml(string xml)
    {
        string returnString='';
        try
        {
            integer listSplit=xml.split('<Name>Authentication</Name>')[0].split('<Url>').size();
            returnString=xml.split('<Name>Authentication</Name>')[0].split('<Url>')[xml.split('<Name>Authentication</Name>')[0].split('<Url>').size()-1].split('<')[0];
        }
        catch(exception e){}
        return returnString;
    }
    
    public virtual string authApiUrlFromSoapUrl(string url)
    {
        string returnString='';
        try
        {
            returnString=url.split('/Service.asmx')[0]+'/Authentication/Auth.svc';
        }
        catch (exception e){}
        return returnString;
    }

    public virtual string restUrlFromXml(string xml)
    {
        string returnString='';
        try
        {
            returnString=xml.split('<Name>Rest</Name>')[0].split('<Url>')[xml.split('<Name>Rest</Name>')[0].split('<Url>').size()-1].split('<')[0];
        }
        catch(exception e){}
        return returnString;
    }

    public virtual string userIdFromJson(string json)
    {
   /**/
        if(test.isRunningTest() && json!='testUserError' && !json.contains('"key":"fake"'))
        {
            json='"id":"000000000000000000000"key"';
        }
   /**/
        string returnString='';
        try
        {
            returnString=json.split('"id":"')[1].split('"')[0];
        }
        catch(exception e){}
        return returnString;
    }    

    public virtual string parentBUFromJson(string json)
    {
        string returnString='';
        try
        {
            returnString=json.split('"defaultBusinessunitid":')[1].split(',')[0];
        }
        catch(exception e){}
        return returnString;
    } 

    public virtual string accountTypeNameFromJson(string json)
    {
        string returnString='';
        try
        {
            returnString=json.split('"accounttypename":"')[1].split('"')[0];
        }
        catch(exception e){}
        return returnString;
    }
    
    public virtual list<etObject.emailFolder> getEmailFolderDetails(string jsonStr)
    {
        /*
            list<emailFolder> returnList=new list<emailFolder>();
            try
            {
                string[] splitJson=json.split('"id":"');
                emailFolder ef=new emailFolder();
                for (integer x=1 ; x<splitJson.size() ; x++)
                {
                    returnList.add(new emailFolder());
                }
                for (integer x=1 ; x<splitJson.size() ; x++)
                {
                    returnList[x-1].id=splitJson[x].split('"')[0];
                    returnList[x-1].name=splitJson[x].split('"name":"')[1].split('"')[0];
                }
            }
        */
        try
        {
            etObject.callEmailFolderResponse respObj=
              (etObject.callEmailFolderResponse)JSON.deserialize(jsonStr,etObject.callEmailFolderResponse.class);
            return (respObj.entry != null ? respObj.entry : new list<etObject.emailFolder>());
        }
        catch(exception e)
        {
            return new list<etObject.emailFolder>();
        }
        //return returnList;
    }

    public virtual list<folderedEmail> getEmails(string json)
    {
        list<folderedEmail> returnList=new list<folderedEmail>();
        try
        {
            system.debug('json: '+json);
            string[] splitJson=json.split('"id":"');
            etObject.emailFolder ef=new etObject.emailFolder();
            for (integer x=2 ; x<splitJson.size() ; x+=2)
            {
                returnList.add(new folderedEmail());
            }
            for (integer x=2 ; x<splitJson.size() ; x+=2)
            {
                returnList[x/2-1].id=splitJson[x].split('"')[0];
                returnList[x/2-1].name=splitJson[x].split('"name":"')[1].split('","subject"')[0];
                returnList[x/2-1].title=splitJson[x].split('"subject":"')[1].split('","categoryId"')[0];
                returnList[x/2-1].encName=encodingUtil.urlEncode(splitJson[x].split('"name":"')[1].split('","subject"')[0],'UTF-8');
                returnList[x/2-1].encTitle=EncodingUtil.urlEncode(splitJson[x].split('"subject":"')[1].split('","categoryId"')[0],'UTF-8');
            }
        }
        catch(exception e){}
        returnList.sort();
        return returnList;
    }
    
    public virtual string getSyncId(string json)
    {
        string returnString='';
        try
        {
            returnString=json.split('"id":"')[1].split('"')[0];
        }
        catch(exception e){}
        return returnString;
    }
    
    public virtual string getSyncStatus(string json)
    {
        string returnString='';
        try
        {
            returnString=json.split('"syncStatus":"')[1].split('"')[0];
        }
        catch(exception e){}
        return returnString;
    }
}