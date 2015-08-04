public with sharing class SSSC_Stories_TriggerHandler{
  
  public static void newFeed(List<SSSC_SafeStart_Story__c> lStory,String triggerAction){
   list<FeedItem> lFeed=new list<FeedItem>();
   feedItem oFeed;
   List<CollaborationGroup> lColGroup = new List<CollaborationGroup>();
   lColGroup = SSSC_Utility.queryGroup();
   if(lStory.size()>0){
     for(SSSC_SafeStart_Story__c oStory:lStory){
      oFeed = new feedItem();
       if(triggerAction==SSSC_Utility.actionInsert){
         oFeed.Body= SSSC_Utility.feedBodyforInsert;
       }
       if(lColGroup.size()>0){
         oFeed.ParentId = lColGroup[0].id;
       }
       oFeed.Title= oStory.Name;
       oFeed.Type= 'LinkPost';
       oFeed.LinkURL= URL.getSalesforceBaseUrl().toExternalForm()+'/'+oStory.id;
       lFeed.add(oFeed); 
     }
     try{
       if(lFeed.size()>0){
         insert lFeed;
       }    
     }
     catch(Exception e){
     }    

   }
  } 
   
}