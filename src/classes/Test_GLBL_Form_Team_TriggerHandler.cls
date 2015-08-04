/* Class Name  : Test_GLBL_Form_Team_TriggerHandler
* Description  : Test Class for GLBL_Form_Team_TriggerHandler
* Created By   : Venugopal
* Created Date : 4/11/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

@isTest  (SeeAllData = false)
public class Test_GLBL_Form_Team_TriggerHandler{
    
    static testMethod void GLBL_Form_Team_TriggerHandler() {
                
        System.runAs(FORM_DataFactory.createUser('FORM_Advanced_Support_User')) {
        
            Test.startTest();
              
              
            //Inserting a Form templated Record
                List<GLBL_Form_Template__c> lTemplates = FORM_DataFactory.createTemplates(1);
              
            //Inserting a Form Execution record 
                List<GLBL_Form_Execution__c> lExecutions = FORM_DataFactory.createExecutions(1,lTemplates[0]);
                
                //Adding current user to list of users
                list<User> lUsers = New list<User>();
                User u = [SELECT id FROM User WHERE id=:Userinfo.getUserid()];
                User uu = [SELECT id,ProfileID FROM User WHERE IsActive=TRUE AND profile.name ='System Administrator'  LIMIT 1];
                System.Debug('*********'+uu.ProfileID);
                lUsers.add(u);
                //lUsers.add(uu);

                //Inserting form team member so that he will follow the template record inserted above
                List<GLBL_Form_Team__c> lFormTeamMembers = FORM_DataFactory.createFormTeams(lUsers,lTemplates[0]);
                   
            system.assert(lFormTeamMembers!=null);
            system.assertequals(lFormTeamMembers[0].Permission__c, label.FORM_Access_Level_RW);
            
            delete lFormTeamMembers;
              
            Test.stopTest();
        }
    }
}