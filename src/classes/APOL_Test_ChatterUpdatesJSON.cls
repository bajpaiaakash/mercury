/****************************************************************************************************************************************** 
* Class Name   : APOL_Test_ChatterUpdatesJSON
* Description  : test Class for ChatterUpdatesJSON
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
@istest(SeeAllData=false)
public class APOL_Test_ChatterUpdatesJSON {
    
    /* 
    * @Method Name                    :  testChatterUpdatesJSON
    * @Description                    :  Testing of Chatter Updates JSON method . 
    * @Return Type                    :  void
    */      
    public static testmethod void testChatterUpdatesJSON() {
        
        User u = APOL_Test_Utility_Class.CreateApolAdmin(); // Creating a user for Apollo Admin
        
        System.RunAs(u) {
            
            // creating 3 projects 
            List<APOL_Project__c> projLst = APOL_Test_Utility_Class.createProjects(3);
            APOL_Project__c projObj = projLst[0];
            
            // calling projectFollow method and returning true. 
            Boolean prjfollow = APOL_HomePageController.projectFollow(projObj.Id, 1);
            
            // Updating Stakeholder group , so that it is captured in Chatter Updates. 
            projObj.Project_stakeholder_groups__c = Label.APOL_patients.substring(0,Label.APOL_patients.length()-1).tolowercase()
                + ';' + Label.APOL_investigators.substring(0,Label.APOL_investigators.length()-1).tolowercase();
            update projObj;
            
            
            test.starttest();
            Map<String,List<APOL_ChatterUpdatesJSON.chatterUpdateWrapper>> chatterUpdatesMap 
                = APOL_ChatterUpdatesJSON.chatterUpdates(new Set<String>{projObj.Id});
            
            // assert if the map is blank. 
            system.assert(chatterUpdatesMap!= null);
           
            APOL_ChatterUpdatesJSON.chatterUpdateWrapper wrapperObj = new 
                APOL_ChatterUpdatesJSON.chatterUpdateWrapper(Label.APOL_ApolloTestData,Label.APOL_ApolloTestData);
            
            APOL_Project__Feed prjFeed = new APOL_Project__Feed();
            Map<String,List<APOL_ChatterUpdatesJSON.chatterUpdateWrapper>> mapChatterUpdates = new 
                Map<String,List<APOL_ChatterUpdatesJSON.chatterUpdateWrapper>>{Label.APOL_ApolloTestData => 
                    new List<APOL_ChatterUpdatesJSON.chatterUpdateWrapper>()};
                        Map<String,String> mapFieldNameLabel = new Map<String,String>();
            
            // calling FillFeedTrack method and passing all the fields of feedtrackchange as parameters to the method. 
            APOL_ChatterUpdatesJSON.FillFeedTrack(new FeedTrackedChange(), prjFeed, Label.APOL_ApolloTestData, 
             mapChatterUpdates,mapFieldNameLabel,Userinfo.getname(), Label.APOL_ApolloTestData,
             Label.APOL_ApolloTestData,Label.APOL_ApolloTestData,Datetime.now());
            
            test.stopTest();
        }
    }
    
    /* 
    * @Method Name                    :  testChatterUpdatesJSON
    * @Description                    :  Testing of Chatter Updates JSON method . 
    * @Return Type                    :  void
    */      
    public static testmethod void testChatterUpdatesJSONFeedItem() {
        
        User u = APOL_Test_Utility_Class.CreateApolAdmin(); // Creating a user for Apollo Admin
        
        System.RunAs(u) {
            
            // creating 3 projects 
            List<APOL_Project__c> projLst = APOL_Test_Utility_Class.createProjects(3);
            APOL_Project__c projObj = projLst[0];
            
            // calling projectFollow method and returning true. 
            Boolean prjfollow = APOL_HomePageController.projectFollow(projObj.Id, 1);
            
            // Updating Stakeholder group , so that it is captured in Chatter Updates. 
            projObj.Project_stakeholder_groups__c = Label.APOL_patients.substring(0,Label.APOL_patients.length()-1).tolowercase()
                + ';' + Label.APOL_investigators.substring(0,Label.APOL_investigators.length()-1).tolowercase();
            update projObj;
            
            
            test.starttest();
            Map<String,List<APOL_ChatterUpdatesJSON.chatterUpdateWrapper>> chatterUpdatesMap 
                = APOL_ChatterUpdatesJSON.chatterUpdates(new Set<String>{projObj.Id});
            
            // assert if the map is blank. 
            system.assert(chatterUpdatesMap!= null);
            
            // call the ChatterUpdates method. 
            chatterUpdatesMap = APOL_ChatterUpdatesJSON.chatterUpdates(new Set<String>{projObj.Id});
            FeedItem[] Flist = new List<FeedItem>();
            FeedItem fpost = new FeedItem();
            fpost.ParentId = projObj.Id;
            fpost.body = Label.APOL_ApolloTestData;
            fpost.type = Label.APOL_TrackedChange;
            Flist.add(fpost);
            
            // assert if the list contains a value of FeedItem. 
            System.assertEquals(Flist.size(), 1);
            APOL_ChatterUpdatesJSON.chatterUpdateWrapper wrapperObj = new 
                APOL_ChatterUpdatesJSON.chatterUpdateWrapper(Label.APOL_ApolloTestData,Label.APOL_ApolloTestData);
            
            APOL_Project__Feed prjFeed = new APOL_Project__Feed();
            Map<String,List<APOL_ChatterUpdatesJSON.chatterUpdateWrapper>> mapChatterUpdates = new 
                Map<String,List<APOL_ChatterUpdatesJSON.chatterUpdateWrapper>>{Label.APOL_ApolloTestData => 
                    new List<APOL_ChatterUpdatesJSON.chatterUpdateWrapper>()};
                        Map<String,String> mapFieldNameLabel = new Map<String,String>();
            
            // calling FillFeedTrack method and passing all the fields of feedtrackchange as parameters to the method. 
            APOL_ChatterUpdatesJSON.FillFeedTrack(new FeedTrackedChange(), prjFeed, Label.APOL_ApolloTestData, 
             mapChatterUpdates,mapFieldNameLabel,Userinfo.getname(), Label.APOL_ApolloTestData,
             Label.APOL_ApolloTestData,Label.APOL_ApolloTestData,Datetime.now());
            
            test.stopTest();
        }
    }
    
}