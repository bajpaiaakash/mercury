public with sharing class MERC_MergedAccountsController {

	/* this list of accounts that have been merged and need manual intervention */
	public List<SelectableAccount> mergedAccounts { get; set; }

	/* the list of related lists for the selected account */
	public List<RelatedList>    relatedLists   { get; set; }

	/* The account that a user has selected to work on */
	public Id activeAccountId    { get; set; }
	public Account activeAccount { get; private set; }

	public MERC_MergedAccountsController() {
		mergedAccounts = new List<SelectableAccount>();
		activeAccount  = new Account();
		//List<Merge_History_GLBL__c> unprocessedMerges =
		for (Account a : [SELECT Id, Name, Country_of_Residence_GLBL__c, IsPersonAccount FROM Account Limit 10])
		{
			mergedAccounts.add( new SelectableAccount(a));
		}
	}

	public ApexPages.StandardSetController setController {
		get
		{
			String query = 'Select Id, Name FROM Account Order By Name limit 10';
			if(setController == null) {
				setController = new ApexPages.StandardSetController(Database.getQueryLocator( query ));
				// sets the number of records in each page set
				setController.setPageSize(5);
			}
		return setController;
		}
		set;
	}

	public void selectAccount()
	{
		System.debug('###### activeAccountId ' + activeAccountId);
	}

	public void markAccountsAsComplete()
	{
		System.debug('\n\n\n        STARTING LOOP\n\n\n');
		for (SelectableAccount wa : mergedAccounts)
		{
			System.debug('\n\n' + wa);
			if (wa.selected)
			{
				System.debug('\n\n' + wa.detail.Name);
				//wa.selected = false;
			}
		}
	}

	/* Holds this list of accounts with a selected boolean so that
	   Users can mark an account as completed */
	public class SelectableAccount
	{
		public Account detail   { get; set; }
		public Boolean selected { get; set; }

		public SelectableAccount(Account a)
		{
			this.detail   = a;
			this.selected = false;
		}
	}

	/* a generic sObject with a selected attribute */
	public class WrappedSObject
 	{
 		public SObject detail   { get; private set; }
 		public Boolean selected { get; set; }
 	}

 	/* represents two sets of relates lists. the winning records list
 	   (for reference) and the losing records list with the records that
 	   can be moved to the winning record */
 	public class RelatedList
 	{
 		public List<SObject>        winningObjectList { get; private set; }
 		public List<WrappedSObject> losingObjectList  { get; private set; }
		private Id winningRecordId;

		public RelatedList(Id winningRecordId)
		{
			this.winningRecordId   = winningRecordId;
			this.winningObjectList = new List<SObject>();
			this.losingObjectList  = new List<WrappedSObject>();
		}

		public void moveRecordsToWinner()
		{
			for (WrappedSObject wo : losingObjectList)
			{
				if (wo.selected)
				{
					//TODO: reparent/copy record to winner
				}
			}
		}
 	}
}