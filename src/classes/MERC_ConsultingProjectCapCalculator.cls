public with sharing class MERC_ConsultingProjectCapCalculator implements GLBL_TriggerHandler.HandlerInterface {
	
	Schema.SobjectType triggeredSobjectType;

	public MERC_ConsultingProjectCapCalculator(Schema.SobjectType sobjectType) {
		this.triggeredSobjectType = sObjectType;
	}

	public void handle() {
		if (Trigger.isUpdate || Trigger.isUndelete) {
	    	execute(Trigger.new);
	   	} else if (Trigger.isDelete) {
	   		execute(Trigger.old);
	   	}
	}

	void execute(List<Sobject> sobjects) {
		List<Invoice_MERC__c> invoices;
		if (this.triggeredSobjectType == Invoice_MERC__c.sObjectType) {
			invoices = (List<Invoice_MERC__c>)sobjects;
		} else if (this.triggeredSobjectType == Invoice_Line_Item_MERC__c.sObjectType) {
			Set<Id> invoiceIds = new Set<Id>();
			for (Sobject lineItem : sobjects) {
				invoiceIds.add((Id)lineItem.get('Invoice_MERC__c'));
			}
			invoices = [SELECT ID, Meeting_Participant_Account_Id_MERC__c FROM Invoice_MERC__c WHERE ID in :invoiceIds];
		}

		if (invoices.size() == 0) return;

		Set<Id> meetingParticipantIds = new Set<Id>();
		Set<Id> accountIds = new Set<Id>();

		for (Invoice_MERC__c i : invoices)
			accountIds.add(i.Meeting_Participant_Account_Id_MERC__c);

		System.debug('>>>> '+accountIds);

		List<AggregateResult> results = [SELECT 
											Meeting_Participant_MERC__r.Account_MERC__c, 
											Sum(Consulting_Project_Amount_excl_VAT_MERC__c) lre0 
												FROM Invoice_MERC__c 
													WHERE 
														Meeting_Participant_MERC__r.Account_MERC__c IN :accountIds AND 
														Invoice_Date_MERC__c = THIS_YEAR 
															GROUP BY Meeting_Participant_MERC__r.Account_MERC__c];

		System.debug('>>>> '+results);

		List<Account> accounts = new List<Account>();

		for (AggregateResult res : results){
			System.debug('========== '+res);
		    Id masterRecId = (Id)res.get('Account_MERC__c');
		    if (masterRecId == null) {
		        System.debug(Logginglevel.WARN, 'No master record found for ID :' + masterRecId);
		        continue;
		    }
		    Object aggregatedDetailVal = res.get('lre0');
		    Account a = new Account();
		    a.Id = masterRecId;
		    a.Consulting_Project_Paid_CAP_MERC__c = (Decimal)aggregatedDetailVal;
			accounts.add(a);		    
		}

		update accounts;
	}
}