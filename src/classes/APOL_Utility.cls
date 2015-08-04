/****************************************************************************************************************************************** 
* Class Name   : APOL_Utility
* Description  : It has the list of utility methods , which are called from the controller of Chord Page. 
* Created By   : Deloitte Consulting
*****************************************************************************************************************************************/
public with sharing class APOL_Utility {

    /*
    * @Method Name                    :  getHomeUrl
    * @Description                    :  Getting Home URL to redirect to force.com from Chord Page.
    * @Return Type                    :  String
    */
    public static String getHomeUrl() {
        String homeURL = '';
        List<AppMenuItem> appMenuItemLst = new List<AppMenuItem>();
        appMenuItemLst = [Select StartUrl from AppMenuItem where Name = :Label.APOL_Apollo_App_Name];
        for(AppMenuitem appObj : appMenuItemLst) {
            homeURL= appObj.StartUrl;
        }
        homeURL = homeURL.substring(homeURL.lastindexOf(Label.APOL_HomeUrl.substring(19))+1);
        homeURL= Label.APOL_Homeurl+homeURL;
        return homeUrl;
    }

    /*
    * @Method Name                    :  Unfollow
    * @Description                    :  Used to unfollow a project which the user is following. 
    It takes the project Id as parameter and returns true if it executes successfully.
    * @Return Type                    :  String
    */
    public Static Boolean Unfollow(String projectId) {
        List<EntitySubscription> EsLst = [Select id from entitysubscription where parentid =: projectId
        and SubscriberId = :Userinfo.getUserid() limit 1];
        if(EsLst.Size() > 0) {
            Database.Deleteresult savRes = database.delete(esLst[0],false);
            if(savRes.isSuccess() == false) {
                APOL_Utility.insertErrorLog(savRes.getErrors());
            } return savRes.isSuccess();
        } else return false;
    }
    
    /*
    * @Method Name                    :  follow
    * @Description                    :  Used to follow a project . It takes the project Id as parameter and
    returns true if it executes successfully. If the user is already following
    the project, it returns false;
    * @Return Type                    :  String
    */
    public Static Boolean Follow(String ProjectId) {
        List<EntitySubscription> EsLst = [Select id from entitysubscription where parentid =: projectId
        and SubscriberId = :Userinfo.getUserid() Limit 1];
        if(EsLst.Size() == 0) {
            EntitySubscription esObj = new EntitySubscription(ParentId = ProjectId,SubscriberId = userinfo.getuserid());
            Database.saveresult savRes = database.insert(esObj,false);
            if(savRes.isSuccess() == false) {
                APOL_Utility.insertErrorLog(savRes.getErrors());
                } return savRes.isSuccess();
        } else return false;
    }
    
    /*
    * @Method Name                    :  projectFollow
    * @Description                    :  Used to follow/unfollow a project . It takes the project Id and following as parameter.
    IF following is 1, then user follows the project. If following is 0,
    then the user unfollows the project.
    * @Return Type                    :  String
    */
    public static Boolean projectFollow(String projectId,Integer follow)    {
        Boolean isSuccess = true;
        if(follow == 1) {
            isSuccess = follow(projectId);
        } else {
            isSuccess = unFollow(projectId);
        } return isSuccess;
    }
    
    /*
    * @Method Name                    :  isNull
    * @Description                    :  Used in Project JSON. If the string is null, it returns a blank string.
    * @Return Type                    :  String
    */
    public static String isNull(String projectValue) {
        if(projectValue == null) {
            projectValue = '';
        }
        return projectValue;
    }
    
    /*
    * @Method Name                    :  insertErrorLog
    * @Description                    :  Used to insert a record in GLBL Error Log , once an exception occurs while 
    *                                    following / unfollowing a project record from Chord Page. 
    * @Return Type                    :  void
    */
    public static void insertErrorLog(List<Database.Error> errorLst) {
        List<GLBL_Error_Log__c> errLogLst = new List<GLBL_Error_Log__c>();
          for(Database.Error e : errorLst) {
                    errLogLst.add(new GLBL_Error_Log__c( Error_Datetime__c= DateTime.Now(),
                    Error_Message__c= e.getMessage(),Running_User__c = UserInfo.getUserId() ,Stack_Trace__c = e.getStatusCode()+''));
                } insert errLogLst;
    }
}