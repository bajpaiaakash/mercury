@isTest
private class Test_MeetingParticipantTrackingCtrlerExt {

    @isTest
    static void test_no_individual_email_results() {
        Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];
        insert meeting;

        Sonoma_ET_Config__c config = TestUtils.CreateConfig();
        insert config;

        List<Account> accts = TestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 1);
        insert accts;

        Meeting_Participant_MERC__c participant = TestUtils.CreateParticipants(meeting, accts)[0];
        insert participant;

        ApexPages.StandardController standardController = 
            new ApexPages.StandardController(participant);

        Test.startTest();
        MeetingParticipantTrackingControllerExt controllerExt = 
            new MeetingParticipantTrackingControllerExt(standardController);
        Test.stopTest();

        System.assertEquals(0, controllerExt.individualEmailResults.size());
        System.assertEquals(false, controllerExt.getHasErrors());
    }

    @isTest
    static void test_individual_email_results() {
        Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];
        insert meeting;

        Sonoma_ET_Config__c config = TestUtils.CreateConfig();
        insert config;

        List<Account> accts = TestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 1);
        insert accts;
        Account personAccount = [SELECT PersonContactId FROM Account WHERE id =: accts[0].id];

        Meeting_Participant_MERC__c participant = TestUtils.CreateParticipants(meeting, accts)[0];
        insert participant;
        participant = 
            [SELECT Account_MERC__c, Meeting_Merc__c, Account_MERC__r.PersonContactId 
            FROM Meeting_Participant_MERC__c
            WHERE Id =: participant.id];

        List<et4ae5__SendDefinition__c> etSends = TestUtils.CreateETSend(1);
        insert etSends;

        List<et4ae5__IndividualEmailResult__c> etIndividualTrackings = TestUtils.CreateEtIndividualTrackingResult(personAccount.PersonContactId, etSends);
        insert etIndividualTrackings;

        List<Meeting_Email_Send_MERC__c> meetingJunctions = TestUtils.CreateMeetingEmailSend(meeting.id, etSends);
        insert meetingJunctions;

        List<Meeting_Participant_Email_Send_MERC__c> meetingParticipantJunctions = TestUtils.CreateMeetingParticipantEmailSend(participant.id, meetingJunctions);
        insert meetingParticipantJunctions;

        ApexPages.StandardController standardController = 
            new ApexPages.StandardController(participant);

        Test.startTest();
        MeetingParticipantTrackingControllerExt controllerExt = 
            new MeetingParticipantTrackingControllerExt(standardController);
        Test.stopTest();

        System.assertEquals(false, controllerExt.getHasErrors());
        System.assertEquals(1, controllerExt.individualEmailResults.size());
    }

    @isTest
    static void test_individual_email_results_bulk() {
        Meeting_MERC__c meeting = TestUtils.CreateMeetings(1)[0];
        insert meeting;

        Sonoma_ET_Config__c config = TestUtils.CreateConfig();
        insert config;

        List<Account> accts = TestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 1);
        insert accts;
        Account personAccount = [SELECT PersonContactId FROM Account WHERE id =: accts[0].id];

        Meeting_Participant_MERC__c participant = TestUtils.CreateParticipants(meeting, accts)[0];
        insert participant;
        participant = 
            [SELECT Account_MERC__c, Meeting_Merc__c, Account_MERC__r.PersonContactId 
            FROM Meeting_Participant_MERC__c
            WHERE Id =: participant.id];


        List<et4ae5__SendDefinition__c> etSends = TestUtils.CreateETSend(201);
        insert etSends;

        List<et4ae5__IndividualEmailResult__c> etIndividualTrackings = TestUtils.CreateEtIndividualTrackingResult(personAccount.PersonContactId, etSends);
        insert etIndividualTrackings;

        List<Meeting_Email_Send_MERC__c> meetingJunctions = TestUtils.CreateMeetingEmailSend(meeting.id, etSends);
        insert meetingJunctions;

        List<Meeting_Participant_Email_Send_MERC__c> meetingParticipantJunctions = TestUtils.CreateMeetingParticipantEmailSend(participant.id, meetingJunctions);
        insert meetingParticipantJunctions;

        ApexPages.StandardController standardController = 
            new ApexPages.StandardController(participant);

        Test.startTest();
        MeetingParticipantTrackingControllerExt controllerExt = 
            new MeetingParticipantTrackingControllerExt(standardController);
        Test.stopTest();

        System.assertEquals(false, controllerExt.getHasErrors());
        System.assertEquals(201, controllerExt.individualEmailResults.size());
    }
}