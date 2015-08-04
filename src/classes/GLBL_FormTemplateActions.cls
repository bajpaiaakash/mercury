/*
*@ Class Name                                                    : GLBL_formTemplateActions
*@ Description                                                   : Utility Class for form assessments including LaunchPad
*@ CreatedBy                                                     : Jayalakshmi Mohanan Pillai
*@ CreatedOn                                                     : 08-20-2014
*@ Modification Log                                              :          
*                                        Added stamping of sequence and helptext from form template question to form template question and answer : on 09-08-2014
*                                        Stamping surrent user as the form executor : on 09-08-2014                     
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
            listFormTemplateQuestion = [SELECT Id, Name, Active__c, Form_Template__c, Helptext__c, Question_Text__c, Sequence__c,Question_Type__c,Mandatory__c,Decimal_Places__c,Character_Limit__c,Attachment_Allowed__c
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
                GLBL_Form_Template__c   temp = [SELECT Id, Name, Notify_User__c, Type__c, Description__c from GLBL_Form_Template__c WHERE ID=:template.id];               
                    formExecution.Source_Form__c = template.id;
                    formExecution.Form_Name__c = template.Name;
                    formExecution.Type__c = template.Type__c;
                    formExecution.Description__c = template.Description__c;
                    formExecution.Form_Executor__c = Userinfo.getUserId();
                    formExecution.Notify_User__c = temp.Notify_User__c;
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
                formExecutionQuestionAnswer.Question_Type__c = iter.Question_Type__c;
                formExecutionQuestionAnswer.Question_Text__c = iter.Question_Text__c;
                formExecutionQuestionAnswer.Sequence__c = iter.Sequence__c;
                formExecutionQuestionAnswer.Helptext__c = iter.Helptext__c;
                formExecutionQuestionAnswer.Mandatory__c = iter.Mandatory__c;
                formExecutionQuestionAnswer.Decimal_Places__c = iter.Decimal_Places__c;
                formExecutionQuestionAnswer.Character_Limit__c = iter.Character_Limit__c;
                formExecutionQuestionAnswer.Attachment_Allowed__c = iter.Attachment_Allowed__c;
                listFormExecQuestionAnswer.add(formExecutionQuestionAnswer);
            }
            
            if (listFormExecQuestionAnswer.size() !=0){
                insert listFormExecQuestionAnswer;
            }
  
        }
        return formExecution;
    }
    
    /**
     * Create form execution based on template Id
     */
    public GLBL_Form_Execution__c createFormExecution(String templateId) {
		try {   
             
                    // Query Form Template questions based upon template id passed
                    listFormTemplateQuestion = [SELECT 
                    								Id, Name, Active__c, Form_Template__c, 
                    								Helptext__c, Question_Text__c, 
                    								Sequence__c,
                    								Question_Type__c,Attachment_Allowed__c,
                    								Mandatory__c, Decimal_Places__c, Character_Limit__c
                                               FROM 
                                               		GLBL_Form_Template_Question__c
                                               WHERE 
                                               		Form_Template__c = : templateId
                                               AND 
                                               		Active__c = true];
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
            if ( templateId != NULL && listFormTemplateQuestion.size() != 0) {  
                try { 
                    GLBL_Form_Template__c   template = [SELECT Id, Name, Notify_User__c, Type__c, Description__c from GLBL_Form_Template__c WHERE Id = :templateId];               
                    formExecution.Source_Form__c = template.Id;
                    formExecution.Form_Name__c = template.Name;
                    formExecution.Type__c = template.Type__c;
                    formExecution.Description__c = template.Description__c;
                    formExecution.Form_Executor__c = Userinfo.getUserId();
                    formExecution.Notify_User__c = template.Notify_User__c;
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
                    formExecutionQuestionAnswer.Question_Type__c = iter.Question_Type__c;
                    formExecutionQuestionAnswer.Question_Text__c = iter.Question_Text__c;
                    formExecutionQuestionAnswer.Sequence__c = iter.Sequence__c;
                    formExecutionQuestionAnswer.Helptext__c = iter.Helptext__c;
                    formExecutionQuestionAnswer.Mandatory__c = iter.Mandatory__c;
                    formExecutionQuestionAnswer.Decimal_Places__c = iter.Decimal_Places__c;
                    formExecutionQuestionAnswer.Character_Limit__c = iter.Character_Limit__c;
                    formExecutionQuestionAnswer.Attachment_Allowed__c = iter.Attachment_Allowed__c;
                    listFormExecQuestionAnswer.add(formExecutionQuestionAnswer);
                }
                if (listFormExecQuestionAnswer.size() !=0){
                    insert listFormExecQuestionAnswer;
                }

  
            }
            return formExecution;
    }
    
    /**
     * fetch form execution based on Id.
     */
    public GLBL_Form_Execution__c getFormExecution(String id) {
    	GLBL_Form_Execution__c formExecution = [SELECT Name, Id, Execution_Status__c 
    											FROM GLBL_Form_Execution__c
    											WHERE Id = :id
    											LIMIT 1][0];
    	return formExecution;
    }
    
    /**
	 * Returns true if this form requires approval, false otherwise
	 */
	public static Boolean isApprovalRequired(String templateId) {
		GLBL_Form_Template__c formTemplate = [SELECT Id, Approval_Status__c, Approval_Required__c
											  FROM GLBL_Form_Template__c
											  WHERE Id = :templateId][0];
			
		if ((formTemplate.Approval_Required__c) && (formTemplate.Approval_Status__c != FORM_Constants.APPROVAL_STATUS)) {
			return true;
		}

		return false;
		
	}
	
	/**
	 * Checks if we can access the form template.
	 * @return true if a record is found, false otherwise
	 */
	public static Boolean isFormTemplateAccessible(String templateId) {
		
		List<GLBL_Form_Template__c> formTemplateList = [SELECT Id FROM GLBL_Form_Template__c WHERE Id = :templateId];
		
		if (formTemplateList.size() == 1) { // there will only ever be 1 at most.
			return true;
		}
		return false;
		
	}
	
	/**
	 * Checks the form template and returns True if the Active__c flag is ticked, False otherwise.
	 * Used to determine whether to direct the user to the access denied page
	 */
	public static Boolean isFormTemplateActive(String templateId) {
		
		GLBL_Form_Template__c formTemplate = [	SELECT Id, Active__c 
												FROM GLBL_Form_Template__c
												WHERE Id = :templateId][0];
												
		return formTemplate.Active__c;
	}
     
}