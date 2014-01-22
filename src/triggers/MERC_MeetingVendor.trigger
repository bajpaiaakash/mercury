trigger MERC_MeetingVendor on Meeting_Vendor_MERC__c (after update) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_TOVCalculator(Meeting_Vendor_MERC__c.SobjectType))
        .manage();

}