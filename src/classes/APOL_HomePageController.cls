/****************************************************************************************************************************************** 
* Class Name   : APOL_HomePageController
* Description  : the Controller for the Chord Page. It is used to generate the JSON for 
                 Project Details, Find Filters, Chatter Updates. It has list of methods as remoting functions, 
                 which are called from Angular JS on the Page.                  
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
public with sharing class APOL_HomePageController {
    public String loggedinUserName{set;get;}
    public String homeURL{set;get;}
    public String userAvatar {set;get;}
    /*
    * @Method Name                    :  FindFilters
    * @Description                    :  Getting Dynamic JSON for Find Filter .
    * @Return Type                    :  Object
    */
    @RemoteAction
    public static Object FindFilters()   {
        return APOL_FindFilterJson.FindFilters();
    }
    /*
    * @Method Name                    :  ProjectDetails
    * @Description                    :  Getting Dynamic JSON for Projects .
    * @Return Type                    :  Object
    */
    @RemoteAction
    public static Object ProjectDetails()  {
        return APOL_ProjectJson.ProjectDetails();
    }
    /*
    * @Method Name                    :  controller for the APOL_Home_Page
    * @Description                    :  getting the global path of the static resource url on Page Load ,
    *                                    So that all the Image URLs are appended with the correct path  .
    * @Return Type                    :  String
    */
    public APOL_HomepageController()    {
        LoggedinUserName = Userinfo.getName();
        homeUrl = APOL_Utility.getHomeUrl();
        for(User user : [Select fullPhotoUrl from User where Id = :userinfo.getuserid()]) {
            userAvatar = user.fullPhotoUrl;
        }
        
    }
    /*
    * @Method Name                    :  projectFollow
    * @Description                    :  used to follow the project with the specified 
                                         project Id. 0 is for unfollow, 1 is for follow 
    * @Return Type                    :  Boolean
    */
    @RemoteAction
    public static Boolean projectFollow(String projectId,Integer follow)    {
        return APOL_Utility.projectFollow(projectId,follow);
    }
}