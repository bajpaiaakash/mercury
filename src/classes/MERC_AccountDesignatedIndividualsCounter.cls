/**
 * @author Joseph Ferraro
 *
 * Passes Account objects to the rollup handler which calculates the number of designated inviduals for an account
 */
public with sharing class MERC_AccountDesignatedIndividualsCounter implements GLBL_TriggerHandler.HandlerInterface {

    public Boolean isActive() {
        return MERC_TriggerHandlerStateManager.isActive(MERC_AccountDesignatedIndividualsCounter.class);
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