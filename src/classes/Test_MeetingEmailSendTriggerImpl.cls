@isTest
private class Test_MeetingEmailSendTriggerImpl {
    
    private static List<Meeting_Email_Send_MERC__c> setup(Integer numberOfMeetingEmailSends) {
    	et4ae5__configuration__c etConfig = TestUtils.CreateEtConfig();
        etConfig.et4ae5__Root_Rest_API_URL__c = 's1.qa1';
        etConfig.et4ae5__Auth_API_URL__c = 's1.qa1';
        insert etConfig;
        
        List<Meeting_MERC__c> meetings = TestUtils.CreateMeetings(1);
        insert meetings;
        
        List<Meeting_Email_Send_MERC__c> meetingEmailSends = TestUtils.createMeetingEmailSend(meetings[0].Id, numberOfMeetingEmailSends);
        
        setupMeetingEmailSends(meetingEmailSends);
        return meetingEmailSends;
    }
    
    private static void setupMeetingEmailSends(List<Meeting_Email_Send_MERC__c> meetingEmailSends) {
    	for (Meeting_Email_Send_MERC__c meetingEmailSend : meetingEmailSends) {
    		meetingEmailSend.ET_From_Name_MERC__c = 'Eli Lilly';
    		meetingEmailSend.ET_From_Email_MERC__c = 'cmseurope@lilly.com';
    		meetingEmailSend.ET_Dedupe_Subscribers_MERC__c = false;
    		meetingEmailSend.ET_Email_ID_MERC__c = '1234';
    		meetingEmailSend.ET_Subject_MERC__c = 'Test Subject';
    	}
    }
    
    private static testmethod void test_AfterInsert_SendEmailIsTrue() {
    	List<Meeting_Email_Send_MERC__c> meetingEmailSends = setup(1);
    	
    	Meeting_Email_Send_MERC__c meetingEmailSend = meetingEmailSends[0];
    	
    	meetingEmailSend.Send_Email__c = true;

    	Test.startTest();
    	    Test.setMock(HttpCalloutMock.class, new Mock_ETSendDefinitionCallout());
    	    insert meetingEmailSends;
    	Test.stopTest();
    	system.debug('After Stop Test');
    	
    	// We cannot test the callout while doing an insert
    	// Just verify that the error was logged 
    	meetingEmailSend = [SELECT Id, Retry_Count__c
    	                    FROM Meeting_Email_Send_MERC__c
    	                    WHERE Id =: meetingEmailSend.Id];
    	                    
    	System.assertEquals(meetingEMailSend.Retry_Count__c, 1);
    }
    
    private static testmethod void test_AfterInsert_SendMultiple() {
        List<Meeting_Email_Send_MERC__c> meetingEmailSends = setup(2);
        
        meetingEmailSends[0].Send_Email__c = true;
        meetingEmailSends[1].Send_Email__c = true;
        boolean exceptionOccurred = false;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Mock_ETSendDefinitionCallout());
            try {
                insert meetingEmailSends;
            }
            catch (Exception e) {
            	exceptionOccurred = true;
            }
        Test.stopTest();

        System.assertEquals(exceptionOccurred, true);
    }
    
    private static testmethod void test_AfterUpdate_SendEmailsChanged() {
    List<Meeting_Email_Send_MERC__c> meetingEmailSends = setup(1);
        
        Meeting_Email_Send_MERC__c meetingEmailSend = meetingEmailSends[0];
        
        meetingEmailSend.Send_Email__c = false;
        insert meetingEmailSends;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Mock_ETSendDefinitionCallout());
            
            meetingEmailSend.Send_Email__c = true;
            update meetingEmailSends;
        Test.stopTest();
        system.debug('After Stop Test');
        
        // We cannot test the callout while doing an insert
        // Just verify that the error was logged 
        meetingEmailSend = [SELECT Id, Retry_Count__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Id =: meetingEmailSend.Id];
                            
        System.assertEquals(meetingEMailSend.Retry_Count__c, 1);
    }
    
    private static testmethod void test_AfterUpdate_SendEmailsDidNotChanged() {
    List<Meeting_Email_Send_MERC__c> meetingEmailSends = setup(1);
        
        Meeting_Email_Send_MERC__c meetingEmailSend = meetingEmailSends[0];
        
        meetingEmailSend.Send_Email__c = false;
        insert meetingEmailSends;
        
        Test.startTest();            
            meetingEmailSend.Send_Email__c = false;
            update meetingEmailSends;
        Test.stopTest();
        system.debug('After Stop Test');

        meetingEmailSend = [SELECT Id, Retry_Count__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Id =: meetingEmailSend.Id];
                            
        System.assertEquals(meetingEMailSend.Retry_Count__c, 0);
    }
    
    private static testmethod void test_AfterUpdate_SendMultiple() {
        List<Meeting_Email_Send_MERC__c> meetingEmailSends = setup(2);
        
        meetingEmailSends[0].Send_Email__c = false;
        meetingEmailSends[1].Send_Email__c = false;
        
        insert meetingEmailSends;
        
        boolean exceptionOccurred = false;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Mock_ETSendDefinitionCallout());
            
            meetingEmailSends[0].Send_Email__c = true;
            meetingEmailSends[1].Send_Email__c = true;
            try {
                update meetingEmailSends;
            }
            catch (Exception e) {
                exceptionOccurred = true;
            }
        Test.stopTest();

        System.assertEquals(exceptionOccurred, true);
    }
    
}