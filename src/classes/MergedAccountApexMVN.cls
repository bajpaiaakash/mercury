public with sharing class MergedAccountApexMVN
{

	private Account winningAccount = new Account();
	private Id      losingAccountId;

	public MergedAccountApexMVN(Id winnerId, Id loserId)
	{
		losingAccountId = loserId;

		/*----- Build the query string for the winning account from the field set -----*/
		Set<String> acctFieldSet = new Set<String>{'Id'};
		for(Schema.FieldSetMember fsm : Schema.SObjectType.Account.fieldSets.Merge_Account_Page_Main_List.getFields())
		{
			acctFieldSet.add(fsm.getFieldPath());
		}
		String soqlQuery = 'SELECT ';
		for (String s : acctFieldSet)
		{
			soqlQuery += s + ', ';
		}
		/*----- remove the last comma -----*/
		soqlQuery.left(soqlQuery.length() - 2);
		soqlQuery += ' FROM Account WHERE Id = \'' + winnerId +'\' LIMIT 1';

		/*----- Use the query string to get the winning and losing account -----*/
		if (String.isNotBlank(winnerId))
		{
			try
			{
				winningAccount = database.query(soqlQuery);
			}
			catch (System.QueryException ex)
			{
				System.debug('\n\n\nQuery Exception: ' + ex + '\n\n\n');
				throw new MERC_Exception('An error has occurred querying for the account information.');
			}
		}
	}



	public class RelatedListGroup
	{
		List<SObject>           winningList { get; private set; }
		List<SelectableSObject> losingList  { get; private set; }
	}

	public class SelectableSObject
	{
		public SObject detail   { get; private set; }
		public Boolean selected { get; set; }
	}
}