public virtual with sharing class MERC_ETParseString
{
    
    public virtual list<MERC_ETObject.emailFolder> getEmailFolderDetails(string jsonStr)
    {
        try
        {
            MERC_ETObject.callEmailFolderResponse respObj=
              (MERC_ETObject.callEmailFolderResponse)JSON.deserialize(jsonStr,MERC_ETObject.callEmailFolderResponse.class);
            return (respObj.entry != null ? respObj.entry : new list<MERC_ETObject.emailFolder>());
        }
        catch(exception e)
        {
            return new list<MERC_ETObject.emailFolder>();
        }
    }

    public virtual list<MERC_ETFolderedEmail> getEmails(string json)
    {
        list<MERC_ETFolderedEmail> returnList=new list<MERC_ETFolderedEmail>();
        try
        {
            system.debug('json: '+json);
            string[] splitJson=json.split('"id":"');
            MERC_ETObject.emailFolder ef=new MERC_ETObject.emailFolder();
            for (integer x=2 ; x<splitJson.size() ; x+=2)
            {
                returnList.add(new MERC_ETFolderedEmail());
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
    
}