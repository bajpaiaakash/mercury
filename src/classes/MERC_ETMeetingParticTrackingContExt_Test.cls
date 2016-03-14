@isTest
private class MERC_ETMeetingParticTrackingContExt_Test {
    @testSetup static void prepareConfiguration(){
        MERC_MarketingCloudTestUtility.insertConfiguration(true);
        MERC_MarketingCloudTestUtility.insertBusinessUnit();
        MERC_MarketingCloudTestUtility.insertSettings();
    }

    @isTest
    static void test_no_individual_email_results() {
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        List<Account> accts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 1);
        insert accts;

        Meeting_Participant_MERC__c participant = MERC_ETTestUtils.CreateParticipants(meeting, accts)[0];
        insert participant;

        ApexPages.StandardController standardController = 
            new ApexPages.StandardController(participant);

        Test.startTest();
        MERC_ETMeetingParticipantTrackingContExt controllerExt = 
            new MERC_ETMeetingParticipantTrackingContExt(standardController);
        Test.stopTest();

        System.assertEquals(0, controllerExt.individualEmailResults.size());
        System.assertEquals(false, controllerExt.getHasErrors());
    }

    @isTest
    static void test_individual_email_results() {
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        List<Account> accts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 1);
        insert accts;
        Account personAccount = [SELECT PersonContactId FROM Account WHERE id =: accts[0].id];

        Meeting_Participant_MERC__c participant = MERC_ETTestUtils.CreateParticipants(meeting, accts)[0];
        insert participant;
        participant = 
            [SELECT Account_MERC__c, Meeting_Merc__c, Account_MERC__r.PersonContactId 
            FROM Meeting_Participant_MERC__c
            WHERE Id =: participant.id];

        List<et4ae5__SendDefinition__c> etSends = MERC_ETTestUtils.CreateETSend(1);
        insert etSends;

        List<et4ae5__IndividualEmailResult__c> etIndividualTrackings = MERC_ETTestUtils.CreateEtIndividualTrackingResult(personAccount.PersonContactId, etSends);
        insert etIndividualTrackings;

        List<Meeting_Email_Send_MERC__c> meetingJunctions = MERC_ETTestUtils.CreateMeetingEmailSend(meeting.id, etSends);
        insert meetingJunctions;

        List<Meeting_Participant_Email_Send_MERC__c> meetingParticipantJunctions = MERC_ETTestUtils.CreateMeetingParticipantEmailSend(participant.id, meetingJunctions);
        insert meetingParticipantJunctions;

        ApexPages.StandardController standardController = 
            new ApexPages.StandardController(participant);

        Test.startTest();
        MERC_ETMeetingParticipantTrackingContExt controllerExt = 
            new MERC_ETMeetingParticipantTrackingContExt(standardController);
        Test.stopTest();

        System.assertEquals(false, controllerExt.getHasErrors());
        System.assertEquals(1, controllerExt.individualEmailResults.size());
    }

    @isTest
    static void test_individual_email_results_bulk() {
        Meeting_MERC__c meeting = MERC_ETTestUtils.CreateMeetings(1)[0];
        insert meeting;

        List<Account> accts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 1);
        insert accts;
        Account personAccount = [SELECT PersonContactId FROM Account WHERE id =: accts[0].id];

        Meeting_Participant_MERC__c participant = MERC_ETTestUtils.CreateParticipants(meeting, accts)[0];
        insert participant;
        participant = 
            [SELECT Account_MERC__c, Meeting_Merc__c, Account_MERC__r.PersonContactId 
            FROM Meeting_Participant_MERC__c
            WHERE Id =: participant.id];


        List<et4ae5__SendDefinition__c> etSends = MERC_ETTestUtils.CreateETSend(201);
        insert etSends;

        List<et4ae5__IndividualEmailResult__c> etIndividualTrackings = MERC_ETTestUtils.CreateEtIndividualTrackingResult(personAccount.PersonContactId, etSends);
        insert etIndividualTrackings;

        List<Meeting_Email_Send_MERC__c> meetingJunctions = MERC_ETTestUtils.CreateMeetingEmailSend(meeting.id, etSends);
        insert meetingJunctions;

        List<Meeting_Participant_Email_Send_MERC__c> meetingParticipantJunctions = MERC_ETTestUtils.CreateMeetingParticipantEmailSend(participant.id, meetingJunctions);
        insert meetingParticipantJunctions;

        ApexPages.StandardController standardController = 
            new ApexPages.StandardController(participant);

        Test.startTest();
        MERC_ETMeetingParticipantTrackingContExt controllerExt = 
            new MERC_ETMeetingParticipantTrackingContExt(standardController);
        Test.stopTest();

        System.assertEquals(false, controllerExt.getHasErrors());
        System.assertEquals(201, controllerExt.individualEmailResults.size());
    }
}