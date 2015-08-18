/**
 * @author Joseph Ferraro
 *
 * Trigger handler that ensures preference rollups are run on preference/consent DML operations
 */
public with sharing class MERC_AccountPreferenceRollupManager implements GLBL_TriggerHandler.HandlerInterface {

	public Boolean isActive() {
	    return true;
	}

	public void handle() {
		if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
	    	execute(Trigger.new);
	   	} else if (Trigger.isDelete) {
	   		execute(Trigger.old);
	   	}
	}

	public void execute(List<SObject> sobjects) {
		Set<Id> accountIds = new Set<Id>();
		for (Preferences_and_Consent_GLBL__c pc : (List<Preferences_and_Consent_GLBL__c>) sobjects) {
			accountIds.add(pc.Account_GLBL__c);
		}
		if (!accountIds.isEmpty()) {
			System.enqueueJob(new MERC_AccountRollups(accountIds));
		}
	}
}