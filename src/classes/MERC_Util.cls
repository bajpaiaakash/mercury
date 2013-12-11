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

	public static String generateRandomString(Integer count) {
	    String chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz';
	    String hash = '';
	    for (integer i = 0; i < count; i++) {
	        Integer rnum = Math.floor(Math.random() * chars.length()).intValue();
	        hash += chars.substring(rnum,rnum+1);
	    }
	    return hash;
	}

	public static void rollupCapCalculationsFromParticipantToAccount(List<Meeting_Participant_MERC__c> participants) {
		String currentYear = String.valueOf(Date.today().year());
        
        //forecasted rollup to reserved
		List<GLBL_RollupSummaryUtility.fieldDefinition> fieldDefinitions = 
			new List<GLBL_RollupSummaryUtility.fieldDefinition> {
		            new GLBL_RollupSummaryUtility.fieldDefinition(
		            	'SUM', 'Final_Fee_MERC__c', 'Reserved_CAP_MERC__c')
		        };
		         
        GLBL_RollupSummaryUtility.rollUpTrigger(fieldDefinitions, participants, 
        	'Meeting_Participant_MERC__c', 'Account_MERC__c', 'Account', 
        	'AND Meeting_MERC__r.End_Date_Year_MERC__c = \''+currentYear+'\' AND Meeting_MERC__r.Meeting_Status_MERC__c = \'Forecasted\'');
	
        //registered rollup to allocated
        fieldDefinitions = 
			new List<GLBL_RollupSummaryUtility.fieldDefinition> {
		            new GLBL_RollupSummaryUtility.fieldDefinition(
		            	'SUM', 'Final_Fee_MERC__c', 'Allocated_CAP_MERC__c')
		        };
		         
        GLBL_RollupSummaryUtility.rollUpTrigger(fieldDefinitions, participants, 
        	'Meeting_Participant_MERC__c', 'Account_MERC__c', 'Account', 
        	'AND Meeting_MERC__r.End_Date_Year_MERC__c = \''+currentYear+'\' AND Meeting_MERC__r.Meeting_Status_MERC__c = \'Registered\'');
	
        //services rendered rollup to paid cap
        fieldDefinitions = 
			new List<GLBL_RollupSummaryUtility.fieldDefinition> {
		            new GLBL_RollupSummaryUtility.fieldDefinition(
		            	'SUM', 'Final_Fee_MERC__c', 'Paid_CAP_MERC__c')
		        };
		         
        GLBL_RollupSummaryUtility.rollUpTrigger(fieldDefinitions, participants, 
        	'Meeting_Participant_MERC__c', 'Account_MERC__c', 'Account', 
        	'AND Meeting_MERC__r.End_Date_Year_MERC__c = \''+currentYear+'\' AND Services_Rendered_MERC__c = \'Yes\'');
	}
}