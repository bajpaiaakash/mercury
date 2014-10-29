public with sharing class LPAD_LandingPageController {
	
	/* variable declarations */
	public String feedId {get; set;}
	
	/**
	 * Constructor
	 */
	public LPAD_LandingPageController () {
	}
	
	/**
	 * Init method to get the chatter feed.
	 * Would do this in the constructor, but DML is not allowed in a constructor.
	 */
	public void init() {
		
		// try to get the chatter group
		try {
			feedId = [SELECT Chatter_Group__c FROM LPAD_Settings__c LIMIT 1][0].Chatter_Group__c;
		}
		catch (Exception e) {
			System.debug('Error fetching feed id from custom setting. Are you sure there is at least 1 record in LPAD_Settings__c?\n' + e);
			GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(	Error_Datetime__c= DateTime.Now(),
                                                 				Error_Message__c= e.getMessage(),
                                                 				Running_User__c = UserInfo.getUserId() ,
                                                 				Stack_Trace__c = e.getStackTraceString(),
                                                 				Additional_Information__c = 'Error fetching feed id custom setting. Are you sure there is at least 1 record in LPAD_Settings__c?'
                                                 				);	
			insert errlog;
		}
		finally {
			//if the assigment failed, use the current user's chatter feed
			if (String.isEmpty(feedId)) {
				feedId = UserInfo.getUserId();
			}
		}
	}
	
}