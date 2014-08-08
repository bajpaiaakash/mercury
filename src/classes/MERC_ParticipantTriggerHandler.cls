public with sharing class MERC_ParticipantTriggerHandler implements GLBL_TriggerHandler.HandlerInterface {

	public Boolean isActive() {
		return MERC_TriggerHandlerStateManager.isActive(MERC_ParticipantTriggerHandler.class);
	}

	public void handle() {
		if (Trigger.isBefore) {
			if (Trigger.isInsert) {
		    	stampPersonAccountDetails((List<Meeting_Participant_MERC__c>)Trigger.new);
		   	}

	    	populateShadowFieldsForCapCalc((List<Meeting_Participant_MERC__c>)Trigger.new);
		}
	}

	public void stampPersonAccountDetails(List<Meeting_Participant_MERC__c> participants) {        
		Set<Id> accountIds = new Set<Id>();
		for (Meeting_Participant_MERC__c mp : participants) {
			if (mp.Account_MERC__c != null) {
				accountIds.add(mp.Account_MERC__c);
			}
		}

		Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, CurrencyIsoCode, PersonContactId, PersonEmail FROM Account WHERE ID in :accountIds]);

		for (Meeting_Participant_MERC__c mp : participants) {
			if (mp.Account_MERC__c != null && accountMap.get(mp.Account_MERC__c) != null) {
				mp.Person_Contact_Id_MERC__c = accountMap.get(mp.Account_MERC__c).PersonContactId;
				mp.Email_MERC__c = accountMap.get(mp.Account_MERC__c).PersonEmail;
				mp.CurrencyIsoCode = accountMap.get(mp.Account_MERC__c).CurrencyIsoCode;
			}
		}
	}

	public void populateShadowFieldsForCapCalc(List<Meeting_Participant_MERC__c> participants) {
		for (Meeting_Participant_MERC__c mp : participants) {
			if (mp.Proposed_Final_Fee_MERC__c!=null) mp.Proposed_Final_Fee_Rollup_MERC__c = mp.Proposed_Final_Fee_MERC__c;
			if (mp.Final_Fee_Rollup_MERC__c != null) mp.Final_Fee_Rollup_MERC__c = mp.Final_Fee_MERC__c;
		}
	}
}