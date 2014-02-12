@isTest
private class CUST_RecordTypeIdLookupTest {

	// create an apps setting entry List
	// create three record types
		static Id hcpRecordTypeId = [Select ID From RecordType Where SObjectType = 'Account' and DeveloperName = 'HCP_GLBL'].ID;
	
	static String rtName1;
	static String rtName2;
	static String rtName3;
	static String rt1;
	static String rt2;
	static String rt3;
	static List<CST_App_Settings_CUST__c> settings;
	
	static {
		rtName1 = 'HCP_GLBL';
		rtName2 = 'Non_HCP_MERC';
		rtName3 = 'Employee_GLBL';
    	// NOTE: Assumes existence of certain Lilly Account types
    	rt1 = [Select ID From RecordType Where SObjectType = 'Account' and DeveloperName = :rtName1].ID;
    	rt2 = [Select ID From RecordType Where SObjectType = 'Account' and DeveloperName = :rtName2].ID;
    	rt3 = [Select ID From RecordType Where SObjectType = 'Account' and DeveloperName = :rtName3].ID;
    	settings = new List<CST_App_Settings_CUST__c>();	
	}
	
	// test update
	static testMethod void testDataExists() {
		System.assert(rt1 != null);
		System.assert(rt2 != null);
		System.assert(rt3 != null);
	}

    static testMethod void oneName() {
    	Test.startTest();
	    init(rtName1);
		insert settings;
		
		CST_App_Settings_CUST__c cst = [SELECT Record_Type_Ids_CUST__c FROM CST_App_Settings_CUST__c WHERE Id = :settings.get(0).Id];
		String result = cst.Record_Type_Ids_CUST__c;
        System.assert(result!=null, 'The RTID list appears to be null.');
        System.assertEquals(result, rt1, 'Expected '+rt1+' but got '+result);
    }
    
    // test error
    
    static void init(String s) {
    	
    	for (Integer i=0;i<200;i++) {
    		CST_App_Settings_CUST__c cst = new CST_App_Settings_CUST__c(Record_Types_CUST__c=s);
   			settings.add(cst);
    	}
    }    
}