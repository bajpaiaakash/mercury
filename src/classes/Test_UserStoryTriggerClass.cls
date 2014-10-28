@
isTest
public class Test_UserStoryTriggerClass
{
    /*
     * Method name  : Test_UserStoryTriggerClass
     * @description Function tests the trigger actions on User Story.
     */
    static MICO_User_Story__c story;
    static MICO_App__c app;
    public static void createStory()
    {
        // user
        User stakeholderUser = new User(Alias = 'stkhldr', Email = 'stakeholderUser@mico-test.com', EmailEncodingKey = 'UTF-8', LastName = 'User', FirstName = 'Stakeholder', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = [select Id from Profile where Name = 'System Administrator'
            limit 1
        ].Id, TimeZoneSidKey = 'America/Chicago', Username = 'stakeholder@mico-test' + Math.round(Math.random() * 10000) + '.com', UserRoleId = null, Country = 'Great Britain');
        insert stakeholderUser;
        // app
        app = new MICO_App__c();
        app.Name = 'mico-app';
        app.System_Custodian__c = stakeholderUser.Id;
        app.System_Owner__c = stakeholderUser.Id;
        app.Business_Quality__c = stakeholderUser.Id;
        app.Computer_Systems_Quality__c = stakeholderUser.Id;
        insert app;
        System.assert(app.id != null);
        // project
        MICO_Project__c project = new MICO_Project__c();
        project.Name = 'mico-project';
        insert project;
        System.assert(project.id != null);
        story = new MICO_User_Story__c();
        story.Project__c = project.Id;
        story.App__c = app.Id;
        insert story;
        System.assert(story.id != null);
    }
    public static testMethod void test_productActions()
        {
            MICO_User_Story__c testRequirement = new MICO_User_Story__c();
            MICO_Project__c testProject = new MICO_Project__c();
            testProject.Name = 'TestProject';
            insert TestProject;
            testRequirement.Project__c = TestProject.id;
            testRequirement.Acceptance_Criteria__c = 'OldAcceptanceCriteria';
            testRequirement.Compliance_Criteria__c = 'OldCC';
            insert testRequirement;
            testRequirement.Acceptance_Criteria__c = 'NewAcceptanceCriteria';
            testRequirement.Compliance_Criteria__c = 'NewCC';
            update testRequirement;
            MICO_AC_History__c newlyCreatedACHistoryRecord = [Select Acceptance_Criteria__c from MICO_AC_History__c
                where User_Story__c = : testRequirement.id
                ORDER BY SystemModStamp DESC NULLS LAST
                LIMIT 1
            ];
            System.assertEquals('OldAcceptanceCriteria', newlyCreatedACHistoryRecord.Acceptance_Criteria__c);
        }
        /**
         * test that the stakeholder fields from the app are propagated through
         * when left blank in the user story record
         */
    public static testMethod void testPopulateAppStakeholders()
    {
        createStory();
        // now run the test
        test.startTest();
        story = ([SELECT Id, System_Custodian__c, System_Owner__c, Compliance_Owner__c, Computer_Systems_Quality__c
            FROM MICO_User_Story__c
            WHERE Id = : story.Id
            LIMIT 1
        ])[0];
        System.assertEquals(app.System_Custodian__c, story.System_Custodian__c);
        System.assertEquals(app.System_Owner__c, story.System_Owner__c);
        System.assertEquals(app.Business_Quality__c, story.Compliance_Owner__c);
        System.assertEquals(app.Computer_Systems_Quality__c, story.Computer_Systems_Quality__c);
        test.stopTest();
    }
    public static testMethod void testcreateNewACHistoryRecord()
    {
        createStory();
        Map < Id, String > mapStoryACHistory = new Map < Id, String > ();
        mapStoryACHistory.put(story.id, 'Test');
        Map < Id, String > mapStoryCCHistory = new Map < Id, String > ();
        mapStoryCCHistory.put(story.id, 'Test');
        UserStoryTriggerClass.createNewACHistoryRecord(mapStoryACHistory, mapStoryACHistory);
    }
    public static testMethod void testcreateNewApprovalHistoryRecord()
    {
        createStory();
        story.So_that__c = 'Test';
        story.I_Want_To__c = 'test';
        story.As_A_text__c = 'Test';
        story.Approval_Status__c = 'Open';
        story.System_Owner__c = UserInfo.getUserId();
        story.Compliance_Owner__c = UserInfo.getUserId();
        story.Computer_Systems_Quality__c = UserInfo.getUserId();
        story.System_Custodian__c = UserInfo.getUserId();
        update story;
        System.assert(story.id != null);
        Map < Id, MICO_User_Story__c > mapStoryFields = new Map < Id, MICO_User_Story__c > ();
        mapStoryFields.put(story.id, story);
        UserStoryTriggerClass.createNewApprovalHistoryRecord(mapStoryFields);
    }
}