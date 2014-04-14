/**
 * @author Joseph Ferraro
 *
 * Sends recipient statuses to a handler for stamping on Meeting Participants
 */

trigger MERC_DocusignRecipientStatus on dsfs__DocuSign_Recipient_Status__c (after insert, after update) {
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_DocusignRecipientStatusHandler())
		.bind(GLBL_TriggerHandler.Evt.afterupdate, new MERC_DocusignRecipientStatusHandler())
		.manage();
}