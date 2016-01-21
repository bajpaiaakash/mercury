trigger MERC_Invoice on Invoice_MERC__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_InvoiceXmlWriter())
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_InvoiceXmlWriter())
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_InvoiceXmlWriter())

		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_ConsultingProjectCapCalculator(Invoice_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_ConsultingProjectCapCalculator(Invoice_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_ConsultingProjectCapCalculator(Invoice_MERC__c.SobjectType))

		.bind(GLBL_TriggerHandler.Evt.beforedelete, new MERC_LockedInvoiceDeleteHandler())
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_InvoiceCurrencyTriggerHandler())
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_InvoiceCurrencyTriggerHandler())

        .manage();

}