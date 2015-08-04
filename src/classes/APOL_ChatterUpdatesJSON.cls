/****************************************************************************************************************************************** 
* Class Name   : APOL_ChatterUpdatesJSON 
* Description  : Get Chatter Updates for all the projects which the logged in user is following.
                 It returns a map with key as the project Id and value as a list of chatter Updates with timestamp.
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
public with sharing class APOL_ChatterUpdatesJSON {
    
    
    public static String userPrefix = User.sObjectType.getDescribe().getKeyPrefix();
    /*
    * @Method Name                    :  chatterUpdates
    * @Description                    :  get Chatter Updates for all the projects which the logged in user is following.
    It returns a map with key as the project Id and value as a list of chatter Updates with timestamp.
    * @Return Type                    :  Map<String,List<chatterUpdateWrapper>>
    */
    public static Map<String,List<chatterUpdateWrapper>> chatterUpdates(Set<String> projectIds)  {
    
        // This map has key as Project ID and value is a list of updates and timestamp for each update.  
        Map<String,List<chatterUpdateWrapper>> mapChatterUpdates = new Map<String,List<chatterUpdateWrapper>>();
        
        // This map stores key as API name and value as Label for all Project Fields. 
        Map<String,String> mapFieldNameLabel = new Map<String,String>();
        
        // This map is storing the list of fields for APOL Project and the respective labels. 
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(Label.APOL_Project).getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keySet()) {
            mapFieldNameLabel.put(Label.APOL_Project+'.'+ fieldName.tolowercase(),fieldMap.get(fieldName).getDescribe().getLabel());
        }    
        
          // this list stores all the updates for all the projects which the Logged in User is following. 
        List<APOL_Project__Feed> lstProjectFeed = new List<APOL_Project__Feed>();
            lstProjectFeed = [SELECT Id,Insertedby.Name,createddate,ParentId, (SELECT Id, FieldName, OldValue, NewValue FROM FeedTrackedChanges ORDER BY Id DESC) 
            FROM APOL_Project__Feed WHERE ParentID in :projectIds and createddate >= last_n_days:14 ORDER BY CreatedDate DESC, Id DESC ];
            lstProjectFeed = [SELECT Id,Insertedby.Name,createddate,ParentId, (SELECT Id, FieldName, OldValue, NewValue FROM FeedTrackedChanges ORDER BY Id DESC
            limit 10 ) FROM APOL_Project__Feed WHERE ParentID in :projectIds and createddate >= last_n_days:14 ORDER BY CreatedDate DESC, Id DESC ];
        //populating the map with the users updates and the timestamp.  
        for(APOL_Project__Feed projectFeed : lstProjectFeed ) {
            if(projectFeed.FeedTrackedChanges.size() > 0) {
                for(FeedTrackedChange feedTrackChange : projectFeed.FeedTrackedChanges) {
                    FillFeedTrack(feedTrackChange, projectFeed,projectFeed.ParentId, 
                    mapChatterUpdates, mapFieldNameLabel,ProjectFeed.Insertedby.Name, feedTrackChange.FieldName,
                    feedTrackChange.NewValue+'',feedTrackChange.OldValue+'',projectFeed.CreatedDate);
                }
            }
        } return mapChatterUpdates;
    }
    
    /*
    * @Class Name                    :  chatterUpdateWrapper
    * @Description                    :  This class is used to store the Chatter Updates for each field with timestamp.
    */
    public class chatterUpdateWrapper {
        public string chatterUpdate {set;get;}
        public String timestamp {set;get;}
        
    /*
    * @Method Name                    :  constructor
    * @Description                    :  constructor for chatterUpdateWrapper class.
    * @Return Type                    :  void
    */
        public chatterUpdateWrapper(string chatterUpdate,string timestamp) {
            this.chatterUpdate=chatterUpdate;
            this.timestamp = timestamp;
        }
    }
    
    /*
    * @Method Name                    :  FillFeedTrack
    * @Description                    :  this method populates the updates and timestamp for each project, based on the format. 
    * @Return Type                    :  void
    */    
    public static void FillFeedTrack(FeedTrackedChange feedTrackChange, APOL_Project__Feed projectFeed, String feedParentId, 
    Map<String,List<chatterUpdateWrapper>> mapChatterUpdates, Map<String,String> mapFieldNameLabel
    , String Feeduser, String fieldName,String newVal, String oldVal, DateTime projCreatedDate) {
    
    list<chatterUpdateWrapper> lstChatter = new list<chatterUpdateWrapper>();
    
    if(mapChatterUpdates.containsKey(feedParentId)) {
        lstChatter = mapChatterUpdates.get(feedParentId);
    }
    if(!NewVal.Contains(UserPrefix)) {
    lstChatter.add(new chatterUpdateWrapper(Feeduser + ' ' + Label.APOL_Changed +' ' + mapFieldNameLabel.get(FieldName.tolowercase()) + 
    ((NewVal != 'null' && NewVal != null  && NewVal != '')?(' ' + Label.APOL_from+' ' +  OldVal +' ' +  Label.APOL_to
    + ' ' + NewVal):''),projCreatedDate.format(Label.APOL_DatetimeFormat)));
    
    mapChatterUpdates.put(projectFeed.parentId,lstChatter);
        }
    }
    
}