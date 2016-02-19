/*
 * @author David Andrew Helmer
 *
 * Trigger handler that Stamps the Consulting_Amount_MERC__c on 

MERC_Consulting_Contracted_Amount_Rollup__c to avoid Conversion issues
 */

public with sharing class MERC_InvoiceLineItemRollupStamp implements 

GLBL_TriggerHandler.HandlerInterface {
    public MERC_InvoiceLineItemRollupStamp() {
        
    }

    public Boolean isActive() {
        return true;
    }

    public void handle() {
        stampRollupFields(Trigger.new);
    }

    private void stampRollupFields(List<Sobject> sobjects){
        List<Invoice_Line_Item_MERC__c> lineItems = 

(List<Invoice_Line_Item_MERC__c>)sobjects;      
        for(Invoice_Line_Item_MERC__c lineItem : lineItems){
                lineItem.MERC_Consulting_Contracted_Amount_Rollup__c = lineItem.Amount_MERC__c;
                
        }
    }
}