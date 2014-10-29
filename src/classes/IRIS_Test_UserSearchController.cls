/*
*  Classname : Iriss_Test_UserSearchController 
*   Created By: Deloitte USI    
*   Created Date: 19-Mar-2014
*   Description: This class is the test class for Iriss_UserSearchController class.
*   Version : 0.1 
*   Change Log
*   Version     Description                         Updated By
*    
*/
@isTest

public with sharing class IRIS_Test_UserSearchController{

    static testMethod void testSearchUser(){
        
        User oUser = Iris_Test_Setup.newAssessorUser();
        User usr = [Select id, Name, Email From User Where id =: oUser.id];
        Test.setCurrentPage(Page.Iris_UserSearch);
        ApexPages.currentPage().getParameters().put('userIds', usr.id);
        ApexPages.currentPage().getParameters().put('selectedUserIds', usr.id);  
        Iris_UserSearchController controller = new Iris_UserSearchController();
        controller.saveResponse();
        Iris_UserSearchController checklst = new Iris_UserSearchController();
        System.Assert(checklst.lstUserWrapp.size()>0);
        
    }
}