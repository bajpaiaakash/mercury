trigger MERC_ETMeetingEmailSendTrigger on Meeting_Email_Send_MERC__c (after insert, before update) {
    MERC_ETMeetingEmailSendTriggerImpl impl = new MERC_ETMeetingEmailSendTriggerImpl();
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            impl.doAfterInsert(Trigger.new, Trigger.newMap);
        } 
    }
    else if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            impl.doBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
        }
    }
}