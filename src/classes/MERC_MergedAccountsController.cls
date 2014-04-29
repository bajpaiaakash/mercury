public with sharing class MERC_MergedAccountsController {

	/* The account that a user has selected to work on */
	public Id activeAccountId    { get; set; }
	public ApexPages.StandardSetController ssc { get; set; }
	String baseAcctSoqlQuery;

	public MERC_MergedAccountsController() {
		List<Merge_History_GLBL__c> mergeHistoryToProcess = [SELECT Id
																  , Winning_Id_GLBL__c
		                                                          , Original_Account_ID_GLBL__c
		                                                          , Merge_Processed_MERC__c
		                                                       FROM Merge_History_GLBL__c
		                                                      WHERE Merge_Processed_MERC__c = false];
		ssc = new ApexPages.StandardSetController(mergeHistoryToProcess);
		ssc.setPageSize(1);
		Schema.FieldSet acctFieldSet = Schema.SObjectType.Account.fieldsets.Merge_Account_Page_Main_List;
		baseAcctSoqlQuery = 'SELECT Id';
		for (Schema.FieldSetMember fsm : acctFieldSet.getFields())
		{
			if (fsm.getFieldPath() != 'Id')
				baseAcctSoqlQuery += ', ' + fsm.getFieldPath();
		}
		baseAcctSoqlQuery += ' FROM Account WHERE Id IN (';
	}

	public List<Account> getAccounts()
	{
		if (ssc.getRecords().isEmpty())
		{
			return new List<Account>();
		}
		String soqlQuery =  baseAcctSoqlQuery;
		Boolean afterFirst = false;
		for (SObject mh : ssc.getRecords())
		{
			if (afterFirst) soqlQuery += ',';
			soqlQuery += '\'' + mh.get('Winning_Id_GLBL__c') + '\'';
			afterFirst = true;
		}
		soqlQuery += ')';

		return Database.query(soqlQuery);
	}
}