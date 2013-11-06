public with sharing class MERC_HcpCapActualsCalculator implements GLBL_TriggerHandler.HandlerInterface {
	
	String triggeredSobjectAPIName;

	public MERC_HcpCapActualsCalculator(String objApiName) {
		this.triggeredSobjectAPIName = objApiName;
	}

	public void handle() {
		if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
	    	execute(Trigger.new);
	   	} else if (Trigger.isDelete) {
	   		execute(Trigger.old);
	   	}
	}

	void execute(List<SObject> sobjects) {
		List<Meeting_Participant_MERC__c> participants;
		
		if (this.triggeredSobjectAPIName == null)
			triggeredSobjectAPIName = MERC_Util.getSobjectAPIName(sobjects.get(0));
		
		if (triggeredSobjectAPIName == 'Meeting_MERC__c') {
			List<Meeting_MERC__c> meetings = (List<Meeting_MERC__c>)sobjects;
			Set<Id> meetingIdsToProcess = new Set<Id>();
			for (Meeting_MERC__c m : meetings) {
				if (
					Trigger.oldMap.get(m.Id).get('Meeting_Status_MERC__c') != m.Meeting_Status_MERC__c ||
					Trigger.oldMap.get(m.Id).get('End_Date_of_Event_MERC__c') != m.End_Date_of_Event_MERC__c
				) {
					meetingIdsToProcess.add(m.Id);
				}
			}
			participants = [SELECT ID, Account_MERC__c, Meeting_MERC__c FROM Meeting_Participant_MERC__c WHERE 
										Meeting_MERC__c in :meetingIdsToProcess];
		} else if (triggeredSobjectAPIName == 'Meeting_Participant_MERC__c') {
			participants = (List<Meeting_Participant_MERC__c>)sobjects;
		}


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