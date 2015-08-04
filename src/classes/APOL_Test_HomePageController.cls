/****************************************************************************************************************************************** 
* Class Name   : APOL_Test_HomePageController 
* Description  : test Class for APOL_HomePageController
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
@istest(SeeAllData=false)
public class APOL_Test_HomePageController {
    
    /* 
    * @Method Name                    :  testFindfilters
    * @Description                    :  Testing of findfilters method , which will get all the values of the Find Filter
                                         using Describe calls , and create a JSON in the specified format.  
    * @Return Type                    :  void
    */       
    public static testmethod void testFindfilters() {
    User u = APOL_Test_Utility_Class.CreateApolAdmin(); // Creating a user for Apollo Admin
    System.RunAs(u) {
    test.starttest();
    Object jsonresp =  APOL_HomePageController.FindFilters();
    system.assert(jsonresp!=null); 
    String jsonrespasString = jsonresp+'';
    system.assert(jsonrespasString.contains(label.APOL_Business_Unit));
    test.stoptest();
    }
    }
    
    
    /* 
    * @Method Name                    :  testProjectDetails
    * @Description                    :  Testing of Project Details method . 
    * @Return Type                    :  void   
    */       
    public static testmethod void testProjectDetails() {
    User u = APOL_Test_Utility_Class.CreateApolAdmin(); // Creating a user for Apollo Admin
    System.RunAs(u) {    
    APOL_Project__c projectObj = APOL_Test_Utility_Class.createProjects(1)[0];
    projectObj.Project_stakeholder_groups__c = Label.APOL_patients.substring(0,Label.APOL_patients.length()-1).tolowercase()
    + ';' + Label.APOL_investigators.substring(0,Label.APOL_investigators.length()-1).tolowercase();
    projectObj.Geography__c = Label.APOL_ApolloTestData;
    update projectObj;
    List<APOL_Applied__c> AppLst = APOL_Test_Utility_Class.createApplied(3, projectObj);
    test.starttest();
    APOL_HomepageController cons = new APOL_HomepageController();
    Object jsonresp =  APOL_HomePageController.ProjectDetails();
    system.assert(jsonresp!=null);
    String jsonrespasString = jsonresp+''; 
    system.assert(jsonrespasString.contains(projectObj.Id));
    Boolean prjfollow = APOL_HomePageController.projectFollow(projectObj.Id, 1);
    system.assertEquals(prjfollow, true);
        prjfollow = APOL_HomePageController.projectFollow(projectObj.Id, 1);
    system.assertEquals(prjfollow, false);
    Boolean prjunfollow = APOL_HomePageController.projectFollow(projectObj.Id, 0);
    system.assertEquals(prjunfollow, true);
    system.assertNotEquals(prjunfollow, false);
        prjunfollow = APOL_HomePageController.projectFollow(projectObj.Id, 0);
    system.assertEquals(prjunfollow, false);
    test.stoptest();
    }
    }
    
    /* 
    * @Method Name                    :  testGetResourceURL
    * @Description                    :  Testing of Static Resource Method . 
    * @Return Type                    :  void
    */ 
 public static testmethod void testGetResourceUrl() {
    
    User u = APOL_Test_Utility_Class.CreateApolAdmin(); // Creating a user for Apollo Admin
    System.RunAs(u) {    
    test.starttest();
    APOL_HomePageController cont = new APOL_HomePageController();
    system.assertequals(cont.loggedinUserName,userinfo.getName());
    system.assert(cont.homeURL.contains(Label.APOL_Homeurl));
    system.assert(cont.userAvatar!= null);
        APOL_Utility.insertErrorLog(new List<Database.Error>());
    test.stoptest();
    } 
    }

    /* 
    * @Method Name                    :  testProjectDetails
    * @Description                    :  Testing of Project Details method . 
    * @Return Type                    :  void   
    */       
    public static testmethod void testProjectDetailsProjectLead() {
    User u = APOL_Test_Utility_Class.CreateApolProjectLead(); // Creating a user for Apollo Admin
    System.RunAs(u) {    
    APOL_Project__c projectObj = APOL_Test_Utility_Class.createProjects(1)[0];
    projectObj.Project_stakeholder_groups__c = Label.APOL_patients.substring(0,Label.APOL_patients.length()-1).tolowercase()
    + ';' + Label.APOL_investigators.substring(0,Label.APOL_investigators.length()-1).tolowercase();
    projectObj.Geography__c = Label.APOL_ApolloTestData;
    update projectObj;
    List<APOL_Applied__c> AppLst = APOL_Test_Utility_Class.createApplied(3, projectObj);
    test.starttest();
    APOL_HomepageController cons = new APOL_HomepageController();
    Object jsonresp =  APOL_HomePageController.ProjectDetails();
    system.assert(jsonresp!=null);
    String jsonrespasString = jsonresp+''; 
    system.assert(jsonrespasString.contains(projectObj.Id));
    Boolean prjfollow = APOL_HomePageController.projectFollow(projectObj.Id, 1);
    system.assertEquals(prjfollow, true);
        prjfollow = APOL_HomePageController.projectFollow(projectObj.Id, 1);
    system.assertEquals(prjfollow, false);
    Boolean prjunfollow = APOL_HomePageController.projectFollow(projectObj.Id, 0);
    system.assertEquals(prjunfollow, true);
    system.assertNotEquals(prjunfollow, false);
        prjunfollow = APOL_HomePageController.projectFollow(projectObj.Id, 0);
    system.assertEquals(prjunfollow, false);
    test.stoptest();
    }
    }
    
}