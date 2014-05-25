public virtual with sharing class parseString
{
    
    public virtual list<etObject.emailFolder> getEmailFolderDetails(string jsonStr)
    {
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
    
}