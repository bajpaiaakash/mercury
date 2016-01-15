trigger MERC_HCPContract on HCP_Contract_MERC__c (after insert, after update, after delete, after undelete) {
    new GLBL_TriggerHandler()
        .bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_HCPContractRollupManager())
        .bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_HCPContractRollupManager())
        .bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_HCPContractRollupManager())
        .bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_HCPContractRollupManager())
        
        //To Cancel DocuSign Envelop; Modification done by Vijay Garg on 13-JAN-2016 for US-39525
        .bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_HCPContractCancellation())
        
        .manage();
}