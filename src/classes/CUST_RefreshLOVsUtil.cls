public with sharing class CUST_RefreshLOVsUtil {

	public final String DATENAME = '_Capture_Date';
	public final String SUFFIX = '_GLBL__c';

	public CUST_RefreshLOVsUtil() {}

	public String getDateFieldName(String f) {
		return f.substring(0,f.indexOfIgnoreCase(SUFFIX))+DATENAME+SUFFIX;
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

	public void p(String m) {
		System.debug('\n\n\nYYZ - '+m+'\n\n\n\n');
	}

	public class ObjToken {
		public String       name {get; set;}
		public String       abbreviation {get; set;}
		public String       relation {get; set;}
		public String       filter {get; set;}
		public String       fieldsCSV {get; private set;}
		public String       lookup {get; set;}
		public List<String> fields {get; 
							set{ 
								fields = value; 
								fieldsCSV = (fields!=null) ? CUST_RefreshLOVsUtil.getCSVString(fields) : null;
								}
							}

		public ObjToken(String s) {
			name = s;
		}
	}
}