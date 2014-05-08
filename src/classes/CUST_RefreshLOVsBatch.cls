global class CUST_RefreshLOVsBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	global String                    email;
	global List<String>              errors;
	global CST_App_Menu_Pool_GLBL__c pool;
	global String                    query;
	global Date                      sysmoddate;
	global Boolean                   useSysmoddate;
	global CUST_RefreshLOVsUtil      util;
	global Map<String, CUST_RefreshLOVsUtil.ObjToken> objMap;

	global CUST_RefreshLOVsBatch(CST_App_Menu_Pool_GLBL__c  p, Map<String, CUST_RefreshLOVsUtil.ObjToken> objFieldMap, Date d, String email) {
		pool = p;
		sysmoddate = d;
		objMap = objFieldMap;
		util = new CUST_RefreshLOVsUtil();
		useSysmoddate = true;
		setQuery(objMap);
	}
	
	void setQuery(Map<String, CUST_RefreshLOVsUtil.ObjToken> objTokenMap) {

		query = 'SELECT ';

		CUST_RefreshLOVsUtil.ObjToken aTk = objTokenMap.get('Account');
		if (aTk!=null && aTk.fieldsCSV!=null) query += aTk.fieldsCSV+', ';
		//for (String name : objTokenMap.keySet()) {
		//	if (name != 'Account') {
		//		CUST_RefreshLOVsUtil.ObjToken tk = objTokenMap.get(name);
		//		query += ' (SELECT '+tk.fieldsCSV+' FROM '+tk.relation+'), ';
		//	}
		//}
		query = query.removeEnd(', ') + ' FROM Account WHERE RecordType.DeveloperName = \'HCP_GLBL\' AND ';
		query += (useSysmoddate) ? 'SYSTEMMODSTAMP > :sysmoddate AND (': '(';
		for (String name : objTokenMap.keySet()) {
			CUST_RefreshLOVsUtil.ObjToken tk = objTokenMap.get(name);
			if (name == 'Account' && tk.fields!=null) {
				for (String f : tk.fields) {
					query += f + ' != null OR ';
				}
			} else if (tk.filter != null) {
				query += tk.filter + ' > 0 OR ';
			}
		}
		query = query.removeEnd('OR ') + ')';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		p(query);
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Account> accts = (List<Account>) scope;
		for (Account a : accts) {
			for (String objName : objMap.keySet()) {
				if (objMap.get(objName).fields!=null) {
					CUST_RefreshLOVsUtil.ObjToken tk = objMap.get(objName);
					
					for (String fName : objMap.get(objName).fields) {
						if (tk.name=='Account') {
							addNewValues(fName, a, tk);
						} else {
							//	if (a.getSObjects(tk.relation) != null) {
							//	for (sObject obj : (List<sObject>) a.getSObjects(tk.relation)) {
							//		addNewValues(fName, obj, tk);
							//	}
							//}
						}
					}
				}
			}
		}
	}

	void addNewValues(String f, sObject o, CUST_RefreshLOVsUtil.ObjToken tk) { 
		String val = String.valueOf(o.get(f));
		if (val==null || val.trim()=='') return;

		if (!tk.values.containsKey(f)) {
			tk.values.put(f,val);
		} else {
			if (!tk.values.get(f).contains(val)) tk.values.put(f,tk.values.get(f)+','+val);
		}
		return;
	}
	
	global void finish(Database.BatchableContext BC) {
		for (String objName : objMap.keySet()) {
			if (objMap.containsKey(objName) && objMap.get(objName).fields!=null) {
				for (String fName : objMap.get(objName).fields) {
					try {
						pool.put(util.getDateFieldName(fName),Date.today());
						pool.put(fName, objMap.get(objName).values.get(fName));
					} catch (SObjectException se) {
						errors.add('fName or related date: '+se.getMessage());
					}
				}
			}
		}
		upsert pool;

		AsyncApexJob a = [SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed,
		  TotalJobItems, CreatedBy.Email, CompletedDate
		  FROM AsyncApexJob WHERE Id = :BC.getJobId()];
		String status = 'Job '+a.Id+' processed ' + a.TotalJobItems +
			' batches with '+ a.NumberOfErrors + ' failures. '+a.CompletedDate;

		if (a.Status=='Failed') status += '/n/n/n'+a.ExtendedStatus;

		if (!Test.isRunningTest()) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			List<String> toAddresses = new List<String>{a.CreatedBy.Email};
			if (email!=null) toAddresses.add(email);
			mail.setToAddresses(toAddresses);
			mail.setSubject('CST Data Collection ' + a.Status);
			mail.setPlainTextBody(status);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}

		pool.Last_Job_Status_GLBL__c = status;
		upsert pool;
	}

		static void p(String m) {
			System.debug('\n\n\nYYZ - '+m+'\n\n\n\n');
		}
}