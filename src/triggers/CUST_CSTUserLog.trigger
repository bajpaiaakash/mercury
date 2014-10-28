/*
 * @author Sean Harrison
 *
 * Binds Customer Search Tool Application User Log obj to CUST_GlobalIdLookup which
 * is responsible for associating an Account record based on a Lilly Global Employee Id.
 */
trigger CUST_CSTUserLog on CST_User_Log_CUST__c (before insert, before update) {
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new GLBL_GlobalIdAccountLookup('Prsnl_Nbr_GLBL__c','User_Account_CUST__c'))
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new GLBL_GlobalIdAccountLookup('Prsnl_Nbr_GLBL__c','User_Account_CUST__c'))
		.manage();
}