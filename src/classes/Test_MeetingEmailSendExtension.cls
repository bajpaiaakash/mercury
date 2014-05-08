@isTest
private class Test_MeetingEmailSendExtension {
    @isTest
    public static void Test_Constructor() {
        Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];
        insert meeting;

        Sonoma_ET_Config__c config = TestUtils.CreateConfig();
        insert config;

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

        Test.startTest();
        MeetingEmailSendExtension ext = new MeetingEmailSendExtension(controller);
        Test.stopTest();

        System.assertEquals(false, ext.getHasErrors());
    }

    @isTest
    public static void Test_Constructor_NoMeeting() {
        Sonoma_ET_Config__c config = TestUtils.CreateConfig();
        insert config;

        Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];

        ApexPages.StandardController controller = new ApexPages.StandardController(meeting);

        Test.startTest();
        MeetingEmailSendExtension ext = new MeetingEmailSendExtension(controller);
        Test.stopTest();

        System.assertEquals(true, ext.getHasErrors());
    }

    @isTest
    public static void Test_SelectAllClicked() {
        Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];
        insert meeting;

        Sonoma_ET_Config__c config = TestUtils.CreateConfig();
        insert config;

        ApexPages.StandardController controller = new ApexPages.StandardController(null);
        MeetingEmailSendExtension ext = new MeetingEmailSendExtension(controller);

        List<Account> accts = TestUtils.CreatePersonAccounts(100);
        insert accts;

        
    }
}