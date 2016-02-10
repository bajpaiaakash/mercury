/**
* MERC_Account Trigger
* Created By: Mavens Consulting
* Description: Executes a variety of trigger handler classes that make changes to the account or associated records.
*/
trigger MERC_Account on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new GLBL_TriggerHandler()
        .bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_HcpCapLimitCalculator())
        .bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_HcpCapLimitCalculator())
        .bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_ParticipantFMVCalculator(Account.SobjectType))
        .bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_AccountDesignatedIndividualsCounter())
        .bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_AccountDesignatedIndividualsCounter())
        .bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_AccountDesignatedIndividualsCounter())
        .bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_AccountDesignatedIndividualsCounter())
        .bind(GLBL_TriggerHandler.Evt.beforedelete, new GLBL_AccountMergeStampTrigger())
        .bind(GLBL_TriggerHandler.Evt.afterdelete, new GLBL_AccountMergeStampTrigger())
        .bind(GLBL_TriggerHandler.Evt.afterupdate, new GLBL_AccountMergeStampTrigger())
        .manage();
}