trigger MERC_MeetingProducts on Meeting_Products_MERC__c (after delete) {

	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_DeleteNotifyService())
        .manage();

}