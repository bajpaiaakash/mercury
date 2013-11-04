public with sharing class MERC_ContentVersionHandler implements GLBL_TriggerHandler.HandlerInterface {

	public void handle() {
		if (Trigger.isInsert) {
	    	execute(Trigger.new);
	   	}
	}

	public void execute(list<Sobject> sobjects) {        
		List<ContentVersion> documents = (List<ContentVersion>)sobjects;
		Id hcpContractRecordTypeId = [Select ID From RecordType Where SobjectType = 'ContentVersion' and DeveloperName = 'HCP_Contract_MERC'].ID;
		for (ContentVersion d : documents) {
			if (d.HCP_Contract_MERC__c != null) {
				d.RecordTypeId = hcpContractRecordTypeId;
			}
		}

	}
}