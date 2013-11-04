public with sharing class MERC_TOVCalculator implements GLBL_TriggerHandler.HandlerInterface {
	
	public void handle() {
		if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
	    	execute(Trigger.new);
	   	} else if (Trigger.isDelete) {
	   		execute(Trigger.old);
	   	}
	}

	void execute(List<SObject> sobjects) {
		List<Sobject> detailSobjects; //these should be Daily_Attendance_TOV_MERC__c records

		String triggeredSobjectAPIName = MERC_Util.getSobjectAPIName(sobjects.get(0));
		
		if (triggeredSobjectAPIName == 'Meeting_Day_MERC__c') {
			detailSobjects = [Select ID, Meeting_Participant_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Meeting_Day_MERC__c in :sobjects];
		} else if (triggeredSobjectAPIName == 'Daily_Attendance_TOV_MERC__c') {
			detailSobjects = sobjects;
		}

		List<GLBL_RollupSummaryUtility.fieldDefinition> fieldDefinitions = 
			new List<GLBL_RollupSummaryUtility.fieldDefinition> {
		            new GLBL_RollupSummaryUtility.fieldDefinition(
		            	'SUM', 'Est_Hotel_ToV_MERC__c', 'Total_Hotel_TOV_MERC__c'), 
		            new GLBL_RollupSummaryUtility.fieldDefinition(
		            	'SUM', 'Est_Food_Bev_ToV_MERC__c', 'Total_Food_Beverage_ToV_MERC__c'),
		            new GLBL_RollupSummaryUtility.fieldDefinition(
		            	'SUM', 'Est_Other_ToV_MERC__c', 'Total_Other_ToV_MERC__c'),
		            new GLBL_RollupSummaryUtility.fieldDefinition(
		            	'SUM', 'Est_Reg_Amt_ToV_MERC__c', 'Total_Registration_ToV_MERC__c'),
		            new GLBL_RollupSummaryUtility.fieldDefinition(
		            	'SUM', 'Est_Grnd_Transp_MERC__c', 'Total_Ground_Transporation_ToV_MERC__c')
		        };
		         
        GLBL_RollupSummaryUtility.rollUpTrigger(fieldDefinitions, detailSobjects, 
        'Daily_Attendance_TOV_MERC__c', 'Meeting_Participant_MERC__c', 'Meeting_Participant_MERC__c', '');
	}
}