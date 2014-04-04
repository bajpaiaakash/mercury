public with sharing class CUST_RefreshLOVsController {

	CUST_RefreshLOVsUtil              util;
	CST_App_Menu_Pool_GLBL__c         pool;
	public CST_App_Settings_CUST__c   settings { get; private set; }
	public String 					  fieldsToRefresh { get; set; }
	public String                     email { get; set; }

	public CUST_RefreshLOVsController(ApexPages.StandardController controller) {

		CST_App_Settings_CUST__c record = (CST_App_Settings_CUST__c) controller.getRecord();

		if (record.Id != null) {
			// get all fields in the App Settings record for VF page
			MERC_Util.SelectAll allSelector = new MERC_Util.SelectAll(CST_App_Settings_CUST__c.sObjectType, record.Id);
			settings = Database.query(allSelector.SOQL);

			// get all fields in the related pool record
			try 
			{
				pool = [SELECT Id FROM CST_App_Menu_Pool_GLBL__c WHERE App_Settings_CUST__c = :record.Id];
				allSelector = new MERC_Util.SelectAll(CST_App_Menu_Pool_GLBL__c.sObjectType, pool.Id);
				pool = Database.query(allSelector.SOQL);
			} catch (QueryException qe) {
				System.debug(LoggingLevel.WARN, 'When getting pool records: '+qe.getMessage());
			}
			
			// init helper class
			util = new CUST_RefreshLOVsUtil();
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No App Settings record found.'));
		}
	}

	public PageReference refreshSelectedLOVs() {
		if (fieldsToRefresh==null || fieldsToRefresh=='') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No fields selected for refresh.'));
			return null;
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'fieldsToRefresh: '+fieldsToRefresh));
		}

		Map<String, CUST_RefreshLOVsUtil.ObjToken> objMap = new Map<String, CUST_RefreshLOVsUtil.ObjToken>();
		for (String field : fieldsToRefresh.split(',')) {
			processSubmittedField(field, objMap);
		}

		refresh(objMap, getEarliestModDate(objMap));
		//TODO - !!!! SANITIZE INCOMING FIELD NAMES!!!
		return null;
	}

	public void refresh(Map<String, CUST_RefreshLOVsUtil.ObjToken> objMap, Date d) {
		CST_App_Menu_Pool_GLBL__c p = (pool != null) ? pool : new CST_App_Menu_Pool_GLBL__c();
		p.App_Settings_CUST__c = settings.Id;
		CUST_RefreshLOVsBatch batch = new CUST_RefreshLOVsBatch(p, objMap, d, email);
		Database.executeBatch(batch);
	}

	private void processSubmittedField(String objFieldPair, Map<String, CUST_RefreshLOVsUtil.ObjToken> objectsToFields) {
		List<String> objNameAndFieldName = objFieldPair.split('\\.');
		CUST_RefreshLOVsUtil.ObjToken t = new CUST_RefreshLOVsUtil.ObjToken(objNameAndFieldName[0]);
		if (!t.ABBREVIATIONS.containsKey(objNameAndFieldName[0])) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to target object. ('+objNameAndFieldName+')'));
		} else {
			if (objectsToFields.get(t.name)==null) {
				t.fields = new List<String>();
				t.values = new Map<String,String>();
				objectsToFields.put(t.name, t);
			}

			objectsToFields.get(t.name).fields.add(objNameAndFieldName[1]);
			if (pool!=null && pool.get(objNameAndFieldName[1])!=null) {
				objectsToFields.get(t.name).values.put(objNameAndFieldName[1], (String) pool.get(objNameAndFieldName[1]));
			}
		}
	}

	public Date getEarliestModDate(Map<String, CUST_RefreshLOVsUtil.ObjToken> objMap) {
		List<String> fieldNames = new List<String>();
		for (CUST_RefreshLOVsUtil.ObjToken t : objMap.values()) fieldNames.addAll(t.fields);

		List<String> dateFieldNames = new List<String>();
		for (String s : fieldNames) dateFieldNames.add(util.getDateFieldName(s));

		List<Date> captureDates = new List<Date>();
		for (String dateField : dateFieldNames) {
			Date d = (pool != null && pool.get(dateField)!=null) ? (Date) pool.get(dateField) : Date.today().addMonths(-6);
			captureDates.add(d);
		}
		captureDates.sort();
		return captureDates.get(0);
	}
}