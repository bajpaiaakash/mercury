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
        //set to mercury library
        try {
            this.file.FirstPublishLocationId = [select Id from ContentWorkspace WHERE Name = 'Mercury'].Id;    
        } catch(Exception e) {
            throw new MERC_Exception('Insufficient access to the Mercury Content Workspace. Please contact your system administrator.');
        }

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

    public PageReference upload() {
        if (this.file.versionData == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select a document to upload.'));
            return null;  
        }
        try {
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