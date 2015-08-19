/**
 * @author Joseph Ferraro
 *
 * This batch job is scheduled to run once a year to trigger all meeting participants
 * and force a recalculation of their cap numbers.
 */
global class MERC_HcpCapYearlyCalculationJob implements Database.Batchable<sObject> {

	String query;

	global MERC_HcpCapYearlyCalculationJob() {
		query = 'SELECT ID, Account_MERC__c FROM Meeting_Participant_MERC__c';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		Set<Id> accountIdsForRollup = new Set<Id>();
		for (Meeting_Participant_MERC__c mp : (List<Meeting_Participant_MERC__c>)scope) {
			accountIdsForRollup.add(mp.Account_MERC__c);
		}
		System.enqueueJob(new MERC_AccountRollups(accountIdsForRollup));
	}

	global void finish(Database.BatchableContext BC) {

	}
}