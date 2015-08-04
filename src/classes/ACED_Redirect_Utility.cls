Public with sharing class ACED_Redirect_Utility{

    public static Map<String, String> createDefaultValues(PageReference pReference, Schema.SObjectType oGenericSobjectType) {
    pReference.getParameters().put('nooverride', '1');
    String html='';
    if (Test.IsRunningTest())
   {
        html=Blob.valueOf('/' + ACED_MOT__c.SObjectType.getDescribe().getKeyPrefix() + '/e').toString();
   }
   else
   {
        html=pReference.getContent().toString();

   }
    
   // String html = pReference.getContent().toString();
    Map<String, String> labelToId = new Map<String, String>();
    Matcher m = Pattern.compile('<label for="(.*?)">(<span class="requiredMark">\\*</span>)?(.*?)</label>').matcher(html);
    while (m.find()) {
        String label = m.group(3);
        String id = m.group(1);
        labelToId.put(label, id);
    }
    // Relate the magic ids to the SObject fields
    Map<String, String> params = new Map<String, String>();
    
    // Query current user details 
    User oCurrentUser = [Select Id,ACED_Affiliate__c,ACED_HUB__c from user where id = : UserInfo.getUserId() limit 1];
    Map<String,String> mFields = new Map<String,String>();
    //Populate all the fields that needs to be populated
    mFields.put('HUB__c',oCurrentUser.ACED_HUB__c);
    mFields.put('Affiliate__c',oCurrentUser.ACED_Affiliate__c);
    
    for (SObjectField field : oGenericSobjectType.getDescribe().fields.getMap().values()) {
        Object value;
        if(mFields.containskey(string.valueof(field))){
            value = mFields.get(string.valueof(field));
        }
        if (value != null) {
            DescribeFieldResult f = field.getDescribe();
            String label = f.getLabel();
            if (labelToId.containsKey(label)) {
                // Format
                String valueAsString;
                if (f.getType() == DisplayType.Date) {
                    valueAsString = ((Date) value).format();
                } else if (f.getType() == DisplayType.Datetime) {
                    valueAsString = ((Datetime) value).format();
                } else if (f.getType() == DisplayType.Boolean) {
                    valueAsString = ((Boolean) value) ? '1' : '0';
                } else {
                    valueAsString = String.valueOf(value);
                }
                params.put(labelToId.get(label), valueAsString);
            }
        }
    }
    return params;
    }
    
    

}