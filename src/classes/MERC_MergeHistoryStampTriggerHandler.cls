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
		//all of the winning account Ids.
		List<Id> winningIds = new List<Id>();
		for(Integer i = 0, j = histories.size(); i < j; i++) {
			winningIds.add(histories[i].Original_Account_ID_GLBL__c);
		}

		//Build our base queries for every related list object
		List<String> countQueries = buildCountQueriesForObjects();

		//This map will store the ongoing count as we loop through the aggregate results
		Map<Id, Integer> idRelatedRecords = new Map<Id, Integer>();

		//Loop through the queries and store their results in a list of results
		List<List<AggregateResult>> aggResults = new List<List<AggregateResult>>();

		for(String query : countQueries){
			List<AggregateResult> queryResult = Database.query(query);
			aggResults.add(queryResult);
		}

		for(List<AggregateResult> results : aggResults) {
			for(Integer i = 0, j = results.size(); i < j; i++) {
				String accountId = (String)results[i].get('Prior_Parent_Id_GLBL__c');
				Integer count = (Integer)results[i].get('expr0');

				if(idRelatedRecords.containsKey(accountId)) {
					count += idRelatedRecords.get(accountId);
				} 

				idRelatedRecords.put(accountId, count);
			}
		}

		List<Merge_History_GLBL__c> updatedHistories = new List<Merge_History_GLBL__c>();

		for(Integer i = 0, j = histories.size(); i < j; i++) {
			Id previousAccountId = histories[i].Original_Account_ID_GLBL__c;

			if(!idRelatedRecords.containsKey(previousAccountId)) {
				histories[i].Merge_Marked_Complete_MERC__c = true;
				updatedHistories.add(histories[i]);
			}
		}
	}

	private List<String> buildCountQueriesForObjects() {
		Map<String, Account_Merge_Related_Lists_MERC__c> relatedListSettings = Account_Merge_Related_Lists_MERC__c.getAll();

		List<String> queries = new List<String>();

		for(String relatedObject : relatedListSettings.keySet()) {
			String query = 'SELECT Prior_Parent_Id_GLBL__c, COUNT(Id) FROM ' + relatedListSettings.get(relatedObject).get('Related_Object_API_Name__c')
				+ ' WHERE Prior_Parent_Id_GLBL__c in :winningIds GROUP BY Prior_Parent_Id_GLBL__c';
			queries.add(query);
		}

		return queries;
	}

}