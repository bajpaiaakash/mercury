public with sharing class MERC_LookupRollupTriggerHandler implements GLBL_TriggerHandler.HandlerInterface {

    public Boolean isActive() {
        return true;
    }
    
    public void handle() {
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
            execute(Trigger.new);
        } else if (Trigger.isDelete) {
            execute(Trigger.old);
        }
    }

    public void execute(List<SObject> sobjects) {
        GLBL_RollupService.triggerHandler(sobjects);
    }
}