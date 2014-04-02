global class CUST_RefreshLOVsBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	global String                    query;
	global Map<String, List<String>> fields;
	global Date                      sysmoddate;
	global CST_App_Settings_CUST__c  settings;
	global CST_App_Menu_Pool_GLBL__c pool;
	global CUST_RefreshLOVsUtil      util;
	global Map<String, String>       newValues;

	global CUST_RefreshLOVsBatch(CST_App_Settings_CUST__c s, CST_App_Menu_Pool_GLBL__c  p, Map<String, List<String>> objFieldMap, Date d) {
		settings = s;
		pool = p;
		sysmoddate = d;
		fields = objFieldMap;
		util = new CUST_RefreshLOVsUtil();
		newValues = new Map<String, String>();

		Map<String, CUST_RefreshLOVsUtil.ObjToken> objMap = new Map<String, CUST_RefreshLOVsUtil.ObjToken>();

		String key = 'Account';
		CUST_RefreshLOVsUtil.ObjToken t = new CUST_RefreshLOVsUtil.ObjToken(key);
		t.fields = objFieldMap.get(key);
		objMap.put(t.name, t);

		key = 'Affiliation_GLBL__c';
		if (objFieldMap.get(key) != null) {
			t = new CUST_RefreshLOVsUtil.ObjToken(key);
			t.relation = 'Affiliations_To__r';
			t.lookup = 'Account_GLBL__c';
			t.filter = 'CST_App_Menu_Flag_Affil_CUST__c';
			t.fields = objFieldMap.get(key);
			objMap.put(t.name, t);		
		}

		key = 'Alternate_Id_GLBL__c';
		if (objFieldMap.get(key) != null) {
			t = new CUST_RefreshLOVsUtil.ObjToken(key);
			t.relation = 'Alternate_ID__r';
			t.lookup = 'Account_GLBL__c';
			t.fields = objFieldMap.get(key);
			objMap.put(t.name, t);
		}

		key = 'Preferences_and_Consent_GLBL__c';
		if (objFieldMap.get(key) != null) {
			t = new CUST_RefreshLOVsUtil.ObjToken(key);
			t.relation = 'Consent__r';
			t.lookup = 'Account_GLBL__c';
			t.filter = 'CST_App_Menu_Flag_Consent_CUST__c';
			t.fields = objFieldMap.get(key);
			objMap.put(t.name, t);
		}

		key = 'Specialty_MERC__c';
		if (objFieldMap.get(key) != null) {
			t = new CUST_RefreshLOVsUtil.ObjToken(key);
			t.relation = 'Specialities__r';
			t.lookup = 'Account_GLBL__c';
			t.fields = objFieldMap.get(key);
			objMap.put(t.name, t);
		}

		util.p('objMap: '+objMap);
		setQuery(objMap);
	}
	
	void setQuery(Map<String, CUST_RefreshLOVsUtil.ObjToken> objMap) {

		query = 'SELECT ';
		if (objMap.get('Account').fieldsCSV!=null) query += objMap.get('Account').fieldsCSV+', ';
		for (String name : objMap.keySet()) {
			if (name != 'Account') {
				CUST_RefreshLOVsUtil.ObjToken tk = objMap.get(name);
				query += ' (SELECT '+tk.fieldsCSV+' FROM '+tk.relation+'), ';

			}
		}
		query = query.removeEnd(', ') + ' FROM Account WHERE RecordType.DeveloperName = \'HCP_GLBL\' AND (';
		for (String name : objMap.keySet()) {
			CUST_RefreshLOVsUtil.ObjToken tk = objMap.get(name);
			if (name == 'Account' && tk.fields!=null) {
				for (String f : tk.fields) {
					query += f + ' != null OR ';
				}
			} else if (tk.filter != null) {
				query += tk.filter + ' > 0 OR ';
			}
		}
		query = query.removeEnd('OR ') + ')';
		util.p('query: '+query);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Account> accts = (List<Account>) scope;
		util.p('execute method on '+accts.size()+' '+accts);
		for (Account a : accts) {
			if (fields.get('Account')!=null) {
				for (String fName : fields.get('Account')) {
					String val = (String) a.get(fName);
					if (!newValues.containsKey(fName)) {
						newValues.put(fName,val);
					} else {
						if (!newValues.get(fName).contains(val)) newValues.put(fName,newValues.get(fName)+','+val);
					}
				}
			}
			if (fields.get('Affiliation_GLBL__c')!=null) {
				for (String fName : fields.get('Affiliation_GLBL__c')) {
					for (Affiliation_GLBL__c affil : a.Affiliations_To__r) {
						String val = String.valueOf(affil.get(fName));
						if (!newValues.containsKey(fName)) {
							newValues.put(fName,val);
						} else {
							if (!newValues.get(fName).contains(val)) newValues.put(fName,newValues.get(fName)+','+val);
						}									
					}
				}
			}
		}
	}
	
//    global void execute(SchedulableContext sc) {
//        CUST_RefreshLOVsBatch b = new CUST_RefreshLOVsBatch();
//        Database.executeBatch(b);
//    }    

	global void finish(Database.BatchableContext BC) {

		util.p('after execute newValues is: '+newValues);
		
		pool.App_Settings_CUST__c = settings.Id;
		if (fields.get('Account')!=null) {
			for (String fName : fields.get('Account')) {
				pool.put(util.getDateFieldName(fName),Date.today());
				pool.put(fName,newValues.get(fName));
				// TODO: catch String too long
			}
		}
		if (fields.get('Affiliation_GLBL__c')!=null) {
			for (String fName : fields.get('Affiliation_GLBL__c')) {
				pool.put(util.getDateFieldName(fName),Date.today());
				pool.put(fName,newValues.get(fName));
				// TODO: catch String too long
			}
		}

		upsert pool;
		
	}
	
}