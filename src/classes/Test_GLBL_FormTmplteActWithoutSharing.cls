/* Class Name  : Test_GLBL_FormTmplteActWithoutSharing
* Description  : Test Class for GLBL_FormTemplateActionsWithoutSharing
* Created By   : Goutham
* Created Date : 10/11/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

@isTest  (SeeAllData = false)

public class Test_GLBL_FormTmplteActWithoutSharing{
    
    static testMethod void FormTmplteActWithoutSharing() {
    
    User runAsUser = FORM_DataFactory.createUser('FORM_Form_Creator');
    System.runas(runAsUser){
    	
    //Adding current user to list of users
    list<User> lUsers = New list<User>();
    User u = [SELECT id FROM User WHERE id=:Userinfo.getUserid()];
    lUsers.add(u);
    
    //Inserting a Form template Record
    List<GLBL_Form_Template__c> lTemplates = FORM_DataFactory.createTemplates(1);
    
    //Making current user follow above template record
    List<EntitySubscription> lEntitySubscriptions = FORM_DataFactory.createEntitySubscriptions(lTemplates);
    
    //Inserting form team member so that he will follow the template record inserted above which he is already following
    List<GLBL_Form_Team__c> lFormTeams = New List<GLBL_Form_Team__c>();
    lFormTeams = FORM_DataFactory.createFormTeams(lUsers,lTemplates[0]);
    
    
    //Making current user follow above template record
    delete lEntitySubscriptions;
    
    //Deleting the form team with current user
    delete lFormTeams;
    
    
    //Inserting form team member so that he will follow the template record inserted above
    List<GLBL_Form_Team__c> lFormTeamMembers = New List<GLBL_Form_Team__c>();

    lFormTeamMembers = FORM_DataFactory.createFormTeams(lUsers,lTemplates[0]);

    
    //Updating the form team member so that he will not follow the template record

    lFormTeamMembers[0].Follow_Template__c=FALSE;
    update lFormTeamMembers;
    List<EntitySubscription> lentitySubscriptionsUnfollow = [SELECT id,parentID,SubscriberID 
                                                     FROM EntitySubscription 
                                                     WHERE parentID =:lTemplates[0].id AND SubscriberID =: lFormTeamMembers[0].id LIMIT 1000];
                                                     
    
    system.assertequals(lentitySubscriptionsUnfollow.size(),0);
    
    //Updating the form team member so that he will follow the template record again
    lFormTeamMembers[0].Follow_Template__c=True;
    update lFormTeamMembers;
    
    List<EntitySubscription> lentitySubscriptionsUnfollow2 = [SELECT id,parentID,SubscriberID 
                                                     FROM EntitySubscription 
                                                     WHERE parentID =:lTemplates[0].id AND SubscriberID =: lFormTeamMembers[0].id LIMIT 1000];
                                                     
        
    //Deleting form team member so that he will follow the template record again

    delete lFormTeamMembers; 
    
    }
}    
}