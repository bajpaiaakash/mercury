/****************************************************************************************************************************************** 
* Class Name   : APOL_Test_ProjectJSON 
* Description  : test Class for ProjectJSON
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
@istest(SeeAllData=false)
public class APOL_Test_ProjectJSON {

   
    /* 
    * @Method Name                    :  testProjectDetails
    * @Description                    :  Testing of Project Details method . 
    * @Return Type                    :  void
    */       
    public static testmethod void testProjectDetails() {
        
        User u = APOL_Test_Utility_Class.CreateApolAdmin(); // Creating a user for Apollo Admin
        System.RunAs(u) {
        //Creating Test Projects
        List<APOL_Project__c> projLst = APOL_Test_Utility_Class.createProjects(3);   
        projLst[0].Project_stakeholder_groups__c = Label.APOL_patients.substring(0,Label.APOL_patients.length()-1).tolowercase()
             + ';' + Label.APOL_investigators.substring(0,Label.APOL_investigators.length()-1).tolowercase();
        projLst[0].Geography__c = Label.APOL_ApolloTestData;
        update projlst[0];
        List<APOL_Applied__c> AppLst = APOL_Test_Utility_Class.createApplied(3, projLst[0]);
        
        APOL_HomePageController.projectFollow(projlst[0].Id, 1);
        test.starttest();
        APOL_ProjectJSON cons = new APOL_ProjectJSON();
        Object jsonresp =  APOL_ProjectJSON.ProjectDetails();
        system.assert(jsonresp!=null);
        String jsonrespasString = jsonresp+'';
        system.assert(jsonrespasString.contains(projLst[0].Id));
        test.stoptest();
        }
    }
 }