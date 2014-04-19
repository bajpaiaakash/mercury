/**
 * Unit tests for the MERC_AddMeetingParticipantsController extension
 * <p>
 * fyi: the name MERC_AddMeetingParticipantsControllerTest.cls was too long  :-(
 *
 * @author  Sean Harrison
 **/
@isTest
private class MERC_AddMeetingParticipantsCntlrTest {
	
	static final Integer TEST_SET_SIZE = 200;

	static Mercury_Settings_MERC__c settings;
	static List<Account> accts;
	static List<Meeting_MERC__c> meetings;
	static List<Meeting_Participant_MERC__c> participants;
	static GLBL_CustomerSearchToolServiceMock mockServices;
	static MERC_AddMeetingParticipantsController c;

	static {
		//settings = new Mercury_Settings_MERC__c();
		//settings.CST_Client_Id_MERC__c = 'Guildenstern';
		//settings.CST_Client_Secret_MERC__c = 'Rosencrantz';
		//insert settings;

//		accts = MERC_TestFactory.insertAccounts(TEST_SET_SIZE);
		meetings = MERC_TestFactory.insertMeetings(10);
//		participants = MERC_TestFactory.insertParticipants(meetings[0].Id, accts);
	}

	/*
	 * Setup for most of these tests is the same so encapsulated here...
	 */
	static void init() {
		PageReference ref = Page.MERC_AddMeetingParticipants;
		Test.setCurrentPage(ref);

//	UNDO	ApexPages.StandardSetController setCntrlr = new ApexPages.StandardSetController(participants);
		ApexPages.StandardSetController setCntrlr = new ApexPages.StandardSetController(new List<Meeting_Participant_MERC__c>());
		c = new MERC_AddMeetingParticipantsController(setCntrlr);

		mockServices = new GLBL_CustomerSearchToolServiceMock();
		Test.setMock(HttpCalloutMock.class, mockServices);
	}
	
//	@isTest
	static void doSearch() {
		Test.startTest();
		init();

		// setup a pretend result list to be returned by the mock CST service
		List<Account> acctResultList = MERC_TestFactory.insertAccounts(TEST_SET_SIZE);
		acctResultList.addAll(accts);

		String s = JSON.serialize(acctResultList);
		List<GLBL_CustomerSearchToolService.SearchResult> results = 
			(List<GLBL_CustomerSearchToolService.SearchResult>) JSON.deserialize(s, List<GLBL_CustomerSearchToolService.SearchResult>.class);
		for (GLBL_CustomerSearchToolService.SearchResult sr : results) {
			sr.sfid = sr.id;   // real service would have SFDC record id in this field, not in "id"
		}
		mockServices.setBody(JSON.serialize(results));

		// check things before the search (and get this property and this method covered)
		System.assertEquals(null,c.results,'Result list should be empty before execution.');
		System.assertEquals(0,c.getSrCount(),'Result size should have been 0 before execution.');

		// meeting id is passed at request time
		ApexPages.currentPage().getParameters().put('id',meetings[0].Id);
		c.doSearch();
		Test.stopTest();

		// result set should be double our initial participant set size but only half should be selectable
		System.assertEquals((TEST_SET_SIZE*2),c.getSrCount(),'Unexpected search result size.');
		Integer selectableCount = 0;
		for (GLBL_CustomerSearchToolService.SearchResult sr : c.searchResults) {
			if (sr.selectable) selectableCount++;
		}
		System.assertEquals(TEST_SET_SIZE,selectableCount,'Unexpected # of selectable result rows.');
	}

//	@isTest
	static void addParticipant() {
		init();

		List<Meeting_Participant_MERC__c> currentParticipants = [SELECT Id FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings[0].Id];
		System.assertEquals(TEST_SET_SIZE,currentParticipants.size(),'Conditions not right for assert. Unexpected # of participants.');

 		Account newHCP = MERC_TestFactory.insertAccounts(1)[0];

		Test.startTest();
		ApexPages.currentPage().getParameters().put('id',meetings[0].Id);   // meeting
		ApexPages.currentPage().getParameters().put('aid',newHCP.Id);       // account
		c.newParticipantRecordTypeId = c.recordTypeOptions[1].getValue();   // participant record type
		PageReference result = c.addToMeeting();
		Test.stopTest();

		System.assertNotEquals(true,c.hasError,'An error has occurred while adding a participant: '+ApexPages.getMessages());
		System.assertEquals(null,result,'Unexpected PageReference returned: '+result);
		System.assertEquals(TEST_SET_SIZE+1,c.getMpCount(),'Unexpected # of participants after addition.');
		currentParticipants = [SELECT Id FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings[0].Id];
		System.assertEquals(currentParticipants.size(), c.getMpCount(), 'Somehow the controller disagrees with my participant query.');
	}

//	@isTest 
	static void testAddParticipantException() {
		init();

		Test.startTest();
		ApexPages.currentPage().getParameters().put('aid','not_a_real_id');
		PageReference result = c.addToMeeting();
		Test.stopTest();

		System.assertEquals(null, result, 'Unexpected PageRef returned.');
		System.assertEquals(true,c.hasError,'Unexpected hasError property');

		List<Meeting_Participant_MERC__c> currentParticipants = [SELECT Id FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings[0].Id];
		System.assertEquals(TEST_SET_SIZE,currentParticipants.size(),'# of participants should have remained the same.');
	}

//	@isTest 
	static void removeParticipant() {
		init();

		List<Meeting_Participant_MERC__c> currentParticipants = [SELECT Id FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings[0].Id];
		System.assertEquals(TEST_SET_SIZE,currentParticipants.size(),'Conditions not right for assert. Unexpected # of participants.');

		Test.startTest();
		ApexPages.currentPage().getParameters().put('id',meetings[0].Id);   // meeting
		ApexPages.currentPage().getParameters().put('pid',c.getMeetingParticipants()[0].Id);  // delete the first person on the current page
		PageReference result = c.removeFromMeeting();
		Test.stopTest();

		currentParticipants = [SELECT Id FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings[0].Id];
		System.assertEquals(null,result,'Unexpected PageReference returned: '+result);
		System.assertEquals(TEST_SET_SIZE-1,currentParticipants.size(),'Unexpected # of participants after removal.');
	}

//	@isTest 
	static void testRemoveParticipantException() {
		init();

		Test.startTest();
		ApexPages.currentPage().getParameters().put('pid','not_a_real_id');
		PageReference result = c.removeFromMeeting();
		Test.stopTest();

		System.assertEquals(null, result, 'Unexpected PageRef returned.');
		System.assertEquals(true,c.hasError,'Unexpected hasError property');

		List<Meeting_Participant_MERC__c> currentParticipants = [SELECT Id FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings[0].Id];
		System.assertEquals(TEST_SET_SIZE,currentParticipants.size(),'# of participants should have remained the same.');
	}

	/*
	 *  This is covered by other testMethods but let's test it explicitly so it's easy 
	 *  to see if it's ever a problem
	 */
 	@isTest 
	static void instantiateAndGetCSTToken() {
		PageReference ref = Page.MERC_AddMeetingParticipants;
		Test.setCurrentPage(ref);

		List<Meeting_Participant_MERC__c> pList = new List<Meeting_Participant_MERC__c>();
		ApexPages.StandardSetController setCntrlr = new ApexPages.StandardSetController(pList);
		c = new MERC_AddMeetingParticipantsController(setCntrlr);

		GLBL_CustomerSearchToolService.AccessTokenResponse tokenRespObj = new GLBL_CustomerSearchToolService.AccessTokenResponse();
		tokenRespObj.access_token = 'Alas! Poor Yorick!';
        String tokenResponse = JSON.serialize(tokenRespObj);
		Test.setMock(HttpCalloutMock.class, new GLBL_CustomerSearchToolServiceMock(200, 'OK', tokenResponse, new Map<String, String>{'Content-Type'=>'application/json'}));
		
		Test.startTest();
		c.ensureCstToken();
		Test.stopTest();

		System.assertEquals(tokenRespObj.access_token,c.cstService.accessToken,'Unexpected value for access token: '+c.cstService.accessToken);
	}

	@isTest
	static void testAllMenuSelects() {
		init();

		Test.startTest();
		System.assertNotEquals(null,c.specialtyPriorityRanks,'specialtyPriorityRanks failed to init.');
		System.assertNotEquals(null,c.affiliationPriorityRanks,'affiliationPriorityRanks failed to init.');
		System.assertNotEquals(null,c.affiliationRoleTypes,'affiliationRoleTypes failed to init.');
		System.assertNotEquals(null,c.accountClassifications,'accountClassifications failed to init.');
		System.assertNotEquals(null,c.accountStatusTypes,'accountStatusTypes failed to init.');
		System.assertNotEquals(null,c.professionalDesignations,'professionalDesignations failed to init.');
		System.assertNotEquals(null,c.specialties,'specialties failed to init.');
		System.assertNotEquals(null,c.alternateIdTypes,'alternateIdTypes failed to init.');
		System.assertNotEquals(null,c.countries,'countries failed to init.');
		System.assertNotEquals(null,c.dummy,'dummy failed to init.');
		Test.stopTest();
	}
}