/*
 * MERC_TravelProposalsControllerTest
 * Description: Test the MERC_TravelProposalsController.
 * Author: Kyle Thornton (Mavens Consulting)
 * Created Date: April 23, 2015
 * Modified By: Kyle Thornton & Rick Locke (Mavens Consulting)
 * Modified Date: June 20, 2015
 */

@isTest
private class MERC_TravelProposalsControllerTest
{
    static Account                        account;
    static Meeting_MERC__c                meeting;
    static Meeting_Participant_MERC__c    participant;
    static MERC_TravelProposalsController controller;
    static PageReference                  currentPageRef;
    static List<sObject>                  segmentTypeDefinitions;

    static {
        segmentTypeDefinitions = MERC_TestFactory.loadTravelProposalSegmentTypeSettings();
        account                = MERC_TestFactory.insertAccounts(1)[0];
        meeting                = MERC_TestFactory.insertMeetings(1)[0];
        participant            = MERC_TestFactory.insertParticipants(meeting.id, new List<Account>{account})[0];
    }

    /****************** Scenario : Page accessed without an Id **********************/
    @isTest
    static void itShouldErrorWhenNoIdParameterIsProvided()
    {
        Test.startTest();
        givenThePageIsLoaded(null);
        Test.stopTest();

        expectOneErrorMessage();
        expectErrorMessageToBe(Label.Travel_Proposals_No_Participant_Id);
        expectAnInitializationError();
    }

    /****************** Scenario : Page accessed with a bad Id **********************/
    @isTest
    static void itShouldErrorWhenBadIdIsProvided() {
        Test.startTest();
        givenThePageIsLoaded('001000000000000'); //with a bad id
        Test.stopTest();

        expectOneErrorMessage();
        expectErrorMessageToBe(Label.Travel_Proposals_Cannot_Find_Participant);
        expectAnInitializationError();
    }

    /***************** Scenario : Page is accessed with no Itineraries **************/
    @isTest
    static void itShouldLoadPageProperly() {
        Test.startTest();
        givenThePageIsLoaded();
        Test.stopTest();

        expectNoErrors();
        expectPageTitleToBeSet();
        expectPageSubTitleToBeSet();
        //expectNewProposalButtonToBeVisible();
    }

    /******************  Scenario : User Creates a Proposal    **********************/
    @isTest
    static void itShouldCreateProposalAndSegment() {
        Test.startTest();
        givenThePageIsLoaded();
        givenTheUserClicksNewProposal();
        Test.stopTest();

        expectProposalCountToBe(1);
        expectProposalXToHaveYSegments(0,1);
    }

    /********  Scenario : User Creates a Proposal, saves *******/
    @isTest
    static void itShouldBeAbleToAddSegmentsAndSaveItineraries() {
            Test.startTest();
        givenThePageIsLoaded();
        givenTheUserClicksNewProposal();

        expectTheSegmentTypesToBeDefined();

        expectProposalXSegmentYFieldsToBeUndefined(0,0);
        givenTheUserTogglesTheProposalXSegmentYTypeToAir(0,0);
        expectAirSegmentFieldsToBeDisplayedForProposalXSegmentY(0,0);

        givenTheUserCompletesProposalXSegmentYInformation(0,0);

        
        givenTheUserClicksSave(); //exercising save only
        

        expectTheParticipantToHaveXProposalsWithYSegments(1,0);
        Test.stopTest();
    }

    /********  Scenario : User creates segment saves & exits *******/
    @isTest static void itShouldBeAbleToAddSegmentsAndSaveAndExit() {
            Test.startTest();
        givenThePageIsLoaded();
        givenTheUserClicksNewProposal();
        givenTheUserTogglesTheProposalXSegmentYTypeToAir(0,0);
        givenTheUserCompletesProposalXSegmentYInformation(0,0);


        givenTheUserClicksSaveAndExit(); //exercising Save And Exit
        
        expectUserToBeReturnedToMeetingParticipant();
        expectTheParticipantToHaveXProposalsWithYSegments(1,0);
        Test.stopTest();
    }

    /********  Scenario : User encounters error on save *******/
    @isTest
    static void itShouldBeAbleToHandleSaveErrors() {
            Test.startTest();
        givenThePageIsLoaded();
        givenTheUserClicksNewProposal();
        givenTheUserTogglesTheProposalXSegmentYTypeToAir(0,0);
        givenTheUserCompletesProposalXSegmentYInformation(0,0);
        givenTheUserWillEncounterAnError();


        givenTheUserClicksSave();
        Test.stopTest();

        expectOneErrorMessage();
        //expectErrorStartsWith(Label.Travel_Proposals_Error_updating_proposals_segments);
    }

    /********  Scenario : User encounters error on save & exit*******/
    @isTest
    static void itShouldBeAbleToHandleSaveAndExitErrors() {
            Test.startTest();
        givenThePageIsLoaded();
        givenTheUserClicksNewProposal();
        givenTheUserTogglesTheProposalXSegmentYTypeToAir(0,0);
        givenTheUserCompletesProposalXSegmentYInformation(0,0);
        givenTheUserWillEncounterAnError();


        givenTheUserClicksSaveAndExit();
        Test.stopTest();

        expectUserToRemainOnThePage();
        expectOneErrorMessage();
        //expectErrorStartsWith(Label.Travel_Proposals_Error_updating_proposals_segments);
    }

    /********  Scenario : User cancels segments and proposals *******/
    @isTest
    static void itShouldNotLoadCancelledSegments() {
            Test.startTest();
        givenThePageIsLoaded();
        givenTheUserClicksNewProposal();


        givenTheUserChangesProposalXSegmentYToCancelled(0,0);

        givenTheUserClicksSave();
        expectProposalXToHaveYSegments(0,0);
        Test.stopTest();
    }

    /********  Scenario : User cancels segments and proposals *******/
    @isTest
    static void itShouldNotLoadCancelledProposals() {
            Test.startTest();
        givenThePageIsLoaded();
        givenTheUserClicksNewProposal();


        givenTheUserChangesPropsalXToCancelled(0);
        expectProposalXSegmentsToBeHidden(0);

        givenTheUserClicksSave();
        Test.stopTest();

        expectProposalCountToBe(0);
    }

    @isTest
   static void getNewRenderTest() {
      Test.startTest();
        givenThePageIsLoaded();
        givenTheUserClicksNewProposal();


        givenTheUserChangesProposalXSegmentYToCancelled(0,0);

        givenTheUserClicksSave();
        expectProposalXToHaveYSegments(0,0);

        controller.getNewRender();
        controller.getCloneRender();
        Test.stopTest();

    }
  
  
    
    /************ Scenario : Segment Type somehow set to non-defined value ******/
    // this tests a protection that might be over protective, but is in place regardless
    @isTest
    static void itShouldReturnNullIfBadSegmentTypeIsSet() {
            Test.startTest();
        givenThePageIsLoaded();
        givenTheUserClicksNewProposal();
        givenTheProposalXSegmentYSegmentTypeHasBadValue(0,0);


        expectProposalXSegmentYGetSegmentDetailToReturnNull(0,0);
        Test.stopTest();
    }

    /************ Scenario : Custom Settings are not defined ******/
    @isTest
    static void itShouldThrowErrorIfCustomSettingsAreNotDefined() {
        givenNoCustomSettingsAreDefined();

        Test.startTest();
        givenThePageIsLoaded();
        Test.stopTest();

        expectOneErrorMessage();
        expectErrorMessageToBe(Label.Travel_Proposals_Custom_Settings_not_defined);
    }


    /*********************************************************************************

                         HELPER METHODS

    *********************************************************************************/



    /******************************* Actions *********************************/
    private static void givenThePageIsLoaded() {
        givenThePageIsLoaded(participant.Id);
    }

    private static void givenThePageIsLoaded(String participantId) {
        PageReference proposalPage = Page.MERC_TravelProposals;
        proposalPage.getParameters().put('id', participantId);
        Test.setCurrentPage(proposalPage);

        controller = new MERC_TravelProposalsController();
    }

    private static void givenTheUserClicksNewProposal() {
        controller.addProposal();
    }

    private static void givenTheUserCompletesProposalXSegmentYInformation(Integer proposalIndex, Integer segmentIndex) {
        controller.proposals[proposalIndex].segments[segmentIndex].detail.Segment_Begin_Timezone_MERC__c = 'Central European Time (Europe/Berlin)';
        controller.proposals[proposalIndex].segments[segmentIndex].detail.Segment_End_Timezone_MERC__c = 'Central European Time (Europe/Berlin)';
        controller.proposals[proposalIndex].segments[segmentIndex].detail.Sgmnt_Bgin_TS_MERC__c = meeting.Date_of_Event_MERC__c.addDays(-1);
        controller.proposals[proposalIndex].segments[segmentIndex].detail.Sgmnt_End_TS_MERC__c = meeting.Date_of_Event_MERC__c.addDays(-1);
        controller.proposals[proposalIndex].segments[segmentIndex].detail.Travel_Detail_Typ_MERC__c = 'Outbound Leg';
        controller.proposals[proposalIndex].segments[segmentIndex].detail.Flght_Nmbr_MERC__c = '445';
        controller.proposals[proposalIndex].segments[segmentIndex].detail.Dprtr_Trmnl_Nm_MERC__c = 'Departure';
        controller.proposals[proposalIndex].segments[segmentIndex].detail.Arrvl_Trmnl_Nm_MERC__c = 'Arrival';
    }

    private static void givenTheUserClicksSave() {
        controller.save();
    }

    private static void givenTheUserAddsAnotherSegmentToProposal(Integer proposalIndex) {
        controller.proposals[proposalIndex].addSegment();
    }

    private static void givenTheUserClicksSaveAndExit() {
        currentPageRef = null; //null this out to make sure that we are setting it. Avoid any possible false positives
        currentPageRef = controller.saveProposalsAndReturn();
    }

    private static void givenTheUserTogglesTheProposalXSegmentYTypeToAir(Integer proposalIndex, Integer segmentIndex) {
        controller.proposals[proposalIndex].segments[segmentIndex].segmentType = 'Merc_Air';
        controller.doNothing(); //simulate the post back to the server from the page onchange actionsupport
    }

    private static void givenTheUserWillEncounterAnError() {
        Test.setReadOnlyApplicationMode(true);
    }

    private static void givenTheUserChangesProposalXSegmentYToCancelled(Integer proposalIndex, Integer segmentIndex) {
        controller.proposals[proposalIndex].segments[segmentIndex].detail.Status_MERC__c = 'Cancelled';
    }

    private static void givenTheUserChangesPropsalXToCancelled(Integer proposalIndex) {
        controller.proposals[proposalIndex].detail.Status_MERC__c = 'Cancelled';
    }

    private static void givenTheProposalXSegmentYSegmentTypeHasBadValue(Integer proposalIndex, Integer segmentIndex) {
        controller.proposals[proposalIndex].segments[segmentIndex].segmentType = 'badSegmentType';
    }

    private static void givenNoCustomSettingsAreDefined() {
        delete [SELECT Id FROM Travel_Proposal_Segment_Type_MERC__c];
    }

    /******************************* Expectations *********************************/
    private static void expectOneErrorMessage() {
        System.assertEquals(1, ApexPages.getMessages().size());
    }

    private static void expectErrorMessageToBe(String error) {
        System.assertEquals(error, ApexPages.getMessages().get(0).getSummary());
    }

    private static void expectAnInitializationError() {
        System.assert(controller.initializationError);
    }

    private static void expectNoErrors() {
        System.assertEquals(0, ApexPages.getMessages().size());
        System.assertEquals(false, controller.initializationError);
    }

    private static void expectProposalCountToBe(Integer count) {
        System.assertEquals(count, controller.proposals.size());
    }

    private static void expectPageTitleToBeSet() {
        System.assertEquals(Schema.SObjectType.Meeting_MERC__c.fields.Name.getLabel() + ': ' + meeting.Name,
                            controller.getPageTitle());
    }

    private static void expectPageSubTitleToBeSet() {
        Meeting_Participant_MERC__c thisParticipant =  [select id, name, account_merc__r.name from Meeting_Participant_MERC__c where id=:participant.id];
        System.assertEquals(Label.Travel_Proposals_Page_subtitle_prefix + thisParticipant.Name + ' (' + thisParticipant.Account_MERC__r.Name + ')',
                             controller.getPageSubTitle());
    }

    /*private static void expectNewProposalButtonToBeVisible() {
        System.assert(controller.getShowNewTravelItineraryButton());
    }*/

    private static void expectProposalXToHaveYSegments(Integer proposalIndex, Integer segmentCount) {
        System.assertEquals(segmentCount, controller.proposals[proposalIndex].segments.size());
    }

    private static void expectUserToBeReturnedToMeetingParticipant() {
        System.assertEquals('/'+participant.id, currentPageRef.getUrl());
    }

    private static void expectUserToRemainOnThePage() {
        System.assertEquals(null, currentPageRef);
    }
    private static void expectTheParticipantToHaveXProposalsWithYSegments(Integer proposalCount, Integer segmentCount) {
        List<Travel_Itinerary_MERC__c> itineraries = [SELECT Id,
                                                             (SELECT Id FROM Travel_Itineraries__r)
                                                        FROM Travel_Itinerary_MERC__c
                                                       WHERE Meeting_Participant_MERC__c=:participant.id
                                                         AND RecordTypeId=:MERC_TravelProposalsController.proposalRecordTypeId];

        System.assertEquals(proposalCount, itineraries.size());
        System.assertEquals(segmentCount, itineraries[0].Travel_Itineraries__r.size());
    }

    private static void expectErrorStartsWith(String errorBegin) {
        System.debug('#### ApexPages.getMessages().get(0).getSummary() == ' + ApexPages.getMessages().get(0).getSummary());
        System.debug('#### errorBegin == ' + errorBegin);
        System.assert(ApexPages.getMessages().get(0).getSummary().startsWith(errorBegin));
    }

    private static void expectTheSegmentTypesToBeDefined() {
        Set<String> types = new Set<String>{''}; //first option should be empty string
        for (sObject so : segmentTypeDefinitions) {
            types.add((String)so.get('Record_Type_Name_MERC__c'));
        }
        //System.assert(controller.segmentOptions.size() > 1, 'No segment types defined');
        System.assertEquals(types.size(), controller.segmentOptions.size());
        for (SelectOption option : controller.segmentOptions) {
            System.assert(types.contains(option.getValue()));
        }
    }

    private static void expectProposalXSegmentYFieldsToBeUndefined(Integer proposalIndex, Integer segmentIndex) {
        System.assert(controller.proposals[proposalIndex].segments[segmentIndex].getSegmentFields().isEmpty());
    }

    private static void expectProposalXSegmentsToBeHidden(Integer proposalIndex) {
        System.assertEquals(false, controller.proposals[proposalIndex].getDisplaySegments());
    }

    private static void expectAirSegmentFieldsToBeDisplayedForProposalXSegmentY(Integer proposalIndex, Integer segmentIndex) {
        System.assertEquals(true, controller.proposals[proposalIndex].segments[segmentIndex].getSegmentFields().isEmpty());
    }

    private static void expectProposalXSegmentYGetSegmentDetailToReturnNull(Integer proposalIndex, Integer segmentIndex) {
        System.assertEquals(null, controller.proposals[proposalIndex].segments[segmentIndex].getSegmentDetail());
    }
    

    
    
}