global class MERC_HcpCapYearlyCalculationJob implements Database.Batchable<sObject> {
	
	String query;
	
	global MERC_HcpCapYearlyCalculationJob() {
		query = 'SELECT ID, Account_MERC__c FROM Meeting_Participant_MERC__c';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		MERC_Util.rollupCapCalculationsFromParticipantToAccount((List<Meeting_Participant_MERC__c>)scope);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}