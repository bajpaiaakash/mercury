public with sharing class CUST_RefreshLOVsController {

	CUST_RefreshLOVsUtil       util;
	CST_App_Menu_Pool_GLBL__c  pool;

	public CST_App_Settings_CUST__c   settings { get; private set; }
	public String 					  fieldsToRefresh { get; set; }

	public CUST_RefreshLOVsController(ApexPages.StandardController controller) {

		CST_App_Settings_CUST__c record = (CST_App_Settings_CUST__c) controller.getRecord();

		if (record.Id != null) {
			MERC_Util.SelectAll allSelector = new MERC_Util.SelectAll(CST_App_Settings_CUST__c.sObjectType, record.Id);
			settings = Database.query(allSelector.SOQL);

			allSelector = new MERC_Util.SelectAll(CST_App_Menu_Pool_GLBL__c.sObjectType, null);
			try 
			{
				pool = Database.query(allSelector.SOQL);
			} catch (QueryException qe) {
				System.debug(LoggingLevel.WARN, 'When getting pool records: '+qe.getMessage());
			}
			
			util = new CUST_RefreshLOVsUtil();
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No App Settings record found.'));
		}
	}

	public PageReference refreshSelectedLOVs() {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'fieldsToRefresh: '+fieldsToRefresh));

		fieldsToRefresh = 'Bnft_Dsgn_Cd_GLBL__c';
		util.p('Setting fieldsToRefresh to a simple value for now: '+fieldsToRefresh);
		refresh(fieldsToRefresh, getEarliestModDate(fieldsToRefresh));

		//TODO - !!!! SANITIZE INCOMING FIELD NAMES!!!

		return null;
	}

	public void refresh(String f, Date d) {
		String SQL = 'select '+f+' from Account where RecordType.DeveloperName = \'HCP_GLBL\' group by '+f; 
		AggregateResult[] aggResults = Database.query(SQL);

		Map<String, String> newValues = new Map<String, String>();
		for (AggregateResult ar : aggResults) {
			if (!newValues.containsKey(f)) {
				newValues.put(f,(String) ar.get(f));
			} else {
				newValues.put(f,newValues.get(f)+','+ar.get(f));
			}
		}

		CST_App_Menu_Pool_GLBL__c p = (pool != null) ? pool : new CST_App_Menu_Pool_GLBL__c();
		p.put(f,newValues.get(f));
		// TODO: catch String too long
		String dateField = f.substring(0,f.indexOfIgnoreCase(util.SUFFIX))+util.DATENAME+util.SUFFIX;
		p.put(dateField,Date.today());

		upsert p;
	}

	public PageReference refreshAllLOVs() {
		return null;
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