/**
 * @author Joseph Ferraro
 *
 * Trigger handler that facilitates TOV rollups
 */

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

		if (detailSobjects.size() > 0)
			GLBL_Rollup.RollupService.triggerHandler(detailSobjects);
	}
}