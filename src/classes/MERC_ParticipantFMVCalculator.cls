/**
 * @author Joseph Ferraro
 *
 * Trigger handler that calculates min/max rate for HCPs based on FMV custom settings
 */


public with sharing class MERC_ParticipantFMVCalculator implements GLBL_TriggerHandler.HandlerInterface {
	
	Schema.SobjectType triggeredSobjectType;

	public MERC_ParticipantFMVCalculator(Schema.SobjectType sobjectType) {
		this.triggeredSobjectType = sObjectType;
	}

	public void handle() {
		if (Trigger.isInsert || Trigger.isUpdate ) {
	    	execute(Trigger.new);
	   	}
	}

	void execute(List<Sobject> sobjects) {
		List<Meeting_Participant_MERC__c> participants;
		
		if (this.triggeredSobjectType == Account.SobjectType) {
			List<Account> accounts = (List<Account>)sobjects;
			Set<Id> accountIdsToProcess = new Set<Id>();
			for (Account a : accounts) {
				if (
					(
						Trigger.oldMap.get(a.Id).get('Service_Provider_Tier_MERC__c') != a.Service_Provider_Tier_MERC__c
						&&
						a.Calculate_Open_Meeting_Fees_MERC__c == true
					) ||
					(
						Trigger.oldMap.get(a.Id).get('Calculate_Open_Meeting_Fees_MERC__c') == false
						&&
						a.Calculate_Open_Meeting_Fees_MERC__c == true
						&&
						a.Service_Provider_Tier_MERC__c != null
					)
				) {
					if (a.Service_Provider_Tier_MERC__c != null)
						accountIdsToProcess.add(a.Id);
				}
			}
			participants = [SELECT ID, Country_of_Residence_MERC__c, Service_Provider_Tier_MERC__c 
									FROM Meeting_Participant_MERC__c WHERE
										Final_Fee_MERC__c = null AND 
										Account_MERC__c in :accountIdsToProcess AND
										Meeting_MERC__r.Meeting_Status_MERC__c != 'Closed' AND
										Meeting_MERC__r.Meeting_Status_MERC__c != 'Cancelled'];
		} else if (this.triggeredSobjectType == Meeting_Participant_MERC__c.SobjectType) {
			List<Meeting_Participant_MERC__c> triggeredParticipants = (List<Meeting_Participant_MERC__c>)sobjects;
			for (Meeting_Participant_MERC__c p : triggeredParticipants) {
				if (p.Final_Fee_MERC__c == null)
					participants.add(p);
			}
		}

		Set<String> countries = new Set<String>();
		for (Meeting_Participant_MERC__c p : participants) {
			countries.add(p.Country_of_Residence_MERC__c);
		}

		Map<String, List<FMV_Settings_MERC__c>> fmvMap = new Map<String, List<FMV_Settings_MERC__c>>();
		for (FMV_Settings_MERC__c fmvSetting : [SELECT 
													Country_Code_MERC__c, 
													Tier_Value_MERC__c,
													Minimum_Hourly_Rate_MERC__c, 
													Maximum_Hourly_Rate_MERC__c
														FROM FMV_Settings_MERC__c 
															WHERE Country_Code_MERC__c in :countries]) {
			if (fmvMap.containsKey(fmvSetting.Country_Code_MERC__c)) {
				List<FMV_Settings_MERC__c> fmvList = fmvMap.get(fmvSetting.Country_Code_MERC__c);
				fmvList.add(fmvSetting);
				fmvMap.put(fmvSetting.Country_Code_MERC__c, fmvList);
			} else {
				List<FMV_Settings_MERC__c> fmvList = new List<FMV_Settings_MERC__c>{fmvSetting};
				fmvMap.put(fmvSetting.Country_Code_MERC__c, fmvList);
			}
		}

		for (Meeting_Participant_MERC__c p : participants) {
			if (p.Service_Provider_Tier_MERC__c == null) continue;
			if (p.Country_of_Residence_MERC__c == null) continue;

			Integer participantTierValue = p.Service_Provider_Tier_MERC__c.intValue();
			List<FMV_Settings_MERC__c> fmvSettings = fmvMap.get(p.Country_of_Residence_MERC__c);
			
			if (fmvSettings != null) {
				for (FMV_Settings_MERC__c fmvSetting : fmvSettings) {
					Integer fmvTierValue = fmvSetting.Tier_Value_MERC__c.intValue();
					if (fmvTierValue == participantTierValue) {
						p.Minimum_Rate_MERC__c = fmvSetting.Minimum_Hourly_Rate_MERC__c;
						p.Maximum_Rate_MERC__c = fmvSetting.Maximum_Hourly_Rate_MERC__c;
						break;
					}
				}
			}
		}

		if (this.triggeredSobjectType == Account.SobjectType) {
			update participants;
		}
	}
}