<<<<<<< HEAD
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
=======
public with sharing class MERC_InvoiceCreditNoteController {

	public RecordType newInvoiceRecType { get; private set; }

    public Invoice_MERC__c invoice { get; private set; }
    transient private List<Invoice_Line_Item_MERC__c> lineItems = new List<Invoice_Line_Item_MERC__c>();
    transient private List<ContentVersion> files               = new List<ContentVersion>();

    /*----- The extension constructor initializes the private member variable
            mysObject by using the getRecord method from the standard controller. -----*/
    public MERC_InvoiceCreditNoteController(ApexPages.StandardController stdController) {
>>>>>>> 828e4725e2b95e1366edccc53b0a185dfee83071
        invoice = (Invoice_MERC__c)stdController.getRecord();
        invoice = [Select Id, RecordTypeId, Name FROM Invoice_MERC__c WHERE Id =:invoice.Id];

        /*----- a map from the current record type to the type that should be created -----*/
<<<<<<< HEAD
        Map<String, String> existingToNewRecTypeMap
                            = new Map<String, String>{ 'Invoice_Locked_MERC'     => 'Credit_Note_MERC',
                                                       'Credit_Note_Locked_MERC' => 'Invoice_MERC'};

        /*----- create a map of Invoice record types by Id-----*/
        Map<Id, RecordType> recordTypeMap
                            = new Map<Id, RecordType>([SELECT Id, Name, DeveloperName
                                                         FROM RecordType
                                                        WHERE SObjectType = 'Invoice_MERC__c']);

        /*----- use the prior to maps to figure out what the record type will be for the new Invoice/Credit Note Record
                Invoice_Locked will clone to Credit_Note. Credit_note_locked will clone to an invoice. Anything else will
                return an error to the user. -----*/
=======
        Map<String, String> existingToNewRecTypeMap = new Map<String, String>{ 'Invoice_Locked_MERC'     => 'Credit_Note_MERC',
                                                                               'Credit_Note_Locked_MERC' => 'Invoice_MERC'};

        /*----- create a map of Invoice record types by Id-----*/
        Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Invoice_MERC__c']);


        /*----- use the prior to maps to figure out what the record type will be for the new Invoice/Credit Note Record -----*/
>>>>>>> 828e4725e2b95e1366edccc53b0a185dfee83071
        if (recordTypeMap.containsKey(invoice.RecordTypeId) && existingToNewRecTypeMap.containsKey(recordTypeMap.get(invoice.RecordTypeId).DeveloperName))
        {
            newInvoiceRecType = [SELECT Id, toLabel(Name), DeveloperName
                                   FROM RecordType
                                  WHERE SObjectType   = 'Invoice_MERC__c'
                                    AND DeveloperName = :existingToNewRecTypeMap.get(recordTypeMap.get(invoice.RecordTypeId).DeveloperName)
                                  LIMIT 1];
<<<<<<< HEAD
        }
        else
        {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'This invoice/credit note cannot be cloned. Please contact an administrator.'));
        }
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
            newInvoice.Credit_Note_Invoice_MERC__c        = newInvoiceRecType.DeveloperName == 'Credit_Note_MERC' ? invoice.Id : null;


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
=======
        } else {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'This invoice/credit note cannot be cloned. Please contact an administrator.'));
        }

        /*----- if we successfully sorted out what the new record type will be we can carry on -----*/
        if (newInvoiceRecType != null)
        {
            /*----- Just need this for a count. Don't want to overwhelm the view state -----*/
            lineItems = [SELECT Id FROM Invoice_Line_Item_MERC__c WHERE Invoice_MERC__c = :invoice.Id];
            files = [SELECT Id FROM ContentVersion WHERE Invoice_MERC__c = :invoice.Id];
        }
    }

    public Integer getLineItemCount() {
        return lineItems.size();
    }

    public Integer getContentCount() {
        return files.size();
    }

    public PageReference createNewInvoice() {
        System.savePoint sp = Database.setSavePoint();

        String invSoqlQuery = 'SELECT Id';
        for (Schema.FieldSetMember fsm : Schema.SObjectType.Invoice_MERC__c.fieldSets.Invoice_Clone_Field_Set.getFields())
        {
            invSoqlQuery += ', ' + fsm.getFieldPath();
        }
        invSoqlQuery += ' FROM Invoice_MERC__c WHERE Id = \'' + invoice.Id + '\'';

        Invoice_MERC__c oldInvoice = Database.query(invSoqlQuery);

        Invoice_MERC__c newInvoice                    = oldInvoice.clone();
        newInvoice.Submit_for_Payment_MERC__c         = 'No';
        newInvoice.Submitted_for_Payment_Date_MERC__c = null;
        newInvoice.RecordTypeId                       = newInvoiceRecType.Id;
        newInvoice.Credit_Note_Invoice_MERC__c        = newInvoiceRecType.DeveloperName == 'Credit_Note_MERC' ? invoice.Id : null;

        try {
            insert newInvoice;
        } catch (System.DMLException ex) {
            Database.rollback(sp);
            ApexPages.addMessages(ex);
            return null;
        }

        String soqlQuery = 'SELECT Id';
        for (Schema.FieldSetMember fsm : Schema.SObjectType.Invoice_Line_Item_MERC__c.fieldSets.Invoice_Clone_Field_Set.getFields())
        {
            soqlQuery += ', ' + fsm.getFieldPath();
        }
        soqlQuery += ' FROM Invoice_Line_Item_MERC__c WHERE Invoice_MERC__c = \'' + invoice.Id + '\'';

        lineItems = Database.query(soqlQuery);

        List<Invoice_Line_Item_MERC__c> newLineItems = lineItems.deepClone();
        for (Invoice_Line_Item_MERC__c li : newLineItems) {
            li.Invoice_MERC__c = newInvoice.Id;
        }

        try {
            insert newLineItems;
        } catch(System.DMLException ex) {
            Database.rollback(sp);
            ApexPages.addMessages(ex);
            return null;
        }

        if (newInvoiceRecType.DeveloperName == 'Credit_Note_MERC') {

            /*----- query for files, skip Expose_on_Portal_MERC__c as it throws errors, FirstPublishLocationId: we aren't allowed to set it-----*/
            files = [SELECT Account_Archive_Date__c, Account_GLBL__c, Approval_Reference_Number_MERC__c, Archive_Date_MERC__c, Budget_Archive_Date_MERC__c, Budget_MERC__c, Checksum, Code_MERC__c,
                            ContentDocumentId, ContentModifiedById, ContentModifiedDate, ContentSize, ContentUrl, Contract_Archive_Date_MERC__c, Contract_End_Date_MERC__c, Contract_Start_Date_MERC__c,
                            Country_of_Residence_MERC__c, CreatedById, CreatedDate, CurrencyIsoCode, Customer_Id_MERC__c, Description, Document_Type_MERC__c, FeaturedContentBoost, FeaturedContentDate,
                            FileType, HCP_Contract_MERC__c, HCP_Name_MERC__c, Id, Invoice_Archive_Date_MERC__c, Invoice_MERC__c, IsDeleted, IsLatest, LastModifiedById, LastModifiedDate,
                            Library_Name_MERC__c, Meeting_Archive_Date_MERC__c, Meeting_City_MERC__c, Meeting_Country_MERC__c, Meeting_MERC__c, Meeting_Participant_MERC__c, Meeting_Start_Date_MERC__c,
                            NegativeRatingCount, Origin, OwnerId, Participant_Name_MERC__c, PathOnClient, PositiveRatingCount, Product_1_MERC__c, Product_2_MERC__c, Product_3_MERC__c, PublishStatus,
                            RatingCount, ReasonForChange, RecordTypeId, SystemModstamp, TagCsv, Title, Upload_Date_MERC__c, VersionData, VersionNumber
                       FROM ContentVersion
                      WHERE Invoice_MERC__c = :invoice.id];

            List<ContentVersion> newFiles = files.deepClone();
            for (ContentVersion file : newFiles) {
                file.Invoice_MERC__c = newInvoice.Id;
                file.ReasonForChange = 'Cloned from Invoice to Credit Note.';
            }

            try {
                insert newFiles;
            } catch(System.DMLException ex) {
                Database.rollback(sp);
                ApexPages.addMessages(ex);
                return null;
            }
        }

        PageReference invPage = new ApexPages.StandardController(newInvoice).view();
        invPage.setRedirect(true);
        return invPage;
>>>>>>> 828e4725e2b95e1366edccc53b0a185dfee83071
    }
}