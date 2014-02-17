public with sharing class MERC_ParticipantTriggerHandler implements GLBL_TriggerHandler.HandlerInterface {

	public void handle() {
		if (Trigger.isInsert) {
	    	execute(Trigger.new);
	   	}
	}

	public void execute(list<Sobject> sobjects) {        
		List<Meeting_Participant_MERC__c> participants = (List<Meeting_Participant_MERC__c>)sobjects;
		Set<Id> accountIds = new Set<Id>();
		for (Meeting_Participant_MERC__c mp : participants) {
			if (mp.Account_MERC__c != null) {
				accountIds.add(mp.Account_MERC__c);
			}
		}

		Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, PersonContactId, PersonEmail FROM Account WHERE ID in :accountIds]);

		for (Meeting_Participant_MERC__c mp : participants) {
			if (mp.Account_MERC__c != null && accountMap.get(mp.Account_MERC__c) != null) {
				mp.Person_Contact_Id_MERC__c = accountMap.get(mp.Account_MERC__c).PersonContactId;
				mp.Email_MERC__c = accountMap.get(mp.Account_MERC__c).PersonEmail;
			}
		}
	}
}