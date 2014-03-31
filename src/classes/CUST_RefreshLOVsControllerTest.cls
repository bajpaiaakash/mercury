@isTest
private class CUST_RefreshLOVsControllerTest {

	private static CST_App_Settings_CUST__c   record;
	private static CUST_RefreshLOVsController controller;
	private static CUST_RefreshLOVsUtil util;
	
	static {
		record = CUST_TestFactory.insertAppSetting();
		controller = new CUST_RefreshLOVsController(new ApexPages.StandardController(record));
		util = new CUST_RefreshLOVsUtil();

		Test.setCurrentPage(Page.CUST_RefreshLOVs);
	}

//	@isTest 
	static void testConstructor() {
		System.assertNotEquals(null, controller.settings,'settings not initiated.');
	}

//	@isTest
	static void testConstructorError() {
		ApexPages.StandardController noRecordId = new ApexPages.StandardController(new CST_App_Settings_CUST__c());
		controller = new CUST_RefreshLOVsController(noRecordId);

		System.assert(!ApexPages.getMessages().isEmpty(),'Error message not passed back to page.');
	}

	@isTest
	static void refreshFields() {

		List<Account> accts = MERC_TestFactory.insertAccounts(3);

		String f = 'Bnft_Dsgn_Cd_GLBL__c';
		controller.fieldsToRefresh = f;
		accts = Database.query('SELECT Id, '+f+' FROM Account WHERE Id in :accts');

		List<String> newValues = new List<String>{'Othello','Desdemona','Iago'};
		Integer i = 0;
		String thisVal;
		for (Account a : accts) {
			a.put(f,newValues.get(i));
			i++;
			if (i>=newValues.size()) i = 0;
		}
		update accts;

		PageReference result = controller.refreshSelectedLOVs();

		System.assertEquals(null,result,'Diff PageRef returned: '+result);

		List<CST_App_Menu_Pool_GLBL__c> poolRecords = Database.query('SELECT Id, '+f+', '+util.getDateFieldName(f)+' FROM CST_App_Menu_Pool_GLBL__c');
		System.assert(!poolRecords.isEmpty());

		String SQL = 'SELECT '+f+' from Account where Id in :accts group by '+f; 
		AggregateResult[] aggResults = Database.query(SQL);

		for (AggregateResult ar : aggResults) {
			System.assert(poolRecords[0].Bnft_Dsgn_Cd_GLBL__c.contains((String) ar.get(f)),
				'pool record for '+f+' does not contain test value "'+(String) ar.get(f)+'"');
			System.assertEquals(Date.today(), poolRecords[0].get(util.getDateFieldName(f)));
		}
	}

	static void p(String m) {
		System.debug('\n\n\nYYZ - '+m+'\n\n\n\n');
	}
}