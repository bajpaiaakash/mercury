/**
 * @author Joseph Ferraro, Sean Harrison
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

   		// update cap limit
   		List<Meeting_Participant_MERC__c> mpList = (List<Meeting_Participant_MERC__c>) scope;
   		List<Id> accountIds = new List<Id>();
   		for (Meeting_Participant_MERC__c mp : mpList) {
   			accountIds.add(mp.Account_MERC__c);
   		}

   		List<Account> accountsToReset = new List<Account>();
   		for (Account a : [SELECT Id, Annual_CAP_Limit_Reset_Flag_MERC__c FROM Account WHERE Id in :accountIds]) {
   			a.Annual_CAP_Limit_Reset_Flag_MERC__c = true;
   			accountsToReset.add(a);
   		}
   		update accountsToReset;

   		// update rollups
		update GLBL_RollupService.rollup(scope);
	}

	global void finish(Database.BatchableContext BC) {

	}
}