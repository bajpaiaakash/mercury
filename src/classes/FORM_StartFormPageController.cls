/**
 * Utility class to handle the fact that the template and execution both actually want to go to the same VF
 * page, but it can only have 1 controller.
 * Use this class to redirect to the QuestionnairePage from the StartForm and ResumeForm pages.
 */
public with sharing class FORM_StartFormPageController {
	
	/**
	 * Constructor (blank)
	 */
	public FORM_StartFormPageController(ApexPages.StandardController controller) {
	}
	
	public PageReference init() {
		
		System.debug('### URL:' + ApexPages.currentPage().getUrl());
		System.debug('### PARAMS:' + ApexPages.currentPage().getParameters());
		
		String templateId = ApexPages.currentPage().getParameters().get('id');
		
		if (GLBL_FormTemplateActions.isFormTemplateAccessible(templateId)) {
			if (GLBL_FormTemplateActions.isFormTemplateActive(templateId) && !GLBL_FormTemplateActions.isApprovalRequired(templateId)) {
				GLBL_FormTemplateActions formActions = new GLBL_FormTemplateActions();
				GLBL_Form_Execution__c formExecution = formActions.createFormExecution(templateId);
				
				PageReference formPage = Page.FORM_FormExecutionPage;
				formPage.getParameters().put('templateId', templateId);
				formPage.getParameters().put('executionId', formExecution.Id);
				formPage.getParameters().putAll(ApexPages.currentPage().getParameters());
				
				return formPage;
			}
		}

		return Page.FORM_AccessDeniedPage;
	}

}