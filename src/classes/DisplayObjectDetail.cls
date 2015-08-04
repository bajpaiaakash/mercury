public class DisplayObjectDetail{

	public Map<String, Schema.SObjectType> AllObjmap;

	public DisplayObjectDetail(){}

	public List<objClass> getObjList(){
		List<objClass> objList = new List<objClass>();

		for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
			String apiName = objTyp.getDescribe().getName();
			if(!objTyp.getDescribe().isCustomSetting() 
				&& !apiName.endsWith('Feed')
				&& !apiName.endsWith('History') 
				&& !apiName.endsWith('Share')
				&& apiName != 'CaseTeamMember'
				&& apiName != 'CaseTeamRole'
				&& apiName != 'CaseTeamTemplate'
				&& apiName != 'CaseTeamTemplateMember'
				&& apiName != 'CaseTeamTemplateRecord'
				&& apiName != 'CategoryNodeLocalization'
				&& apiName != 'RecordTypeLocalization'
				&& apiName != 'ScontrolLocalization'
				&& apiName != 'TopicLocalization'
				&& apiName != 'WebLinkLocalization') {
				objList.add(new objClass(objTyp.getDescribe().getLabel(), apiName, objTyp.getDescribe().isAccessible()));
			}
		}

		return objList;
	}

	public List<objClass> getOtherList(){
		List<objClass> objList = new List<objClass>();

		for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
			String apiName = objTyp.getDescribe().getName();
			if(!objTyp.getDescribe().isCustomSetting() 
				&& (apiName.endsWith('Feed')
				|| apiName.endsWith('History') 
				|| apiName.endsWith('Share'))) {
				objList.add(new objClass(objTyp.getDescribe().getLabel(), apiName, objTyp.getDescribe().isAccessible()));
			}
		}

		return objList;
	}

	public List<objClass> getCantSaveList(){
		List<objClass> objList = new List<objClass>();

		for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
			String apiName = objTyp.getDescribe().getName();
			if(apiName == 'CaseTeamMember'
				|| apiName == 'CaseTeamRole'
				|| apiName == 'CaseTeamTemplate'
				|| apiName == 'CaseTeamTemplateMember'
				|| apiName == 'CaseTeamTemplateRecord'
				|| apiName == 'CategoryNodeLocalization'
				|| apiName == 'RecordTypeLocalization'
				|| apiName == 'ScontrolLocalization'
				|| apiName == 'TopicLocalization'
				|| apiName == 'WebLinkLocalization') {
				objList.add(new objClass(objTyp.getDescribe().getLabel(), apiName, objTyp.getDescribe().isAccessible()));
			}
		}

		return objList;
	}

	public List<objClass> getCustomSettingList(){
		List<objClass> objList = new List<objClass>();

		for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
			String apiName = objTyp.getDescribe().getName();
			if(objTyp.getDescribe().isCustomSetting()
				){
				objList.add(new objClass(objTyp.getDescribe().getLabel(), apiName, objTyp.getDescribe().isAccessible()));
			}
		}

		return objList;
	}

	public class objClass {
		public String apiName {get;set;}
		public String label {get;set;}
		public Boolean accessible {get;set;}

		public objClass (string lab, string api, boolean access) {
			this.apiName = api;
			this.label = lab;
			this.accessible = access;
		}
	}
}