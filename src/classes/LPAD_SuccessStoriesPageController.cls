public with sharing class LPAD_SuccessStoriesPageController {
	
	// variable declarations
	public static final Integer SUCCESS_STORIES_LIMIT = 30;
	public static final String SUCCESS_STORY_RECORD_TYPE = 'Success Story';
	public List<GLBL_GSO_Content__c> successStories;
	
	/**
	 * Constructor
	 */
	public LPAD_SuccessStoriesPageController () {
		
	}
	
	/**
	 * Get content records where type = success story
	 */
	public List<GLBL_GSO_Content__c> getSuccessStories() {
		if (successStories == null) {
			
			try {
				successStories = [	SELECT Id, Name, Description__c, Icon_Caption__c, Sequence_Number__c, Icon_Image_URL__c, Detail_Image_URL__c
									FROM GLBL_GSO_Content__c 
									WHERE Record_Type_Name__c = :SUCCESS_STORY_RECORD_TYPE
										AND Active__c = true
									ORDER BY Sequence_Number__c ASC, CreatedDate DESC
									LIMIT :SUCCESS_STORIES_LIMIT];
			}
			catch (Exception e) {
				System.debug('Error: could not query list of success stories!\n' +e);
				successStories = new List<GLBL_GSO_Content__c>();
			}

		}
		return successStories;
	}
}