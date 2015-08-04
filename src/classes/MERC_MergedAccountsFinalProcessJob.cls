global class MERC_MergedAccountsFinalProcessJob implements Database.Batchable<sObject>, Schedulable {
	
	private String query;
	
	global MERC_MergedAccountsFinalProcessJob() {
		query = 'SELECT Id, Merge_Processed_MERC__c, Original_Account_ID_GLBL__c, Winning_Id_GLBL__c '+
			'FROM Merge_History_GLBL__c WHERE Merge_Processed_MERC__c = false AND Merge_Marked_Complete_MERC__c = true';
	}

	global void execute(SchedulableContext sc) {
		MERC_MergedAccountsFinalProcessJob job = new MERC_MergedAccountsFinalProcessJob();
		database.executebatch(job);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		p('starting batch');
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

   		p('executing batch');
   		List<Merge_History_GLBL__c> completeMergeHistories = (List<Merge_History_GLBL__c>) scope;
   		for (Merge_History_GLBL__c mh : completeMergeHistories) {

	        MERC_MergedAccountApex deleteObject = 
	        	new MERC_MergedAccountApex(mh.Winning_Id_GLBL__c, mh.Original_Account_ID_GLBL__c);

	        /*----- delete all child records associated with the losing account -----*/
	        deleteObject.destroyLosingRecords();

	        /*----- set the merge history object to processed -----*/
	        mh.Merge_Processed_MERC__c = true;
	        // p('completed process of '+mh);
   		}
        update completeMergeHistories;	
	}
	
	global void finish(Database.BatchableContext BC) {
		p('finished');
	}
	
	static void p(String m) {
		System.debug('\n\n\nYYZ - '+m+'\n\n\n\n');
	}
}