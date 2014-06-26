@isTest
private class Test_MeetingEmailSendFutureProcessor {

    private static Meeting_Email_Send_MERC__c setup() {
        et4ae5__configuration__c etConfig = TestUtils.CreateEtConfig();
        etConfig.et4ae5__Root_Rest_API_URL__c = 's1.qa1';
        etConfig.et4ae5__Auth_API_URL__c = 'www.testauthurl.com/Auth.svc';
        insert etConfig;
        
        MERC_TriggerHandlerStateManager.deactivate(MERC_PrimaryMeetingOwnerHandler.class);
        List<Meeting_MERC__c> meetings = TestUtils.CreateMeetings(1);
        insert meetings;
        
        Meeting_Email_Send_MERC__c meetingEmailSend = TestUtils.createMeetingEmailSend(meetings[0].Id, 1)[0];
        
        setupMeetingEmailSends(meetingEmailSend);
        return meetingEmailSend;
    }
    
    private static void setupMeetingEmailSends(Meeting_Email_Send_MERC__c meetingEmailSend) {
        meetingEmailSend.ET_From_Name_MERC__c = 'Eli Lilly';
        meetingEmailSend.ET_From_Email_MERC__c = 'cmseurope@lilly.com';
        meetingEmailSend.ET_Dedupe_Subscribers_MERC__c = false;
        meetingEmailSend.ET_Email_ID_MERC__c = '1234';
        meetingEmailSend.ET_Subject_MERC__c = 'Test Subject';
        //Set Send Email to false to avoid triggering the callout in the trigger
        meetingEmailSend.Send_Email__c = false;
    }
    
    private static void testOneStepSendError(string sendStatus) {
    	Meeting_Email_Send_MERC__c meetingEmailSend = setup();

        meetingEmailSend.Send_Status__c = sendStatus;
        insert meetingEmailSend;
        
        Mock_ETSendAndAuthorize mockSend = new Mock_ETSendAndAuthorize();
        mockSend.returnError = true;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, mockSend);
            MeetingEmailSendFutureProcessor.handleSendDefinitionProcessForMeetingEmailSend(meetingEmailSend.Id);
        Test.stopTest();
       
        meetingEmailSend = [SELECT Retry_Date__c, Email_Send_Number_MERC__c, Send_Status__c
                            FROM Meeting_Email_Send_MERC__c 
                            WHERE Id=: meetingEmailSend.Id];
                            
        system.assertNotEquals(meetingEmailSend.Retry_Date__c, null);
        system.assertEquals(meetingEmailSend.Email_Send_Number_MERC__c, null);
        system.assertEquals(meetingEmailSend.Send_Status__c, sendStatus);
    }
    
    private static testmethod void test_MeetingEmailSendFutureProcessor_sendSuccesfully() {
        Meeting_Email_Send_MERC__c meetingEmailSend = setup();

        insert meetingEmailSend;
        
        Mock_ETSendAndAuthorize mockSend = new Mock_ETSendAndAuthorize();
        mockSend.sendCheckStatusResponseComplete = true;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, mockSend);
            MeetingEmailSendFutureProcessor.handleSendDefinitionProcessForMeetingEmailSend(meetingEmailSend.Id);
        Test.stopTest();
       
        meetingEmailSend = [SELECT Incomplete_MERC__c, Retry_Date__c, Email_Send_Number_MERC__c, Send_Status__c
                            FROM Meeting_Email_Send_MERC__c 
                            WHERE Id=: meetingEmailSend.Id];
                            
        system.assertEquals(meetingEmailSend.Incomplete_MERC__c, false);
        system.assertEquals(meetingEmailSend.Retry_Date__c, null);
        system.assertNotEquals(meetingEmailSend.Email_Send_Number_MERC__c, null);
        system.assertEquals(meetingEmailSend.Send_Status__c, 'Email Send Created');
    }
    
    public static testmethod void test_MeetingEmailSendFutureProcessor_checkSendStatusStillProcessing() {
    	Meeting_Email_Send_MERC__c meetingEmailSend = setup();

        meetingEmailSend.Send_Status__c = 'Check Send Status';
        meetingEmailSend.ET_Send_Definition_MERC__c = 'abc';
        insert meetingEmailSend;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Mock_ETSendAndAuthorize());
            MeetingEmailSendFutureProcessor.handleSendDefinitionProcessForMeetingEmailSend(meetingEmailSend.Id);
        Test.stopTest();
       
        meetingEmailSend = [SELECT Incomplete_MERC__c, Retry_Date__c, Email_Send_Number_MERC__c, Send_Status__c
                            FROM Meeting_Email_Send_MERC__c 
                            WHERE Id=: meetingEmailSend.Id];
                            
        system.assertEquals(meetingEmailSend.Incomplete_MERC__c, false);
        system.assertNotEquals(meetingEmailSend.Retry_Date__c, null);
        system.assertNotEquals(meetingEmailSend.Email_Send_Number_MERC__c, null);
        system.assertEquals(meetingEmailSend.Send_Status__c, 'Check Send Status');
    }
    
    public static testmethod void test_MeetingEmailSendFutureProcessor_checkSendStatusCompleteExistingETSEnd() {
        Meeting_Email_Send_MERC__c meetingEmailSend = setup();

        meetingEmailSend.Send_Status__c = 'Check Send Status';
        meetingEmailSend.ET_Send_Definition_MERC__c = 'abc';
        insert meetingEmailSend;
        
        et4ae5__SendDefinition__c send = new et4ae5__SendDefinition__c();
        send.et4ae5__SyncComplete__c = true;
        send.et4ae5__TrackingOnly__c = true;
        send.et4ae5__FromName__c = meetingEmailSend.ET_From_Name_MERC__c;
        send.et4ae5__FromEmail__c = meetingEmailSend.ET_From_Email_MERC__c;
        send.et4ae5__DedupeSubscribers__c = meetingEmailSend.ET_Dedupe_Subscribers_MERC__c;
        send.et4ae5__EmailId__c = meetingEmailSend.ET_Email_ID_MERC__c;
        send.et4ae5__Subject__c = meetingEmailSend.ET_Subject_MERC__c;
        send.et4ae5__ETSendDef__c = meetingEmailSend.ET_Send_Definition_MERC__c;
        
        insert send;
        
        meetingEmailSend.Email_Send_Number_MERC__c = send.Id;
        
        update meetingEmailSend;
        Mock_ETSendAndAuthorize mockSend = new Mock_ETSendAndAuthorize();
        mockSend.sendCheckStatusResponseComplete = true;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, mockSend);
            MeetingEmailSendFutureProcessor.handleSendDefinitionProcessForMeetingEmailSend(meetingEmailSend.Id);
        Test.stopTest();
       
        send = [SELECT Id, et4ae5__SendStatus__c FROM et4ae5__SendDefinition__c where Id =: send.Id];
        
        system.assertEquals(send.et4ae5__SendStatus__c, 'Completed');
    }
    
    public static testmethod void test_MeetingEMailSendFutureProcessor_hitMaxRetry() {
    	Meeting_Email_Send_MERC__c meetingEmailSend = setup();

        meetingEmailSend.Retry_Count__c = 1;
        insert meetingEmailSend;
        
        Mock_ETSendAndAuthorize mockSend = new Mock_ETSendAndAuthorize();
        mockSend.returnError = true;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, mockSend);
            MeetingEmailSendFutureProcessor.handleSendDefinitionProcessForMeetingEmailSend(meetingEmailSend.Id);
        Test.stopTest();
       
        meetingEmailSend = [SELECT Incomplete_MERC__c, Retry_Date__c, Email_Send_Number_MERC__c, Send_Status__c
                            FROM Meeting_Email_Send_MERC__c 
                            WHERE Id=: meetingEmailSend.Id];
                            
        system.assertEquals(meetingEmailSend.Incomplete_MERC__c, true);
        system.assertEquals(meetingEmailSend.Retry_Date__c, null);
        system.assertEquals(meetingEmailSend.Email_Send_Number_MERC__c, null);
        system.assertEquals(meetingEmailSend.Send_Status__c, 'Create Sender Profile');
    }
    
    public static testmethod void test_MeetingEMailSendFutureProcessor_hitMaxRetryCheckSendStatus() {
        Meeting_Email_Send_MERC__c meetingEmailSend = setup();

        meetingEmailSend.Retry_Count__c = 298;
        meetingEMailSend.Send_Status__c = 'Check Send Status';
        insert meetingEmailSend;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Mock_ETSendAndAuthorize());
            MeetingEmailSendFutureProcessor.handleSendDefinitionProcessForMeetingEmailSend(meetingEmailSend.Id);
        Test.stopTest();
       
        meetingEmailSend = [SELECT Incomplete_MERC__c, Retry_Date__c, Email_Send_Number_MERC__c, Send_Status__c
                            FROM Meeting_Email_Send_MERC__c 
                            WHERE Id=: meetingEmailSend.Id];
                            
        system.assertEquals(meetingEmailSend.Incomplete_MERC__c, true);
        system.assertEquals(meetingEmailSend.Retry_Date__c, null);
        system.assertEquals(meetingEmailSend.Email_Send_Number_MERC__c, null);
        system.assertEquals(meetingEmailSend.Send_Status__c, 'Check Send Status');
    }
    
    public static testmethod void test_MeetingEmailSendFutureProcessor_errorOnCreateSenderProfile() {
    	testOneStepSendError('Create Sender Profile');
    }
    
    public static testmethod void test_MeetingEmailSendFutureProcessor_errorOnCreateSendDefinition() {
        testOneStepSendError('Create Send Definition');
    }
    
    public static testmethod void test_MeetingEmailSendFutureProcessor_errorOnCreateStartSendDefinition() {
        testOneStepSendError('Start Send Definition');
    }
    
    public static testmethod void test_MeetingEmailSendFutureProcessor_errorOnCreateCheckSendStatus() {
        testOneStepSendError('Check Send Status');
    }
    
    //Disable this test as the functionality is disabled
    //public static testmethod void test_MeetingEmailSendFutureProcessor_copyAttachments() {
        //Meeting_Email_Send_MERC__c meetingEmailSend = setup();

        //meetingEmailSend.Send_Status__c = 'Check Send Status';
        //meetingEmailSend.ET_Send_Definition_MERC__c = 'abc';
        //insert meetingEmailSend;	
        
        //Attachment emailSendAttachment = new Attachment();
	    //emailSendAttachment.ParentId = meetingEmailSend.Id;
	    //emailSendAttachment.Body = Blob.valueOf('abc');
	    //emailSendAttachment.Name = 'Attachment';
	    
	    //insert emailSendAttachment;
	    
	    //Test.startTest();
            //Test.setMock(HttpCalloutMock.class, new Mock_ETSendAndAuthorize());
            //MeetingEmailSendFutureProcessor.handleSendDefinitionProcessForMeetingEmailSend(meetingEmailSend.Id);
        //Test.stopTest();
        
        //meetingEmailSend = [SELECT Email_Send_Number_MERC__c FROM Meeting_Email_Send_MERC__c WHERE Id =: meetingEmailSend.Id];
        
        //List<Attachment> emailSendAttachments = [SELECT Id FROM Attachment WHERE ParentId =: meetingEmailSend.Email_Send_Number_MERC__c];
                
        //system.assertEquals(emailSendAttachments.size(), 1);
    //}
    
}