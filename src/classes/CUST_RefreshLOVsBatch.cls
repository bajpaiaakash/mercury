/**
 * CUST_RefreshLOVsBatch
 * Created By: Joe Ferraro, Mavens Consulting
 * Description: Dynamically updates batches of LoV related records based on inputs.
 */
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
		objMap = objFieldMap;
		util = new CUST_RefreshLOVsUtil();
		useSysmoddate = d!=null;
		sysmoddate = d;
		setQuery(objMap);
	}

	// set the query that will be used in the start method.
	void setQuery (Map<String, CUST_RefreshLOVsUtil.ObjToken> objTokenMap) {
		query = 'SELECT Id FROM Account WHERE RecordTypeId = \''+MERC_TestFactory.hcpRecordTypeId+'\' AND ';
		query += (useSysmoddate) ? 'SYSTEMMODSTAMP > :sysmoddate AND (': '(';
		for (String name : objTokenMap.keySet()) {
			CUST_RefreshLOVsUtil.ObjToken tk = objTokenMap.get(name);
			if (name == 'Account' && tk.fields!=null) {
				for (String f : tk.fields) {
					// query += f + ' != null OR ';
				}
			} else if (tk.filter != null) {
				query += tk.filter + ' > 0 OR ';
			}
		}
		query = query.removeEnd('OR ') + ')';
		query = query.removeEnd('()');
		query = query.removeEnd('AND ');
	}

	// query the database
	global Database.QueryLocator start(Database.BatchableContext BC) {
		p(query);
		return Database.getQueryLocator(query);
	}

	// iterate through scope and update LoV related records.
   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Account> acctsInScope = (List<Account>) scope;

		// get all the info we need
		String subQuery = setSubQuery(objMap, acctsInScope);
		p(subQuery);
		List<Account> accts = Database.query(subQuery);

		for (Account a : accts) {
			for (String objName : objMap.keySet()) {
				CUST_RefreshLOVsUtil.ObjToken tk = objMap.get(objName);
				if (tk!=null && tk.fields!=null) {
					for (String fName : tk.fields) {
						if (tk.name=='Account') {
							addNewValues(fName, a, tk);
						} else {
								if (a.getSObjects(tk.relation) != null) {
								for (sObject obj : (List<sObject>) a.getSObjects(tk.relation)) {
									addNewValues(fName, obj, tk);
								}
							}
						}
					}
				}
			}
		}
	}

	String setSubQuery(Map<String, CUST_RefreshLOVsUtil.ObjToken> objTokenMap, List<Account> aList) {


		String idString = '(';
		for (Account a : aList) idString += '\''+a.Id+'\',';
		idString = idString.removeEnd(',') + ')';

		query = 'SELECT Id, ';

		CUST_RefreshLOVsUtil.ObjToken aTk = objTokenMap.get('Account');
		if (aTk!=null && aTk.fieldsCSV!=null) query += aTk.fieldsCSV+', ';
		for (String name : objTokenMap.keySet()) {
			if (name != 'Account') {
				CUST_RefreshLOVsUtil.ObjToken tk = objTokenMap.get(name);
				query += ' (SELECT '+tk.fieldsCSV+' FROM '+tk.relation+'), ';
			}
		}
		query = query.removeEnd(', ') + ' FROM Account WHERE Id in '+ idString;
		return query;
	}

	void addNewValues(String f, sObject o, CUST_RefreshLOVsUtil.ObjToken tk) {
		String val = String.valueOf(o.get(f));
		if (val==null || val.trim()=='') return;

		if (!tk.values.containsKey(f)) {
			tk.values.put(f,val);
		} else {
			if (!(tk.values.get(f).length()>32750) && !tk.values.get(f).containsIgnoreCase(val)) tk.values.put(f,tk.values.get(f)+','+val);
		}
		return;
	}

	global void finish(Database.BatchableContext BC) {
		String valueCollectionWarning = '';

		for (String objName : objMap.keySet()) {
			if (objMap.containsKey(objName) && objMap.get(objName).fields!=null) {
				for (String fName : objMap.get(objName).fields) {
					try {
						String newValue = objMap.get(objName).values.get(fName);
						if (newValue!=null && newValue.length()>32768) {
							valueCollectionWarning += 'Truncating values for '+objName+'.'+fName+'. <br/>';
							newValue = newValue.substring(0,32767);
						}
						pool.put(util.getDateFieldName(fName),Date.today());
						pool.put(fName, newValue);
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

		if (a.Status=='Failed') status += '/n/n/n'+a.ExtendedStatus+'/n/n/n'+errors;

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<String> toAddresses = new List<String>{a.CreatedBy.Email};
		if (email!=null) toAddresses.add(email);
		mail.setToAddresses(toAddresses);
		mail.setSubject('CST Data Collection ' + a.Status);
		mail.setHtmlBody(status + '<br/><br/>'+valueCollectionWarning+ '<br/><br/>Errors:<br />'+errors);
		mail.setPlainTextBody(status);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

		pool.Last_Job_Status_GLBL__c = status;
		upsert pool;
	}

		static void p(String m) {
			System.debug('\n\n\nYYZ - '+m+'\n\n\n\n');
		}
}