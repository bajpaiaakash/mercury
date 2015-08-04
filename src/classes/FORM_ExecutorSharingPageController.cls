/**
 * Page controller to handle Standard Sharing of a form with an executor.
 * Checks if the Form requires an approval so as to share it with any executor and only allows to do so if the Approval Status is 'Approved'
 */
public with sharing class FORM_ExecutorSharingPageController {
	
	/**
	 * Constructor
	 */
	public FORM_ExecutorSharingPageController(ApexPages.StandardController controller) {
	}
	
	public PageReference init() {
		
		String templateId = ApexPages.currentPage().getParameters().get('id');
		
		if (!GLBL_FormTemplateActions.isApprovalRequired(templateId)) {
			
			return new pagereference('/p/share/CustomObjectSharingDetail?parentId='+templateId);
		}
		else {
			return Page.FORM_AccessDeniedPage;
		}
	}
	

	
}