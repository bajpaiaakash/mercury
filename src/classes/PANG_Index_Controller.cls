/****************************************************************************************************************************************** 
* Class Name   : PANG_Index_Controller
* Description  : Class for PANG_Index Component
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
Public with sharing class PANG_Index_Controller {

    Public String homeUrl {
        get;
        set;
    }
    Public String searchWord {
        get;
        set;
    }
    Public Boolean Studies {
        get;
        set;
    }
    Public Boolean Everything {
        get;
        set;
    }
    Public Boolean DataAssets {
        get;
        set;
    }
    Public Boolean Partnerships {
        get;
        set;
    }
    Public Boolean Requests {
        get;
        set;
    }
    Public Boolean IsInc {
        get;
        set;
    }
    Public String SetTitle {
        get;
        set;
    }
    public list<PermissionSetAssignment> perset;

    //Constructor for Index component
    Public PANG_Index_Controller() {

        Everything = true;
        Studies = true;
        DataAssets = true;
        Partnerships = true;
        Requests = true;

        homeurl = PANG_Index_Controller.gethomeurl();
        
        perset=[SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =:UserInfo.getUserId() AND PermissionSet.Name = 'PANG_RWE_Member' limit 1];
        if (perset.size() >0)
        {
        IsInc= False;
        }
        else 
        {
        IsInc = True;
        SetTitle = 'Coming Soon!';
        }

    }
    
     /* 
    * @Method Name                    :  populateGlobalURL
    * @Description                    :  Method for Referencing tabs on the Page
    * @Return Type                    :  PageReference 
    * @Parameters                     :  None
    */   
    public PageReference populateGlobalURL() {
        if (searchWord != NULL && searchWord != '') {
            string reference;
            reference = '/apex/PANG_Global_Search?searchWord=' + searchWord;
            if (Studies == true) {
                reference += '&Studies=true';
            }
            if (DataAssets == true) {
                reference += '&DataAssets=true';
            }
            if (Partnerships == true) {
                reference += '&Partnerships=true';
            }
            if (Requests == true) {
                reference += '&Requests=true';
            }
            PageReference pageRef = new PageReference(reference);
            pageRef.setRedirect(true);
            return pageRef;
        } else {
            return NULL;
        }
    }
    
     /* 
    * @Method Name                    :  getHomeUrl
    * @Description                    :  Method for Returning back to RWE App
    * @Return Type                    :  String
    * @Parameters                     :  None
    */  
    public static String getHomeUrl() {
        String homeURL = '';
        PANG_Request_FieldId_Settings__c oCustSetting = PANG_Request_FieldId_Settings__c.getOrgDefaults();
        String AppId = oCustSetting.RWE_AppId__c;
        homeURL = homeURL.substring(homeURL.lastindexOf(Label.PANG_Pangaea_HomeURL.substring(19)) + 1);
        homeURL = Label.PANG_Pangaea_HomeURL + AppId;
        return homeUrl;
    }

}