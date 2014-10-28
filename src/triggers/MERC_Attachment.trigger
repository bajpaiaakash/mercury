trigger MERC_Attachment on Attachment (after insert) {
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_HandleDocusignAttachmentInsert())
		.manage();
}