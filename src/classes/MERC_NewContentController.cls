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

    public MERC_NewContentController() {
        this.recordId = (Id)ApexPages.currentPage().getParameters().get('id');
        String objectAPIName = this.recordId.getSObjectType().getDescribe().getName();
        this.mysObject = Database.query('Select Id, Name From '+objectAPIName+' WHERE Id = \''+this.recordId+'\'');
        this.stdController = new ApexPages.StandardController(this.mysObject);
        this.file = new ContentVersion();
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
                this.file.Title = Mercury_Settings_MERC__c.getOrgDefaults().Invoice_File_Prefix_MERC__c + String.valueOf(this.recordId).substring(0,15) + '.tif';
                MERC_InvoiceDocFilterController.deleteOldDocsInContent(new List<Id>{this.recordId},'TIFF');
            }
            if (ApexPages.currentPage().getParameters().containsKey('pdf') && ApexPages.currentPage().getParameters().get('pdf') == '1') {
                this.file.Title = Mercury_Settings_MERC__c.getOrgDefaults().Invoice_File_Prefix_MERC__c + String.valueOf(this.recordId).substring(0,15) + '.pdf';
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
        this.file.FirstPublishLocationId = getLibraryId(this.sobjectAPIName);
    }

    Id getLibraryId(String objectAPIName) {
        String libraryName = 'Mercury'; //default to Mercury, overwrite below.
        String country;
        try {
            if (objectAPIName == 'Meeting_MERC__c') {
                country = [SELECT Event_Country_MERC__c FROM Meeting_MERC__c WHERE Id = :recordId].Event_Country_MERC__c;
                libraryName = country + ' - Public';
            } else if (objectAPIName == 'HCP_Contract_MERC__c') {
                country = [SELECT Country_of_Residence_MERC__c FROM HCP_Contract_MERC__c WHERE Id = :recordId].Country_of_Residence_MERC__c;
                libraryName = country + ' - Private';
            } else if (objectAPIName == 'Invoice_MERC__c') {
                Invoice_MERC__c invoice = [SELECT Meeting_Participant_MERC__r.Country_of_Residence_MERC__c FROM Invoice_MERC__c WHERE Id = :recordId];
                if (invoice.Meeting_Participant_MERC__r.Country_of_Residence_MERC__c != null)
                {
                    country = invoice.Meeting_Participant_MERC__r.Country_of_Residence_MERC__c;
                    libraryName = country + ' - Private';
                }
            } else if (objectAPIName == 'Budget_MERC__c') {
                country = [SELECT Meeting_MERC__r.Event_Country_MERC__c FROM Budget_MERC__c WHERE Id = :recordId].Meeting_MERC__r.Event_Country_MERC__c;
                libraryName = country + ' - Private';
            } else if (objectAPIName == 'Meeting_Participant_MERC__c') {
                country = [SELECT Country_of_Residence_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :recordId].Country_of_Residence_MERC__c;
                libraryName = country + ' - Private';
            } else if (objectAPIName == 'Account') {
                country = [SELECT Country_of_Residence_GLBL__c FROM Account WHERE Id = :recordId].Country_of_Residence_GLBL__c;
                libraryName = country + ' - Private';
            }
        } catch(Exception e) {
            throw new MERC_Exception('Unable to determine the proper country content library. '+e.getMessage());
        }
        if (country == null) {
            throw new MERC_Exception('Unable to determine the appropriate content library because the country has not been set properly for '+getsObjectName()+' ('+objectAPIName+')');
        }

        try {
            return [select Id from ContentWorkspace WHERE Name = :libraryName].Id;
        } catch(System.QueryException e) {
            if (e.getMessage().contains('List has no rows for assignment to SObject')) {
                throw new MERC_Exception('Unable to locate content library with the name: "'+libraryName+'." It either does not exist or you are not a member of the library. Please contact your system administrator.');
            } else {
                throw e;
            }
        }
    }

    public PageReference upload() {
        if (this.file.versionData == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select a document to upload.'));
            return null;
        }
        try {
            //for the SAP integration the file needs to be named just right.
            if (sObjectAPIName == 'Invoice_MERC__c') {
                String fileName = Mercury_Settings_MERC__c.getOrgDefaults().Invoice_File_Prefix_MERC__c + String.valueOf(this.recordId).substring(0,15);
                if (ApexPages.currentPage().getParameters().containsKey('tif') && ApexPages.currentPage().getParameters().get('tif') == '1') {
                    this.file.PathOnClient =  fileName + '.tif';
                } else if (ApexPages.currentPage().getParameters().containsKey('pdf') && ApexPages.currentPage().getParameters().get('pdf') == '1') {
                    this.file.PathOnClient =  fileName + '.pdf';
                } 
            }
            insert this.file;
        } catch (Exception e) {
            this.file.versionData = null;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            return null;
        }
        return this.stdController.view();
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