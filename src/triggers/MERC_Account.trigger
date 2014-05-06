trigger MERC_Account on Account (before insert, before update, after insert, after update, after delete, after undelete) {
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_HcpCapLimitCalculator())
		.bind(GLBL_TriggerHandler.Evt.beforeupdate, new MERC_HcpCapLimitCalculator())
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_ParticipantFMVCalculator(Account.SobjectType))
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_AccountRollupHandler())
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_AccountRollupHandler())
		.bind(GLBL_TriggerHandler.Evt.afterdelete, new MERC_AccountRollupHandler())
		.bind(GLBL_TriggerHandler.Evt.afterundelete, new MERC_AccountRollupHandler())
        .manage();
}