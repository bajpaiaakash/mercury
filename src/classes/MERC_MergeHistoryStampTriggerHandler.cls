/**
  * @author Paul Battisson
  * This trigger is responsible for reviewing all newly created Merge_History_GLBL__c records
  * and counting the number of related records for the losing account to determine whether 
  * the record should be processed and needs review, otherwise ist should be marked as 
  * complete/processed.
  */
public with sharing class MERC_MergeHistoryStampTriggerHandler {

	public void handle()
	{
		if(Trigger.isInsert && Trigger.isAfter) {
			executeAfterInsert(Trigger.new);
		}
	}

	private void executeAfterInsert(List<Merge_History_GLBL__c> histories) {
		//Firstly let us loop through the list of Merge History records and retrieve
		//all of the winning account Ids.
		Set<Id> winningIds = new Set<Id>();
		for(Integer i = 0, j = histories.size(); i < j; i++) {
			winningIds.add(histories[i].Winning_Id_GLBL__c);
		}

		//Build our base queries for every related list object
		Map<String, String> countQueries = buildCountQueriesForObjects();

		//This map will store the ongoing count as we loop through the aggregate results
		Map<Id, Integer> idRelatedRecords = new Map<Id, Integer>();

		//Loop through the queries and store their results in a list of results
		Map<String, List<AggregateResult>> aggResults = new Map<String, List<AggregateResult>>();

		for(String relationshipName : countQueries.keySet()){
			List<AggregateResult> queryResult = Database.query(countQueries.get(relationshipName));
			aggResults.put(relationshipName, queryResult);
		}

		for(String expressionName : aggResults.keySet()) {
			List<AggregateResult> results = aggResults.get(expressionName);
			for(Integer i = 0, j = results.size(); i < j; i++) {
				String accountId = (String)results[i].get(expressionName);
				Integer count = (Integer)results[i].get('expr0');

				if(idRelatedRecords.containsKey(accountId)) {
					count += idRelatedRecords.get(accountId);
				} 

				idRelatedRecords.put(accountId, count);
			}
		}


		List<Merge_History_GLBL__c> updatedHistories = new List<Merge_History_GLBL__c>();

		for(Integer i = 0, j = histories.size(); i < j; i++) {
			Id historyId = histories[i].Id;

			if(!idRelatedRecords.containsKey(historyId)) {
				histories[i].Merge_Marked_Complete_MERC__c = true;
				updatedHistories.add(histories[i]);
			}
		}

		update updatedHistories;

	}

	private Map<String, String> buildCountQueriesForObjects() {
		Map<String, Account_Merge_Related_Lists_MERC__c> relatedListSettings = Account_Merge_Related_Lists_MERC__c.getAll();

		Map<String, String> queries = new Map<String, String>();

		for(String relatedObject : relatedListSettings.keySet()) {

			String relationshipName = (String)relatedListSettings.get(relatedObject).get('Account_Relationship_Name__c');
			String query = 'SELECT ' + relationshipName + ' COUNT(Id) FROM ' + 
				relatedListSettings.get(relatedObject).get('Related_Object_API_Name__c') + ' WHERE Id in :winningIds GROUP BY ' 
				+ relationshipName;
			queries.put(relationshipName, query);
		}

		return queries;
	}

}