/**
* CUST_RefreshLOVsControllerTest
* Created By: Mavens Consulting
* Description: Tests the CUST_RefreshLOVsController class.
*/
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

	@isTest
	static void testConstructor() {
		System.assertNotEquals(null, controller.settings,'settings not initiated.');
	}

	@isTest
	static void testConstructorError() {
		ApexPages.StandardController noRecordId = new ApexPages.StandardController(new CST_App_Settings_CUST__c());
		controller = new CUST_RefreshLOVsController(noRecordId);

		System.assert(!ApexPages.getMessages().isEmpty(),'Error message not passed back to page.');
	}

	@isTest
	static void refreshAccountFields() {

		List<Account> accts = MERC_TestFactory.insertAccounts(2);
		String acctFields = 'Bnft_Dsgn_Cd_GLBL__c,Clsfctn_Cd_GLBL__c,Party_Sts_Cd_GLBL__c';
		accts = Database.query('SELECT Id, '+acctFields+' FROM Account WHERE Id in :accts');

		List<String> newValues = new List<String>{'Othello','Desdemona','Iago','Cassio','Emilia','Bianca','Brabantio','Roderigo','the Duke of Venice'};

		Integer i = 0;
		String thisVal;
		for (Account a : accts) {
			for (String f : acctFields.split(',')) {
				a.put(f,newValues.get(i));
			}
			i++;
			if (i>=newValues.size()) i = 0;

			a.CST_App_Menu_Flag_CUST__c = acctFields.replace(',',';');
		}
		update accts;

		Test.startTest();
		controller.fieldsToRefresh = 'a.Bnft_Dsgn_Cd_GLBL__c,a.Clsfctn_Cd_GLBL__c,a.Party_Sts_Cd_GLBL__c';
		PageReference result = controller.refreshSelectedLOVs();
		Test.stopTest();

		System.assertEquals(null,result,'Unexpected PageRef returned: '+result);

		Id settingsId = controller.settings.Id;
		String fields = acctFields;
		List<CST_App_Menu_Pool_GLBL__c> poolRecords = Database.query(
			'SELECT Id, '+fields+','+util.getDateFieldNames(fields)+
			' FROM CST_App_Menu_Pool_GLBL__c WHERE App_Settings_CUST__c = :settingsId'
			);
		util.p('pool:'+poolRecords);
		System.assert(!poolRecords.isEmpty(),'Pool records not found WHERE App_Settings_CUST__c = '+ settingsId);
		System.assertEquals(1,poolRecords.size(),'Unexpected # of pool records. Should just be 1 for '+ settingsId + ' but there are '+ poolRecords.size());

		for (String f : acctFields.split(',')) {
			System.assert(poolRecords[0].get(f) != null, f+' was null.');
			String SQL = 'SELECT '+f+' from Account where Id in :accts group by '+f;
			AggregateResult[] aggResults = Database.query(SQL);

			for (AggregateResult ar : aggResults) {
				String values = (String) poolRecords[0].get(f);
				System.assert(values.contains((String) ar.get(f)),
					'pool record for '+f+' does not contain test value "'+(String) ar.get(f)+'"');
				System.assertEquals(Date.today(), poolRecords[0].get(util.getDateFieldName(f)), 'pool record not updated to today');

			}
		}
	}

	@isTest
	static void refreshAllFields() {

		List<Account> accts = MERC_TestFactory.insertAccounts(2);
		String acctFields = 'Bnft_Dsgn_Cd_GLBL__c,Clsfctn_Cd_GLBL__c,Party_Sts_Cd_GLBL__c';
		accts = Database.query('SELECT Id, '+acctFields+' FROM Account WHERE Id in :accts');

		List<String> newValues = new List<String>{'Othello','Desdemona','Iago','Cassio','Emilia','Bianca','Brabantio','Roderigo','the Duke of Venice'};
		List<Integer> newNumbers = new List<Integer>{3,7,32,42,44};

		Integer i = 0;
		String thisVal;
		for (Account a : accts) {
			for (String f : acctFields.split(',')) {
				a.put(f,newValues.get(i));
			}
			i++;
			if (i>=newValues.size()) i = 0;

			a.CST_App_Menu_Flag_CUST__c = acctFields.replace(',',';');
		}
		update accts;

		String affFields = 'Rltnshp_Typ_Desc_GLBL__c,Priority_Rank_Nbr_GLBL__c';
		List<Account> affilAccounts = MERC_TestFactory.insertAccounts(2);
		List<Affiliation_GLBL__c> affils = new List<Affiliation_GLBL__c>();
		i = 0;
		Integer j = 0,k = 0;
		for (Account a : affilAccounts) {
			if (k<accts.size()) {
				Affiliation_GLBL__c affil = new Affiliation_GLBL__c();
				affil.Account_GLBL__c = accts.get(k).Id;
				affil.Account_Cust_Id_GLBL__c = a.Id;
				affil.Afltn_Role_Desc_GLBL__c = newValues.get(i);
				affil.Priority_Rank_Nbr_GLBL__c = newNumbers.get(j);
				affil.Rltnshp_Typ_Desc_GLBL__c = newValues.get(i);
				i++;
				if (i>=newValues.size()) i = 0;
				j++;
				if (j>=newNumbers.size()) j = 0;
				affils.add(affil);
			}
			k++;
		}
		insert affils;


		Test.startTest();
		controller.fieldsToRefresh = 'a.Bnft_Dsgn_Cd_GLBL__c,a.Clsfctn_Cd_GLBL__c,a.Party_Sts_Cd_GLBL__c,s.Spclty_Desc_Cd_GLBL__c,'+
			's.Priority_Rank_Nbr_GLBL__c,alt.Altrnt_Id_Typ_Desc_GLBL__c,c.Cnsnt_Sts_Cd_GLBL__c,'+
			'c.Cnsnt_Prps_Cd_GLBL__c,aff.Rltnshp_Typ_Desc_GLBL__c,aff.Priority_Rank_Nbr_GLBL__c';
		PageReference result = controller.refreshSelectedLOVs();
		Test.stopTest();

		System.assertEquals(null,result,'Unexpected PageRef returned: '+result);

		Id settingsId = controller.settings.Id;
		String fields = acctFields +','+ affFields;
		List<CST_App_Menu_Pool_GLBL__c> poolRecords = Database.query(
			'SELECT Id, Last_Job_Status_GLBL__c, '+fields+','+util.getDateFieldNames(fields)+
			' FROM CST_App_Menu_Pool_GLBL__c WHERE App_Settings_CUST__c = :settingsId'
			);
		System.assert(!poolRecords.isEmpty(),'Pool records not found WHERE App_Settings_CUST__c = '+ settingsId);
		System.assertEquals(1,poolRecords.size(),'Unexpected # of pool records. Should just be 1 for '+ settingsId + ' but there are '+ poolRecords.size());
		System.assert(poolRecords[0].Last_Job_Status_GLBL__c != null,'Status info was empty.');
		util.p(poolRecords[0].Last_Job_Status_GLBL__c);

		for (String f : acctFields.split(',')) {
			System.assert(poolRecords[0].get(f) != null, f+' was null.');
			String SQL = 'SELECT '+f+' from Account where Id in :accts group by '+f;
			AggregateResult[] aggResults = Database.query(SQL);

			for (AggregateResult ar : aggResults) {
				String values = (String) poolRecords[0].get(f);
				System.assert(values.contains((String) ar.get(f)),
					'pool record for '+f+' does not contain test value "'+(String) ar.get(f)+'"');
				System.assertEquals(Date.today(), poolRecords[0].get(util.getDateFieldName(f)), 'pool record not updated to today');
			}
		}

		for (String f : affFields.split(',')) {
			if (f != 'Priority_Rank_Nbr_GLBL__c') {
				System.assert(poolRecords[0].get(f) != null, f+' was null.');
				String SQL = 'SELECT '+f+' from Affiliation_GLBL__c where Id in :affils group by '+f;
				AggregateResult[] aggResults = Database.query(SQL);

				for (AggregateResult ar : aggResults) {
					String values = (String) poolRecords[0].get(f);
					System.assert(values.contains((String) ar.get(f)),
						'pool record for '+f+' does not contain test value "'+(String) ar.get(f)+'"');
					System.assertEquals(Date.today(), poolRecords[0].get(util.getDateFieldName(f)), 'pool record not updated to today');
				}
			}
		}
	}

	@isTest static void test_refreshSelectedLOVs() {
		controller.fieldsToRefresh = null;
		System.assertEquals(null, controller.refreshSelectedLOVs());
		System.assertEquals('No fields selected for refresh.', ApexPages.getMessages().get(0).getSummary());
	}
}