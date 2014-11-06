/**
 * @author Sean Harrison
 *
 * Unit tests for MERC_HandleDocusignAttachmentInsert.cls which copies attachments
 * created by Docusign to Content and deletes the attachment.
 */
@isTest
private class MERC_HandleDocusignAttachmentInsertTest {
    
    static List<Account> accts;
    static HCP_Contract_MERC__c contract;
    static User runningUser = MERC_TestFactory.getRunningUser();
    static User testUser = MERC_TestFactory.getTestingUser();

    static {
        System.runAs(runningUser) {
            accts = MERC_TestFactory.insertHcpAccountsInCountry(1,'GB');
            contract = MERC_TestFactory.insertHCPContract((String)accts[0].Id);
            // generate initial contract
            ContentVersion file = new ContentVersion();
            file.Title = 'Generated Contract';
            file.VersionData = Blob.valueOf('A kingdom for a stage, princes to act and monarchs to behold the swelling scene');
            file.HCP_Contract_MERC__c = contract.Id;
            file.RecordTypeId = [Select Id From RecordType WHERE DeveloperName = 'HCP_Contract_MERC' AND SobjectType = 'ContentVersion' LIMIT 1].Id;
            file.PathOnClient = 'GeneratedContract.pdf';
            file.FirstPublishLocationId = [select Id from ContentWorkspace WHERE Name = 'GB - Regional'].Id;
            insert file;
        }
    }

    @isTest 
    static void contractAttachementBecomesContent() {

        System.runAs(runningUser) {
            Test.startTest();
            Attachment a = new Attachment(ParentId = contract.Id, Name = 'Henry V');
            a.Body = Blob.valueOf('Oh, for a muse of fire that would ascend the brightest heaven of invention!');
            insert a;
            Test.stopTest();
        }

        System.runAs(testUser) {
            List<Attachment> shouldBeEmpty = new List<Attachment>([SELECT Id FROM Attachment WHERE ParentId = :contract.Id]);
            System.assert(shouldBeEmpty.isEmpty(),'Should be no attachments but I found something: '+shouldBeEmpty);

            List<ContentVersion> contentVers = new List<ContentVersion>(
                [SELECT ContentDocumentId, Title, PathOnClient, VersionData From ContentVersion 
                   WHERE HCP_Contract_MERC__c = :contract.Id]
                );
            System.assert(!contentVers.isEmpty(), 'The attachment does not appear as Content');
        }
    }
    
    // Should only work for HCP Contracts, so let's try a non-contract obj to confirm attachment remains
    @isTest 
    static void justHCPContractsShouldHaveAttachmentsConverted() {
        List<Meeting_MERC__c> meets = MERC_TestFactory.insertMeetings(1);

        Test.startTest();
        Attachment a = new Attachment(ParentId = meets[0].Id, Name = 'Macbeth');
        a.Body = Blob.valueOf('Is this a dagger which I see before me, the handle toward my hand?');
        insert a;
        Test.stopTest();

        List<Attachment> shouldNotBeEmpty = new List<Attachment>([SELECT Id FROM Attachment WHERE ParentId = :meets[0].Id]);
        System.assert(!shouldNotBeEmpty.isEmpty(),'Attachement not found');
    }
}