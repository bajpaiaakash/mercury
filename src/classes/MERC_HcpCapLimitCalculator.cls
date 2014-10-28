/**
 * @author Joseph Ferraro
 *
 * Responsible for calculating annual cap limit for HCP based on CAP_Settings_MERC__c Custom Setting data
 */


public with sharing class MERC_HcpCapLimitCalculator implements GLBL_TriggerHandler.HandlerInterface {

	public Boolean isActive() {
		return MERC_TriggerHandlerStateManager.isActive(MERC_HcpCapLimitCalculator.class);
	}

	public void handle() {
		if (Trigger.isInsert || Trigger.isUpdate) {
	    	execute(Trigger.new);
	   	}
	}

	void execute(List<Sobject> sobjects) {
		List<Account> accs = (List<Account>)sobjects;
		List<Account> accountsToProcess = new List<Account>();
		Set<String> countries = new Set<String>();
		for (Account a : accs) {
			if (Trigger.isInsert) {
				if (a.Country_of_Residence_GLBL__c != null)
					countries.add(a.Country_of_Residence_GLBL__c);
					accountsToProcess.add(a);
			} else if (Trigger.isUpdate) {
				if ((String)Trigger.oldMap.get(a.Id).get('Country_of_Residence_GLBL__c') != a.Country_of_Residence_GLBL__c) {
					if (a.Country_of_Residence_GLBL__c != null) {
						countries.add(a.Country_of_Residence_GLBL__c);
						accountsToProcess.add(a);
					} else {
						a.Annual_CAP_Limit_MERC__c = null;
					}
				}
			}
		}

		String currentYear = String.valueOf(Date.today().year());
		Map<String, List<CAP_Settings_MERC__c>> capMap = new Map<String, List<CAP_Settings_MERC__c>>();
		for (CAP_Settings_MERC__c capSetting : [SELECT 
													Annual_Amount_MERC__c, 
													Year_MERC__c,
													Country_Code_MERC__c, 
													Currency_Code_MERC__c
														FROM CAP_Settings_MERC__c 
															WHERE Country_Code_MERC__c in :countries AND Year_MERC__c = :currentYear]) {
			if (capMap.containsKey(capSetting.Country_Code_MERC__c)) {
				List<CAP_Settings_MERC__c> capList = capMap.get(capSetting.Country_Code_MERC__c);
				capList.add(capSetting);
				capMap.put(capSetting.Country_Code_MERC__c, capList);
			} else {
				List<CAP_Settings_MERC__c> capList = new List<CAP_Settings_MERC__c>{capSetting};
				capMap.put(capSetting.Country_Code_MERC__c, capList);
			}
		}

		for (Account a : accountsToProcess) {
			String accountCountry = a.Country_of_Residence_GLBL__c;
			List<CAP_Settings_MERC__c> capSettings = capMap.get(a.Country_of_Residence_GLBL__c);
			
			if (capSettings != null) {
				for (CAP_Settings_MERC__c capSetting : capSettings) {
					if (capSetting.Country_Code_MERC__c == accountCountry) {
						a.Annual_CAP_Limit_MERC__c = capSetting.Annual_Amount_MERC__c;
						break;
					}
				}
			}
		}
	}
}