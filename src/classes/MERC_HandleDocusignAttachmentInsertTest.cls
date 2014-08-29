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
        // UK user groups for membership in Content Libraries
        List<Group> groups = [SELECT Id FROM Group WHERE Name LIKE '%GB'];
        List<GroupMember> members = new List<GroupMember>();
        for (Group g : groups) {
            members.add(new GroupMember(GroupId=g.Id,UserOrGroupId=testUser.Id));
            members.add(new GroupMember(GroupId=g.Id,UserOrGroupId=runningUser.Id));
        }
        insert members;

        System.runAs(runningUser) {
            accts = MERC_TestFactory.insertAccounts(1);
            contract = MERC_TestFactory.insertHCPContract((String)accts[0].Id);
        }
    }

    @isTest 
    static void contractAttachementBecomesContent() {

        Test.startTest();
        Attachment a = new Attachment(ParentId = contract.Id, Name = 'Henry V');
        a.Body = Blob.valueOf('Oh, for a muse of fire that would ascend the brightest heaven of invention!');
        insert a;
        Test.stopTest();

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