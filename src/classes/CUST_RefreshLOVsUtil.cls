public with sharing class CUST_RefreshLOVsUtil {

	public final String DATENAME = '_Capture_Date';
	public final String SUFFIX = '_GLBL__c';

	public CUST_RefreshLOVsUtil() {}

	public String getDateFieldName(String f) {
		return f.substring(0,f.indexOfIgnoreCase(SUFFIX))+DATENAME+SUFFIX;
	}

	public void p(String m) {
		System.debug('\n\n\nYYZ - '+m+'\n\n\n\n');
	}
}