/**
 * Unit tests for the MERC_AddMeetingParticipantsController extension
 *
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
    static User runningUser = MERC_TestFactory.getRunningUser();
    static User testUser = MERC_TestFactory.getTestingUser();

    static {
        System.runAs(runningUser) {
            settings = new Mercury_Settings_MERC__c();
            settings.CST_Client_Id_MERC__c = 'Guildenstern';
            settings.CST_Client_Secret_MERC__c = 'Rosencrantz';
            insert settings;

            MERC_TestFactory.adjustForSFDCSetMockBug = true;
            accts = MERC_TestFactory.insertAccounts(TEST_SET_SIZE);
            meetings = MERC_TestFactory.insertMeetings(10);
            participants = MERC_TestFactory.insertParticipants(meetings[0].Id, accts);
            //Start modified by Jyoti Gaur on 15 Jan for US-39477
            Add_Meeting_Participant_Record_Type_MERC__c setting = new Add_Meeting_Participant_Record_Type_MERC__c();
            setting.Ad_Hoc_Consulting_MERC__c = 'MERC_Consulting,MERC_Delegate,MERC_Individual_Sponsorship,MERC_Service_Provider';
            setting.Completed_MERC__c = 'MERC_Consulting,MERC_Delegate,MERC_Individual_Sponsorship,MERC_Service_Provider';
            setting.Forecasted_MERC__c = 'MERC_Consulting,MERC_Delegate,MERC_Individual_Sponsorship,MERC_Service_Provider';
            setting.Independent_Sponsorship_MERC__c = 'MERC_Consulting,MERC_Delegate,MERC_Individual_Sponsorship,MERC_Service_Provider';
            setting.Meeting_Active_MERC__c = 'MERC_Consulting,MERC_Delegate,MERC_Individual_Sponsorship,MERC_Service_Provider';
            setting.Meeting_Program_MERC__c = 'MERC_Consulting,MERC_Delegate,MERC_Individual_Sponsorship,MERC_Service_Provider';
            setting.Registered_MERC__c = 'MERC_Consulting,MERC_Delegate,MERC_Individual_Sponsorship,MERC_Service_Provider';
            //end modified by Jyoti Gaur on 15 Jan for US-39477
            insert setting;
            
        }
    }

    /*
     * Setup for most of these tests is the same so encapsulated here...
     */
    static void init() {
        PageReference ref = Page.MERC_AddMeetingParticipants;
        Test.setCurrentPage(ref);

        ApexPages.StandardSetController setCntrlr = new ApexPages.StandardSetController(participants);
        c = new MERC_AddMeetingParticipantsController(setCntrlr);

        mockServices = new GLBL_CustomerSearchToolServiceMock();
        Test.setMock(HttpCalloutMock.class, mockServices);
    }

    @isTest
    static void doSearch() {
        System.runAs(testUser) {
            init();

            // setup a pretend search id that will be returned by the mock CST service
            GLBL_CustomerSearchToolService.SearchIdResult searchIdResult = new GLBL_CustomerSearchToolService.SearchIdResult();
            searchIdResult.search_id = '012345678';
            String s = JSON.serialize(searchIdResult);
            mockServices.setBody(s);

            // check things before the search (and get this property and this method covered)
            System.assertEquals(null,c.searchId,'Result list should be empty before execution.');

            Test.startTest();
            // meeting id is passed at request time
            ApexPages.currentPage().getParameters().put('id',meetings[0].Id);
            c.doSearch();
            Test.stopTest();

            System.debug('#### Search Id is ' + c.searchId);

            // result set should be double our initial participant set size but only half should be selectable
            System.assertEquals('012345678',c.searchId,'Unexpected search result size.');
        }
    }

    @isTest
    static void retrieveResults() {
        System.runAs(testUser) {
            init();

            // setup a pretend result list to be returned by the mock CST service
            List<GLBL_CustomerSearchToolService.SearchResult> results = new List<GLBL_CustomerSearchToolService.SearchResult>();
            System.debug('#### result building loop');
            for (Integer i = 0; i < TEST_SET_SIZE; i++) {
                GLBL_CustomerSearchToolService.SearchResult searchResult = new GLBL_CustomerSearchToolService.SearchResult();
                searchResult.selected = true;
                searchResult.selectable = true;
                searchResult.sfid = i + '';
                searchResult.lastname = 'lastname';
                searchResult.firstname = 'firstname';
                results.add(searchResult);
            }

            GLBL_CustomerSearchToolService.FullSearchResult resultWrapper = new GLBL_CustomerSearchToolService.FullSearchResult();
            resultWrapper.status = 'complete';
            resultWrapper.result = results;

            System.debug('#### results = ' + results);
            System.debug('#### results before serialization = ' + resultWrapper);

            mockServices.setBody(JSON.serialize(resultWrapper));
            System.debug('#### resultWrapper serialized = ' + JSON.serialize(resultWrapper));

            // check things before the search (and get this property and this method covered)
            System.assertEquals(null,c.results,'Result list should be empty before execution.');
            System.assertEquals(0,c.getSrCount(),'Result size should have been 0 before execution.');

            Test.startTest();
            // meeting id is passed at request time
            ApexPages.currentPage().getParameters().put('id',meetings[0].Id);
            c.retrieveResults();
            Test.stopTest();

            System.debug('#### results are ' + c.searchResults);

            // result set should be double our initial participant set size but only half should be selectable
            System.assertEquals((TEST_SET_SIZE),c.getSrCount(),'Unexpected search result size.');
            Integer selectableCount = 0;
            for (GLBL_CustomerSearchToolService.SearchResult sr : c.searchResults) {
                if (sr.selectable) selectableCount++;
            }
            System.assertEquals(TEST_SET_SIZE,selectableCount,'Unexpected # of selectable result rows.');
        }
    }

    @isTest
    static void addParticipant() {
        System.runAs(testUser) {
            init();

            List<Meeting_Participant_MERC__c> currentParticipants = [SELECT Id FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings[0].Id];
            System.assertEquals(TEST_SET_SIZE,currentParticipants.size(),'Conditions not right for assert. Unexpected # of participants.');

            Account newHCP = MERC_TestFactory.insertAccounts(1)[0];

            Test.startTest();
            ApexPages.currentPage().getParameters().put('id',meetings[0].Id);   // meeting
            ApexPages.currentPage().getParameters().put('aid',newHCP.Id);       // account
            c.meetingParticipant.RecordTypeId = c.recordTypeOptions[1].getValue();   // participant record type
            List<Schema.FieldSetMember> requiredFields = c.requiredFields; //exercise this code to initialize the meeting participant
                                                                           //but nothing beyond that is going to happen since we can't create/access field sets in tests
            c.meetingParticipant.Description_of_Service_MERC__c = 'desc of service, in case the record type is consultant we need to work around the val rule';

            PageReference result = c.addToMeeting();
            Test.stopTest();

            System.assertNotEquals(true,c.hasError,'An error has occurred while adding a participant: '+ApexPages.getMessages());
            System.assertEquals(null,result,'Unexpected PageReference returned: '+result);
            System.assertEquals(TEST_SET_SIZE+1,c.getMpCount(),'Unexpected # of participants after addition.');
            currentParticipants = [SELECT Id FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings[0].Id];
            System.assertEquals(currentParticipants.size(), c.getMpCount(), 'Somehow the controller disagrees with my participant query.');
        }
    }

    @isTest
    static void addParticipantAndredirect() {
        System.runAs(testUser) {
            init();

            List<Meeting_Participant_MERC__c> currentParticipants = [SELECT Id FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings[0].Id];
            System.assertEquals(TEST_SET_SIZE,currentParticipants.size(),'Conditions not right for assert. Unexpected # of participants.');

            Account newHCP = MERC_TestFactory.insertAccounts(1)[0];

            Test.startTest();
            ApexPages.currentPage().getParameters().put('id',meetings[0].Id);   // meeting
            ApexPages.currentPage().getParameters().put('aid',newHCP.Id);       // account
            c.meetingParticipant.RecordTypeId = c.recordTypeOptions[1].getValue();   // participant record type
            List<Schema.FieldSetMember> requiredFields = c.requiredFields; //exercise this code to initialize the meeting participant
                                                                           //but nothing beyond that is going to happen since we can't create/access field sets in tests
            c.meetingParticipant.Description_of_Service_MERC__c = 'desc of service, in case the record type is consultant we need to work around the val rule';

            PageReference result = c.addToMeetingAndRedirect();
            Test.stopTest();

            System.assertNotEquals(true,c.hasError,'An error has occurred while adding a participant: '+ApexPages.getMessages());

            //pretty much the same test as addPartipant but we should get a non-null page reference.
            System.assertNotEquals(null,result,'Null PageReference returned.');
            System.assertEquals(TEST_SET_SIZE+1,c.getMpCount(),'Unexpected # of participants after addition.');
            currentParticipants = [SELECT Id FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings[0].Id];
            System.assertEquals(currentParticipants.size(), c.getMpCount(), 'Somehow the controller disagrees with my participant query.');
        }
    }

    @isTest
    static void testAddParticipantException() {
        System.runAs(testUser) {
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
    }

    @isTest
    static void removeParticipant() {
        System.runAs(testUser) {
            init();

            List<Meeting_Participant_MERC__c> currentParticipants = [SELECT Id FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings[0].Id];
            System.assertEquals(TEST_SET_SIZE,currentParticipants.size(),'Conditions not right for assert. Unexpected # of participants.');

            Test.startTest();
            ApexPages.currentPage().getParameters().put('id',meetings[0].Id);   // meeting
            ApexPages.currentPage().getParameters().put('pid',c.getMeetingParticipants()[0].Id);  // delete the first person on the current page
            PageReference result = c.removeFromMeeting();
            Test.stopTest();

            currentParticipants = [SELECT Id FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings[0].Id AND Status_MERC__c != 'Cancelled'];
            System.assertEquals(null,result,'Unexpected PageReference returned: '+result);
            System.assertEquals(TEST_SET_SIZE-1,currentParticipants.size(),'Unexpected # of participants after removal. ' + ApexPages.getMessages());
        }
    }

    @isTest
    static void testRemoveParticipantException() {
        System.runAs(testUser) {
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
    }

    /*
     *  This is covered by other testMethods but let's test it explicitly so it's easy
     *  to see if it's ever a problem
     */

    @isTest
    static void instantiateAndGetCSTToken() {
        System.runAs(testUser) {
            PageReference ref = Page.MERC_AddMeetingParticipants;
            Test.setCurrentPage(ref);

            Test.startTest();
            List<Meeting_Participant_MERC__c> pList = new List<Meeting_Participant_MERC__c>();
            ApexPages.StandardSetController setCntrlr = new ApexPages.StandardSetController(pList);
            c = new MERC_AddMeetingParticipantsController(setCntrlr);

            GLBL_CustomerSearchToolService.AccessTokenResponse tokenRespObj = new GLBL_CustomerSearchToolService.AccessTokenResponse();
            tokenRespObj.access_token = 'Alas! Poor Yorick!';
            String tokenResponse = JSON.serialize(tokenRespObj);
            Test.setMock(HttpCalloutMock.class, new GLBL_CustomerSearchToolServiceMock(200, 'OK', tokenResponse, new Map<String, String>{'Content-Type'=>'application/json'}));

            c.ensureCstToken();
            Test.stopTest();

            System.assertEquals(tokenRespObj.access_token,c.cstService.accessToken,'Unexpected value for access token: '+c.cstService.accessToken);
        }
    }

    /*
     *  Testing...
     */
 // @isTest
    //static void instantiateAndGetCSTTokenTEST0848() {
    //  System.runAs(testUser) {
    //      PageReference ref = Page.MERC_AddMeetingParticipants;
    //      Test.setCurrentPage(ref);

    //      List<Meeting_Participant_MERC__c> pList = new List<Meeting_Participant_MERC__c>();
    //      ApexPages.StandardSetController setCntrlr = new ApexPages.StandardSetController(pList);
    //      c = new MERC_AddMeetingParticipantsController(setCntrlr);

    //      GLBL_CustomerSearchToolService.AccessTokenResponse tokenRespObj = new GLBL_CustomerSearchToolService.AccessTokenResponse();
    //      tokenRespObj.access_token = 'Alas! Poor Yorick!';
    //        String tokenResponse = JSON.serialize(tokenRespObj);
    //      Test.startTest();
    //      Test.setMock(HttpCalloutMock.class, new GLBL_CustomerSearchToolServiceMock(200, 'OK', tokenResponse, new Map<String, String>{'Content-Type'=>'application/json'}));
    //      c.ensureCstToken();
    //      Test.stopTest();

    //  System.assertEquals(tokenRespObj.access_token,c.cstService.accessToken,'Unexpected value for access token: '+c.cstService.accessToken);
    //  }
    //}

    @isTest
    static void testAllMenuSelects() {
        System.runAs(testUser) {
            init();

            Test.startTest();
            System.assertNotEquals(null,c.specialtyPriorityRanks,'specialtyPriorityRanks failed to init.');
            System.assertNotEquals(null,c.affiliationPriorityRanks,'affiliationPriorityRanks failed to init.');
            System.assertNotEquals(null,c.affiliationRoleTypes,'affiliationRoleTypes failed to init.');
            System.assertNotEquals(null,c.accountClassifications,'accountClassifications failed to init.');
            System.assertNotEquals(null,c.accountStatusTypes,'accountStatusTypes failed to init.');
            //System.assertNotEquals(null,c.professionalDesignations,'professionalDesignations failed to init.');
            System.assertNotEquals(null,c.specialties,'specialties failed to init.');
            System.assertNotEquals(null,c.alternateIdTypes,'alternateIdTypes failed to init.');
            System.assertNotEquals(null,c.countries,'countries failed to init.');
            System.assertNotEquals(null,c.dummy,'dummy failed to init.');
            Test.stopTest();
        }
    }

    @isTest
    static void testNonAuthError() {
        System.runAs(testUser) {
            PageReference ref = Page.MERC_AddMeetingParticipants;
            Test.setCurrentPage(ref);

            ApexPages.StandardSetController setCntrlr = new ApexPages.StandardSetController(participants);
            c = new MERC_AddMeetingParticipantsController(setCntrlr);

            mockServices = new GLBL_CustomerSearchToolServiceMock(401, 'Unauthorized', 'Not valid json response', null);
            Test.setMock(HttpCalloutMock.class, mockServices);

            Test.startTest();
            // meeting id is passed at request time
            ApexPages.currentPage().getParameters().put('id',meetings[0].Id);
            c.doSearch();
            Test.stopTest();

            System.assert(ApexPages.hasMessages());
            System.assertEquals(Label.CST_Service_Error, ApexPages.getMessages()[0].getSummary());
        }

    }

    @isTest
    static void testMalformedJSONError() {
        System.runAs(testUser) {
            PageReference ref = Page.MERC_AddMeetingParticipants;
            Test.setCurrentPage(ref);

            ApexPages.StandardSetController setCntrlr = new ApexPages.StandardSetController(participants);
            c = new MERC_AddMeetingParticipantsController(setCntrlr);

            mockServices = new GLBL_CustomerSearchToolServiceMock(200, 'Okay', 'Non valid json response', null);
            Test.setMock(HttpCalloutMock.class, mockServices);

            Test.startTest();
            // meeting id is passed at request time
            ApexPages.currentPage().getParameters().put('id',meetings[0].Id);
            c.doSearch();
            Test.stopTest();

            System.assert(ApexPages.hasMessages());
            System.assertEquals(Label.CST_Service_Error, ApexPages.getMessages()[0].getSummary());
        }

    }

    @isTest 
    static void testRetrieveResultsError() {
        System.runAs(testUser) {
            PageReference ref = Page.MERC_AddMeetingParticipants;
            Test.setCurrentPage(ref);

            ApexPages.StandardSetController setCntrlr = new ApexPages.StandardSetController(participants);
            c = new MERC_AddMeetingParticipantsController(setCntrlr);

            mockServices = new GLBL_CustomerSearchToolServiceMock(401, 'Unauthorized', 'Not valid json response', null);
            Test.setMock(HttpCalloutMock.class, mockServices);

            Test.startTest();
            // meeting id is passed at request time
            ApexPages.currentPage().getParameters().put('id',meetings[0].Id);
            c.retrieveResults();
            Test.stopTest();

            System.assert(ApexPages.hasMessages());
            System.assertEquals(Label.CST_Retrieve_Results_Error, ApexPages.getMessages()[0].getSummary());
        }
    }
}