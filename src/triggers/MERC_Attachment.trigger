/**
 * MERC_Attachment Trigger
 * Created By:  Joseph Ferraro, Mavens Consulting
 * Description: This trigger calls MERC_HandleDocusignAttachmentInsert which copies that attachment to content and deletes the attachment on executed version(s) of the contracts.
 */
trigger MERC_Attachment on Attachment (after insert) {
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_HandleDocusignAttachmentInsert())
		.manage();
}