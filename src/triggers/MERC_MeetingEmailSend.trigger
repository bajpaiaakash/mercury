/*
*   MERC_MeetingEmailSend
*   Created By:     David Helmer
*   Created Date:   December 3rd 2015
*   Description:    A Trigger for handling changes to MERC_MeetingEmailSend objects
*   Handlers:
*       - MERC_MeetingEmailSendAttemptHandler: Attempts to send a Meeting Email Send to Marketing Cloud
*/
trigger MERC_MeetingEmailSend on Meeting_Email_Send_MERC__c (after insert, before update) {
    MERC_MeetingEmailSendAttemptHandler attemptHandler = new MERC_MeetingEmailSendAttemptHandler();

    new GLBL_TriggerHandler()
        .bind(GLBL_TriggerHandler.Evt.afterinsert, attemptHandler)
        .bind(GLBL_TriggerHandler.Evt.beforeupdate, attemptHandler)
        .manage();
}