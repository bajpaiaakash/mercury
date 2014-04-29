public with sharing class MERC_AccountDesignatedIndividualsCounter implements GLBL_TriggerHandler.HandlerInterface {
	
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