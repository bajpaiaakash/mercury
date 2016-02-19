trigger MERC_InvoiceLineItem on Invoice_Line_Item_MERC__c (after insert, after update, after delete, after undelete, before insert, before update) {

    new GLBL_TriggerHandler()
        .bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_AllocatedCapCalculator(Invoice_Line_Item_MERC__c.SobjectType))
        .bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_AllocatedCapCalculator(Invoice_Line_Item_MERC__c.SobjectType))
        .bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_AllocatedCapCalculator(Invoice_Line_Item_MERC__c.SobjectType))
        
        
        .bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_PaidCapCalculator(Invoice_Line_Item_MERC__c.SobjectType))
        .bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_PaidCapCalculator(Invoice_Line_Item_MERC__c.SobjectType))
        .bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_PaidCapCalculator(Invoice_Line_Item_MERC__c.SobjectType))
        
        
        .bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_InvoiceLineItemRollupStamp())
        .bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_InvoiceLineItemRollupStamp())
        .manage();

}