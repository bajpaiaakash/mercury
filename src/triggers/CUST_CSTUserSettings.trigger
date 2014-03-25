trigger CUST_CSTUserSettings on CST_User_Settings_CUST__c (before update) {
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new CUST_UserSettingStatusUpdate())
		.manage();
}