trigger MERC_Invoice on Invoice_MERC__c (after insert, after update, after delete, after undelete) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_InvoiceXmlWriter())
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_InvoiceXmlWriter())
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_InvoiceXmlWriter())
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_ConsultingProjectCapCalculator(Invoice_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_ConsultingProjectCapCalculator(Invoice_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_ConsultingProjectCapCalculator(Invoice_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_LookupRollupTriggerHandler())
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_LookupRollupTriggerHandler())
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_LookupRollupTriggerHandler())
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_LookupRollupTriggerHandler())
        .manage();

}