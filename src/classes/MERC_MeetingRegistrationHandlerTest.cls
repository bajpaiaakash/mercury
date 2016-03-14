@isTest
private class MERC_MeetingRegistrationHandlerTest {
    @testSetup static void prepareConfiguration(){
        MERC_MarketingCloudTestUtility.insertConfiguration(true);
        MERC_MarketingCloudTestUtility.insertBusinessUnit();
        MERC_MarketingCloudTestUtility.insertSettings();
    }

    @isTest static void test_sendMeetingRegistrationConfirmations(){
        MERC_TriggerHandlerStateManager.deactivateAll();
        User testUser = MERC_MarketingCloudTestUtility.getUser();
        insert testUser;
        Meeting_MERC__c meeting = null;
        List<Account> personAccounts = null;
        List<Meeting_Participant_MERC__c> participants = null;

        System.runAs(testUser){
            MERC_TestFactory.adjustForSFDCSetMockBug = true;
            MERC_MarketingCloudTestUtility.adjustTime();
            meeting = MERC_MarketingCloudTestUtility.insertMeeting();
            personAccounts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType(
                MERC_MarketingCloudTestUtility.RECORD_TYPE_STRING_HCP, 1);
            personAccounts[0].Country_of_Residence_GLBL__c = 'GB';
            insert personAccounts;

            participants = MERC_ETTestUtils.CreateParticipants(meeting, personAccounts);
            for(Meeting_Participant_MERC__c participant : participants){
                participant.Status_MERC__c = 'Invited';
            }
            insert participants;

            MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.MockRequestsForRegistrationConfirmationSend(
                testUser,
                meeting,
                participants,
                personAccounts);
            mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetEmailFoldersAllRequest());  
            mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetMyEmailsFolderRequest('8'));  
            mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getMockGetGBEmailsRequest('10')); 
            mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getClassificationsRequest());  
            Test.setMock(HttpCalloutMock.class, mockResponseService);

            Test.startTest();
            
            Meeting_Participant_MERC__c participant = participants[0];
            participant.Status_MERC__c = 'Accepted';
            participant.WS_Updt_Dt_MERC__c = Date.today();
            update participant;

            Test.stopTest();

            Meeting_Email_Send_MERC__c meetingEmailSend = [SELECT Id,
                                                                  Send_Status__c 
                                                             FROM Meeting_Email_Send_MERC__c
                                                            WHERE Meeting_MERC__c = :meeting.Id
                                                            LIMIT 1][0];
            System.assertEquals(MERC_MarketingCloudService.CreateSenderProfile, meetingEmailSend.Send_Status__c);
        }
    }
}