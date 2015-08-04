public with sharing class LPAD_CirrusProcessPageController {
	
	// variable declarations
	public static final Integer RECORD_LIMIT = 20;
	public static final String RECORD_TYPE = 'Cirrus Process Step';
	public List<GLBL_GSO_Content__c> processSteps;
	
	/**
	 * Constructor
	 */
	public LPAD_CirrusProcessPageController () {
		
	}
	
	/**
	 * Get content records where type = success story
	 */
	public List<GLBL_GSO_Content__c> getProcessSteps() {
		if (processSteps == null) {
			
			try {
				processSteps = [	SELECT Id, Name, Description__c, Process_Step_Image_URL__c, Sequence_Number__c 
									FROM GLBL_GSO_Content__c 
									WHERE Record_Type_Name__c = :RECORD_TYPE
										AND Active__c = true
									ORDER BY Sequence_Number__c ASC, CreatedDate DESC
									LIMIT :RECORD_LIMIT];
			}
			catch (Exception e) {
				System.debug('Error: could not query list of process steps!\n' +e);
				processSteps = new List<GLBL_GSO_Content__c>();
			}

		}
		return processSteps;
	}
}