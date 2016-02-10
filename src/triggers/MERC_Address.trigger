/**
* MERC_Address Trigger
* Created By: David Helmer, Mavens Consulting
* Description: Executes the MERC_AddressCountryStampTrigger class that is responsible for stamping the Country on related Accounts when the Country changes or the address is inserted for addresses of record type Other.
*/
trigger MERC_Address on Address_GLBL__c (before insert, before update) {
    new GLBL_TriggerHandler()
        .bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_AddressCountryStampTrigger())
        .bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_AddressCountryStampTrigger())
        .manage();
}