/** 
* @author Sean Harrison 
* 
* This is a unit test class for CUST_RecordTypeIdLookup.cls
*
* NOTE: Assumes the existence of certain RecordTypes
*/
@isTest(SeeAllData=true)
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
	
	// check that test unit setup is ok
	static testMethod void testDataExists() {
		System.assert(rt1 != null);
		System.assert(rt2 != null);
		System.assert(rt3 != null);
	}

	// tests when one record type name is entered
    static testMethod void oneName() {
    	Test.startTest();
	    init(rtName1);
		insert settings;
		Test.stopTest();
		
		CST_App_Settings_CUST__c cst = [SELECT Record_Type_Ids_CUST__c FROM CST_App_Settings_CUST__c WHERE Id = :settings.get(0).Id];
		String result = cst.Record_Type_Ids_CUST__c;
        System.assert(result!=null, 'The RTID list appears to be null.');
        System.assertEquals(result, rt1, 'Expected '+rt1+' but got '+result);
    }

    // Tests multiple record type names
    static testMethod void testMultipleRTNames() {
    	Test.startTest();
    	String multipleNames = rtName1+','+rtName2+','+rtName3;
	    init(multipleNames);
		insert settings;
		Test.stopTest();
		
		CST_App_Settings_CUST__c cst = [SELECT Record_Type_Ids_CUST__c FROM CST_App_Settings_CUST__c WHERE Id = :settings.get(0).Id];
		String result = cst.Record_Type_Ids_CUST__c;
        System.assert(result!=null, 'The RTID list appears to be null.');
        System.assertEquals(result, rt1+','+rt2+','+rt3, 'Expected '+rt1+','+rt2+','+rt3+' but got '+result);
    }

    // Check record updates
    static testMethod void testUpdate() {
    	Test.startTest();
	    init(rtName1);
		insert settings;

		List<CST_App_Settings_CUST__c> cstList = [SELECT Record_Type_Ids_CUST__c, Employee_Record_Type_CUST__c FROM CST_App_Settings_CUST__c 
			WHERE Record_Types_CUST__c = :rtName1];
		for (CST_App_Settings_CUST__c cst : cstList) {
			cst.Record_Types_CUST__c = rtName2;
			cst.Employee_Record_Type_CUST__c = rtName3;
		}
		update cstList;
		Test.stopTest();
		
		CST_App_Settings_CUST__c cst = [SELECT Record_Type_Ids_CUST__c, Employee_Record_Type_Id_CUST__c FROM CST_App_Settings_CUST__c 
			WHERE Id = :cstList.get(0).Id];
		String result = cst.Record_Type_Ids_CUST__c;
        System.assert(result!=null, 'The RTID list appears to be null.');
        System.assertEquals(result, rt2, 'Expected '+rt2+' but got '+result);   	
		result = cst.Employee_Record_Type_Id_CUST__c;
        System.assertEquals(result, rt3, 'Expected '+rt3+' but got '+result);
    }
    
    // test error condition when invalid record type names used
    static testMethod void confirmErrorsThrown() {
     	Test.startTest();
	    init('bogus_record_type_name');
	    boolean errThrown = false;
	    try {
				insert settings;
			} catch (Exception e) {
				System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),'Wrong error thrown: '+e.getMessage());
				errThrown = true;
			}
		System.assert(errThrown, 'Expected an error but insert was successful instead');
    }
    
    // data setup
    static void init(String s) {
    	for (Integer i=0;i<200;i++) {
    		CST_App_Settings_CUST__c cst = new CST_App_Settings_CUST__c(Record_Types_CUST__c=s,Employee_Record_Type_CUST__c=s,HCO_Record_Types_CUST__c=s);
   			settings.add(cst);
    	}
    }    
}