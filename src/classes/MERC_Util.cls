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
			options.add(new SelectOption(f.getValue(), f.getLabel()));
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
		return getCSTPicklistValuesForFieldName(fieldName, includeNullSelectOption, 1000);
	}

	public static List<SelectOption> getCSTPicklistValuesForFieldName(String fieldName, Boolean includeNullSelectOption, Integer restrictCollectionSize) {
		List<SelectOption> options = new List<SelectOption>();
		if (includeNullSelectOption)
			options.add(new SelectOption('','--Select--'));

		if (fieldName.endsWith('__c')) {
			for (Sobject appSetting : Database.query('SELECT '+fieldName+' FROM CST_App_Settings_CUST__c LIMIT 1')) {
				String optionString = (String)appSetting.get(fieldName);
				for (String s : optionString.split(',')) {
					options.add(new SelectOption(s,s));
				}
			}
		} else {
			for (CST_Picklist_CUST__c pick : Database.query('SELECT Picklist_CUST__c, Value_CUST__c FROM CST_Picklist_CUST__c WHERE Picklist_CUST__c = \''+fieldName+'\' ORDER BY Picklist_CUST__c')) {
				options.add(new SelectOption(pick.Value_CUST__c,pick.Value_CUST__c));
			}
		}

		// for VisualForce collection limits
		while (options.size() > restrictCollectionSize) {
			options.remove(restrictCollectionSize);
		}
		return options;
	}

	public static String getSobjectAPIName(Sobject s) {
		Id recordId = (Id)s.get('Id');
		return recordId.getSObjectType().getDescribe().getName();
	}

	private static Map<String, Map<String, String>> objectFieldTimeZoneMap;
	public static Map<String, String> getTimeZoneFieldMapForObject(String objectAPIName){
		if(objectFieldTimeZoneMap == null){
			buildFieldMapsFromTimeZoneFieldMappings(queryTimeZoneFieldMappings());
		}
		if(objectFieldTimeZoneMap.containsKey(objectAPIName)){
			return objectFieldTimeZoneMap.get(objectAPIName);
		} else {
			System.debug(LoggingLevel.WARN, 'No TimeZoneFieldMap found for ' + objectAPIName);
			return new Map<String,String>();
		}
	}

	private static void buildFieldMapsFromTimeZoneFieldMappings(List<Time_Zone_Field_Mappings_MERC__c> mappings){
		objectFieldTimeZoneMap = new Map<String, Map<String, String>>();
		for(Time_Zone_Field_Mappings_MERC__c mapping : mappings){
			if(!objectFieldTimeZoneMap.containsKey(mapping.Object_API_Name_MERC__c)){
				objectFieldTimeZoneMap.put(mapping.Object_API_Name_MERC__c, new Map<String, String>());
			}
			Map<String, String> fieldTimeZoneMap = objectFieldTimeZoneMap.get(mapping.Object_API_Name_MERC__c);
			fieldTimeZoneMap.put(mapping.Field_API_Name_MERC__c, mapping.Time_Zone_Field_API_Name_MERC__c);
		}
	}

	private static List<Time_Zone_Field_Mappings_MERC__c> queryTimeZoneFieldMappings(){
		return [SELECT Field_API_Name_MERC__c,
					   Time_Zone_Field_API_Name_MERC__c,
					   Object_API_Name_MERC__c
				  FROM Time_Zone_Field_Mappings_MERC__c];
	}

	private static Map<String, Map<String, String>> objectAPINameToDateFieldAPINameToFieldToStampAPIName = new Map<String, Map<String, String>>();
	private static Map<String, Datetime> objectAPINameToLastModifiedDateFieldAPINameToFieldToStampAPIName = new Map<String, Datetime>();
	public static Map<String, String> getStampFieldMapForObject(String objectAPIName) {
		if(!objectAPINameToDateFieldAPINameToFieldToStampAPIName.containsKey(objectAPIName) ||
			objectAPINameToLastModifiedDateFieldAPINameToFieldToStampAPIName.get(objectAPIName).addMinutes(3) < Datetime.now()){
			objectAPINameToLastModifiedDateFieldAPINameToFieldToStampAPIName.put(objectAPIName, Datetime.now());
			Map<String, String> dateFieldAPINameToFieldToStampAPIName = new Map<String, String>();
			for (Time_Zone_Field_Mappings_MERC__c fm : [SELECT
															Field_API_Name_MERC__c,
															Static_Field_To_Stamp_MERC__c
																FROM
																	Time_Zone_Field_Mappings_MERC__c
																		WHERE Object_API_Name_MERC__c = :objectAPIName]) {
				dateFieldAPINameToFieldToStampAPIName.put(fm.Field_API_Name_MERC__c, fm.Static_Field_To_Stamp_MERC__c);
			}
			objectAPINameToDateFieldAPINameToFieldToStampAPIName.put(objectAPIName, dateFieldAPINameToFieldToStampAPIName);
		}
		return objectAPINameToDateFieldAPINameToFieldToStampAPIName.get(objectAPIName);
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

	public static Set<String> getPicklistValueList(Schema.DescribeFieldResult fieldResult) {
		Set<String> vals = new Set<String>();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry f : ple) {
			vals.add(f.getValue());
		}
		return vals;
	}


	/**
	 * Wrapper for getCountryPicklistValuesForCurrentUser() to allow for optional addition of
	 * a "null" first option in the selectOption list.
	 *
	 * @param   includeNullSelectOption  If true AND if the number of generated choices is more than
	 *                                   one, a --Select-- option is added to the top of the list
	 * @return  a List of SelectOptions returned from getCountryPicklistValuesForCurrentUser()
	 * @see     #getCountryPicklistValuesForCurrentUser()
	 */
	public static List<SelectOption> getCountryPicklistValuesForCurrentUser(Boolean includeNullSelectOption) {

		List<SelectOption> options = getCountryPicklistValuesForCurrentUser();
		if (options.size()<2) {
			return options;
		}

		if (includeNullSelectOption)
			options.add(0,new SelectOption('--','--Select--'));

		return options;
	}

	/**
	 * Provide a form list of countries available to the current running user
	 *
	 * @return a List of SelectOptions with a country name as the labels and the 2-letter ISO
	 *         country code as the value
	 * @see    #getUserCountriesByTerritory(Id)
	 */
	public static List<SelectOption> getCountryPicklistValuesForCurrentUser() {
		List<SelectOption> options = new List<SelectOption>();
		Map<String, String> nameToISO = getUserCountriesByTerritory(UserInfo.getUserId());

		List<String> sortedNames = new List<String>(nameToISO.keySet());
		sortedNames.sort();

		for(String n : sortedNames) {
			options.add(new SelectOption(nameToISO.get(n), n));
		}
		return options;
	}

	/**
	 * Provides a map of country names to ISO codes for the submitted user. Based one the
	 * assigment of countries in the Territory hierarchy
	 *
	 * @param  userId  The id of the user of interest
	 * @return         A Map of names (String) to 2-letter ISO codes (String)
	 * @see            #getUserTerritoriesAndChildrenTerritories(List<Id>)
	 * @see            Territory.ISO_Country_Code_GLBL__c
	 */
	public static Map<String, String> getUserCountriesByTerritory(Id userId) {
		Map<String, String> nameToISO = new Map<String, String>();

		Map<Id, Set<Territory>> userTerrMap = getUserTerritoriesAndChildrenTerritories(new List<Id>{userId});
    	Schema.DescribeFieldResult fieldResult = CST_User_Settings_CUST__c.Country_Code_CUST__c.getDescribe();
    	Set<String> ISOCodes = getPicklistValueList(fieldResult);

		if (userTerrMap.containsKey(userId)) {
			for (Territory t : userTerrMap.get(userId)) {
				if (ISOCodes.contains(t.ISO_Country_Code_GLBL__c)) nameToISO.put(t.Name,t.ISO_Country_Code_GLBL__c);
			}
		}
		return nameToISO;
	}

	/**
	 * Provides a map of user ids to the territories assigned along with all decendents in the hierarchy.
	 * <p>
	 * Intended for Account searching, this method includes custom Terr fields for downstream use.
	 *
	 * @param  userIds  List of User ids
	 * @return          Map of User ids to Set of Territories
	 * @see             Territory.ISO_Country_Code_GLBL__c
	 */
	public static Map<Id, Set<Territory>> getUserTerritoriesAndChildrenTerritories(List<Id> userIds) {
		Map<Id, Set<Territory>> result = new Map<Id, Set<Territory>>();

		List<UserTerritory> userTerrs = new List<UserTerritory>([
			SELECT UserId, TerritoryId FROM UserTerritory WHERE IsActive = true AND UserId in :userIds
			]);

		// user Ids => terr ids map + List of terr ids
		Map<Id, Set<Id>> useridToTerrids = new Map<Id, Set<Id>>();
		for (UserTerritory ut : userTerrs)
		{
			if (!useridToTerrids.containsKey(ut.UserId)) useridToTerrids.put((ut.UserId), new Set<Id>());
			useridToTerrids.get(ut.UserId).add(ut.TerritoryId);
		}

		// loop list to get Terr records
		Map<Id,Territory> allTerrs = new Map<Id,Territory>([SELECT Id, Name, ParentTerritoryId, ISO_Country_Code_GLBL__c FROM Territory]);

		for (Id uId : useridToTerrids.keySet()) {
			if (!result.containsKey(uId)) result.put(uId, new Set<Territory>());
			for (Id tId : useridToTerrids.get(uId)) {
				result.get(uId).add(allTerrs.get(tId));
			}
		}

		// get all child terr records of the same set of ids
		for (Id u : result.keySet()) {
			Map<Id,Territory> userTerrMap = new Map<Id,Territory>();
			for (Territory t : result.get(u)) userTerrMap.put(t.Id, t);
			result.get(u).addAll(getTerrDescendents(userTerrMap,allTerrs).values());
		}

		return result;
	}

	/**
	 * A recursive method that walks down the hierarchy to provide all the decendents of a given set of Territories.
	 *
	 * @param  ancestors  Map of the ancestors to start the search with
	 * @param  universe   Map of all Territories. Since this method is recursive, the SOQL should be burned upstream
	 * @return            Map of all decendent Territories
	 */
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

	    public String allfields;
	    public String SOQL;
	    public Schema.DescribeSobjectResult d;

	    public SelectAll() { }

	    public SelectAll(Schema.SobjectType sObjectType, Id recordId) {
	        this.d = sObjectType.getdescribe();
	        Map<String, Schema.SobjectField> m = this.d.fields.getmap();
	        Set<String> s = m.keyset();
	        string query = '';
	        for(string f : s) {
	            query = query+f+', ';
	        }
	        query = query.substring(0,query.length()-2);
	        this.allfields = query;
	        this.SOQL = 'SELECT ' + query + ' FROM ' + this.d.getName();
	        this.SOQL += (recordId != null) ? ' WHERE Id = \''+recordId+'\'' : ' LIMIT 1';
	    }

	    public SelectAll(Schema.SobjectType sObjectType) {
	        this.d = sObjectType.getdescribe();
	        Map<String, Schema.SobjectField> m = d.fields.getmap();
	        Set<String> s = m.keyset();
	        string query = '';
	        for(string f : s) {
	            query = query+f+', ';
	        }
	        query = query.substring(0,query.length()-2);
	        this.allfields = query;
	    }

	    public String byId(Id recordId) {
	    	this.SOQL = 'SELECT ' + this.allfields + ' FROM ' + d.getName();
	    	this.SOQL += ' WHERE Id = \''+recordId+'\'';
	    	return this.SOQL;
	    }

	    public String byList(String listName) {
	    	this.SOQL = 'SELECT ' + this.allfields + ' FROM ' + d.getName();
	    	this.SOQL += ' WHERE Id in :'+listName+'';
	    	return this.SOQL;
	    }
	}
}