trigger MERC_Meeting on Meeting_MERC__c (before insert, before update, before delete, after insert, after update, after delete) {

    new GLBL_TriggerHandler()
        .bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_LockedRecordHandler(Meeting_MERC__c.SobjectType))
        .bind(GLBL_TriggerHandler.Evt.beforedelete, new MERC_LockedRecordHandler(Meeting_MERC__c.SobjectType))
        
        .bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_MeetingTOVFinalValidation(Meeting_MERC__c.SobjectType))

        .bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_MVIMeetingTimeZoneHandler())
        .bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_MVIMeetingTimeZoneHandler())

        .bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_TimestampHandler(Meeting_MERC__c.SobjectType))
        .bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_TimestampHandler(Meeting_MERC__c.SobjectType))

        .bind(GLBL_TriggerHandler.Evt.afterupdate,  new MERC_HcpCapActualsCalculator(Meeting_MERC__c.SobjectType))

        .bind(GLBL_TriggerHandler.Evt.afterdelete,  new MERC_DeleteNotifyService())

        .bind(GLBL_TriggerHandler.Evt.afterinsert,  new MERC_MeetingCancellationHandler())
        .bind(GLBL_TriggerHandler.Evt.afterupdate,  new MERC_MeetingCancellationHandler())

        .bind(GLBL_TriggerHandler.Evt.afterinsert,  new MERC_PrimaryMeetingOwnerHandler())

        .bind(GLBL_TriggerHandler.Evt.afterinsert,  new MERC_AnonymiseNonHCPDataHandler())
        .bind(GLBL_TriggerHandler.Evt.afterupdate,  new MERC_AnonymiseNonHCPDataHandler())

        .bind(GLBL_TriggerHandler.Evt.afterupdate,  new MERC_MeetingCurrencyUpdateHandler())

        .bind(GLBL_TriggerHandler.Evt.afterupdate,  new MERC_MeetingProcessLogicHandler(Meeting_MERC__c.SObjectType))

        .bind(GLBL_TriggerHandler.Evt.afterupdate,  new MERC_CancelDelegateMgmtProcesses(Meeting_MERC__c.SObjectType))
        .manage();
}