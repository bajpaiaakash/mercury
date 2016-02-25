/**
 * @author Joseph Ferraro
 *
 * Ensures RecordTypeId is being set when Content is uploaded via custom VF Page
*/

@isTest
private class MERC_ContentVersionHandlerTest {
    
    //TODO: THIS IS BREAKING OUR BUILD RIGHT NOW
    //when run normally, these pass, however, when run as part of the build, they fail
    static List<Account> accs;
    static List<Meeting_MERC__c> mtgs;
    static List<Meeting_Participant_MERC__c> ps;
    static List<Invoice_MERC__c> invoices;
    static HCP_Contract_MERC__c contract;
    static Budget_MERC__c budget;
    static Set<String> mercuryContentRecordTypes;
    static Map<String, String> objectTypeToContentRecordId;
    static Id workspaceId;
    static String versionData = 'foo';
    static Blob versionDataBlob = Blob.valueOf(versionData);
    static ContentVersion c;

    static {
        mercuryContentRecordTypes = new Set<String>{
            'Invoice_MERC', 'Meeting_MERC', 'HCP_Contract_MERC', 'Account_MERC', 'Meeting_Participant_MERC', 'Budget_MERC'
        };
        objectTypeToContentRecordId = new Map<String, String>();
        for (RecordType recordType : [Select ID, DeveloperName From RecordType Where SobjectType = 'ContentVersion' and DeveloperName IN :mercuryContentRecordTypes]) {
            objectTypeToContentRecordId.put(recordType.DeveloperName, recordType.Id);
        }
        workspaceId = [SELECT Id FROM ContentWorkspace WHERE Name = 'Mercury' Limit 1].Id; //we dont seem to be able to create this in a test
        system.assertNotEquals(workspaceId, null);
        
        c = new ContentVersion();
        c.Title = 'foo';
        c.FirstPublishLocationId = workspaceId;
        c.PathOnClient = 'foo';
        c.VersionData = versionDataBlob;
    }

    @isTest static void assert_contract_recordtypeid() {
        accs = MERC_TestFactory.insertAccounts(1);
        mtgs = MERC_TestFactory.insertMeetings(1);
        ps = MERC_TestFactory.insertParticipants(mtgs.get(0).Id, accs);
        contract = MERC_TestFactory.insertHCPContract(accs.get(0).Id);

        c.HCP_Contract_MERC__c = contract.Id;
        insert c;

        System.assertEquals(objectTypeToContentRecordId.get('HCP_Contract_MERC'), [SELECT RecordTypeId FROM ContentVersion WHERE Id = :c.Id].RecordTypeId);
    }

    @isTest static void assert_account_recordtypeid() {
        accs = MERC_TestFactory.insertAccounts(1);
        
        c.Account_GLBL__c = accs.get(0).Id;
        insert c;

        System.assertEquals(objectTypeToContentRecordId.get('Account_MERC'), [SELECT RecordTypeId FROM ContentVersion WHERE Id = :c.Id].RecordTypeId);
    }

    @isTest static void assert_invoice_recordtypeid() {
        accs = MERC_TestFactory.insertAccounts(1);
        mtgs = MERC_TestFactory.insertMeetings(1);
        ps = MERC_TestFactory.insertParticipants(mtgs.get(0).Id, accs);
        Test.startTest();
        invoices = MERC_TestFactory.insertInvoices(ps);
        c.Invoice_MERC__c = invoices.get(0).Id;
        insert c;
        Test.stopTest();
        System.assertEquals(objectTypeToContentRecordId.get('Invoice_MERC'), [SELECT RecordTypeId FROM ContentVersion WHERE Id = :c.Id].RecordTypeId);
    }

    @isTest static void assert_meeting_recordtypeid() {
        accs = MERC_TestFactory.insertAccounts(1);
        mtgs = MERC_TestFactory.insertMeetings(1);
        
        c.Meeting_MERC__c = mtgs.get(0).Id;
        insert c;

        System.assertEquals(objectTypeToContentRecordId.get('Meeting_MERC'), [SELECT RecordTypeId FROM ContentVersion WHERE Id = :c.Id].RecordTypeId);
    }

    @isTest static void assert_meeting_participant_recordtypeid() {
        accs = MERC_TestFactory.insertAccounts(1);
        mtgs = MERC_TestFactory.insertMeetings(1);
        ps = MERC_TestFactory.insertParticipants(mtgs.get(0).Id, accs);

        c.Meeting_Participant_MERC__c = ps.get(0).Id;
        insert c;

        System.assertEquals(objectTypeToContentRecordId.get('Meeting_Participant_MERC'), [SELECT RecordTypeId FROM ContentVersion WHERE Id = :c.Id].RecordTypeId);
    }

    @isTest static void assert_budget_recordtypeid() {
        MERC_TriggerHandlerStateManager.deactivateAll();
        accs = MERC_TestFactory.insertAccounts(1);
        mtgs = MERC_TestFactory.insertMeetings(1);
        budget = MERC_TestFactory.insertBudget(mtgs.get(0).Id, true); // Modified by Aakash for US-37784 on 23-06-2015
        Test.startTest();
        c.Budget_MERC__c = budget.Id;
        insert c;
        Test.stopTest();
        System.assertEquals(objectTypeToContentRecordId.get('Budget_MERC'), [SELECT RecordTypeId FROM ContentVersion WHERE Id = :c.Id].RecordTypeId);
    }
    
}