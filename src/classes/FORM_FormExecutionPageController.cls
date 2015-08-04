/**
 * Page controller to handle user exeuction of a form. 
 * Takes care of fectching the execution record, the associated questions, and saving the answers
 */
public with sharing class FORM_FormExecutionPageController {

	// class variables
	public String templateId {get; set;}
	public String executionId {get; set;}
	public GLBL_Form_Template__c formTemplate {get; set;}
	public GLBL_Form_Execution__c formExecution {get; set;}
	public List<GLBL_Form_Execution_Question_Answer__c> formExecutionQuestionAnswers {get; set;}
	public List<List<GLBL_Form_Execution_Question_Answer__c>> formExecutionQuestionAnswersMap {get; set;}
	public Map<Id, List<GLBL_Form_Template_Answer_Option__c>> formTemplateAnswerOptionsMap {get; set;}
	public Map<Id,List<SelectOption>> formTemplateSelectOptionsMap {get; set;}
	public Boolean isFormSaved {get; set;}
	public Boolean isFormSubmitted {get; set;}
	public Boolean isFormCancelled {get; set;}
	//Map to store skip to questions: Source Question ID, Map of <Answer Option ID, Skip To Question ID>
	//because multiple answer options in the same question can have their own skip to questions associated
	public Map<Id, Map<String, Id>> answerOptionsSkipToQuestionsMap {get; set;}
	
	public String twoColumnOpenDiv {
		get {
			return '<div class="row">';
		}
		set;
	}

	public String twoColumnCloseDiv {
		get {
			return '</div>';
		}
		set;
	}
	
	/**
	 * Constructor
	 */
	public FORM_FormExecutionPageController() {
		
		isFormSaved = false;
		isFormSubmitted = false;
		isFormCancelled = false;
		
		// get the template and execution Ids
		templateId = ApexPages.currentPage().getParameters().get('templateId');
		executionId = ApexPages.currentPage().getParameters().get('executionId');
		
		// get the template record
		formTemplate = [	SELECT Id, Logo_Image__c, Two_Column_Layout__c
							FROM GLBL_Form_Template__c
							WHERE Id = :templateId
							LIMIT 1][0];
							
		// get the execution record
		formExecution = [	SELECT Id, Name, Form_Name__c, Execution_Status__c, Source_Form__c, OwnerId, Description__c 
							FROM GLBL_Form_Execution__c
							WHERE Id = :executionId
							LIMIT 1][0];
		
		// get execution question and answers list (and map for easy k,v referencing)
		formExecutionQuestionAnswers = [SELECT Id, Name, Form_Execution__c, Source_Question__c, Helptext__c, Question_Text__c,  
		                                       Sequence__c,Question_Type__c, Mandatory__c, Decimal_Places__c, Character_Limit__c, 
		                                       Response_Text__c, Response_Number__c,Response_Boolean__c,Attachment_Allowed__c
										FROM GLBL_Form_Execution_Question_Answer__c
										WHERE Form_Execution__c = :executionId
										ORDER BY Sequence__c ASC];
		
		formExecutionQuestionAnswersMap = new List<List<GLBL_Form_Execution_Question_Answer__c>>();
		for (Integer i = 0; i < formExecutionQuestionAnswers.size(); i += 2) {
			List<GLBL_Form_Execution_Question_Answer__c> tempList = new List<GLBL_Form_Execution_Question_Answer__c>();
			tempList.add(formExecutionQuestionAnswers.get(i));
			if (i+1 < formExecutionQuestionAnswers.size()) {
				tempList.add(formExecutionQuestionAnswers.get(i+1));
			}
			formExecutionQuestionAnswersMap.add(tempList);
		}
		
		
		// get picklist answer options
		formTemplateAnswerOptionsMap = new Map<Id, List<GLBL_Form_Template_Answer_Option__c>>();
		formTemplateSelectOptionsMap = new Map<Id, List<SelectOption>>();
		
		// first get the Ids of all the picklist questions
		List<Id> picklistQuestionIds = new List<Id>();
		for (GLBL_Form_Execution_Question_Answer__c formExecutionQuestionAnswer : formExecutionQuestionAnswers) {
			if (formExecutionQuestionAnswer.Question_Type__c == FORM_Constants.QUESTION_TYPE_PICKLIST) {
				picklistQuestionIds.add(formExecutionQuestionAnswer.Source_Question__c);
			}
		}
		
		// then get all the related answer options
		List<GLBL_Form_Template_Answer_Option__c> templateAnswerOptions = [	SELECT 	Id,		
																					Answer_option__c,
																					Form_Template_Question__c,
																					Form_Template_Question__r.Sequence__c,
																					Helptext__c, Sequence__c, Skip_To_Question__c
																			FROM GLBL_Form_Template_Answer_Option__c
																			WHERE Form_Template_Question__c IN :picklistQuestionIds
																			ORDER BY Form_Template_Question__r.Sequence__c, Sequence__c ASC];
		
		// then put those answer options into 2 maps. 1 for k,v referencing, and one for the VF page selectOption
		
		// first initialise the maps for each ID (in case someone hasn't put any options in yet)
		for (Id questionId : picklistQuestionIds) {
			formTemplateAnswerOptionsMap.put(questionId, new List<GLBL_Form_Template_Answer_Option__c>());
			formTemplateSelectOptionsMap.put(questionId, new List<SelectOption>());
			formTemplateSelectOptionsMap.get(questionId).add(new SelectOption(FORM_Constants.ANSWER_OPTION_DEFAULT_TEXT, FORM_Constants.ANSWER_OPTION_DEFAULT_TEXT));
		}
		
		answerOptionsSkipToQuestionsMap = new Map<Id, Map<String, Id>>();
		// then add each answer option as a select option
		for (GLBL_Form_Template_Answer_Option__c answerOption : templateAnswerOptions) {
			formTemplateAnswerOptionsMap.get(answerOption.Form_Template_Question__c).add(answerOption);
			formTemplateSelectOptionsMap.get(answerOption.Form_Template_Question__c).add(new SelectOption(answerOption.Answer_Option__c,answerOption.Answer_Option__c));

			if (answerOption.Skip_To_Question__c != null) {
				//Add this to a map so that it can be referenced on the template
				Map<String, Id> tempSkipToMap;
				//Check if this answerOption's Form Template Question already has an entry in the map
				if (answerOptionsSkipToQuestionsMap.containsKey(answerOption.Form_Template_Question__c)) {
					tempSkipToMap = answerOptionsSkipToQuestionsMap.get(answerOption.Form_Template_Question__c);
				} else {
					tempSkipToMap = new Map<String, Id>();
				}
				//Add to skip_to_question map so that we can reference it on the template
				tempSkipToMap.put(answerOption.Answer_option__c, answerOption.Skip_To_Question__c);
				answerOptionsSkipToQuestionsMap.put(answerOption.Form_Template_Question__c, tempSkipToMap);
			}
		}
				
	}
	
	
	
	
	/**
	 * Saves answer value to the associated question
	 */
	 @RemoteAction
	public static Boolean remoteSaveAnswer(String answer, String questionId) {
		System.debug('Remote call to save answer:' + answer + ' for question:'  + questionId);
		try {
			
			//get the question and answer record to save to
			GLBL_Form_Execution_Question_Answer__c questionAnswer = [	SELECT Id, Question_Type__c, Response_Text__c, Response_Number__c
																		FROM GLBL_Form_Execution_Question_Answer__c
																		WHERE Id = :questionId
																		][0];
				
			//save the value to the right type of field
			if (questionAnswer.Question_Type__c == FORM_Constants.QUESTION_TYPE_PICKLIST) {
				if (answer == FORM_Constants.ANSWER_OPTION_DEFAULT_TEXT) {
					questionAnswer.Response_Text__c = null;
				}
				else {
					questionAnswer.Response_Text__c = answer;
					// TODO scoring
				}
			}
			else if (questionAnswer.Question_Type__c == FORM_Constants.QUESTION_TYPE_TEXT) {
				questionAnswer.Response_Text__c = answer;
			}
			else if (questionAnswer.Question_Type__c == FORM_Constants.QUESTION_TYPE_NUMBER) {
				questionAnswer.Response_Number__c = Decimal.ValueOf(answer);
				questionAnswer.Response_Text__c = answer;
			}
			else if (questionAnswer.Question_Type__c == FORM_Constants.QUESTION_TYPE_CURRENCY) {
				questionAnswer.Response_Number__c = Decimal.ValueOf(answer);
				questionAnswer.Response_Text__c = answer;
			}
			update questionAnswer;
			
			return true;
		}
		catch (Exception e) {
            System.debug('Exception occured when remote saving answer:' + answer + ' for question '  + questionId + '\n' + e + '\n' + e.getStackTraceString());
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                             Error_Message__c= e.getMessage(),
                                                             Running_User__c = UserInfo.getUserId() ,
                                                             Stack_Trace__c = e.getStackTraceString()); 
			return false;
		}
	}
	
	/**
	 * Submit the form / change the execution status to complete.
	 */
	public void submitForm () {
        
        try {
        	formExecution.Execution_Status__c = 'Complete';
        	formExecution.Completed_date_time__c = System.now();
            update formExecution;
            isFormSubmitted = true;
            
            GLBL_Form_Template__c temp = [SELECT id,Name from GLBL_Form_Template__c where id =:formExecution.Source_Form__c];                         
			FeedItem fItem = new FeedItem(); 
			fItem.Type = 'LinkPost'; 
			fItem.ParentId = formExecution.Source_Form__c;
			fItem.Body = userinfo.getName()+' '+Label.FORM_Completion_Chatter_Prefix+' ' + temp.name+Label.FORM_Completion_Chatter_Suffix;
			fItem.Title=formExecution.Name;
			fItem.Linkurl=URL.getSalesforceBaseUrl().toExternalForm()+'/'+formExecution.id;						 
			insert fItem;
		
        }
        catch (Exception e) {
            system.debug('Exception occured during the change of execution status to complete' + e);
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c (	Error_Datetime__c= DateTime.Now(),
		                                                        Error_Message__c= e.getMessage(),
		                                                        Running_User__c = UserInfo.getUserId() ,
		                                                        Stack_Trace__c = e.getStackTraceString());   
            insert errlog;              
                
        }
	}
	
	/**
	 * This doesn't actually do anything other than show the message,  
	 * as we save the form on the fly anyway
	 */
	public void saveForm () {
		System.debug('## Saving the form');
		isFormSaved = true;
		
	}
	
	/**
     * Cancel the form execution and change the status of execution record to 'Cancelled'
     */
	public void cancelForm () {
		
		try {
		  formExecution.Execution_Status__c = 'Cancelled';
			update formExecution;
			isFormCancelled = true;
			
		}
		catch (Exception e) {
			system.debug('Exception occured during the change of execution status to Cancelled' + e);
			GLBL_Error_Log__c errLog = new GLBL_Error_Log__c (  Error_Datetime__c= DateTime.Now(),
															Error_Message__c= e.getMessage(),
															Running_User__c = UserInfo.getUserId() ,
															Stack_Trace__c = e.getStackTraceString());   
			insert errlog;			  
				
		}  

	}
	
	
	
	
}