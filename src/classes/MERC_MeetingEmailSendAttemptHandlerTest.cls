/*
* MERC_MarketingCloudServiceTest
* Description : Test for MERC_MeetingEmailSendAttemptHandler
* Authors: David Helmer
*/
@isTest
public class MERC_MeetingEmailSendAttemptHandlerTest {
    @testSetup static void prepareConfiguration(){
        MERC_MarketingCloudTestUtility.insertConfiguration(true);
        MERC_MarketingCloudTestUtility.insertBusinessUnit();
        MERC_MarketingCloudTestUtility.insertSettings();
    }

    @isTest static void test_MeetingEmailSendInsert_CreatesSendDefinitionAndRetries(){  
        User testUser = MERC_MarketingCloudTestUtility.getUser();
        insert testUser;
        System.runAs(testUser){
            MERC_TestFactory.adjustForSFDCSetMockBug = true;
            MERC_MarketingCloudTestUtility.adjustTime();
            Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
            Meeting_Email_Send_MERC__c meetingEmailSend = MERC_MarketingCloudTestUtility.getMeetingEmailSend(meeting.Id);


            meetingEmailSend.Send_Email__c = true;
            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
            MERC_MarketingCloudTestUtility.MockSendDefinitionRequests(mockResponseService);
            Test.setMock(HttpCalloutMock.class, mockResponseService);

            Test.startTest();

            insert meetingEmailSend;

            Test.stopTest();

            Meeting_Email_Send_MERC__c meetingEmailSendAfter = [SELECT Id,
                                                                       Retry_Count__c,
                                                                       Retry_Date__c,
                                                                       Send_Status__c
                                                                  FROM Meeting_Email_Send_MERC__c
                                                                 WHERE Id = :meetingEmailSend.Id
                                                                 LIMIT 1][0];
            System.assertEquals(MERC_MarketingCloudService.CreateSendDefinition, meetingEmailSendAfter.Send_Status__c);
            System.assertEquals(1, meetingEmailSendAfter.Retry_Count__c);
        }
    }

    @isTest static void test_MeetingEmailSendInsertSendEmailFalse_DoesNothing(){  
        User testUser = MERC_MarketingCloudTestUtility.getUser();
        insert testUser;
        System.runAs(testUser){
            MERC_TestFactory.adjustForSFDCSetMockBug = true;
            MERC_MarketingCloudTestUtility.adjustTime();
            Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
            Meeting_Email_Send_MERC__c meetingEmailSend = MERC_MarketingCloudTestUtility.getMeetingEmailSend(meeting.Id);

            meetingEmailSend.Send_Email__c = false;

            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
            MERC_MarketingCloudTestUtility.MockSendDefinitionRequests(mockResponseService);
            Test.setMock(HttpCalloutMock.class, mockResponseService);


            Test.startTest();

            insert meetingEmailSend;

            Test.stopTest();

            Meeting_Email_Send_MERC__c meetingEmailSendAfter = [SELECT Id,
                                                                       Retry_Count__c,
                                                                       Retry_Date__c,
                                                                       Send_Status__c
                                                                  FROM Meeting_Email_Send_MERC__c
                                                                 WHERE Id = :meetingEmailSend.Id
                                                                 LIMIT 1][0];
            System.assertEquals(null, meetingEmailSendAfter.Send_Status__c);
            System.assertEquals(0, meetingEmailSendAfter.Retry_Count__c);
        }
    }

    @isTest static void test_MeetingEmailSendUpdateSendEmailTrue_CreatesSendDefinitionAndRetries(){  
        User testUser = MERC_MarketingCloudTestUtility.getUser();
        insert testUser;
        System.runAs(testUser){
            MERC_TestFactory.adjustForSFDCSetMockBug = true;
            MERC_MarketingCloudTestUtility.adjustTime();
            Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();
            Meeting_Email_Send_MERC__c meetingEmailSend = MERC_MarketingCloudTestUtility.getMeetingEmailSend(meeting.Id);

            meetingEmailSend.Send_Email__c = false;

            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
            MERC_MarketingCloudTestUtility.MockSendDefinitionRequests(mockResponseService);
            Test.setMock(HttpCalloutMock.class, mockResponseService);

            insert meetingEmailSend;

            meetingEmailSend.Retry_Date__c = DateTime.now();
            meetingEmailSend.Send_Email__c = true;
            meetingEmailSend.Send_Status__c = null;

            Test.startTest();

            update meetingEmailSend;

            Test.stopTest();

            Meeting_Email_Send_MERC__c meetingEmailSendAfter = [SELECT Id,
                                                                       Retry_Count__c,
                                                                       Retry_Date__c,
                                                                       Send_Status__c
                                                                  FROM Meeting_Email_Send_MERC__c
                                                                 WHERE Id = :meetingEmailSend.Id
                                                                 LIMIT 1][0];
            System.assertEquals(MERC_MarketingCloudService.CreateSendDefinition, meetingEmailSendAfter.Send_Status__c);
            System.assertEquals(1, meetingEmailSendAfter.Retry_Count__c);
        }
    }

    @isTest static void test_3MeetingEmailSendsInserted_1CreateSendDefinition(){  
        User testUser = MERC_MarketingCloudTestUtility.getUser();
        insert testUser;
        System.runAs(testUser){
            MERC_TestFactory.adjustForSFDCSetMockBug = true;
            MERC_MarketingCloudTestUtility.adjustTime();
            Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();

            List<Meeting_Email_Send_MERC__c> meetingEmailSends = new List<Meeting_Email_Send_MERC__c>();
            for(Integer index = 0; index < 3; index++){
                Meeting_Email_Send_MERC__c meetingEmailSend = MERC_MarketingCloudTestUtility.getMeetingEmailSend(meeting.Id);
                meetingEmailSend.Send_Email__c = true;
                meetingEmailSends.add(meetingEmailSend);
            }

            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
            MERC_MarketingCloudTestUtility.MockSendDefinitionRequests(mockResponseService);
            Test.setMock(HttpCalloutMock.class, mockResponseService);

            Test.startTest();

            insert meetingEmailSends;

            Test.stopTest();

            List<Meeting_Email_Send_MERC__c> meetingEmailSendsAfter = [SELECT Id,
                                                                       Retry_Count__c,
                                                                       Retry_Date__c,
                                                                       Send_Status__c
                                                                  FROM Meeting_Email_Send_MERC__c
                                                                 WHERE Id IN :meetingEmailSends];
            Integer numberSent = 0;
            Integer numberRetrying = 0;
            for(Meeting_Email_Send_MERC__c meetingEmailSend : meetingEmailSendsAfter){
                if(meetingEmailSend.Send_Status__c == MERC_MarketingCloudService.CreateSendDefinition){
                    numberSent++;
                } else if(meetingEmailSend.Retry_Count__c == 1 && meetingEmailSend.Retry_Date__c != null){
                    numberRetrying++;
                }
            }
            
            System.assertEquals(2, numberRetrying);

            System.assertEquals(1, numberSent);
        }
    }

    @isTest static void test_13MeetingEmailSendsInserted_10CreateSendDefinition(){  
        User testUser = MERC_MarketingCloudTestUtility.getUser();
        insert testUser;
        System.runAs(testUser){
            MERC_TestFactory.adjustForSFDCSetMockBug = true;
            MERC_MarketingCloudTestUtility.adjustTime();
            Meeting_MERC__c meeting = MERC_MarketingCloudTestUtility.insertMeeting();

            List<Meeting_Email_Send_MERC__c> meetingEmailSends = new List<Meeting_Email_Send_MERC__c>();
            for(Integer index = 0; index < 13; index++){
                Meeting_Email_Send_MERC__c meetingEmailSend = MERC_MarketingCloudTestUtility.getMeetingEmailSend(meeting.Id);
                meetingEmailSend.Send_Email__c = false;
                meetingEmailSends.add(meetingEmailSend);
            }
            insert meetingEmailSends;

            for(Meeting_Email_Send_MERC__c meetingEmailSend : meetingEmailSends){
                meetingEmailSend.Send_Email__c = true;
            }

            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
            MERC_MarketingCloudTestUtility.MockSendDefinitionRequests(mockResponseService);
            Test.setMock(HttpCalloutMock.class, mockResponseService);

            Test.startTest();

            update meetingEmailSends;

            Test.stopTest();

            List<Meeting_Email_Send_MERC__c> meetingEmailSendsAfter = [SELECT Id,
                                                                       Retry_Count__c,
                                                                       Retry_Date__c,
                                                                       Send_Status__c
                                                                  FROM Meeting_Email_Send_MERC__c
                                                                 WHERE Id IN :meetingEmailSends];
            Integer numberSent = 0;
            Integer numberRetrying = 0;
            for(Meeting_Email_Send_MERC__c meetingEmailSend : meetingEmailSendsAfter){
                if(meetingEmailSend.Send_Status__c == MERC_MarketingCloudService.CreateSendDefinition){
                    numberSent++;
                } else if(meetingEmailSend.Retry_Count__c == 1 && meetingEmailSend.Retry_Date__c != null){
                    numberRetrying++;
                }
            }
            
            System.assertEquals(3, numberRetrying);

            System.assertEquals(10, numberSent);
        }
    }
}