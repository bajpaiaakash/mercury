public with sharing class CUST_RecordTypeIdLookup implements GLBL_TriggerHandler.HandlerInterface {
	
	public void handle() {
		if (Trigger.isInsert || Trigger.isUpdate ) {
	    	execute(Trigger.new);
	   	}
	}

	void execute(List<Sobject> sobjects) {
		List<CST_App_Settings_CUST__c> settings = (List<CST_App_Settings_CUST__c>)sobjects;
		Map<Id,CST_App_Settings_CUST__c> settingsToProcess = new Map<Id,CST_App_Settings_CUST__c>();
		for (CST_App_Settings_CUST__c sets : settings) {
			if (Trigger.isInsert) {
				if (sets.Record_Types_CUST__c != null)
					settingsToProcess.put(sets.Id, sets);
			} else if (Trigger.isUpdate) {
				if ((String)Trigger.oldMap.get(sets.Id).get('Record_Types_CUST__c') != sets.Record_Types_CUST__c) {
					settingsToProcess.put(sets.Id, sets);
				}
			}
		}		
		
		p('settingsToProcess='+settingsToProcess);
		Map<String, Id> rtDevNameToIds = new Map<String, Id>();
		for (RecordType rt : [select Id, DeveloperName from RecordType where SobjectType = 'Account']) {
			rtDevNameToIds.put(rt.DeveloperName, rt.Id);
		}
		
		for (CST_App_Settings_CUST__c cst : settingsToProcess.values()) {
			String errorMsg ='';
			Set<String> rtIds = new Set<String>();
			for (String s : cst.Record_Types_CUST__c.split(',')) {
				if (rtDevNameToIds.containsKey(s.trim())) {
					rtIds.add(rtDevNameToIds.get(s.trim()));
				} else {
					errorMsg += (s.trim()+'_not_found ');
				}
			}
			String strOfRTIds = '';
			for (String s : rtIds) strOfRTIds += s + ',';
			if (strOfRTIds.endsWith(',')) strOfRTIds = strOfRTIds.substring(0,strOfRTIds.length()-1);
			
			if (errorMsg != '') {
				cst.Record_Type_Ids_CUST__c.addError(errorMsg);
			} else {
				cst.Record_Type_Ids_CUST__c = strOfRTIds;
			}
		}
	}
	
	public static void p(String message)
	{
		String prefix = '\n\nYYZ - ';
		String suffix = '\n\n';
		System.debug(prefix+message+suffix);		
	}
	
}