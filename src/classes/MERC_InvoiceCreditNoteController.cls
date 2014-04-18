public with sharing class MERC_InvoiceCreditNoteController {

	public RecordType newInvoiceRecType { get; private set; }

    public Invoice_MERC__c invoice { get; private set; }
    transient private List<Invoice_Line_Item_MERC__c> lineItems = new List<Invoice_Line_Item_MERC__c>();
    transient private List<ContentVersion> files               = new List<ContentVersion>();

    /*----- The extension constructor initializes the private member variable
            mysObject by using the getRecord method from the standard controller. -----*/
    public MERC_InvoiceCreditNoteController(ApexPages.StandardController stdController) {
        invoice = (Invoice_MERC__c)stdController.getRecord();
        invoice = [Select Id, RecordTypeId, Name FROM Invoice_MERC__c WHERE Id =:invoice.Id];

        /*----- a map from the current record type to the type that should be created -----*/
        Map<String, String> existingToNewRecTypeMap = new Map<String, String>{ 'Invoice_Locked_MERC'     => 'Credit_Note_MERC',
                                                                               'Credit_Note_Locked_MERC' => 'Invoice_MERC'};

        /*----- create a map of Invoice record types by Id-----*/
        Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Invoice_MERC__c']);


        /*----- use the prior to maps to figure out what the record type will be for the new Invoice/Credit Note Record -----*/
        if (recordTypeMap.containsKey(invoice.RecordTypeId) && existingToNewRecTypeMap.containsKey(recordTypeMap.get(invoice.RecordTypeId).DeveloperName))
        {
            newInvoiceRecType = [SELECT Id, toLabel(Name), DeveloperName
                                   FROM RecordType
                                  WHERE SObjectType   = 'Invoice_MERC__c'
                                    AND DeveloperName = :existingToNewRecTypeMap.get(recordTypeMap.get(invoice.RecordTypeId).DeveloperName)
                                  LIMIT 1];
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
    }
}