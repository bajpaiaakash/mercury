trigger MERC_ContentVersion on ContentVersion (before insert) {
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_ContentVersionHandler())
        .manage();
}