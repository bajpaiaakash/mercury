/**
 * @author Joseph Ferraro
 *
 * Utility class for all things Mercury
 */

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

	public static String getTimeZonePicklistValueForCurrentUser(Schema.DescribeFieldResult timezoneFieldDescribe) {
		String userTimeZone = String.valueOf(UserInfo.getTimeZone());
		List<Schema.PicklistEntry> picklistValues = timezoneFieldDescribe.getPicklistValues();
		for (Schema.PicklistEntry pe : picklistValues) {
			if (pe.getLabel().contains(userTimeZone)) {
				return pe.getLabel();
			}
		}
		return null;
	}

	public static String getSobjectAPIName(Sobject s) {
		Id recordId = (Id)s.get('Id');
		return recordId.getSObjectType().getDescribe().getName();
	}

	public static Map<String, String> getTimeZoneFieldMapForObject(String objectAPIName) {
		Map<String, String> dateFieldAPINameToTimeZoneFieldAPIName = new Map<String, String>();
		for (Time_Zone_Field_Mappings_MERC__c fm : [SELECT 
														Field_API_Name_MERC__c, 
														Time_Zone_Field_API_Name_MERC__c 
															FROM 
																Time_Zone_Field_Mappings_MERC__c 
																	WHERE Object_API_Name_MERC__c = :objectAPIName]) {
			dateFieldAPINameToTimeZoneFieldAPIName.put(fm.Field_API_Name_MERC__c, fm.Time_Zone_Field_API_Name_MERC__c);
		}
		return dateFieldAPINameToTimeZoneFieldAPIName;
	}

	public static Map<String, String> getStampFieldMapForObject(String objectAPIName) {
		Map<String, String> dateFieldAPINameToFieldToStampAPIName = new Map<String, String>();
		for (Time_Zone_Field_Mappings_MERC__c fm : [SELECT 
														Field_API_Name_MERC__c, 
														Static_Field_To_Stamp_MERC__c 
															FROM 
																Time_Zone_Field_Mappings_MERC__c 
																	WHERE Object_API_Name_MERC__c = :objectAPIName]) {
			dateFieldAPINameToFieldToStampAPIName.put(fm.Field_API_Name_MERC__c, fm.Static_Field_To_Stamp_MERC__c);
		}
		return dateFieldAPINameToFieldToStampAPIName;
	}

	//takes a field set, returns a list of api names
	public static List<String> getFieldSetFieldList(String objectAPIName, String fieldSetAPIName) {
		List<String> fieldNames = new List<String>();
		Schema.SObjectType token = Schema.getGlobalDescribe().get(objectAPIName);
		Schema.DescribeSObjectResult dr = token.getDescribe();
        List<Schema.FieldSetMember> fields = dr.fieldSets.getMap().get(fieldSetAPIName).getFields();
		for(Schema.FieldSetMember f : fields) {
            fieldNames.add(f.getFieldPath());
        }
        return fieldNames;
	}

	//takes a list of field sets, returns a unique list of api names
	public static List<String> getFieldSetFieldList(String objectAPIName, List<String> fieldSetAPINames) {
		Set<String> fieldNames = new Set<String>();
		for (String s : fieldSetAPINames) {
			fieldNames.addAll(MERC_Util.getFieldSetFieldList(objectAPIName, s));
		}
		List<String> uniqueFieldList = new List<String>();
		uniqueFieldList.addAll(fieldNames);
        return uniqueFieldList;
	}

	public static String getUrlParam(String paramValue) {
	    return ApexPages.currentPage().getParameters().get(paramValue);
	}

	public static Map<String, String> getFieldSetLabels(Schema.SObjectType sObjectType, List<String> fieldSetAPINames) {
		Schema.DescribeSObjectResult r1 = sObjectType.getDescribe(); 
		Map<String, String> fieldSetNameMap = new Map<String, String>();
		Map<String, Schema.FieldSet> fieldSetMap = r1.fieldSets.getMap();
		for (String s : fieldSetAPINames)
			fieldSetNameMap.put(s, fieldSetMap.get(s).getLabel());
		return fieldSetNameMap;
	}

	public static String generateRandomString(Integer count) {
	    String chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz';
	    String hash = '';
	    for (integer i = 0; i < count; i++) {
	        Integer rnum = Math.floor(Math.random() * chars.length()).intValue();
	        hash += chars.substring(rnum,rnum+1);
	    }
	    return hash;
	}

	public virtual class RemoteResponse {
		public Boolean success;
		public String message;
		public String contextId;
		public RemoteResponse(Boolean s, String m, String cid) {
			this.success = s;
			this.message = m;
			this.contextId = cid;
		}
	}
}