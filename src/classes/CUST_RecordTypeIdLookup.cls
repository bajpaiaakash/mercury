/** 
* @author Sean Harrison 
* 
* This class is called from a trigger on the CST_App_Settings_CUST__c obj. On insert or update
* the object is checked for changes to fields containing record type api names. These names are 
* then used to lookup the corresponding record type ids for that org and written to a companion
* field on the same obj.
*/
public with sharing class CUST_RecordTypeIdLookup implements GLBL_TriggerHandler.HandlerInterface {
	
	public void handle() {
		if (Trigger.isInsert || Trigger.isUpdate ) {
	    	execute(Trigger.new);
	   	}
	}


	void execute(List<Sobject> sobjects) {
		List<CST_App_Settings_CUST__c> settings = (List<CST_App_Settings_CUST__c>)sobjects;
		List<CST_App_Settings_CUST__c> settingsToProcess = new List<CST_App_Settings_CUST__c>();


		// If any of the two fields change, refresh the ids
		for (CST_App_Settings_CUST__c sets : settings) {
			if (Trigger.isInsert) {
				if (sets.Record_Types_CUST__c != null || sets.Employee_Record_Type_CUST__c != null || sets.HCO_Record_Types_CUST__c != null)
					settingsToProcess.add(sets);
			} else if (Trigger.isUpdate) {
				if ((String)Trigger.oldMap.get(sets.Id).get('Record_Types_CUST__c') != sets.Record_Types_CUST__c
					|| (String)Trigger.oldMap.get(sets.Id).get('Employee_Record_Type_CUST__c') != sets.Employee_Record_Type_CUST__c 
					|| (String)Trigger.oldMap.get(sets.Id).get('HCO_Record_Types_CUST__c') != sets.HCO_Record_Types_CUST__c) 
				{
					settingsToProcess.add(sets);
				}
			}
		}		
				
		// Get all Account RT info for this org
		Map<String, Id> rtDevNameToIds = new Map<String, Id>();
		for (RecordType rt : [select Id, DeveloperName from RecordType where SobjectType = 'Account']) {
			rtDevNameToIds.put(rt.DeveloperName, rt.Id);
		}
		
		// match the names to the ids.  
		for (CST_App_Settings_CUST__c cst : settingsToProcess) {
			String errorMsg ='';
			Set<String> rtIds = new Set<String>();

			// start with Employee...
			String desiredRecordTypes = (cst.Employee_Record_Type_CUST__c != null) ? cst.Employee_Record_Type_CUST__c : '';
			for (String s : desiredRecordTypes.split(',')) {
				if (s.trim()!='') {
					if (rtDevNameToIds.containsKey(s.trim())) {
						rtIds.add(rtDevNameToIds.get(s.trim()));
					} else {
						errorMsg += (s.trim()+'_not_found ');
					}
				}
			}
			String strOfRTIds = '';
			for (String s : rtIds) strOfRTIds += s + ',';
			if (strOfRTIds.endsWith(',')) strOfRTIds = strOfRTIds.substring(0,strOfRTIds.length()-1);
			
			if (errorMsg != '') {
				cst.Employee_Record_Type_CUST__c.addError(errorMsg);
			} else {
				cst.Employee_Record_Type_Id_CUST__c = strOfRTIds;
			}

			// ...now do HCO...
			errorMsg ='';
			rtIds = new Set<String>();
			desiredRecordTypes = (cst.HCO_Record_Types_CUST__c != null) ? cst.HCO_Record_Types_CUST__c : '';
			for (String s : desiredRecordTypes.split(',')) {
				if (s.trim()!='') {
					if (rtDevNameToIds.containsKey(s.trim())) {
						rtIds.add(rtDevNameToIds.get(s.trim()));
					} else {
						errorMsg += (s.trim()+'_not_found ');
					}
				}
			}
			strOfRTIds = '';
			for (String s : rtIds) strOfRTIds += s + ',';
			if (strOfRTIds.endsWith(',')) strOfRTIds = strOfRTIds.substring(0,strOfRTIds.length()-1);
			
			if (errorMsg != '') {
				cst.HCO_Record_Types_CUST__c.addError(errorMsg);
			} else {
				cst.HCO_Record_Type_Ids_CUST__c = strOfRTIds;
			}

			// ...finish up with default list.
			errorMsg ='';
			rtIds = new Set<String>();
			desiredRecordTypes = (cst.Record_Types_CUST__c != null) ? cst.Record_Types_CUST__c : '';
			for (String s : cst.Record_Types_CUST__c.split(',')) {
				if (s.trim()!='') {
					if (rtDevNameToIds.containsKey(s.trim())) {
						rtIds.add(rtDevNameToIds.get(s.trim()));
					} else {
						errorMsg += (s.trim()+'_not_found ');
					}
				}
			}
			strOfRTIds = '';
			for (String s : rtIds) strOfRTIds += s + ',';
			if (strOfRTIds.endsWith(',')) strOfRTIds = strOfRTIds.substring(0,strOfRTIds.length()-1);
			
			if (errorMsg != '') {
				cst.Record_Types_CUST__c.addError(errorMsg);
			} else {
				cst.Record_Type_Ids_CUST__c = strOfRTIds;
			}
		}
	}	
}