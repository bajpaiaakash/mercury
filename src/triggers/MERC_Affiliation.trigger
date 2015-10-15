/* Author --Jyoti Gaur
related to US-37784 for populating affiliated parent account values onto child account********/

trigger MERC_Affiliation on Affiliation_GLBL__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new GLBL_TriggerHandler()
        .bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_PrimaryAffiliation())
        .bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_PrimaryAffiliation())
        .manage();
}