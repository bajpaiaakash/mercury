/**
* @author Frank Neezen 
* @date   10/10/2012 
* @description  Test class for Planning Poker. Due to time constraints we are not asserting all data.
*
* Modification Log    :
* ------------------------------------------------------------------------------------------------
* Developer                 Date                    Description
* ---------------         -----------             ----------------------------------------------
* Frank Neezen             10/10/2012             Original Version
*/

@isTest(SeeAllData = false)
public with sharing class Test_PlanningPoker {
    
    
    /******************************************
     * @descroption Test function for the planning poker controller
     * @method  testPlanningPoker
     * @param   none
     * @return  void
     */
     
    static testMethod void testPlanningPoker() {
        
        
        //Create a test uer
        User oUser = runAsUser('PP_User');
        Database.insert(oUser);
        
            //Test enter Session
        System.runAs(oUser){
            //create a project
            MICO_Project__c pro = new MICO_Project__c();
            pro.Name = 'Test Project';
            insert pro;
            
            //Create a user story
            MICO_User_Story__c oUserStory = new MICO_User_Story__c();
            //oUserStory.User_Story__c = 'Test User Story';
            oUserStory.Project__c = pro.Id;
            Database.insert(oUserStory);
            
            //Set US for session generation
            ApexPages.currentPage().getParameters().put('generateSession',oUserStory.Id);
            Controller_PlanningPoker oControllerSession = new Controller_PlanningPoker();
            oControllerSession.generateSession();
        }
        
        //Fetch the session ID
        MICO_Planning_Poker_Session__c oSession = [ Select Id From MICO_Planning_Poker_Session__c ];
        
        //Fetch content
        MICO_Planning_Poker_Session_Content__c oContent = [ Select Id From MICO_Planning_Poker_Session_Content__c ];
            
        //Test enter Session
        System.runAs(oUser){
            ApexPages.currentPage().getParameters().put('id', oSession.Id);
            Controller_PlanningPoker oController = new Controller_PlanningPoker();
            oController.enterSession();
        
        
            //Test set story
            Controller_PlanningPoker.setStory(oContent.Id);
            
            //Test vote
            Controller_PlanningPoker.vote('5',oSession.Id);
            
            //Test re-estimate
            Controller_PlanningPoker.reEstimate(oSession.Id);
            
            //Test set score
            Controller_PlanningPoker.setScore(oSession.Id,'5','SFDC/Veeva','');
            Controller_PlanningPoker.setScore(oSession.Id,'5','Other','');
            
            //Test get data
            Controller_PlanningPoker.PlanningPokerData oData = Controller_PlanningPoker.getData(oSession.Id);
            
            //Test kick user
            Controller_PlanningPoker.kickUser(oUser.Name, oSession.Id);
        }
        
        
    }
    
     /* @name           runAsUser
     * @description     This function returns an Irish admin user, used to change contact details on irish user.
     * @param           String uniqueKey
     * @return          User
     */ 
      public static User runAsUser(String uniqueKey) {
        return new User(
            Alias = uniqueKey,
            Email = uniqueKey + '@tracker.test',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test' + uniqueKey,
            FirstName = uniqueKey,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [select Id from Profile where Name = 'System Administrator' limit 1].Id,
            TimeZoneSidKey = 'Europe/London',
            Username = uniqueKey + '@tracker_' + Math.round(Math.random() * 10000) + '.com'
        );
    }
}