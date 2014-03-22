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

	public static List<SelectOption> getPicklistValues(Schema.DescribeFieldResult fieldResult) {
		List<SelectOption> options = new List<SelectOption>();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry f : ple) {
			options.add(new SelectOption(f.getLabel(), f.getValue()));
		}       
		return options;
	}

	public static List<SelectOption> getPicklistValues(Schema.DescribeFieldResult fieldResult, Boolean includeNullSelectOption) {
		List<SelectOption> options = new List<SelectOption>();
		if (includeNullSelectOption)
			options.add(new SelectOption('','--Select--'));
		options.addAll(getPicklistValues(fieldResult));
		return options;
	}

	public static List<SelectOption> getCSTPicklistValuesForFieldName(String fieldName, Boolean includeNullSelectOption) {
		List<SelectOption> options = new List<SelectOption>();
		if (includeNullSelectOption)
			options.add(new SelectOption('','--Select--'));
		for (Sobject appSetting : Database.query('SELECT '+fieldName+' FROM CST_App_Settings_CUST__c LIMIT 1')) {
			String optionString = (String)appSetting.get(fieldName);
			for (String s : optionString.split(',')) {
				options.add(new SelectOption(s,s));
			}
		}
		return options;
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

// return all terrs and children terrs for these users
	public static Map<User, Set<Territory>> getUserTerritoriesAndChildrenTerritories(Map<Id, User> users) {
		Map<User, Set<Territory>> result = new Map<User, Set<Territory>>();

		List<UserTerritory> userTerrs = new List<UserTerritory>([
			SELECT UserId, TerritoryId FROM UserTerritory WHERE IsActive = true AND UserId in :users.keySet()
			]);

		// user Ids => terr ids map + List of terr ids
		Map<Id, Set<Id>> useridToTerrids = new Map<Id, Set<Id>>();
//		Set<Id> usersTerrIds = new Set<Id>();
		for (UserTerritory ut : userTerrs)
		{
			if (!useridToTerrids.containsKey(ut.UserId)) useridToTerrids.put((ut.UserId), new Set<Id>());
			useridToTerrids.get(ut.UserId).add(ut.TerritoryId);

//			usersTerrIds.add(ut.TerritoryId);
		}

		// loop keyset to get User records
//		Map<Id,User> userMap = new Map<Id,User>([SELECT Id FROM User WHERE Id in :useridToTerrids.keyset()]);

		// loop list to get Terr records
		Map<Id,Territory> allTerrs = new Map<Id,Territory>([SELECT Id, ParentTerritoryId FROM Territory]);

		for (Id uId : useridToTerrids.keySet()) {
			if (!result.containsKey(users.get(uId))) result.put(users.get(uId), new Set<Territory>());
			for (Id tId : useridToTerrids.get(uId)) {
				result.get(users.get(uId)).add(allTerrs.get(tId));
			}
		}

		// get all child terr records of the same set of ids 
		for (User u : result.keySet()) {
			Map<Id,Territory> userTerrMap = new Map<Id,Territory>();
			for (Territory t : result.get(u)) userTerrMap.put(t.Id, t);
			result.get(u).addAll(getTerrDescendents(userTerrMap,allTerrs).values());
		}

		return result;
	}

	public static Map<Id,Territory> getTerrDescendents(Map<Id,Territory> ancestors, Map<Id,Territory> universe) {
		Map<Id,Territory> childTerrs = new Map<Id,Territory>();
		for (Territory t : universe.values()) {
			if (ancestors.keySet().contains(t.ParentTerritoryId)) childTerrs.put(t.Id, t);
		}

		if (!childTerrs.isEmpty()) {
			childTerrs.putAll(getTerrDescendents(childTerrs, universe));
		}
		return childTerrs;
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

	public class SelectAll {
	    
	    public string allfields;
	    public string SOQL;
	    
	    public SelectAll() { }
	    
	    public SelectAll(Schema.SobjectType sObjectType, Id recordId){
	        Schema.DescribeSobjectResult d = sObjectType.getdescribe();
	        Map<String, Schema.SobjectField> m = d.fields.getmap();
	        Set<String> s = m.keyset();
	        string query = '';
	        for(string f : s) {
	            query = query+f+', ';
	        }
	        query = query.substring(0,query.length()-2);
	        this.allfields = query;
	        this.SOQL = 'SELECT ' + query + ' FROM ' + d.getName() + ' WHERE Id = \''+recordId+'\'';
	    }
	}
}