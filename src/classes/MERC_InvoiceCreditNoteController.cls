/*
 * @author Kyle Thornton
 *
 * @description Controller that allows users to clone a locked invoice or credit note.
 *       When an invoice needs to be fixed users will issue a credit note with the exact
 *       same information (line items & content) as its assoiated invoice and then issue
 *       a new invoice. The Line items for the new invoice are cloned as a starting point
 *       for corrections to be made and then content can be regenerated.
*/

public with sharing class MERC_InvoiceCreditNoteController
{

    public RecordType newInvoiceRecType { get; private set; }
    public Invoice_MERC__c invoice      { get; private set; }

    public MERC_InvoiceCreditNoteController(ApexPages.StandardController stdController)
    {
        invoice = (Invoice_MERC__c)stdController.getRecord();
        p('invoice='+invoice);
        invoice = [Select Id, RecordTypeId, Name FROM Invoice_MERC__c WHERE Id =:invoice.Id];

        /*----- a map from the current record type to the type that should be created -----*/
        Map<String, String> existingToNewRecTypeMap
                            = new Map<String, String>{ 'Invoice_Locked_MERC'     => 'Credit_Note_MERC',
                                                       'Credit_Note_Locked_MERC' => 'Invoice_MERC',
                                                       'Invoice_Invalid_MERC'    => 'Invoice_MERC'};

        /*----- create a map of Invoice record types by Id-----*/
        Map<Id, RecordType> recordTypeMap
                            = new Map<Id, RecordType>([SELECT Id, Name, DeveloperName
                                                         FROM RecordType
                                                        WHERE SObjectType = 'Invoice_MERC__c']);

        /*----- use the prior to maps to figure out what the record type will be for the new Invoice/Credit Note Record
                Invoice_Locked will clone to Credit_Note. Credit_note_locked will clone to an invoice. Anything else will
                return an error to the user. -----*/
        if (recordTypeMap.containsKey(invoice.RecordTypeId) && existingToNewRecTypeMap.containsKey(recordTypeMap.get(invoice.RecordTypeId).DeveloperName))
        {
            newInvoiceRecType = [SELECT Id, toLabel(Name), DeveloperName
                                   FROM RecordType
                                  WHERE SObjectType   = 'Invoice_MERC__c'
                                    AND DeveloperName = :existingToNewRecTypeMap.get(recordTypeMap.get(invoice.RecordTypeId).DeveloperName)
                                  LIMIT 1];
        }
        else
        {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'This invoice/credit note cannot be cloned. Please contact an administrator.'));
        }
    }
    static void p(String m) {
        System.debug('\n\n\nYYZ - '+m+'\n\n\n\n');
    }
    public Integer getLineItemCount()
    {
        return [SELECT COUNT() FROM Invoice_Line_Item_MERC__c WHERE Invoice_MERC__c = :invoice.Id];
    }

    public Integer getContentCount()
    {
        return [SELECT COUNT() FROM ContentVersion WHERE Invoice_MERC__c = :invoice.Id];
    }

    public PageReference createNewInvoice()
    {
        System.savePoint sp = Database.setSavePoint();
        Invoice_MERC__c newInvoice;

        try
        {
            /*----- get the cloned invoice and insert it -----*/
            newInvoice = cloneInvoice(invoice);

            /*----- clone the line items from the original invoice to the new invoice -----*/
            cloneLineItems(invoice, newInvoice);

            /*----- When cloning an invoice to a credit note, need to link all of the content with the credit note as well.
                    If going from credit note to invoice the user will generate new content manually -----*/
            if (newInvoiceRecType.DeveloperName == 'Credit_Note_MERC') {
                updateContentVersions(invoice, newInvoice);
            }
        }
        catch (MERC_Exception ex)
        {
            Database.rollback(sp);
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to clone record. Please contact an administrator.'));
            return null;
        }

        /*----- redirect the user to the new invoice object -----*/
        PageReference invPage = new ApexPages.StandardController(newInvoice).view();
        invPage.setRedirect(true);
        return invPage;
    }

    @TestVisible
    private Invoice_MERC__c cloneInvoice(Invoice_MERC__c invoice)
    {
        Invoice_MERC__c newInvoice;
        try
        {
            /*----- Bulid the query string from the Invoice_Clone_Field_Set on the
                    Invoice object to get all fields that should be copied over -----*/
            String invSoqlQuery = 'SELECT Id';
            for (Schema.FieldSetMember fsm : Schema.SObjectType.Invoice_MERC__c.fieldSets.Invoice_Clone_Field_Set.getFields())
            {
                invSoqlQuery += ', ' + fsm.getFieldPath();
            }
            invSoqlQuery += ' FROM Invoice_MERC__c WHERE Id = \'' + invoice.Id + '\'';

            Invoice_MERC__c oldInvoice = Database.query(invSoqlQuery);

            /*----- clone the invoice and set the record type. Clear submitted and submitted date and if creating a
                    credit note set the credit note invoice to the invoice that we are cloning from -----*/
            newInvoice                                    = oldInvoice.clone();
            newInvoice.Submit_for_Payment_MERC__c         = 'No';
            newInvoice.Submitted_for_Payment_Date_MERC__c = null;
            newInvoice.RecordTypeId                       = newInvoiceRecType.Id;
            newInvoice.Credit_Note_Invoice_MERC__c        = (newInvoiceRecType.DeveloperName == 'Credit_Note_MERC') ? invoice.Id : null;
            newInvoice.Invoice_Type_MERC__c               = (newInvoiceRecType.DeveloperName == 'Credit_Note_MERC') ? 'CR' : 'IN';
            newInvoice.OwnerId                            = UserInfo.getUserId();
            newInvoice.Invoice_Attached_MERC__c           = False;  //Added by Jyoti Gaur on 15 Jan for US-40731

            insert newInvoice;
        }
        catch (System.Exception ex)
        {
            throw new MERC_Exception(ex);
        }

        return newInvoice;
    }

    @TestVisible
    private void cloneLineItems(Invoice_MERC__c oldInvoice, Invoice_MERC__c newInvoice)
    {
        try
        {
            /*----- Bulid the query string from the Invoice_Clone_Field_Set on the
                    Invoice Line Item object to get all fields that should be copied over -----*/
            String soqlQuery = 'SELECT Id';
            for (Schema.FieldSetMember fsm : Schema.SObjectType.Invoice_Line_Item_MERC__c.fieldSets.Invoice_Clone_Field_Set.getFields())
            {
                soqlQuery += ', ' + fsm.getFieldPath();
            }
            soqlQuery += ' FROM Invoice_Line_Item_MERC__c WHERE Invoice_MERC__c = \'' + invoice.Id + '\'';

            List<Invoice_Line_Item_MERC__c> lineItems = Database.query(soqlQuery);

            /*----- clone the line items and update parent to be the new Invoice/Credit Note -----*/
            List<Invoice_Line_Item_MERC__c> newLineItems = lineItems.deepClone();
            for (Invoice_Line_Item_MERC__c li : newLineItems)
            {
                li.Invoice_MERC__c = newInvoice.Id;
            }

            insert newLineItems;
        }
        catch(System.Exception ex)
        {
            throw new MERC_Exception(ex);
        }
    }

    @TestVisible
    private void updateContentVersions(Invoice_MERC__c oldInvoice, Invoice_MERC__c newInvoice)
    {
        try
        {
            /*----- Update all of the files from the invoice to link to the newly created credit note -----*/
            List<ContentVersion> files = [SELECT Id, Credit_Note_MERC__c FROM ContentVersion WHERE Invoice_MERC__c = :oldInvoice.id];

            for (ContentVersion file : files)
            {
                file.Credit_Note_Merc__c = newInvoice.Id;
            }


            update files;
        }
        catch(System.Exception ex)
        {
            throw new MERC_Exception(ex);
        }
    }
}