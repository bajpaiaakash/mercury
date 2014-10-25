public with sharing class LPAD_FooterController {
	
	// variable declarations
	public String footerEmail;
	
	/**
	 * Constructor
	 */
	public LPAD_FooterController () {
	}
	
	/**
	 * Get the footer email from the LPAD custom setting
	 * Would do this in the constructor, but DML is not allowed in a constructor.
	 */
	public String getFooterEmail() {
		// try to get the footer email
		if (String.isEmpty(footerEmail)) {
			try {
				footerEmail = [SELECT Footer_Email__c FROM LPAD_Settings__c LIMIT 1][0].Footer_Email__c;
			}
			catch (Exception e) {
				System.debug('Error fetching email from custom setting. Are you sure there is at least 1 record in LPAD_Settings__c?\n' + e);
				GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(	Error_Datetime__c= DateTime.Now(),
	                                                 				Error_Message__c= e.getMessage(),
	                                                 				Running_User__c = UserInfo.getUserId() ,
	                                                 				Stack_Trace__c = e.getStackTraceString(),
	                                                 				Additional_Information__c = 'Error fetching email from custom setting. Are you sure there is at least 1 record in LPAD_Settings__c?'
	                                                 				);	
				insert errlog;
			}
			finally {
				if (String.isEmpty(footerEmail)) {
					footerEmail = 'dummy@gso1.lly.com';
				}
			}
		}
		
		return footerEmail;
	}
}