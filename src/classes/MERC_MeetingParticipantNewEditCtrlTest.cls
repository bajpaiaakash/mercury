@isTest
private class MERC_MeetingParticipantNewEditCtrlTest {

    static List<Account> accounts;
    static List<Meeting_MERC__c> meetings;
    static User runningUser = MERC_TestFactory.getRunningUser();
    static User testUser = MERC_TestFactory.getTestingUser();
    static {
        System.runAs(runningUser) {
            accounts = MERC_TestFactory.insertAccounts(1); //insert 1 account
            meetings = MERC_TestFactory.insertMeetings(1); //insert 1 meeting
        }
    }

    @isTest static void testNewMeetingParticipant() {
        system.assertEquals(0, [SELECT count() FROM Meeting_Participant_MERC__c]);

        PageReference ref = Page.MERC_MeetingParticipantNewEdit;
        ref.getParameters().put('RecordType', [SELECT ID FROM RecordType WHERE SObjectType = 'Meeting_Participant_MERC__c' AND DeveloperName = 'Merc_Service_Provider'].Id);
        Test.setCurrentPage(ref);

        Meeting_Participant_MERC__c newMeetingParticipant = new Meeting_Participant_MERC__c();
        newMeetingParticipant.Meeting_MERC__c = meetings.get(0).Id;
        //newMeetingParticipant.RecordTypeId = [SELECT ID FROM RecordType WHERE SObjectType = 'Meeting_Participant_MERC__c' AND DeveloperName = 'Merc_Service_Provider'].ID;

        ApexPages.StandardController standardController = new ApexPages.StandardController(newMeetingParticipant);
        MERC_MeetingParticipantNewEditController controller = new MERC_MeetingParticipantNewEditController(standardController);

        system.assertEquals(null, (String)controller.meetingParticipant.get('Id'));

        controller.meetingParticipant.put('Id', 'foo');
        controller.save();

        System.assert(!ApexPages.getMessages().isEmpty(),'Error message not passed back to page.');
        System.assert(ApexPages.getMessages()[0].getDetail().contains('Record ID: id value of incorrect type: foo'));
        system.debug(ApexPages.getMessages());

        controller.meetingParticipant.put('Id', null);

        controller.meetingParticipant.put('Account_MERC__c', accounts.get(0).Id);

        controller.save();

        system.assertEquals(1, [SELECT count() FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings.get(0).Id]);
    }

    @isTest static void testEditMeetingParticipant() {
        MERC_TriggerHandlerStateManager.deactivateAll();

        system.assertEquals(0, [SELECT count() FROM Meeting_Participant_MERC__c]);
        Meeting_Participant_MERC__c existingMeetingParticipant = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts)[0];

        system.debug('meeting particpant id: '+existingMeetingParticipant.Id);

        PageReference ref = Page.MERC_MeetingParticipantNewEdit;
        ref.getParameters().put('id', existingMeetingParticipant.Id);
        Test.setCurrentPage(ref);

        ApexPages.StandardController standardController = new ApexPages.StandardController(existingMeetingParticipant);
        MERC_MeetingParticipantNewEditController controller = new MERC_MeetingParticipantNewEditController(standardController);

        system.assertNotEquals(null, controller.meetingParticipant.Id);

        controller.meetingParticipant.Air_Travel_Required_MERC__c = 'Yes';

        PageReference p = controller.save();
        system.debug('=====>');
        system.debug(controller.meetingParticipant);
        system.debug(ApexPages.getMessages());
        system.debug(p);

        system.assertEquals('Yes', [SELECT Air_Travel_Required_MERC__c FROM Meeting_Participant_MERC__c WHERE ID = :existingMeetingParticipant.Id].Air_Travel_Required_MERC__c);

        p = controller.ajaxUpdate();
        System.assert(ApexPages.getMessages().isEmpty(),'Error message that is not supposed to be there!');

    }

    @isTest static void testAjaxUpdateFail() {
        System.runAs(testUser) {
            Meeting_Participant_MERC__c existingMeetingParticipant = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts)[0];

            PageReference ref = Page.MERC_MeetingParticipantNewEdit;
            ref.getParameters().put('id', existingMeetingParticipant.Id);
            Test.setCurrentPage(ref);

            ApexPages.StandardController standardController = new ApexPages.StandardController(existingMeetingParticipant);
            MERC_MeetingParticipantNewEditController controller = new MERC_MeetingParticipantNewEditController(standardController);

            //force update error
            Test.setReadOnlyApplicationMode(true);
            controller.ajaxUpdate();
            System.assert(!ApexPages.getMessages().isEmpty());
        }
    }

    @isTest static void testsubmitFormViaAjaxJavaScriptMethod() {
        System.runAs(testUser) {
            Meeting_Participant_MERC__c existingMeetingParticipant = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts)[0];

            PageReference ref = Page.MERC_MeetingParticipantNewEdit;
            ref.getParameters().put('id', existingMeetingParticipant.Id);
            Test.setCurrentPage(ref);

            ApexPages.StandardController standardController = new ApexPages.StandardController(existingMeetingParticipant);
            MERC_MeetingParticipantNewEditController controller = new MERC_MeetingParticipantNewEditController(standardController);

            System.assertEquals('submitFormViaAjax', controller.submitFormViaAjaxJavaScriptMethod);
        }
    }
}