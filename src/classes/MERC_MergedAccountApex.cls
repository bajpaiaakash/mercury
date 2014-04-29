public class MERC_MergedAccountApex {

	private Account winningAccount = new Account();
	private Id      losingAccountId;
	private List<RelatedListGroup> relatedLists;
	private static Map<String, Account_Merge_Related_Lists_MERC__c> relatedListSettings = Account_Merge_Related_Lists_MERC__c.getAll();

	public MERC_MergedAccountApex(Id winnerId, Id loserId)
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
<<<<<<< HEAD
		soqlQuery = soqlQuery.left(soqlQuery.length() - 2);
		soqlQuery += ' FROM Account WHERE Id = \'' + winnerId +'\' LIMIT 1';

		System.debug(soqlQuery);

=======
		soqlQuery.left(soqlQuery.length() - 2);
		soqlQuery += ' FROM Account WHERE Id = \'' + winnerId +'\' LIMIT 1';

>>>>>>> FETCH_HEAD
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

	public List<RelatedListGroup> getAllRelatedLists()
	{
		if (relatedLists == null)
		{
			List<String> objectsForSchema = new List<String>();
			for (Account_Merge_Related_Lists_MERC__c rl : relatedListSettings.values())
			{
				objectsForSchema.add(rl.Name);
			}
			List<Schema.DescribeSObjectResult> descResults = Schema.describeSObjects(objectsForSchema);

			for(Schema.DescribeSObjectResult dr : descResults)
			{
				Account_Merge_Related_Lists_MERC__c thisRelatedListSettings =  relatedListSettings.get(dr.getName());
				RelatedListGroup thisRL = new RelatedListGroup(dr.getName(), thisRelatedListSettings.Parent_Account_Field_MERC__c, winningAccount.Id);
				thisRL.createWinningListSoql(dr.fieldSets.getMap().get(thisRelatedListSettings.Winning_Acct_Related_List_Field_Set_MERC__c).getFields());
				thisRL.createLosingListSoql(dr.fieldSets.getMap().get(thisRelatedListSettings.Losing_Acct_Related_List_Field_Set_MERC__c).getFields());
			}
		}
		return relatedLists;
	}

	public class RelatedListGroup
	{
<<<<<<< HEAD
		public List<Schema.FieldSetMember> winningFields { get; private set; }
		public List<Schema.FieldSetMember> losingFields  { get; private set; }

=======
>>>>>>> FETCH_HEAD
		private String winningListSoql;
		private String losingListSoql;
		private String sObjectName;
		private String parentField;
		private String parentId;

		public RelatedListGroup(String name, String parentField, String parentId)
		{
			sObjectName = name;
			parentField = parentField;
			parentId    = parentId;
		}

		public void createWinningListSoql(List<Schema.FieldSetMember> fields)
		{
<<<<<<< HEAD
			winningFields = fields;
=======
>>>>>>> FETCH_HEAD
			winningListSoql = MERC_MergedAccountApex.buildSoqlString(fields, sObjectName, parentField, parentId);
		}

		public void createLosingListSoql(List<Schema.FieldSetMember> fields)
		{
<<<<<<< HEAD
			losingFields = fields;
=======
>>>>>>> FETCH_HEAD
			losingListSoql = MERC_MergedAccountApex.buildSoqlString(fields, sObjectName, parentField, parentId);
		}

		public List<SObject> winningList
		{
			get
			{
				if (winningList == null)
				{
					winningList = Database.query(winningListSoql);
				}
				return winningList;
			}
			private set;
		}

		public List<SelectableSObject> losingList
		{
			get
			{
				if (losingList == null)
				{
					losingList = new List<SelectableSObject>();
					for (SObject so : Database.query(losingListSoql))
					{
						losingList.add(new SelectableSObject(so));
					}
				}
				return losingList;
			}
			private set;
		}

		public void mergeSelectedRecords()
		{
			List<SObject> objectsToUpdate              = new List<SObject>();
			List<SelectableSObject> nonSelectedObjects = new List<SelectableSObject>();

			for (SelectableSObject so : losingList)
			{
				if (so.selected)
				{
					/*----- reparent to the winning record parent id -----*/
					so.detail.put(parentField, parentId);
					objectsToUpdate.add(so.detail);
				}
				else
				{
					nonSelectedObjects.add(so);
				}
			}

			try
			{
				update objectsToUpdate;
				/*----- update the losing list to only the non-reparented items -----*/
				losingList = nonSelectedObjects;
			}
			catch(System.DMLException ex)
			{
				ApexPages.addMessages(ex);
			}
		}

	}

	public class SelectableSObject
	{
		public SObject detail   { get; private set; }
		public Boolean selected { get; set; }

		public SelectableSObject(SObject theObject)
		{
			detail   = theObject;
			selected = false;
		}
	}

	private static String buildSoqlString(List<Schema.FieldSetMember> fields, String objectName, String parentField, String parentId)
	{
		String soql = 'SELECT Id';
		for (Schema.FieldSetMember field : fields)
		{
			if (field.getFieldPath() != 'Id')
			{
				soql += ', ' + field.getFieldPath();
			}
		}
		soql += ' FROM ' + objectName + ' WHERE ' + parentField + '=\'' + parentId+ '\'';
		return soql;
	}
}