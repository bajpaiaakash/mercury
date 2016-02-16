/**
* MERC_HCPContract Trigger
* Created By: Kyle Thornton, Mavens Consulting
* Description: Calls the MERC_HCPContractRollupManager class that ensures preference rollups are run on HCP Contract DML operations
*/
trigger MERC_HCPContract on HCP_Contract_MERC__c (after insert, after update, after delete, after undelete) {
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_HCPContractRollupManager())
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_HCPContractRollupManager())
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_HCPContractRollupManager())
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_HCPContractRollupManager())
		.manage();
}