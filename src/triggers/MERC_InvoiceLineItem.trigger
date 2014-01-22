trigger MERC_InvoiceLineItem on Invoice_Line_Item_MERC__c (after insert, after update, after delete, after undelete) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_ConsultingProjectCapCalculator(Invoice_Line_Item_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_ConsultingProjectCapCalculator(Invoice_Line_Item_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_ConsultingProjectCapCalculator(Invoice_Line_Item_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_ConsultingProjectCapCalculator(Invoice_Line_Item_MERC__c.SobjectType))
        .manage();

}