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
        Set<Id> parentAccountIds = new Set<Id>();
        for (Account account : (List<Account>) sobjects) {
            parentAccountIds.add(account.HCP_Designated_Individuals_MERC__c);
            parentAccountIds.add(account.HCP_Contracting_Party_MERC__c);
        }

        //only enqueue the job if there is at least one non null Id
        parentAccountIds.remove(null);
        if (!parentAccountIds.isEmpty()) {
            System.enqueueJob(new MERC_AccountToAccountRollups(parentAccountIds));
        }
    }
}