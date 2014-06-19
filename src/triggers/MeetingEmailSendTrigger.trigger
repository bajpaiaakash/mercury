trigger MeetingEmailSendTrigger on Meeting_Email_Send_MERC__c (after insert, after update) {
    MeetingEmailSendTriggerImpl impl = new MeetingEmailSendTriggerImpl();
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            impl.doAfterInsert(Trigger.new, Trigger.newMap);
        } else if (Trigger.isUpdate) {
            impl.doAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
        }
    }
}