/**
 * @author David Helmer
 *
 * Trigger handler that stamps the Meeting Participant's CurrencyISOCode on the Invoice's Currency ISO code if it is different
 */

public with sharing class MERC_InvoiceCurrencyTriggerHandler implements GLBL_TriggerHandler.HandlerInterface {
	public MERC_InvoiceCurrencyTriggerHandler() {
		
	}

	public Boolean isActive() {
	    return true;
	}

	public void handle(){
		stampMeetingParticipantFields(Trigger.new);
	}

	private void stampMeetingParticipantFields(List<SObject> sObjects){		
		List<Invoice_MERC__c> invoices = (List<Invoice_MERC__c>)sObjects;

		Set<ID> meetingParticipantIDs = new Set<ID>();
		for(Invoice_MERC__c invoice : invoices){
			if(invoice.Meeting_Participant_MERC__c != null){
				meetingParticipantIDs.add(invoice.Meeting_Participant_MERC__c);
			}
		}

		if(!meetingParticipantIDs.isEmpty()){
			Map<ID, Meeting_Participant_MERC__c> meetingParticipantsMap = new Map<ID, Meeting_Participant_MERC__c>([SELECT ID, CurrencyISOCode FROM Meeting_Participant_MERC__c WHERE ID IN :meetingParticipantIDs]);
			for(Invoice_MERC__c invoice : invoices){
				if(invoice.Meeting_Participant_MERC__c != null
					&& meetingParticipantsMap.containsKey(invoice.Meeting_Participant_MERC__c)
					&& meetingParticipantsMap.get(invoice.Meeting_Participant_MERC__c).CurrencyISOCode != invoice.CurrencyISOCode){
					invoice.CurrencyISOCode = meetingParticipantsMap.get(invoice.Meeting_Participant_MERC__c).CurrencyISOCode;
				}
			}
		}
	}
}