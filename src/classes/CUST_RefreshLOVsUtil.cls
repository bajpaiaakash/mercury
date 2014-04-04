global class CUST_RefreshLOVsUtil {

	public final String DATENAME = '_Capture_Date';
	public final String SUFFIX = '_GLBL__c';

	public CUST_RefreshLOVsUtil() {}

	public String getDateFieldName(String f) {
		String root = f.substring(0,f.indexOfIgnoreCase(SUFFIX));
		String dateFieldName = root+DATENAME+SUFFIX;
		if (dateFieldName.length()>40) dateFieldName = root.remove('_')+'Date'+SUFFIX;
		return dateFieldName;
	}

	public String getDateFieldNames(String fList) {
		String result = '';
		for (String f : fList.split(',')) result += getDateFieldName(f) + ',';
		return result.removeEnd(',');
	}

	public static String getCSVString(String key, Map<String, List<String>> m) {
		String result = '';
		if (m.containsKey(key)) {
			for (String s : m.get(key)) result += s + ',';
			result = result.removeEnd(',');
		}
		return result;
	}

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

	global class ObjToken {
		public String       name {get; set;}
		public String       relation {get; set;}
		public String       filter {get; set;}
		public String       lookup {get; set;}
		public List<String> fields {get; set;}							
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

		public final Map<String,String> ABBREVIATIONS = new Map<String,String>{
				'a'=>'Account',
				'aff'=>'Affiliation_GLBL__c',
				'alt'=>'Alternate_Id_GLBL__c',
				'c'=>'Preferences_and_Consent_GLBL__c',
				's'=>'Specialty_MERC__c'
		};
		public final Map<String,String> RELATIONS = new Map<String,String>{
				'aff'=>'Affiliations_To__r',
				'alt'=>'Alternate_ID__r',
				'c'=>'Consent__r',
				's'=>'Specialities__r'
		};
		public final Map<String,String> FILTERS = new Map<String,String>{
				'aff'=>'CST_App_Menu_Flag_Affil_CUST__c',
				'c'=>'CST_App_Menu_Flag_Consent_CUST__c'
		};

		public ObjToken(String s) {
			abbreviation = s;
			if (s!='a') lookup = 'Account_GLBL__c';
		}
	}
}