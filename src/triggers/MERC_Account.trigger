trigger MERC_Account on Account (before insert, before update, after update) {
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_HcpCapLimitCalculator())
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_HcpCapLimitCalculator())
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_ParticipantFMVCalculator('Account'))
        .manage();
}