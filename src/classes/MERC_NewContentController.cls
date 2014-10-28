/**
 * @author Joseph Ferraro
 *
 * Controller that enables users to upload documents to Salesforce Content and associate with Mercury objects
 */

public with sharing class MERC_NewContentController {

	private final sObject mysObject;
    private final ApexPages.StandardController stdController;
    private Id recordId;
    public ContentVersion file { get; set; }
    public String sobjectAPIName { get; private set; }
    public String fieldSetAPIName  { get; private set; }
    public Boolean successfulUpload { get; private set; }

    public MERC_NewContentController() {
        this.recordId = (Id)ApexPages.currentPage().getParameters().get('id');
        String objectAPIName = this.recordId.getSObjectType().getDescribe().getName();
        this.mysObject = Database.query('Select Id, Name From '+objectAPIName+' WHERE Id = \''+this.recordId+'\'');
        this.stdController = new ApexPages.StandardController(this.mysObject);
        this.file = new ContentVersion();
        this.successfulUpload = false;
        setContentDefaults();
    }

    public PageReference cancel() {
        return new PageReference('/'+(String)this.mysObject.get('Id'));
    }

    public String getsObjectName() {
        return (String)this.mysObject.get('Name');
    }

    public void setContentDefaults() {
        //set to mercury library (replaced by getLibraryId)
        //try {
        //    this.file.FirstPublishLocationId = [select Id from ContentWorkspace WHERE Name = 'Mercury'].Id;
        //} catch(Exception e) {
        //    throw new MERC_Exception('Insufficient access to the Mercury Content Workspace. Please contact your system administrator.');
        //}

        //set record type and lookup(s)
        this.recordId = (Id)this.mysObject.get('Id');
        String objectAPIName = this.recordId.getSObjectType().getDescribe().getName();
        this.sobjectAPIName = objectAPIName;

        if (objectAPIName == 'Meeting_MERC__c') {
            this.file.Meeting_MERC__c = this.recordId;
            this.file.RecordTypeId = [Select Id From RecordType WHERE DeveloperName = 'Meeting_MERC' AND SobjectType = 'ContentVersion' LIMIT 1].Id;
            this.fieldSetAPIName = 'Meeting_MERC';
        } else if (objectAPIName == 'HCP_Contract_MERC__c') {
            this.file.HCP_Contract_MERC__c = this.recordId;
            this.file.RecordTypeId = [Select Id From RecordType WHERE DeveloperName = 'HCP_Contract_MERC' AND SobjectType = 'ContentVersion' LIMIT 1].Id;
            this.fieldSetAPIName = 'HCP_Contract_MERC';
        } else if (objectAPIName == 'Invoice_MERC__c') {
            this.file.Invoice_MERC__c = this.recordId;
            this.file.RecordTypeId = [Select Id From RecordType WHERE DeveloperName = 'Invoice_MERC' AND SobjectType = 'ContentVersion' LIMIT 1].Id;
            this.fieldSetAPIName = 'Invoice_MERC';
            if (ApexPages.currentPage().getParameters().containsKey('tif') && ApexPages.currentPage().getParameters().get('tif') == '1') {
                this.file.Title = Mercury_Settings_MERC__c.getOrgDefaults().Invoice_File_Prefix_MERC__c + String.valueOf(this.recordId) + '.tif';
                this.file.Document_Type_MERC__c = 'Invoices';
                MERC_InvoiceDocFilterController.deleteOldDocsInContent(new List<Id>{this.recordId},'TIFF');
            }
            if (ApexPages.currentPage().getParameters().containsKey('pdf') && ApexPages.currentPage().getParameters().get('pdf') == '1') {
                this.file.Title = Mercury_Settings_MERC__c.getOrgDefaults().Invoice_File_Prefix_MERC__c + String.valueOf(this.recordId) + '.pdf';
                this.file.Document_Type_MERC__c = 'Invoices';
                MERC_InvoiceDocFilterController.deleteOldDocsInContent(new List<Id>{this.recordId},'PDF');
            }
        } else if (objectAPIName == 'Account') {
            this.file.Account_GLBL__c = this.recordId;
            this.file.RecordTypeId = [Select Id From RecordType WHERE DeveloperName = 'Account_MERC' AND SobjectType = 'ContentVersion' LIMIT 1].Id;
            this.fieldSetAPIName = 'Account_MERC';
        } else if (objectAPIName == 'Meeting_Participant_MERC__c') {
            this.file.Meeting_Participant_MERC__c = this.recordId;
            this.file.RecordTypeId = [Select Id From RecordType WHERE DeveloperName = 'Meeting_Participant_MERC' AND SobjectType = 'ContentVersion' LIMIT 1].Id;
            this.fieldSetAPIName = 'Meeting_Participant_MERC';
        } else if (objectAPIName == 'Budget_MERC__c') {
            this.file.Budget_MERC__c = this.recordId;
            this.file.RecordTypeId = [Select Id From RecordType WHERE DeveloperName = 'Budget_MERC' AND SobjectType = 'ContentVersion' LIMIT 1].Id;
            this.fieldSetAPIName = 'Budget_MERC';
        }
    }

    @TestVisible
    Id getLibraryId(String objectAPIName) {
        String libraryName;
        String country;
        String suffix;
        String recTypeName;

        try {
            if (objectAPIName == 'Budget_MERC__c') {
                country = [SELECT Meeting_MERC__r.Event_Country_MERC__c FROM Budget_MERC__c WHERE Id = :recordId].Meeting_MERC__r.Event_Country_MERC__c;
                suffix  = [SELECT Procurement_Library_MERC__c FROM User WHERE Id=:UserInfo.getUserId()].Procurement_Library_MERC__c;
                if (suffix == null) {
                    libraryName = country + ' - Regional';
                } else {
                    libraryName = country + ' - ' + suffix;
                }
            } else {
                if (objectAPIName == 'Meeting_MERC__c') {
                    country = [SELECT Event_Country_MERC__c FROM Meeting_MERC__c WHERE Id = :recordId].Event_Country_MERC__c;
                    recTypeName = 'Meeting_MERC';
                } else if (objectAPIName == 'HCP_Contract_MERC__c') {
                    country = [SELECT Country_of_Residence_MERC__c FROM HCP_Contract_MERC__c WHERE Id = :recordId].Country_of_Residence_MERC__c;
                    recTypeName = 'HCP_Contract_MERC';
                } else if (objectAPIName == 'Invoice_MERC__c') {
                    Invoice_MERC__c invoice = [SELECT Meeting_Participant_MERC__r.Country_of_Residence_MERC__c FROM Invoice_MERC__c WHERE Id = :recordId];
                    if (invoice.Meeting_Participant_MERC__r.Country_of_Residence_MERC__c != null)
                    {
                        country = invoice.Meeting_Participant_MERC__r.Country_of_Residence_MERC__c;
                        recTypeName = 'Invoice_MERC';
                    }
                } else if (objectAPIName == 'Meeting_Participant_MERC__c') {
                    country = [SELECT Country_of_Residence_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :recordId].Country_of_Residence_MERC__c;
                    recTypeName='Meeting_Participant_MERC';
                } else if (objectAPIName == 'Account') {
                    country = [SELECT Country_of_Residence_GLBL__c FROM Account WHERE Id = :recordId].Country_of_Residence_GLBL__c;
                    recTypeName = 'Account_MERC';
                }

                suffix  = [SELECT Library_String_MERC__c
                             FROM Content_Library_Lookup_MERC__c
                            WHERE Content_Record_Type_MERC__c=:recTypeName
                              AND Content_Document_Type_MERC__c=:file.Document_Type_MERC__c].Library_String_MERC__c;
                libraryName = country + ' - ' + suffix;
            }

        } catch(Exception e) {

            throw new MERC_Exception('Unable to determine the proper content library.<br/><br/>Error: '+e.getMessage());
        }

        if (country == null) {
            throw new MERC_Exception('Unable to determine the appropriate content library because the country has not been set properly for '+getsObjectName()+' ('+objectAPIName+')');
        }

        Id contentLibraryId;
        try {
            contentLibraryId = [select Id from ContentWorkspace WHERE Name = :libraryName].Id;
        } catch(System.QueryException e) {
            if (e.getMessage().contains('List has no rows for assignment to SObject')) {
                String defaultLibrary = country + ' - Regional';
                try {
                    contentLibraryId = [select Id from ContentWorkspace WHERE Name = :defaultLibrary].Id;
                    ApexPages.addMessage(
                        new ApexPages.Message(ApexPages.Severity.WARNING,
                                                'You do not have permission to upload the document to the Library ' + libraryName
                                                + '. The document has been uploaded to the ' + defaultLibrary
                                                + ' Library. Please contact CMS Cork who can ensure your access is granted and the document is assigned to the correct Library.'));
                } catch (System.QueryException ex) {
                    throw new MERC_Exception('Unable to locate content library with the name: "'+libraryName+'" or "'+ defaultLibrary
                                             +'." They either do not exist or you are not a member of them. Please contact your system administrator.<br/><br/>'
                                             + 'Error: ' + ex.getMessage());
                }
            } else {
                throw e;
            }
        }

        if (suffix == null && objectAPIName == 'Budget_MERC__c') {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'You have not been granted access to a Procurement Library to upload document against a Budget. This document will be uploaded to: ' + libraryName + '. Please contact a system administrator for assistance with Library access.'));
        }

        return contentLibraryId;
    }

    public PageReference reloadPage() {
        return ApexPages.currentPage();
    }

    public PageReference upload() {
        if (this.file.versionData == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select a document to upload.'));
            return null;
        }

        if (this.file.versionData.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'The document you have selected to upload contains no data.'));
            return null;
        }

        try {
            this.file.FirstPublishLocationId = getLibraryId(this.sobjectAPIName);
            //for the SAP integration the file needs to be named just right.
            if (sObjectAPIName == 'Invoice_MERC__c') {
                String fileName = Mercury_Settings_MERC__c.getOrgDefaults().Invoice_File_Prefix_MERC__c + String.valueOf(this.recordId);
                if (ApexPages.currentPage().getParameters().containsKey('tif') && ApexPages.currentPage().getParameters().get('tif') == '1') {
                    this.file.PathOnClient =  fileName + '.tif';
                } else if (ApexPages.currentPage().getParameters().containsKey('pdf') && ApexPages.currentPage().getParameters().get('pdf') == '1') {
                    this.file.PathOnClient =  fileName + '.pdf';
                }
            }
            System.debug(this.file);
            insert this.file;
        } catch (Exception e) {
            this.file.versionData = null;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            return null;
        }

        successfulUpload = true;
        if (ApexPages.getMessages().isEmpty()) {
            return this.stdController.view();
        } else {
            return null;
        }
    }

    // UNUSED CONSTRUCTOR
    // public MERC_NewContentController(ApexPages.StandardController stdController) {
    //     this.stdController = stdController;
    //     if (!Test.isRunningTest()) {
    //         this.stdController.addFields(new List<String>{ 'Id', 'Name' });
    //     }
    //     this.mysObject = (sObject)stdController.getRecord();
    //     this.file = new ContentVersion();
    //     setContentDefaults();
    // }
}