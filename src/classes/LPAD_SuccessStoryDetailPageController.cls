public with sharing class LPAD_SuccessStoryDetailPageController {
	
	// variable declarations
	public String successStoryId {get; set;}
	public GLBL_GSO_Content__c successStory;
	
	/**
	 * Constructor
	 */
	public LPAD_SuccessStoryDetailPageController () {
		
		successStoryId = ApexPages.currentPage().getParameters().get('id');
	}
	
	public GLBL_GSO_Content__c getSuccessStory () {
		
		if (successStory == null) {
			try {
				successStory = [SELECT Id, Name, Description__c, Sequence_Number__c,Business_Area__c, Business_Value__c,
				                       User_Base__c,Innovation__c,Other_Comments__c,Icon_Image_URL__c,Detail_Image_URL__c
								FROM GLBL_GSO_Content__c 
								WHERE Id = :successStoryId][0];
			}
			catch (Exception e) {
				System.debug('Error: could not query for success story ' + successStoryId + '\n' +e);
				successStory = new GLBL_GSO_Content__c();
			}		
		}
		
		return successStory;
	}
	
}