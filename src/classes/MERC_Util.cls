public with sharing class MERC_Util {
	
	public static void disableBudgetEditValidation() {
		Mercury_Settings_MERC__c settings = Mercury_Settings_MERC__c.getOrgDefaults();
		settings.Budget_Edit_Validation_MERC__c = false;
		update settings;
	}

	public static void enableBudgetEditValidation() {
		Mercury_Settings_MERC__c settings = Mercury_Settings_MERC__c.getOrgDefaults();
		settings.Budget_Edit_Validation_MERC__c = true;
		update settings;
	}

	public static String getSobjectAPIName(Sobject s) {
		Id recordId = (Id)s.get('Id');
		return recordId.getSObjectType().getDescribe().getName();
	}
}