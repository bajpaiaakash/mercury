/*
 * @author David Andrew Helmer
 *
 * Trigger handler that Stamps the Consulting_Amount_MERC__c on Consulting_Amount_Rollup_MERC__c to avoid Conversion issues
 */

public with sharing class MERC_InvoiceLineItemRollupStamp implements GLBL_TriggerHandler.HandlerInterface {
	public MERC_InvoiceLineItemRollupStamp() {
		
	}

	public Boolean isActive() {
		return true;
	}

	public void handle() {
		stampRollupFields(Trigger.new);
	}

	private void stampRollupFields(List<Sobject> sobjects){
		List<Invoice_Line_Item_MERC__c> lineItems = (List<Invoice_Line_Item_MERC__c>)sobjects;		
		for(Invoice_Line_Item_MERC__c lineItem : lineItems){
			if(lineItem.Consulting_Amount_MERC__c != null) lineItem.Consulting_Amount_Rollup_MERC__c = lineItem.Consulting_Amount_MERC__c;	
		}
	}
}