/**
 * @author Joseph Ferraro
 *
 * Rest resource for the Mercury Web Service API to get the Docusign embedded signature URL for a given Meeting Participant
 */

@RestResource(urlMapping='/MERC/Docusign/EmbeddedSignatureURL/*')
global with sharing class MERC_DocusignEmbeddedSignatureService {
	@HttpGet
	global static EmbeddedSignatureResponse doGET() {
		RestRequest req = RestContext.request;
		RestResponse res = Restcontext.response;
		Id meetingParticipantId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

		EmbeddedSignatureResponse response = new EmbeddedSignatureResponse();

		try {
			Meeting_Participant_MERC__c mp = [SELECT ID, Account_MERC__c, Account_MERC__r.Name, Email_Formula_MERC__c, Docusign_Envelope_ID_MERC__c, Docusign_Contract_Status_MERC__c FROM Meeting_Participant_MERC__c WHERE ID = :meetingParticipantId];

			String envelopeId = mp.Docusign_Envelope_Id_MERC__c;

			MERC_DocusignService docService = new MERC_DocusignService();
			MERC_DocusignService.EnvelopeRecipientDetailResponse envelopeDetail = docService.getEnvelopeRecipientDetails(envelopeId);

			system.debug('envelopeDetail -->');
			system.debug(envelopeDetail);

			MERC_DocusignService.Signer embeddedHCPSigner;
			for (MERC_DocusignService.Signer signer : envelopeDetail.signers) {
				system.debug('signer -->');
				system.debug(signer);

				if (signer.status != 'completed' && signer.routingOrder != '1') { //get signer who hasn't completed (this is our HCP)
					embeddedHCPSigner = signer;
					break;
				}
			}

			system.debug('HCP signer -->');
			system.debug(embeddedHCPSigner);

			if (embeddedHCPSigner == null)
				throw new MERC_Exception('Unable to find valid embedded signer');

			//for (MERC_DocusignService.Signer signer : envelopeDetail.signers) {
			//	if (signer.clientUserId != null && signer.clientUserId != '') { //get signer with client id (our embedded signer)
			//		embeddedSigner = signer;
			//		break;
			//	}
			//}

			//retrieve embedded signature URL
			MERC_DocusignService.EmbeddedSignResponse esr = docService.getEmbeddedSignUrl(
																			envelopeId, 
																			embeddedHCPSigner, 
																			'https://mercury-portal-dev.herokuapp.com/meetings');
			response.success = true;
			response.url = esr.url;
		} catch(Exception e) {
			response.success = false;
			response.message = e.getMessage();
		}
		return response;
	}

	global class EmbeddedSignatureResponse {
		public Boolean success;
		public String message;
		public String url;
	}
}