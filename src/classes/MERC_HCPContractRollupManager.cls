/**
 * @author Kyle Thornton
 *
 * Trigger handler that ensures preference rollups are run on HCP Contract DML operations
 */
public with sharing class MERC_HCPContractRollupManager implements GLBL_TriggerHandler.HandlerInterface {

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
        Set<Id> meetingParticipantsIds = new Set<Id>();
        for (HCP_Contract_MERC__c contract : (List<HCP_Contract_MERC__c>)sobjects) {
            meetingParticipantsIds.add(contract.Meeting_Participant_MERC__c);
        }

        meetingParticipantsIds.remove(null);
        if (!meetingParticipantsIds.isEmpty()) {
            System.enqueueJob(new MERC_MeetingParticipantRollups(meetingParticipantsIds));
        }
    }
}