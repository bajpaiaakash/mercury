/**
  * @author Paul Battisson
  * This trigger is responsible for reviewing all newly created Merge_History_GLBL__c records
  * and counting the number of related records for the losing account to determine whether 
  * the record should be processed and needs review, otherwise ist should be marked as 
  * complete/processed.
  */
public with sharing class MERC_MergeHistoryStampTriggerHandler implements GLBL_TriggerHandler.HandlerInterface {

	//Interface required method to determine whether the trigger is active.
	public Boolean isActive()
	{
		return MERC_TriggerHandlerStateManager.isActive(MERC_MergeHistoryStampTriggerHandler.class);
	}

	//Interface required method to handle the trigger context
	public void handle()
	{
		if(Trigger.isInsert && Trigger.isBefore) {
			executeBeforeInsert(Trigger.new);
		}
	}

	/**
	  * @description This is the method to handle the after insert event. The method retrieves a count
	  * of all the related records for each of the Account Ids on the merge records. 
	  */
	private void executeBeforeInsert(List<Merge_History_GLBL__c> histories) {
		//Firstly let us loop through the list of Merge History records and retrieve
		//all of the original account Ids.
		List<String> originalIds = new List<String>();
		for(Integer i = 0, j = histories.size(); i < j; i++) {
			originalIds.add(histories[i].Original_Account_ID_GLBL__c);
		}

		//Build our base queries for every related list object
		List<String> countQueries = buildCountQueriesForObjects();

		//This map will store the ongoing count as we loop through the aggregate results
		Map<String, Integer> idRelatedRecords = new Map<String, Integer>();

		//Loop through the queries running them and storing their results in a list of results
		List<List<AggregateResult>> aggResults = new List<List<AggregateResult>>();
		for(Integer i = 0, j = countQueries.size(); i < j; i++){
			List<AggregateResult> queryResult = Database.query(countQueries[i]);
			aggResults.add(queryResult);
		}

		//Loop through the results and update the counts for each accountID
		for(Integer x = 0, y = aggResults.size(); x < y; x++) {
			List<AggregateResult> results = aggResults[x];
			for(Integer i = 0, j = results.size(); i < j; i++) {
				String accountId = (String)results[i].get('Prior_Parent_Id_GLBL__c');
				Integer count = (Integer)results[i].get('expr0');

				//If the account Id is on the map then a value has been set and so the count should be 
				//updated to add the old value
				if(idRelatedRecords.containsKey(accountId)) {
					count += idRelatedRecords.get(accountId);
				} 

				//Set the count value for the account Id
				idRelatedRecords.put(accountId, count);
			}
		}

		//Loop through all of our history records and for those where the Id is not on the counting map
		//i.e. a value has not been set or no count was returned, mark it as complete.
		for(Integer i = 0, j = histories.size(); i < j; i++) {
			String previousAccountId = histories[i].Original_Account_ID_GLBL__c;

			if(!idRelatedRecords.containsKey(previousAccountId)) {
				histories[i].Merge_Marked_Complete_MERC__c = true;
			}
		}
	}

	/**
	  * @description This method loops through all of the Account Merge Related List objects and creates the
	  * associated COUNT queries returning them as a list of strings to be run. 
	  */
	private List<String> buildCountQueriesForObjects() {
		Map<String, Account_Merge_Related_Lists_MERC__c> relatedListSettings = Account_Merge_Related_Lists_MERC__c.getAll();

		List<String> queries = new List<String>();

		for(String relatedObject : relatedListSettings.keySet()) {
			String query = 'SELECT Prior_Parent_Id_GLBL__c, COUNT(Id) FROM ' + relatedListSettings.get(relatedObject).get('Related_Object_API_Name__c')
				+ ' WHERE Prior_Parent_Id_GLBL__c in :originalIds GROUP BY Prior_Parent_Id_GLBL__c';
			queries.add(query);
		}

		return queries;
	}

}