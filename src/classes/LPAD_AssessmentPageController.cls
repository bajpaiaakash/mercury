public with sharing class LPAD_AssessmentPageController {
	
	// Class level Variable declaration
	public Static Final String TYPE_LAUNCHPAD = 'Launchpad Assessment';	
	public GLBL_Form_Execution__c formExec {get;set;}
	public List<GLBL_Form_Template_Answer_Option__c> listFormTempAnsOption = new List<GLBL_Form_Template_Answer_Option__c>();	
	public List<QuestionAnswerWrap> listQuestionAnswerWrap {get;set;}
	public List<GLBL_Form_Template_Question__c> listFormTemplateQuestion {get;set;}
	public Map<Id,List<GLBL_Form_Template_Answer_Option__c>> mapQuestionAnswers = new Map<Id,List<GLBL_Form_Template_Answer_Option__c>>();
    public Map<Id,List<Selectoption>> mapSelectOption = new Map<Id, List<Selectoption>>();
    public GLBL_Form_Template_Answer_Option__c formTemplateAnswer;
	
	public string nameProject {get;set;}  
	public String ans {get;set;}    
	public String param {get;set;}

	public String assessmentResultHeading {get; set;}
	public String assessmentResultMessage {get; set;}
	public String assessmentResultChatterGroup;
	
	public boolean displayAssessmentResults {get;set;}
	public integer sizeofWrapper {get;set;}
	public id formExecutionId {get;set;}
	public Id formTemplateQuestionId {get;set;}
		
	public GLBL_Form_Execution__c formExecution;
	public GLBL_Form_Execution_Question_Answer__c formExecQuestAnswer;		     
	public GLBL_Form_Template__c formTemplate;
	public String QuestionIDNew {get;set;}
	    	
	
	public class QuestionAnswerWrap{
    	public GLBL_Form_Template_Question__c TempQuest{get;set;}
    	public list<GLBL_Form_Template_Answer_Option__c> listFormTempAnsOptionWrap {get;set;}
    	public list<SelectOption> listAnsOpt {get; set;}
    	public string answerChoosen {get;set;}
    	public boolean displayFeedhelp {get;set;}
    	public String response {get;set;}
    	
    	public QuestionAnswerWrap(GLBL_Form_Template_Question__c temp){
    		TempQuest = temp;
    		listFormTempAnsOptionWrap = new List<GLBL_Form_Template_Answer_Option__c>();
    		listAnsOpt = new List<SelectOption>();
    		answerChoosen = '';
    		displayFeedhelp = false;
    		response = '';
    	}
    }	
	 
	//Constructor
	public LPAD_AssessmentPageController(){
		
		// Query form Template based upon id passed			
		formTemplate =  [SELECT id, name, Active__c, Description__c, Ref__c, Type__c 
						 FROM GLBL_Form_Template__c   
						 WHERE Type__c =: TYPE_LAUNCHPAD AND Active__c =: true
						 ORDER BY CreatedDate DESC LIMIT 1 ]; 
						    
		fetchlistFormTemplateQuestion();		
		createWrapper();
		displayAssessmentResults= false;
		assessmentResultHeading = '';
		assessmentResultMessage = '';
		QuestionIDNew = '';
	
	}
	
	public void init() {
		getAssessmentResultChatterGroup();
	}
	
	public String getAssessmentResultChatterGroup(){
		
		if (assessmentResultChatterGroup == null) {
			try {
				assessmentResultChatterGroup = [SELECT Assessment_Result_Chatter_Group__c FROM LPAD_Settings__c LIMIT 1][0].Assessment_Result_Chatter_Group__c;
			}
			catch (Exception e) {
				System.debug('Error fetching group id from custom setting. Are you sure there is at least 1 record in LPAD_Settings__c?\n' + e);
				GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(	Error_Datetime__c= DateTime.Now(),
	                                                 				Error_Message__c= e.getMessage(),
	                                                 				Running_User__c = UserInfo.getUserId() ,
	                                                 				Stack_Trace__c = e.getStackTraceString(),
	                                                 				Additional_Information__c = 'Error fetching group id from custom setting. Are you sure there is at least 1 record in LPAD_Settings__c?'
	                                                 				);	
				insert errlog;
			}
			finally {
				if (String.isEmpty(assessmentResultChatterGroup)) {
					assessmentResultChatterGroup = UserInfo.getUserId();
				}
			}
		}
		
		return assessmentResultChatterGroup;
	}
	
	/**
	 * Fetch the latest form template of type launchpad, and create an execution for it.
	 */
	public GLBL_Form_Execution__c getformExecution(){			
		if(formExecution == NULL){
			system.debug('++++Form execution getting created');
			GLBL_FormTemplateActions formAction = new GLBL_FormTemplateActions();
			if(formTemplate == NULL){
			 // Query form Template based upon id passed			
			GLBL_Form_Template__c formTemplate =  [SELECT id, name, Active__c, Description__c, Ref__c, Type__c 
										 FROM GLBL_Form_Template__c   
										 WHERE Type__c =: TYPE_LAUNCHPAD AND Active__c =: true
										 ORDER BY CreatedDate DESC LIMIT 1 ];
			}							 
			formExecution = formAction.createFormExecution(formTemplate);
		}		
		return formExecution;
		
	}
	
	
	//Getting the list of questions associated with the particular execution being carried out
	public List<GLBL_Form_Template_Question__c> fetchlistFormTemplateQuestion(){
		system.debug('========entered fetchlistFormTemplateQuestion');
		if(formTemplate.Id != NULL){
		        // Query Form Template questions 
		        listFormTemplateQuestion = [SELECT id, Name, Active__c, Form_Template__c, Helptext__c, Question_Text__c, Sequence__c
											FROM GLBL_Form_Template_Question__c 
											WHERE Form_Template__c = : formTemplate.Id AND Active__c =: true 
											ORDER BY Sequence__c ];
				
				System.debug('====listFormTemplateQuestion' + listFormTemplateQuestion);
											
				List<id> formTempIdList = new List<id>();										
			    for(GLBL_Form_Template_Question__c Ques:listFormTemplateQuestion){
			    	formTempIdList.add(Ques.id);		    	
			    }								
				
				listFormTempAnsOption =  [SELECT id,Answer_option__c, Helptext__c, Form_Template_Question__c, Score_A__c, Score_B__c, Score_C__c, Score_D__c, Score_E__c, Sequence__c
	         	                         FROM GLBL_Form_Template_Answer_Option__c
	         	                         WHERE Form_Template_Question__c IN: formTempIdList
	         	                         ORDER BY Sequence__c];	
	         	                         
	         	System.debug('====listFormTempAnsOption' + listFormTempAnsOption);
	         	                        				
				for(GLBL_Form_Template_Answer_Option__c ansOpt: listFormTempAnsOption){
					if(mapQuestionAnswers.containsKey(ansOpt.Form_Template_Question__c)){
						mapQuestionAnswers.get(ansOpt.Form_Template_Question__c).add(ansOpt);
					}
					else{
						mapQuestionAnswers.put(ansOpt.Form_Template_Question__c,new List<GLBL_Form_Template_Answer_Option__c>{ansOpt} );
					}
					
					SelectOption sp = new SelectOption(ansOpt.Answer_option__c,ansOpt.Answer_option__c);
					
	    			if(mapSelectOption.containsKey(ansOpt.Form_Template_Question__c)){    				
						mapSelectOption.get(ansOpt.Form_Template_Question__c).add(sp);
					}
					else{
						SelectOption spdefault = new SelectOption('None','None');
						mapSelectOption.put(ansOpt.Form_Template_Question__c,new List<SelectOption>{spdefault,sp});
						
					}
				}
				
				return listFormTemplateQuestion;
			}									
		    else {
		    	return NULL;
		    } 
					
	}
    
    /**
     * Filling up wrapper class to get the Question to answer appear in the form
     */
    public void createWrapper(){
    	system.debug('========listFormTemplateQuestion in wrapper' + listFormTemplateQuestion);
    	listQuestionAnswerWrap = new List<QuestionAnswerWrap>();
    	for(GLBL_Form_Template_Question__c iter : listFormTemplateQuestion){
			    QuestionAnswerWrap Awrap = new QuestionAnswerWrap(iter);			
			    for(GLBL_Form_Template_Answer_Option__c r : mapQuestionAnswers.get(iter.Id)){
			        Awrap.listFormTempAnsOptionWrap.add(r);			        
			    }
			    for(SelectOption sp: mapSelectOption.get(iter.Id)){
			    	Awrap.listAnsOpt.add(sp);
			    }
			    listQuestionAnswerWrap.add(Awrap) ;	
			}
	    sizeofWrapper =  listQuestionAnswerWrap.size();		
    }
    
    /**
     * determines the helptext to show for a selected answer option
     */
    public pagereference renderHelpAndCalculate(){    	
    	system.debug('+++IN DO SOMETHING ++++');
    	formExecutionId =  getformExecution().id;
        system.debug('+++QuestionIDNew' + QuestionIDNew);
        system.debug('+++listQuestionAnswerWrap' + listQuestionAnswerWrap);
        system.debug('ans' + ans);                   
               
       
        formTemplateQuestionId = Id.valueof(QuestionIDNew); 
        List<GLBL_Form_Template_Answer_Option__c> currAnsweroptList = mapQuestionAnswers.get(formTemplateQuestionId);
        for(QuestionAnswerWrap Qwrap: listQuestionAnswerWrap){
        	if(Qwrap.tempQuest.Id == formTemplateQuestionId){
	         for(GLBL_Form_Template_Answer_Option__c frmAnsOpt : currAnsweroptList){
	         	 if(frmAnsOpt.Answer_option__c == ans){ 
	         	      formTemplateAnswer = frmAnsOpt;
	         	      Qwrap.response = frmAnsOpt.Helptext__c;
	         	      Qwrap.displayFeedhelp = true;
	         	      Qwrap.answerChoosen = ans;
	         	      system.debug('formTemplateanswer -- answerchoosen' + formTemplateAnswer + Qwrap.answerChoosen);
	         	 }
	         	 else if(ans=='None'){
	         	 	  Qwrap.displayFeedhelp = false;
	         	 }     
	         	 system.debug('=====Qwrap' + Qwrap);     
	         }
        	}  
        }
        
               
	        // calculation of final scores
	    	calculateScores(formExecutionId);
         	
    	return null;
    }
    
     
    /**
     * inserts the Project record, associates the form execution to it, and completes the form execution
     */
    public pagereference createProjectonSubmit(){
    	
    	formExecutionId =  getformExecution().id;
    	
    	// creation of new proj
    	MICO_Project__c aProj = new MICO_Project__c();
    	aProj.Name = nameProject;
    	insert aProj;
    	system.debug('====formExec' + formExecution);
    	
    	displayAssessmentResults = true;
    	
    	// query again to get the fresh scores : rolled up and not the stale ones
    	formExec = [SELECT Id, Aggregate_Score_A__c, Aggregate_Score_B__c, Aggregate_Score_C__c, Aggregate_Score_D__c, 
							       Aggregate_Score_E__c, Description__c, Execution_Status__c, Source_Form__c, Type__c 
		            FROM GLBL_Form_Execution__c
		            WHERE id =:formExecutionId];
		            
    	system.debug('===Comparison' + formExec.Aggregate_Score_A__c + '=='+ formExec.Aggregate_Score_B__c + '==' + formExec.Aggregate_Score_C__c
    	             + '==' + formExec.Aggregate_Score_D__c + '==' + formExec.Aggregate_Score_E__c + '==' + UserInfo.getFirstName() );
    	
    	//Oncompletion of form by click of submit change the status of form execution to Complete    	
    	formExec.Execution_Status__c = 'Complete';
    	formExec.Project__c = aProj.Id;
    	
    	try{
    		update formExec;
    	}catch(DMLException exp){
    		system.debug('Exception occured during the change of execution status to complete' + exp);
    		GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
					                                                 Error_Message__c= exp.getMessage(),
					                                                 Running_User__c = UserInfo.getUserId() ,
					                                                 Stack_Trace__c = exp.getStackTraceString());	
		    insert errlog;				
				
    	}
    	
    	// Message to display if Score A is the highest in accordance with prioritization A>B>C>D>E            
    	if(formExec.Aggregate_Score_A__c >= formExec.Aggregate_Score_B__c && 
    	   formExec.Aggregate_Score_A__c >= formExec.Aggregate_Score_C__c && 
    	   formExec.Aggregate_Score_A__c >= formExec.Aggregate_Score_D__c && 
    	   formExec.Aggregate_Score_A__c >= formExec.Aggregate_Score_E__c) {
    	   	
    	    assessmentResultHeading = System.Label.LPAD_AssessmentPage_Score_A_Result_Heading;
    	    assessmentResultMessage = System.Label.LPAD_AssessmentPage_Result_Message_for_Force;
    	   	return null;
    	   }
    	else if(formExec.Aggregate_Score_B__c > formExec.Aggregate_Score_A__c && 
    	   formExec.Aggregate_Score_B__c >= formExec.Aggregate_Score_C__c && 
    	   formExec.Aggregate_Score_B__c >= formExec.Aggregate_Score_D__c && 
    	   formExec.Aggregate_Score_B__c >= formExec.Aggregate_Score_E__c) {
    	   	
    	   	// Message to display if Score B is the highest in accordance with prioritization A>B>C>D>E  
    	   	assessmentResultHeading = System.Label.LPAD_AssessmentPage_Score_B_Result_Heading;
    	    assessmentResultMessage = System.Label.LPAD_AssessmentPage_Result_Message_for_non_Force;
    	   	return null;
    	   }
    	else if(formExec.Aggregate_Score_C__c > formExec.Aggregate_Score_A__c && 
    	   formExec.Aggregate_Score_C__c > formExec.Aggregate_Score_B__c && 
    	   formExec.Aggregate_Score_C__c >= formExec.Aggregate_Score_D__c && 
    	   formExec.Aggregate_Score_C__c >= formExec.Aggregate_Score_E__c) {
    	   	
    	   	// Message to display if Score C is the highest in accordance with prioritization A>B>C>D>E
    	   	assessmentResultHeading = System.Label.LPAD_AssessmentPage_Score_C_Result_Heading;
    	    assessmentResultMessage = System.Label.LPAD_AssessmentPage_Result_Message_for_non_Force;
    	   	return null;
    	   }  
    	else if(formExec.Aggregate_Score_D__c > formExec.Aggregate_Score_A__c && 
    	   formExec.Aggregate_Score_D__c > formExec.Aggregate_Score_B__c && 
    	   formExec.Aggregate_Score_D__c > formExec.Aggregate_Score_C__c && 
    	   formExec.Aggregate_Score_D__c >= formExec.Aggregate_Score_E__c) {
    	   	
    	   	// Message to display if Score D is the highest in accordance with prioritization A>B>C>D>E
    	   	assessmentResultHeading = System.Label.LPAD_AssessmentPage_Score_D_Result_Heading;
    	    assessmentResultMessage = System.Label.LPAD_AssessmentPage_Result_Message_for_non_Force;
    	   	return null;
    	   }     
    	else if(formExec.Aggregate_Score_E__c > formExec.Aggregate_Score_A__c && 
    	   formExec.Aggregate_Score_E__c > formExec.Aggregate_Score_B__c && 
    	   formExec.Aggregate_Score_E__c > formExec.Aggregate_Score_C__c && 
    	   formExec.Aggregate_Score_E__c > formExec.Aggregate_Score_D__c) {
    	   	
    	   	// Message to display if Score E is the highest in accordance with prioritization A>B>C>D>E
    	   	assessmentResultHeading = System.Label.LPAD_AssessmentPage_Score_E_Result_Heading;
    	    assessmentResultMessage = System.Label.LPAD_AssessmentPage_Result_Message_for_non_Force;
    	   	return null;
    	   }        
    	else {  
    		return null;
    	}  
    }
    
    
    /* 
     * @Method Name                    :  calculateScores 
     * @Description                    :  Method called on click of Next button on Assessment question pages 
                                          to stamp scores on formExecutionQuestionAnswer 
     * @Return Type                    :  void
     * @Param                          :  
                                          
    */
    public void calculateScores(ID formExecutionID){ 
    	 system.debug('++++ IN CALCULATE SCORES');
         system.debug('calculateScores : formExecutionId' + formExecution.Id);
         system.debug('calculateScores : formTemplateQuestionId' + formTemplateQuestionId);
               
         
         //Query to fetch the form Execution question and Answer record thats related to the current Form Execution and Form Template Question
         formExecQuestAnswer  = [SELECT Form_Execution__c,Helptext__c,Question_Text__c,Response_Boolean__c,
         																	   Response_Number__c,Response_Text__c,Sequence__c,Source_Question__c,
         																	   Total_Score_A__c,Total_Score_B__c,Total_Score_C__c,Total_Score_D__c,Total_Score_E__c
         														        FROM  GLBL_Form_Execution_Question_Answer__c
         														        WHERE Form_Execution__c =: formExecution.Id         
            														    AND Source_Question__c =: formTemplateQuestionId ];  
        
         
         system.debug('+++++formExecQuestAnswer '+ formExecQuestAnswer );  														    
         //Stamping the scores from choosen answer option to form Execution Question Answer record
         try{ 	
         	     if(formTemplateanswer != NULL){
			         if(formExecQuestAnswer != NULL){
			         	formExecQuestAnswer.Total_Score_A__c = Decimal.valueOf(formTemplateanswer.Score_A__c);
			         	formExecQuestAnswer.Total_Score_B__c = Decimal.valueOf(formTemplateanswer.Score_B__c);
			         	formExecQuestAnswer.Total_Score_C__c = Decimal.valueOf(formTemplateanswer.Score_C__c);
			         	formExecQuestAnswer.Total_Score_D__c = Decimal.valueOf(formTemplateanswer.Score_D__c);
			         	formExecQuestAnswer.Total_Score_E__c = Decimal.valueOf(formTemplateanswer.Score_E__c); 
			         	formExecQuestAnswer.Response_Text__c = formTemplateanswer.Answer_option__c;
			         	update formExecQuestAnswer;
			         	
			         }
         	     }
         	     else { 
         	     	    // Stamping values to 0 if the value choosen is None
         	     	    formExecQuestAnswer.Total_Score_A__c = 0;
         	     	    formExecQuestAnswer.Total_Score_B__c = 0;
         	     	    formExecQuestAnswer.Total_Score_C__c = 0;
         	     	    formExecQuestAnswer.Total_Score_D__c = 0;
         	     	    formExecQuestAnswer.Total_Score_E__c = 0;
         	     	    formExecQuestAnswer.Response_Text__c = '';
			         	update formExecQuestAnswer;
         	     }    		         
         }
         catch(DMLException e){
         	     System.debug('Exception occurred during update of form Execution Question and answer Record' + e);
				 GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
					                                                 Error_Message__c= e.getMessage(),
					                                                 Running_User__c = UserInfo.getUserId() ,
					                                                 Stack_Trace__c = e.getStackTraceString());	
				 insert errlog;				
				
         }													        
        
    }
}