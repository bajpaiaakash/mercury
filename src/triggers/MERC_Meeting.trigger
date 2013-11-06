trigger MERC_Meeting on Meeting_MERC__c (after update) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_HcpCapActualsCalculator('Meeting_MERC__c'))
        .manage();
}