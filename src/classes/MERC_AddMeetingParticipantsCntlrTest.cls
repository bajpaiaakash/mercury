/**
 *  Unit tests for the MERC_AddMeetingParticipantsController extension
 *
 * fyi: the name MERC_AddMeetingParticipantsControllerTest.cls was too long  :-(
 */
@isTest
private class MERC_AddMeetingParticipantsCntlrTest {
	
	static Mercury_Settings_MERC__c settings;
	static List<Account> accts;
	static List<Meeting_MERC__c> meetings;
	static List<Meeting_Participant_MERC__c> participants;

	static {
		settings = new Mercury_Settings_MERC__c();
		settings.CST_Client_Id_MERC__c = 'Guildenstern';
		settings.CST_Client_Secret_MERC__c = 'Rosencrantz';
		insert settings;

		accts = MERC_TestFactory.insertAccounts(200);
		meetings = MERC_TestFactory.insertMeetings(1);
		participants = MERC_TestFactory.insertParticipants(meetings[0].Id, accts);
	}

	
	// @isTest 
	static void instantiateAndGetCSTToken() {
		PageReference ref = Page.MERC_AddMeetingParticipants;
		Test.setCurrentPage(ref);

		List<Meeting_Participant_MERC__c> pList = new List<Meeting_Participant_MERC__c>();
		ApexPages.StandardSetController setCntrlr = new ApexPages.StandardSetController(pList);
		MERC_AddMeetingParticipantsController c = new MERC_AddMeetingParticipantsController(setCntrlr);

		GLBL_CustomerSearchToolService.AccessTokenResponse tokenRespObj = new GLBL_CustomerSearchToolService.AccessTokenResponse();
		tokenRespObj.access_token = 'Alas! Poor Yorick!';
        String tokenResponse = JSON.serialize(tokenRespObj);
        Map<String, String> responseHeaders = new Map<String, String>{'Content-Type'=>'application/json'};
		Test.setMock(HttpCalloutMock.class, new GLBL_CustomerSearchToolServiceMock(200, 'OK', tokenResponse, responseHeaders));

		Test.startTest();
		c.ensureCstToken();
		Test.stopTest();

		System.assertEquals(tokenRespObj.access_token,c.cstService.accessToken,'Unexpected value for access token: '+c.cstService.accessToken);
	}

	// @isTest
	static void addParticipant() {
		PageReference ref = Page.MERC_AddMeetingParticipants;
		Test.setCurrentPage(ref);

		ApexPages.StandardSetController setCntrlr = new ApexPages.StandardSetController(participants);
		MERC_AddMeetingParticipantsController c = new MERC_AddMeetingParticipantsController(setCntrlr);

		GLBL_CustomerSearchToolService.AccessTokenResponse tokenRespObj = new GLBL_CustomerSearchToolService.AccessTokenResponse();
		tokenRespObj.access_token = 'Alas! Poor Yorick!';
        String tokenResponse = JSON.serialize(tokenRespObj);
        Map<String, String> responseHeaders = new Map<String, String>{'Content-Type'=>'application/json'};
		Test.setMock(HttpCalloutMock.class, new GLBL_CustomerSearchToolServiceMock(200, 'OK', tokenResponse, responseHeaders));

		List<Meeting_Participant_MERC__c> currentParticipants = [SELECT Id FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings[0].Id];
		System.assertEquals(200,currentParticipants.size(),'Conditions not right for assert. Unexpected # of participants.');

		Account newHCP = MERC_TestFactory.insertAccounts(1)[0];
		RecordType mpRT = [SELECT ID, Name From RecordType WHERE SobjectType = 'Meeting_Participant_MERC__c' LIMIT 1];

		Test.startTest();
		ApexPages.currentPage().getParameters().put('id',meetings[0].Id);   // meeting
		ApexPages.currentPage().getParameters().put('aid',newHCP.Id);       // account
		ApexPages.currentPage().getParameters().put('nrtid',mpRT.Id);     // participant record type
		PageReference result = c.addToMeeting();
		Test.stopTest();

		System.assertNotEquals(true,c.hasError,'An error has occurred while adding a participant: '+ApexPages.getMessages());
		currentParticipants = [SELECT Id FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings[0].Id];
		System.assertEquals(null,result,'Unexpected PageReference returned: '+result);
		System.assertEquals(201,currentParticipants.size(),'Unexpected # of participants after removal.');		
	}

	// @isTest 
	static void removeParticipant() {
		PageReference ref = Page.MERC_AddMeetingParticipants;
		Test.setCurrentPage(ref);

		ApexPages.StandardSetController setCntrlr = new ApexPages.StandardSetController(participants);
		MERC_AddMeetingParticipantsController c = new MERC_AddMeetingParticipantsController(setCntrlr);

		GLBL_CustomerSearchToolService.AccessTokenResponse tokenRespObj = new GLBL_CustomerSearchToolService.AccessTokenResponse();
		tokenRespObj.access_token = 'Alas! Poor Yorick!';
        String tokenResponse = JSON.serialize(tokenRespObj);
        Map<String, String> responseHeaders = new Map<String, String>{'Content-Type'=>'application/json'};
		Test.setMock(HttpCalloutMock.class, new GLBL_CustomerSearchToolServiceMock(200, 'OK', tokenResponse, responseHeaders));

		List<Meeting_Participant_MERC__c> currentParticipants = [SELECT Id FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings[0].Id];
		System.assertEquals(200,currentParticipants.size(),'Conditions not right for assert. Unexpected # of participants.');

		Test.startTest();
		ApexPages.currentPage().getParameters().put('pid',participants[0].Id);
		PageReference result = c.removeFromMeeting();
		Test.stopTest();

		currentParticipants = [SELECT Id FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings[0].Id];
		System.assertEquals(null,result,'Unexpected PageReference returned: '+result);
		System.assertEquals(199,currentParticipants.size(),'Unexpected # of participants after removal.');
	}
	
}