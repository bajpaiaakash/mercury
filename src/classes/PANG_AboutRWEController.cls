/**
 * This class is used to dynamically get some salesforce Ids and used them in visualforce page PANG_AboutRWE
*/
public with sharing class PANG_AboutRWEController {
	public String ChatterGroupId {get;set;}
	public String TrainingLibraryId {get;set;}
	
	public PANG_AboutRWEController(){
		String defaultChatterGroup = getSettingValue('Default Chatter Group');
		String trainingMaterialLibrary = getSettingValue('Training Material Library');
		
		if(defaultChatterGroup != null){
			List<CollaborationGroup > groups = [select Id from CollaborationGroup where Name = :defaultChatterGroup limit 1];
			if(groups.size() > 0){
				ChatterGroupId = groups[0].Id;	
			}
		}
		
		if(trainingMaterialLibrary != null){
			List<ContentWorkspace > libraries = [select Id from ContentWorkspace where Name = :trainingMaterialLibrary limit 1];
			if(libraries.size() > 0){
				TrainingLibraryId = libraries[0].Id;	
			}
		}
	} 
	
	/**
	 * get PANG custom setting value from custom setting name
	 * @param settingName custom setting item name
	 * @return custom setting item value
	*/
	private String getSettingValue(String settingName){
		String settingValue = null;
		
		if(PANG_Settings__c.getAll().get(settingName) != null){
			settingValue = PANG_Settings__c.getAll().get(settingName).Setting_Value__c;
		}
		
		return settingValue;
	}
}