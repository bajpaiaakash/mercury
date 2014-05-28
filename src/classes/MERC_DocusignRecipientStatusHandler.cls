/**
 * @author Joseph Ferraro
 *
 * Stamps Docusign signature status on Meeting Participant
 */

public with sharing class MERC_DocusignRecipientStatusHandler implements GLBL_TriggerHandler.HandlerInterface {
	
	public Boolean isActive() {
	    return true;
	}
	
	public void handle() {
		if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter) {
	    	stampMeetingParticipantRecipientStatus((List<dsfs__DocuSign_Recipient_Status__c>)Trigger.new);
	   	}
	}

	public void stampMeetingParticipantRecipientStatus(List<dsfs__DocuSign_Recipient_Status__c> recipientStatuses) {        
		system.debug('----> recipientStatuses: '+recipientStatuses);

		Map<String, dsfs__DocuSign_Recipient_Status__c> envelopeIdPlusEmailToRecipientStatus = new Map<String, dsfs__DocuSign_Recipient_Status__c>();
		Set<String> envelopeIds = new Set<String>();
		for (dsfs__DocuSign_Recipient_Status__c status : recipientStatuses) {
			String envelopeId = status.dsfs__Envelope_Id__c.toLowerCase();
			String email = status.dsfs__DocuSign_Recipient_Email__c.toLowerCase();
			envelopeIds.add(envelopeId);
			envelopeIdPlusEmailToRecipientStatus.put(envelopeId+email, status);
		}

		system.debug('----> envelopeIds: '+envelopeIds);
		system.debug('----> envelopeIdPlusEmailToRecipientStatus: '+envelopeIdPlusEmailToRecipientStatus);

		List<Meeting_Participant_MERC__c> participantsToUpdate = new List<Meeting_Participant_MERC__c>();
		for (Meeting_Participant_MERC__c p : [SELECT ID, Email_Formula_MERC__c, Docusign_Envelope_Id_MERC__c FROM Meeting_Participant_MERC__c WHERE Docusign_Envelope_ID_MERC__c in :envelopeIds AND Email_Formula_MERC__c != null]) {
			String envelopeId = p.Docusign_Envelope_Id_MERC__c.toLowerCase();
			String email = p.Email_Formula_MERC__c.toLowerCase();
			if (envelopeIdPlusEmailToRecipientStatus.get(envelopeId+email) != null) {
				dsfs__DocuSign_Recipient_Status__c recipientStatus = envelopeIdPlusEmailToRecipientStatus.get(envelopeId+email);
				p.Docusign_Contract_Status_MERC__c = recipientStatus.dsfs__Recipient_Status__c;
				participantsToUpdate.add(p);
			}
		}

		system.debug('----> participantsToUpdate: '+participantsToUpdate);

		if (participantsToUpdate.size() > 0)
			update participantsToUpdate;
	}
}