public with sharing class GLBL_EntityChatterPageController {
		
	// variable declarations
	public String entityId;
	
	/**
	 * Constructor
	 */
	public GLBL_EntityChatterPageController () {
		
	}
	
	/**
	 * Get the Id of the record we want to display the chatter feed for
	 */
	public String getEntityId () {
		
		System.debug('### URL:' + ApexPages.currentPage().getUrl());
		
		if (String.isEmpty(entityId)) {
			try {
				entityId = ApexPages.currentPage().getParameters().get('id');
			}
			catch (Exception e) {
				System.debug('Error: could not get record Id  \n' +e);
			}
			finally {
				//if the assigment failed, use the current user's chatter feed
				if (String.isEmpty(entityId)) {
					entityId = UserInfo.getUserId();
				}
			}		
		}
		
		return entityId;
	}

}