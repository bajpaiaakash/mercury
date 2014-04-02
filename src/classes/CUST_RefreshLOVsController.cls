public with sharing class CUST_RefreshLOVsController {

	CUST_RefreshLOVsUtil       util;
	CST_App_Menu_Pool_GLBL__c  pool;
	final Map<String,String>   prefixes;
	public CST_App_Settings_CUST__c   settings { get; private set; }
	public String 					  fieldsToRefresh { get; set; }

	public CUST_RefreshLOVsController(ApexPages.StandardController controller) {

		CST_App_Settings_CUST__c record = (CST_App_Settings_CUST__c) controller.getRecord();

		if (record.Id != null) {
			// get all fields in the App Settings record
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
			
			// init prefix matching
			prefixes = new Map<String,String>{
				'a'=>'Account',
				'aff'=>'Affiliation_GLBL__c',
				'alt'=>'Alternate_Id_GLBL__c',
				'c'=>'Preferences_and_Consent_GLBL__c',
				's'=>'Specialty_MERC__c'
			};

			// init helper class
			util = new CUST_RefreshLOVsUtil();
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No App Settings record found.'));
		}
	}

	public PageReference refreshSelectedLOVs() {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'fieldsToRefresh: '+fieldsToRefresh));
		Map<String, List<String>> objectsToFields = new Map<String, List<String>>();
		for (String field : fieldsToRefresh.split(',')) {
			util.p('field :'+field+' from '+fieldsToRefresh);
			processSubmittedField(field, objectsToFields);
		}
		util.p('Setting fieldsToRefresh to: '+objectsToFields);

		refresh(objectsToFields, getEarliestModDate(fieldsToRefresh));

		//TODO - !!!! SANITIZE INCOMING FIELD NAMES!!!
		return null;
	}

	public void refresh(Map<String, List<String>> objectsToFields, Date d) {
		CST_App_Menu_Pool_GLBL__c p = (pool != null) ? pool : new CST_App_Menu_Pool_GLBL__c();
		CUST_RefreshLOVsBatch batch = new CUST_RefreshLOVsBatch(settings, p, objectsToFields, d);
		Database.executeBatch(batch);
	}

	private void processSubmittedField(String objFieldPair, Map<String, List<String>> objectsToFields) {
		List<String> objNameAndFieldName = objFieldPair.split('\\.');
		util.p('objNameAndFieldName :'+objNameAndFieldName);
		String objName = prefixes.get(objNameAndFieldName[0]);
		if (objName != null) {
			if (objectsToFields.get(objName)==null) objectsToFields.put(objName, new List<String>());
			objectsToFields.get(objName).add(objNameAndFieldName[1]);
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to target object. ('+objNameAndFieldName[0]+')'));
		}
	}

	public Date getEarliestModDate(String fields) {

		List<String> dateFieldNames = new List<String>();
		List<String> fieldNames = fields.split(',');
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