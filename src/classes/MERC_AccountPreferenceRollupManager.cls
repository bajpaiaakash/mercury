/**
 * @author Joseph Ferraro
 *
 * Trigger handler that ensures preference rollups are run on preference/consent DML operations
 */
public with sharing class MERC_AccountPreferenceRollupManager implements GLBL_TriggerHandler.HandlerInterface {
	public void handle() {
		if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
	    	execute(Trigger.new);
	   	} else if (Trigger.isDelete) {
	   		execute(Trigger.old);
	   	}
	}

	public void execute(List<SObject> sobjects) {
		GLBL_Rollup.RollupService.triggerHandler(sobjects);
	}
}