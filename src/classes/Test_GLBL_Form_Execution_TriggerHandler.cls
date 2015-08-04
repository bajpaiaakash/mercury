/* Class Name  : Test_GLBL_Form_Execution_TriggerHandler 
* Description  : Test Class for GLBL_Form_Execution_TriggerHandler 
* Created By   : Goutham
* Created Date : 12/11/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

@isTest  (SeeAllData = false)
public class Test_GLBL_Form_Execution_TriggerHandler{

    static testMethod void Execution_TriggerHandler() {
    
        System.runAs(FORM_DataFactory.createUser('FORM_Form_Executor')) {
        
            Test.startTest();
              
              //Inserting a Form templated Record
                List<GLBL_Form_Template__c> lTemplates = FORM_DataFactory.createTemplates(1);
                
                //Adding current user to list of users
                list<User> lUsers = New list<User>();
                User usr = [SELECT id FROM User WHERE id=:Userinfo.getUserid()];
                lUsers.add(usr);
                User frmCreator = FORM_DataFactory.createUser('FORM_Form_Creator');
                lUsers.add(frmCreator);
                            
                
                //Inserting form team member so that he will follow the template record inserted above
                List<GLBL_Form_Team__c> lFormTeamMembers = FORM_DataFactory.createFormTeams(lUsers,lTemplates[0]);
                
                 //Inserting a Form Execution record 
                List<GLBL_Form_Execution__c> lExecutions = FORM_DataFactory.createExecutions(1,lTemplates[0]);
                
                
                List<GLBL_Form_Execution__Share> lformExecShareafraddTeam = new List<GLBL_Form_Execution__Share>();
                lformExecShareafraddTeam = [SELECT id,ParentId,UserOrGroupId,RowCause,AccessLevel
                                  FROM GLBL_Form_Execution__Share
                                  WHERE ParentId=: lExecutions[0].id 
                                  AND RowCause =:Schema.GLBL_Form_Execution__Share.RowCause.FormTeamMember__c];
                                  
                System.debug('Size of lformExecShareafraddTeam' + lformExecShareafraddTeam.size());         
                
                // Since there are two users in forms team , one being the owner of form execution and other a random user
                // there will be only one form share record created for the random user 
                system.assertequals(lformExecShareafraddTeam.size(),1);
                
                
               
                
                
                          
            Test.stopTest();
        }
    }
    
    /**
     * Tests the scoring engine. This should work irrespective of the running user.
     */
    static testMethod void testScoringEngine () {
    	
    	// create form template and assign score descriptions
    	List<GLBL_Form_Template__c> formTemplates = FORM_DataFactory.createTemplates(1);
    	GLBL_Form_Template__c template = formTemplates[0];
    	template.Enable_Scoring__c = true;
    	template.Score_A_Description__c = 'Force.com';
    	template.Score_B_Description__c = 'LillyWeb';
    	template.Score_C_Description__c = 'Heroku';
    	update template;
    	
    	// create picklist question & answer option and assign scores
    	List<GLBL_Form_Template_Question__c> questions = FORM_DataFactory.createPicklistQuestions(1, template);
    	GLBL_Form_Template_Question__c question = questions[0];
    	List<GLBL_Form_Template_Answer_Option__c> options = FORM_DataFactory.createAnswerOptions(1, question);
    	GLBL_Form_Template_Answer_Option__c option = options[0];
    	option.Score_A__c = 100;
    	option.Score_B__c = 0;
    	option.Score_C__c = 0;
    	update option;
    	
    	// complete an execution and answer 
    	GLBL_Form_Execution__c execution = (new GLBL_FormTemplateActions()).createFormExecution(template.Id);
    	GLBL_Form_Execution_Question_Answer__c executionAnswer = [	SELECT 
    																	Id, Response_Text__c,
    																	Total_Score_A__c, Total_Score_B__c, Total_Score_C__c
    																FROM
    																	GLBL_Form_Execution_Question_Answer__c
    																WHERE
    																	Source_Question__c = :question.Id
    																LIMIT 1][0];
    	executionAnswer.Response_Text__c = option.Answer_option__c;
    	update executionAnswer;
    	
    	// check the scores have been stamped on the answer
    	executionAnswer = [	SELECT 
								Id, Response_Text__c,
								Total_Score_A__c, Total_Score_B__c, Total_Score_C__c
							FROM
								GLBL_Form_Execution_Question_Answer__c
							WHERE
								Source_Question__c = :question.Id
							LIMIT 1][0];
							
		System.assertEquals(executionAnswer.Total_Score_A__c, option.Score_A__c);
    	
    	//check the aggregate scores are correct by requerying for the execution
    }
}