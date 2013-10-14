@isTest
private class SobjectDataLoaderTestMVN {
	
	@IsTest(seeAllData=true) // http://stackoverflow.com/questions/9164986/how-do-i-avoid-standard-price-not-defined-when-unit-testing-an-opportunitylineit 
	public static void testManuallyConfigured()
	{				
		// Save point to rollback test data
		System.Savepoint savePoint = Database.setSavepoint();
		
		// Serialise test data into JSON record set bundle via manual configuration
		String serializedData = SobjectDataLoaderMVN.serialize(createOpportunities(), 
			new SobjectDataLoaderMVN.SerializeConfig().
				followChild(OpportunityLineItem.OpportunityId). 	// Serialize any related OpportunityLineItem's (children)
					follow(OpportunityLineItem.PricebookEntryId). 	// Serialize any related PricebookEntry's
						follow(PricebookEntry.Product2Id). 			// Serialize any related Products's
						omit(OpportunityLineItem.UnitPrice)); 		// Do not serialize the UnitPrice, as TotalPrice is enough and both cannot exist together
					
		// Rollback test data
		Database.rollback(savePoint);
		
		// Recreate test data via deserialize
		Set<ID> resultIds = SobjectDataLoaderMVN.deserialize(serializedData, new ApplyStandardPricebook());
		assertResults(resultIds);
	}

	@IsTest(seeAllData=true) // http://stackoverflow.com/questions/9164986/how-do-i-avoid-standard-price-not-defined-when-unit-testing-an-opportunitylineit
	public static void testAutoConfigured()
	{
		// Save point to rollback test data
		System.Savepoint savePoint = Database.setSavepoint();
		
		// Serialise test data into JSON record set bundle via auto configuraiton (with some manual tweaks)
		String serializedData = SobjectDataLoaderMVN.serialize(createOpportunities(),
			new SobjectDataLoaderMVN.SerializeConfig().
				auto(Opportunity.sObjectType). 			// Automatically determine child and related object references needed (calls follow methods)
				omit(OpportunityLineItem.UnitPrice). 	// Do not serialize the UnitPrice, as TotalPrice is enough and both cannot exist together
				omit(PricebookEntry.Pricebook2Id).		// Do not serialize any Pricebook references (these will be reassoicated apone deserialization)
				omit(Opportunity.Pricebook2Id));		// Do not serialize any Pricebook references (these will be reassoicated apone deserialization)

		// Rollback test data
		Database.rollback(savePoint);
		
		// Recreate test data via deserialize
		Set<ID> resultIds = SobjectDataLoaderMVN.deserialize(serializedData, new ApplyStandardPricebook());
		assertResults(resultIds);				
	}

	/**
		--Without Whitelisting RecordTypeId, the autoconfig serialize/deserialize
			will try to insert a new RecordType object which throws:
			'System.TypeException: DML not allowed on RecordType'

		--Test uses dynamic binding to prevent compile-time errors in orgs without RecordTypes enabled
		--Currently, the test method only tests the logic if there are 2+ RecordTypes on the Account object
			otherwise, the if statement will silently ignore the rest of the testMethod.
	**/

	@isTest(seeAllData=False)
	private static void shouldNotTryToInsertRecordType(){
		List<RecordType> accountRecordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Account' AND isActive = TRUE AND DeveloperName = 'Vendor'];
		//Only run this test if there are multiple active recordtypes on Account object
		if (accountRecordTypes.size() > 0){
			List<sObject> testAccounts = new List<Account>();
			for (RecordType aRT : accountRecordTypes){
				sObject testAccount = new Account(Name = 'Test' + aRT.DeveloperName);
				
				//dynamic binding will prevent any compile time errors if RecordTypeId field doesn't exist
				testAccount.put('RecordTypeId', aRT.Id);
				testAccounts.add(testAccount);
			}
			insert testAccounts;
			Set<Id> newAccountIds = new Set<Id>();
			for (sObject myAccount : testAccounts){
				newAccountIds.add(myAccount.Id);
			}
			String serializedData = SobjectDataLoaderMVN.serialize(newAccountIds);
			Set<Id> resultIds = SobjectDataLoaderMVN.deserialize(serializedData);
			
			//dynamic soql will prevent any compile time errors if RecordTypeId field doesn't exist
			String accountsQuery = 'SELECT Id, RecordTypeId FROM Account WHERE Id IN :newAccountIds';
			testAccounts = Database.query(accountsQuery);
			Set<Id> recordTypeIdsOfNewAccounts = new Set<Id>();

			for (sObject myAccount : testAccounts){
				recordTypeIdsOfNewAccounts.add((Id) myAccount.get('RecordTypeId'));
			}
			system.assertEquals(recordTypeIdsOfNewAccounts.size(), accountRecordTypes.size());
		}
	}

	/**
	 * Test implemetnation of IDeserializeCallback, automatically applies Standard Pricebook to new PricebookEntry's
	 **/
	private class ApplyStandardPricebook implements SobjectDataLoaderMVN.IDeserializeCallback
	{
		private Pricebook2 standardPricebook;
		
		public ApplyStandardPricebook()
		{
			standardPricebook = [select Id from Pricebook2 where IsStandard = true];				
		}
		
		public void unresolvedReferences(Schema.SObjectType sObjectType, List<SobjectDataLoaderMVN.UnresolvedReferences> unresolvedReferences)
		{
			if(sObjectType == PricebookEntry.sObjectType) // PricebookEntry object?
				for(SobjectDataLoaderMVN.UnresolvedReferences unresolvedReference : unresolvedReferences)
					if(unresolvedReference.References.contains(PricebookEntry.Pricebook2Id)) // Pricebook2Id field?
						unresolvedReference.Record.put(PricebookEntry.Pricebook2Id, standardPricebook.id); // Set Standard Pricebook
		}		
	}
	
	private static Set<ID> createOpportunities()
	{
		// Grab the Standard Pricebook (cannot create these via Apex)
		Pricebook2 pb = [select Id from Pricebook2 where IsStandard = true];	
				
		// Insert Opportunities
		List<Opportunity> opps = new List<Opportunity>();
		List<List<Product2>> productsByOpp = new List<List<Product2>>(); 		
		List<List<PricebookEntry>> pricebookEntriesByOpp = new List<List<PricebookEntry>>(); 		
		List<List<OpportunityLineItem>> oppLinesByOpp = new List<List<OpportunityLineItem>>(); 		
		for(Integer o=0; o<10; o++)
		{
			Opportunity opp = new Opportunity();
			opp.Name = 'Test Name ' + o;
			opp.StageName = 'Open';
			opp.CloseDate = System.today();
			opps.add(opp);
			List<Product2> products = new List<Product2>();
			List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
			List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
			for(Integer i=0; i<o+1; i++)
			{						
				Product2 product = new Product2();
				product.Name = opp.Name + ' : Product : ' + i;
				products.add(product);
				PricebookEntry pbe = new PricebookEntry();
				pbe.UnitPrice = 10;
				pbe.IsActive = true;
				pbe.UseStandardPrice = false;
				pbe.Pricebook2Id = pb.Id;
				pricebookEntries.add(pbe);
				OpportunityLineItem oppLineItem = new OpportunityLineItem();
				oppLineItem.Quantity = 1;
				oppLineItem.TotalPrice = 10;
				oppLineItems.add(oppLineItem);
			}
			productsByOpp.add(products);
			pricebookEntriesByOpp.add(pricebookEntries);
			oppLinesByOpp.add(oppLineItems);				
		}
		// Insert Opportunities
		insert opps;
		// Insert Products
		List<Product2> allProducts = new List<Product2>(); 
		for(List<Product2> products : productsByOpp)
		{
			allProducts.addAll(products);			
		}
		insert allProducts;
		// Insert Pricebooks
		Integer oppIdx = 0;			
		List<PricebookEntry> allPricebookEntries = new List<PricebookEntry>();				
		for(List<PricebookEntry> pricebookEntries : pricebookEntriesByOpp)
		{
			List<Product2> products = productsByOpp[oppIdx++];
			Integer lineIdx = 0;
			for(PricebookEntry pricebookEntry : pricebookEntries)
			{
				pricebookEntry.Product2Id = products[lineIdx++].Id;
			}
			allPricebookEntries.addAll(pricebookEntries);
		}			
		insert allPricebookEntries;
		// Insert Opportunity Lines
		oppIdx = 0;						
		List<OpportunityLineItem> allOppLineItems = new List<OpportunityLineItem>(); 			
		for(List<OpportunityLineItem> oppLines : oppLinesByOpp)
		{
			List<PricebookEntry> pricebookEntries = pricebookEntriesByOpp[oppIdx];
			Integer lineIdx = 0;
			for(OpportunityLineItem oppLine : oppLines)
			{
				oppLine.OpportunityId = opps[oppIdx].Id;
				oppLine.PricebookEntryId = pricebookEntries[lineIdx++].Id;
			}
			allOppLineItems.addAll(oppLines);
			oppIdx++;
		}			
		insert allOppLineItems;		
		return new Map<Id, Opportunity>(opps).keySet();			
	}
	
	private static void assertResults(Set<ID> opportunityIds)
	{
		Pricebook2 standardPriceBook = [select Id from Pricebook2 where IsStandard = true];
		List<Opportunity> opportunities = 
			[select Id, Name, Amount, 
				(select id, PricebookEntry.Product2.Name, PricebookEntry.Pricebook2Id, UnitPrice 
				 from OpportunityLineItems 
				 order by PricebookEntry.Product2.Name) 
				from Opportunity 
				where Id in :opportunityIds 
				order by Name];
		System.assertEquals(10, opportunities.size());
		System.assertEquals('Test Name 0', opportunities[0].Name);
		System.assertEquals(10, opportunities[0].Amount);
		System.assertEquals('Test Name 9', opportunities[9].Name);
		System.assertEquals(100, opportunities[9].Amount);		
		System.assertEquals(1, opportunities[0].OpportunityLineItems.size());
		System.assertEquals(10, opportunities[0].OpportunityLineItems[0].UnitPrice);
		System.assertEquals('Test Name 0 : Product : 0', opportunities[0].OpportunityLineItems[0].PricebookEntry.Product2.Name);
		System.assertEquals(standardPriceBook.Id, opportunities[0].OpportunityLineItems[0].PricebookEntry.Pricebook2Id);
		System.assertEquals(10, opportunities[9].OpportunityLineItems.size());
		System.assertEquals(10, opportunities[9].OpportunityLineItems[0].UnitPrice);
		System.assertEquals('Test Name 9 : Product : 9', opportunities[9].OpportunityLineItems[9].PricebookEntry.Product2.Name);
		System.assertEquals(standardPriceBook.Id, opportunities[9].OpportunityLineItems[9].PricebookEntry.Pricebook2Id);		
	}
	
}