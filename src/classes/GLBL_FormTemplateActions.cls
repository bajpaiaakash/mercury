/*
*@ Class Name                                                    : GLBL_formTemplateActions
*@ Description                                                   : Utility Class for form assessments including LaunchPad
*@ CreatedBy                                                     : Jayalakshmi Mohanan Pillai
*@ CreatedOn                                                     : 08-20-2014
*@ Modification Log 			                                 : 			
*                                        Added stamping of sequence and helptext from form template question to form template question and answer : on 09-08-2014
*                                        Stamping surrent user as the form executor	: on 09-08-2014						
*/

public with sharing class GLBL_FormTemplateActions { 
	
	// Class level Variable declaration
	public Static Final String TYPE_LAUNCHPAD = 'Launchpad Assessment';
	public List<GLBL_Form_Execution_Question_Answer__c> listFormExecQuestionAnswer = new List< GLBL_Form_Execution_Question_Answer__c>();
	public GLBL_Form_Execution__c formExecution = new GLBL_Form_Execution__c();
	public List<GLBL_Form_Template_Question__c> listFormTemplateQuestion = new List<GLBL_Form_Template_Question__c>();
	public GLBL_Form_Template__c   formTemplate = new GLBL_Form_Template__c();


        public GLBL_FormTemplateActions(){
                  //Constructor
        }
        
        /* 
          * @Method Name                    :  createFormExecution 
          * @Description                    :  Method to store snapshot of the form template and all its active questions 
          * @Return Type                    :  GLBL_Form_Execution
          * @Param                          :  
                                            templateId: Form Template 
        */
        public GLBL_Form_Execution__c createFormExecution(GLBL_Form_Template__c template) {
			try {   
                    
									 
                    // Query Form Template questions based upon template id passed
                    listFormTemplateQuestion = [SELECT id, Name, Active__c, Form_Template__c, Helptext__c, Question_Text__c, Sequence__c
											   FROM GLBL_Form_Template_Question__c
											   WHERE Form_Template__c = : template.id
											   AND Active__c = true];
			} 
			catch(QueryException E) {
					system.debug('Exception occurred during query of form template or form template question' + e);
					GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
					                                                 Error_Message__c= e.getMessage(),
					                                                 Running_User__c = UserInfo.getUserId() ,
					                                                 Stack_Trace__c = e.getStackTraceString());	
					insert errlog;
					return null ;
			}

			// Creating and inserting the form execution
			if ( template != NULL && listFormTemplateQuestion.size() != 0) {  
				try {                      
						formExecution.Source_Form__c = template.id;
						formExecution.Type__c = template.Type__c; 
						formExecution.Form_Executor__c = Userinfo.getUserId();
						insert formExecution;
				}
				catch(DMLException e) {
					System.debug('Exception occurred during insert of form Execution' + e);
					GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
					                                                 Error_Message__c= e.getMessage(),
					                                                 Running_User__c = UserInfo.getUserId() ,
					                                                 Stack_Trace__c = e.getStackTraceString());	
					insert errlog;				
					return null ;
				}
    
				// Creating and inserting the form execution Question & Answer
				for(GLBL_Form_Template_Question__c  iter  : listFormTemplateQuestion) {   
					GLBL_Form_Execution_Question_Answer__c formExecutionQuestionAnswer = new GLBL_Form_Execution_Question_Answer__c();
					formExecutionQuestionAnswer.Form_Execution__c = formExecution.id;
					formExecutionQuestionAnswer.Source_Question__c = iter.id;
					formExecutionQuestionAnswer.Question_Text__c = iter.Question_Text__c;
					formExecutionQuestionAnswer.Sequence__c = iter.Sequence__c;
					formExecutionQuestionAnswer.Helptext__c = iter.Helptext__c;
					listFormExecQuestionAnswer.add(formExecutionQuestionAnswer);
				}
				if (listFormExecQuestionAnswer.size() !=0){
					insert listFormExecQuestionAnswer;
				}

  
			}
			return formExecution;


    }
     
     
}