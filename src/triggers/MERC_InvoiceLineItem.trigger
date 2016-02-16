/**
* MERC_ContentVersion Trigger
* Created By: Mavens Consulting
* Description: This trigger calls two classes to handle inserts, updates and deletes:
*	1.) MERC_ConsultingProjectCapCalculator which calculates Consulting_Project_Paid_CAP_MERC__c on Account based on an Account's participation in Consulting projects for the year
*	2.) MERC_InvoiceLineItemRollupStamp which stamps the Consulting_Amount_MERC__c on Consulting_Amount_Rollup_MERC__c to avoid Conversion issues
*/
trigger MERC_InvoiceLineItem on Invoice_Line_Item_MERC__c (after insert, after update, after delete, after undelete, before insert, before update) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_ConsultingProjectCapCalculator(Invoice_Line_Item_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_ConsultingProjectCapCalculator(Invoice_Line_Item_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_ConsultingProjectCapCalculator(Invoice_Line_Item_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_ConsultingProjectCapCalculator(Invoice_Line_Item_MERC__c.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_InvoiceLineItemRollupStamp())
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_InvoiceLineItemRollupStamp())
        .manage();

}