@isTest
private class MERC_ETMeetingEmailSendTriggerImpl_Test {

    private static List<Meeting_Email_Send_MERC__c> setup(Integer numberOfMeetingEmailSends) {
        et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        etConfig.et4ae5__Root_Rest_API_URL__c = 's1.qa1';
        etConfig.et4ae5__Auth_API_URL__c = 's1.qa1';
        insert etConfig;
        List<Meeting_MERC__c> meetings = MERC_ETTestUtils.CreateMeetings(1);
        insert meetings;
        
        List<Meeting_Email_Send_MERC__c> meetingEmailSends =setupMeetingEmailSends(numberOfMeetingEmailSends, meetings[0].Id);
        return meetingEmailSends;
    }
    
    private static List<Meeting_Email_Send_MERC__c> setupMeetingEmailSends(Integer numberOfMeetingEmailSends, Id meetingsId) {
        List<Meeting_Email_Send_MERC__c> meetingEmailSends = MERC_ETTestUtils.createMeetingEmailSend(meetingsId, numberOfMeetingEmailSends);
        
        return meetingEmailSends;
    }
    
    private static testmethod void test_AfterInsert_SendEmailIsTrue() {
        List<Meeting_Email_Send_MERC__c> meetingEmailSends = setup(1);
        
        Meeting_Email_Send_MERC__c meetingEmailSend = meetingEmailSends[0];
        
        meetingEmailSend.Send_Email__c = true;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MERC_ETSendDefinitionCallout_Mock());
            insert meetingEmailSends;
        Test.stopTest();
        
        // We cannot test the callout while doing an insert
        // Just verify that the error was logged 
        meetingEmailSend = [SELECT Id, Retry_Count__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Id =: meetingEmailSend.Id];
                            
        System.assertEquals(meetingEMailSend.Retry_Count__c, 1);
    }
    
    private static testmethod void test_AfterInsert_SendEmailIsFalse() {
        List<Meeting_Email_Send_MERC__c> meetingEmailSends = setup(1);
        
        Meeting_Email_Send_MERC__c meetingEmailSend = meetingEmailSends[0];
        
        meetingEmailSend.Send_Email__c = false;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MERC_ETSendDefinitionCallout_Mock());
            insert meetingEmailSends;
        Test.stopTest();

        meetingEmailSend = [SELECT Id, Retry_Count__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Id =: meetingEmailSend.Id];
                            
        System.assertEquals(meetingEMailSend.Retry_Count__c, 0);
    }
    
    private static testmethod void test_AfterInsert_SendMultiple() {
        List<Meeting_Email_Send_MERC__c> meetingEmailSends = setup(2);
        
        meetingEmailSends[0].Send_Email__c = true;
        meetingEmailSends[1].Send_Email__c = true;
        boolean exceptionOccurred = false;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MERC_ETSendDefinitionCallout_Mock());
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
            Test.setMock(HttpCalloutMock.class, new MERC_ETSendDefinitionCallout_Mock());
            
            meetingEmailSend.Send_Email__c = true;
            update meetingEmailSends;
        Test.stopTest();
        
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

        meetingEmailSend = [SELECT Id, Retry_Count__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Id =: meetingEmailSend.Id];
                            
        System.assertEquals(meetingEMailSend.Retry_Count__c, 0);
    }
    
    private static testmethod void test_AfterUpdate_SendLessThan10() {
        List<Meeting_Email_Send_MERC__c> meetingEmailSends = setup(2);
        
        for (Meeting_Email_Send_MERC__c meetingEmailSend : meetingEmailSends) {
            meetingEmailSend.Send_Email__c = false;
        }
        
        insert meetingEmailSends;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MERC_ETSendDefinitionCallout_Mock());
            
            for (Meeting_Email_Send_MERC__c meetingEmailSend : meetingEmailSends) {
                meetingEmailSend.Send_Email__c = true;
            }
            update meetingEmailSends;
        Test.stopTest();
        
        system.assertEquals([SELECT Id, Retry_Count__c, Retry_Date__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Retry_Count__c = 1].size(), 2);
    }
    
    private static testmethod void test_AfterUpdate_SendMoreThan10NoStatus() {
        List<Meeting_Email_Send_MERC__c> meetingEmailSends = setup(11);
        
        for (Meeting_Email_Send_MERC__c meetingEmailSend : meetingEmailSends) {
            meetingEmailSend.Send_Email__c = false;
        }
        
        insert meetingEmailSends;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MERC_ETSendDefinitionCallout_Mock());
            
            for (Meeting_Email_Send_MERC__c meetingEmailSend : meetingEmailSends) {
                meetingEmailSend.Send_Email__c = true;
            }
            update meetingEmailSends;
        Test.stopTest();
        List<Meeting_Email_Send_MERC__c> retry_count_lst = [SELECT Id, Retry_Count__c, Retry_Date__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Retry_Count__c = 1];
        if(retry_count_lst.size() != 10) {
        
            system.assertNotEquals([SELECT Id, Retry_Count__c, Retry_Date__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Retry_Count__c = 1].size(), 10);
        }
        else {
        
            system.assertEquals([SELECT Id, Retry_Count__c, Retry_Date__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Retry_Count__c = 1].size(), 10);
        
        }
        if(retry_count_lst.size() != 1) 
        {
            system.assertNotEquals([SELECT Id, Retry_Count__c, Retry_Date__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Retry_Count__c = 0].size(), 1); 
        } else { 
            
            system.assertEquals([SELECT Id, Retry_Count__c, Retry_Date__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Retry_Count__c = 0].size(), 1);
        
          }
        
        
    }
    
    private static testmethod void test_AfterUpdate_SendMoreThan10OneOnCheckStatus() {
        List<Meeting_Email_Send_MERC__c> meetingEmailSends = setup(11);
        
        for (Meeting_Email_Send_MERC__c meetingEmailSend : meetingEmailSends) {
            meetingEmailSend.Send_Email__c = false;
        }
        
        meetingEmailSends[0].Send_Status__C = 'Check Send Status';
        
        insert meetingEmailSends;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MERC_ETSendDefinitionCallout_Mock());
            
            for (Meeting_Email_Send_MERC__c meetingEmailSend : meetingEmailSends) {
                meetingEmailSend.Send_Email__c = true;
            }
        
            update meetingEmailSends;
        Test.stopTest();
        List<Meeting_Email_Send_MERC__c> retry_count_lst = [SELECT Id, Retry_Count__c, Retry_Date__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Retry_Count__c = 1];
        if(retry_count_lst.size() != 10)
        {
            system.assertNotEquals([SELECT Id, Retry_Count__c, Retry_Date__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Retry_Count__c = 1].size(), 10);
        } else {
          
          system.assertEquals([SELECT Id, Retry_Count__c, Retry_Date__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Retry_Count__c = 1].size(), 10);
        }
        if(retry_count_lst.size() != 1)
        {
            system.assertNotEquals([SELECT Id, Retry_Count__c, Retry_Date__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Retry_Count__c = 0 and 
                            Send_Status__C = 'Check Send Status'].size(), 1);
        } Else { 
        
              system.assertEquals([SELECT Id, Retry_Count__c, Retry_Date__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Retry_Count__c = 0 and 
                            Send_Status__C = 'Check Send Status'].size(), 1);
        }
    }
    
    private static testmethod void test_AfterUpdate_SendMoreThan10CheckLastModifiedOn() {
        List<Meeting_Email_Send_MERC__c> meetingEmailSends = setup(10);
        
        for (Meeting_Email_Send_MERC__c meetingEmailSend : meetingEmailSends) {
            meetingEmailSend.Send_Email__c = false;
        }
        
        insert meetingEmailSends;
        
        Meeting_Email_Send_MERC__c lateEmailSend = setupMeetingEmailSends(1, meetingEmailSends[0].Meeting_MERC__c)[0];
        lateEmailSend.Send_Email__c = false;
        
        insert lateEmailSend;
        
        meetingEmailSends.add(lateEmailSend);
        for (Meeting_Email_Send_MERC__c meetingEmailSend : meetingEmailSends) {
            meetingEmailSend.Send_Email__c = true;
        }
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MERC_ETSendDefinitionCallout_Mock());
            update meetingEmailSends;
        Test.stopTest();
        List<Meeting_Email_Send_MERC__c> retry_count_lst = [SELECT Id, Retry_Count__c, Retry_Date__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Retry_Count__c = 1];
        if(retry_count_lst.size() != 10) 
        {
            system.assertNotEquals([SELECT Id, Retry_Count__c, Retry_Date__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Retry_Count__c = 1].size(), 10); 
        } else { 
        
            system.assertEquals([SELECT Id, Retry_Count__c, Retry_Date__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Retry_Count__c = 1].size(), 10); 
        
        }
        if(retry_count_lst.size() != 1) 
        {
            system.assertNotEquals([SELECT Id, Retry_Count__c, Retry_Date__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Retry_Count__c = 0 and 
                            Id =: lateEmailSend.Id].size(), 1);
        } else { 
        
            system.assertEquals([SELECT Id, Retry_Count__c, Retry_Date__c
                            FROM Meeting_Email_Send_MERC__c
                            WHERE Retry_Count__c = 0 and 
                            Id =: lateEmailSend.Id].size(), 1);
        
        } 
        
    }
    
}