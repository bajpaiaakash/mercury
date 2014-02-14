/**
 * @author Joseph Ferraro
 *
 * Trigger handler for Salesforce Content DML.
 * -It ensures that the Content RecordTypeId field is set based on the lookup provided
 */

public with sharing class MERC_ContentVersionHandler implements GLBL_TriggerHandler.HandlerInterface {

	public void handle() {
		if (Trigger.isInsert) {
	    	execute(Trigger.new);
	   	}
	}

	public void execute(list<Sobject> sobjects) {        
		Set<String> mercuryContentRecordTypes = new Set<String>{
			'Invoice_MERC', 'Meeting_MERC', 'HCP_Contract_MERC', 'Account_MERC', 'Meeting_Participant_MERC', 'Budget_MERC'
		};
		List<ContentVersion> documents = (List<ContentVersion>)sobjects;
		Map<String, String> objectTypeToContentRecordId = new Map<String, String>();
		for (RecordType recordType : [Select ID, DeveloperName From RecordType Where SobjectType = 'ContentVersion' and DeveloperName IN :mercuryContentRecordTypes]) {
			objectTypeToContentRecordId.put(recordType.DeveloperName, recordType.Id);
		}

		for (ContentVersion d : documents) {
			if (d.HCP_Contract_MERC__c != null) {
				d.RecordTypeId = objectTypeToContentRecordId.get('HCP_Contract_MERC');
			} else if (d.Invoice_MERC__c != null) {
				d.RecordTypeId = objectTypeToContentRecordId.get('Invoice_MERC');
			} else if (d.Meeting_MERC__c != null) {
				d.RecordTypeId = objectTypeToContentRecordId.get('Meeting_MERC');
			} else if (d.Account_GLBL__c != null) {
				d.RecordTypeId = objectTypeToContentRecordId.get('Account_MERC');
			} else if (d.Meeting_Participant_MERC__c != null) {
				d.RecordTypeId = objectTypeToContentRecordId.get('Meeting_Participant_MERC');
			} else if (d.Budget_MERC__c != null) {
				d.RecordTypeId = objectTypeToContentRecordId.get('Budget_MERC');
			}
		}

	}
}