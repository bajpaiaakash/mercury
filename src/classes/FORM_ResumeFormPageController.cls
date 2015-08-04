/**
 * Utility class to handle the fact that the template and execution both actually want to go to the same VF
 * page, but it can only have 1 controller.
 * Use this class to redirect to the QuestionnairePage from the StartForm and ResumeForm pages.
 */
public with sharing class FORM_ResumeFormPageController {
	
	/**
	 * Constructor (blank)
	 */
	public FORM_ResumeFormPageController(ApexPages.StandardController controller) {
	}
	
	public PageReference init() {
		
		System.debug('### URL:' + ApexPages.currentPage().getUrl());
		System.debug('### PARAMS:' + ApexPages.currentPage().getParameters());
		
		String executionId = ApexPages.currentPage().getParameters().get('id');
		
		if (!isFormComplete(executionId) && !isFormCancelled(executionId)) {
			
			String templateId = getTemplateId(executionId);
			
			//PageReference formPage = Page.FORM_QuestionnairePage;
			PageReference formPage = Page.FORM_FormExecutionPage;
			formPage.getParameters().put('templateId', templateId);
			formPage.getParameters().put('executionId', executionId);
			formPage.getParameters().putAll(ApexPages.currentPage().getParameters());
			
			return formPage;
		}
		else {
			return Page.FORM_AccessDeniedPage;
		}
	}
	
	/**
	 * get the source form Id for this execution
	 */
	public String getTemplateId (String executionId) {
		GLBL_Form_Execution__c execution = [	SELECT Id, Source_Form__c 
												FROM GLBL_Form_Execution__c 
												WHERE Id = :executionId
												LIMIT 1
												][0];
		return execution.Source_Form__c;
	}
	
	/**
	 * Checks the form execution and returns True if the Status field is not "Complete", False otherwise.
	 * Used to determine whether to direct the user to the access denied page
	 */
	private Boolean isFormComplete(String executionId) {
		GLBL_Form_Execution__c formExecution = [SELECT Id, Execution_Status__c 
												FROM GLBL_Form_Execution__c
												WHERE Id = :executionId][0];
		
		if (formExecution.Execution_Status__c == 'Complete') {
			return true;
		}				
		else {
			return false;
		}						
	}
	
	/**
	 * Checks the form execution and returns True if the Status field is not "Cancelled", False otherwise.
	 * Used to determine whether to direct the user to the access denied page
	 */
	private Boolean isFormCancelled(String executionId) {
		GLBL_Form_Execution__c formExecution = [SELECT Id, Execution_Status__c 
												FROM GLBL_Form_Execution__c
												WHERE Id = :executionId][0];
		
		if (formExecution.Execution_Status__c == 'Cancelled') {
			return true;
		}				
		else {
			return false;
		}						
	}

}