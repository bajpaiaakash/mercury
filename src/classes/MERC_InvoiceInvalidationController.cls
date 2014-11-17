/*
 * Author: Sean Harrison
 *
 * Prepping an Invoice record for invalidation and cloning.
 */
public without sharing class MERC_InvoiceInvalidationController {

	private Invoice_MERC__c mysObject;

    public MERC_InvoiceInvalidationController(ApexPages.StandardController stdController) {
        this.mysObject = (Invoice_MERC__c)stdController.getRecord();
    }

    public PageReference redirect() {
        this.mysObject = [SELECT Id, RecordTypeId FROM Invoice_MERC__c WHERE Id = :this.mysObject.Id];
        this.mysObject.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Invoice_MERC__c' AND DeveloperName = 'Invoice_Invalid_MERC' LIMIT 1].Id;
        update this.mySobject;

        PageReference pageRef = Page.MERC_InvoiceCreditNote;
        pageRef.getParameters().put('id',this.mysObject.Id);
//        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'forwarding to '+pageRef));
        return pageRef;
    }
}