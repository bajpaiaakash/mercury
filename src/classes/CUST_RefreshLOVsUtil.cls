/**
* CUST_RefreshLOVsUtil
* Created By: Maven Consulting
* Description: Utility methods for use throughout all the CUST_RefreshLOVs classes.
*/
global class CUST_RefreshLOVsUtil {

	public final String DATENAME = '_Capture_Date';
	public final String SUFFIX = '_GLBL__c';
	public final Map<String,String> poolToSettingsFieldMap = new Map<String,String>{
								'Bnft_Dsgn_Cd_GLBL__c'=>'Account_Bnft_Dsgn_Cd_CUST__c',
								'Clsfctn_Cd_GLBL__c' => 'Account_Clsfctn_Cd_CUST__c',
								'Party_Sts_Cd_GLBL__c' => 'Account_Status_Types_CUST__c',
								'Spclty_Desc_Cd_GLBL__c' => 'Specialty_Spclty_Cd_CUST__c',
								'Priority_Rank_Nbr_GLBL__c' => 'Specialty_priority_rank_CUST__c',
								'Altrnt_Id_Typ_Desc_GLBL__c' => 'Altid_Altrnt_Id_Typ_Cd_CUST__c',
								'Cnsnt_Sts_Cd_GLBL__c' => 'Cnsnt_Sts_Cd_CUST__c',
								'Cmnctn_Chnl_Cd_GLBL__c' => 'Interaction_Channel_Type_CUST__c',
								'Cnsnt_Prps_Cd_GLBL__c' => 'Cnsnt_Prps_Cd_CUST__c',
								'Rltnshp_Typ_Desc_GLBL__c' => 'Affiliation_Role_Types_CUST__c',
								'Priority_Rank_Nbr_GLBL__c' => 'Affiliation_Priority_Rank_Nbr_CUST__c'
							};

	public CUST_RefreshLOVsUtil() {}

	/**
	* Determines the name of the date field.
	* @param f - Field String
	* @return String - returns the name of Date Field.
	*/
	public String getDateFieldName(String f) {
		String root = f.substring(0,f.indexOfIgnoreCase(SUFFIX));
		String dateFieldName = root+DATENAME+SUFFIX;
		if (dateFieldName.length()>40) {
			dateFieldName = root.remove('_')+'Date'+SUFFIX;
		}
		return dateFieldName;
	}

	/**
	* In conjunction with getDateFieldName it creates a comma delimted list of the names of the Date fields.
	* @param fList - field List.
	* @return String - returns the name of Date Fields.
	*/
	public String getDateFieldNames(String fList) {
		String result = '';
		for (String f : fList.split(',')) {
			result += getDateFieldName(f) + ',';
		}
		return result.removeEnd(',');
	}

	/**
	* Overloaded method that finds key inside of a map, then builds a comma delimeted string for result.
	* @param key - used to find the list of strings in the maps.
	* @param m - Maps strings which are keys to a list of strings.
	* @return String - comma delimited string
	*/
	public static String getCSVString(String key, Map<String, List<String>> m) {
		String result = '';
		if (m.containsKey(key)) {
			for (String s : m.get(key)) {
				result += s + ',';
			}
			result = result.removeEnd(',');
		}
		return result;
	}

	/**
	* Overloaded method that builds a comma delimeted string from the list of strings passed into method.
	* @param vals - List of Strings that needs to be comma delimted into one string
	* @return String - comma delimited string
	*/
	public static String getCSVString(List<String> vals) {
		String result = '';
		for (String s : vals) result += s + ',';
		return result.removeEnd(',');
	}

	public final Set<String> NOTGROUBABLE  = new Set<String>{'Priority_Rank_Nbr_GLBL__c'};
	public Boolean canGroupBy(String f) {
		return !NOTGROUBABLE.contains(f);
	}

	public void p(String m) {
		System.debug('\n\n\nYYZ - '+m+'\n\n\n\n');
	}

	/**
	* ObjToken is a inner class used for passing data in LOV classes.
	*/
	global class ObjToken {
		public String       name {get; set;}
		public String       relation {get; set;}
		public String       filter {get; set;}
		public String       lookup {get; set;}
		public List<String> fields {get{sanitize(fields); return fields;} set;}						
		public String       fieldsCSV {get{return (fields!=null) ? CUST_RefreshLOVsUtil.getCSVString(fields) : null;}}
		public String       abbreviation {get; 
							set{
								abbreviation = value;
								name = ABBREVIATIONS.get(abbreviation);
								relation = RELATIONS.get(abbreviation);
								filter = FILTERS.get(abbreviation);
								}
							}
		public Map<String, String> values {get; set;}

		public final Map<String,String> ABBREVIATIONS = new Map<String,String> {
				'a'=>'Account',
				'aff'=>'Affiliation_GLBL__c',
				'alt'=>'Alternate_Id_GLBL__c',
				'c'=>'Preferences_and_Consent_GLBL__c',
				's'=>'Specialty_MERC__c'
		};
		public final Map<String,String> RELATIONS = new Map<String,String> {
				'aff'=>'Affiliations_To__r',
				'alt'=>'Alternate_ID__r',
				'c'=>'Consent__r',
				's'=>'Specialities__r'
		};
		public final Map<String,String> FILTERS = new Map<String,String> {
			//	'aff'=>'CST_App_Menu_Flag_Affil_CUST__c'
			//	'c'=>'CST_App_Menu_Flag_Consent_CUST__c'  // removed by Katy :-(
		};

		public ObjToken(String s) {
			abbreviation = s;
			if (s!='a') lookup = 'Account_GLBL__c';
		}

		void sanitize(List<String> input) {
			if (input==null) return;
			List<String> clone = input.clone();
			for (Integer i=0; i<clone.size(); i++) {
				String s = clone.get(i);
				if (!s.remove('_').isAlphanumeric()) {
					fields.remove(i);
				}
			}
			return;
		}
	}
}