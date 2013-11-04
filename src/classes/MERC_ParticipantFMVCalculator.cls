public with sharing class MERC_ParticipantFMVCalculator implements GLBL_TriggerHandler.HandlerInterface {
	
	public void handle() {
		if (Trigger.isInsert || Trigger.isUpdate ) {
	    	execute(Trigger.new);
	   	}
	}

	void execute(List<Sobject> sobjects) {
		List<Meeting_Participant_MERC__c> participants = (List<Meeting_Participant_MERC__c>)sobjects;
		
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


	}
}