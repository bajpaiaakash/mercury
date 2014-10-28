/**
 * @author Kyle Thornton
 *
 * Unit test for the MERC_DocusignRecipientStatusHandler
 */
 @isTest
public class MERC_DocusignRecipientStatusHandlerTest {

	@isTest static void testStamping() {
		List<Account> accounts = MERC_TestFactory.insertAccounts(200);
		Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1).get(0);
		List<Meeting_Participant_MERC__c> participants = MERC_TestFactory.insertParticipants(meeting.id, accounts);

		participants = [SELECT Id, Email_Formula_MERC__c, Docusign_Envelope_ID_MERC__c FROM Meeting_Participant_MERC__c WHERE Id IN :participants];

		List<dsfs__DocuSign_Status__c> parentStatuses = new List<dsfs__DocuSign_Status__c>();
		for (Integer i=0; i<200; i++) {
			parentStatuses.add(new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c='envelopeId'+i));
		}
		insert parentStatuses;

		List<dsfs__DocuSign_Recipient_Status__c> statuses = new List<dsfs__DocuSign_Recipient_Status__c>();
		Integer counter = 0;
		for (Meeting_Participant_MERC__c participant : participants) {
			participant.Docusign_Envelope_ID_MERC__c = 'envelopeId'+counter;
			statuses.add( new dsfs__DocuSign_Recipient_Status__c(
										dsfs__Parent_Status_Record__c=parentStatuses.get(counter).Id,
				                        dsfs__Envelope_Id__c='envelopeId'+counter,
				                        dsfs__DocuSign_Recipient_Email__c = participant.Email_Formula_MERC__c,
				                        dsfs__Recipient_Status__c = 'sent',
				                        dsfs__DocuSign_Recipient_Id__c=String.valueof(counter)));
			counter++;
		}

		update participants;

		Test.startTest();
		insert statuses;
		Test.stopTest();

		System.assertEquals(200, [SELECT COUNT() FROM Meeting_Participant_MERC__c WHERE Docusign_Contract_Status_MERC__c='sent']);
	}
}