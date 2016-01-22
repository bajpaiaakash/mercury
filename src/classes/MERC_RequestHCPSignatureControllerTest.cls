/**
 * @author Sean Harrison
 *
 * Exercises the MERC_RequestHCPSignatureController controller and, by extension,
 * some of the MERC_DocusignService too!
 *
 */
@isTest
private class MERC_RequestHCPSignatureControllerTest {

    static HCP_Contract_MERC__c contract;
    static Account hcp;
    static Account internalSignee;
    static User testUser = MERC_TestFactory.getTestingUser();
    static User runningUser = MERC_TestFactory.getRunningUser();

    static {
        System.runAs(runningUser) {     
            hcp = MERC_TestFactory.insertAccounts(1)[0];
            internalSignee = MERC_TestFactory.insertAccounts(1)[0];
            contract = MERC_TestFactory.insertHCPContract(hcp.Id);
        }
    }

    /*
     * Let's require a signature via MERC_RequestHCPSignatureController.requestSignature()
     */
    @isTest
    static void testRequestForSignature() {
        //can't runas test user since initDocusign() calls setupContractContent which needs access to a content library and that can't be setup in a test
        MERC_RequestHCPSignatureController controller = initDocusign();

        //serialize mock response to mimic MERC_DocusignService.EnvelopeResponse
        MERC_DocusignMockMultiResponseObj mockResponse = new MERC_DocusignMockMultiResponseObj();
        mockResponse.envelopeId = '7f7de730-811d-458a-97a3-deeef96b38d0';
        String envelopeResponseJSONString = JSON.serializePretty(mockResponse);
        system.debug(envelopeResponseJSONString);

        MERC_DocusignServiceMock fakeResponse = new MERC_DocusignServiceMock(200, 'Complete', envelopeResponseJSONString, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        Test.startTest();
        PageReference result = controller.requestSignature();
        Test.stopTest();
        System.assertEquals(null,result,'requestSignature returned an unexpected PageReference: '+result);
        System.assertEquals(true,controller.isSent,'Unexpected isSent property value.');
    }

    /*
     * Let's test an expected Docusign error
     */
    @isTest
    static void testRequestANCHORError() {
        //can't runas test user since initiDocusignt calls setupContractContent which needs access to a content library and that can't be setup in a test
        MERC_RequestHCPSignatureController controller = initDocusign();

        // serialize mock response to mimic MERC_DocusignService.EnvelopeResponse with error and
        // a subsequent MERC_DocusignService.TagAndSendResponse
        MERC_DocusignMockMultiResponseObj mockResponse = new MERC_DocusignMockMultiResponseObj();
        mockResponse.errorCode = 'ANCHOR_TAB_STRING_NOT_FOUND';
        mockResponse.envelopeId = 'abc123';
        String envelopeResponseJSONString = JSON.serializePretty(mockResponse);
        system.debug('YYZ: '+envelopeResponseJSONString);

        MERC_DocusignServiceMock fakeResponse = new MERC_DocusignServiceMock(989, 'Complete', envelopeResponseJSONString, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        Test.startTest();
        PageReference result;
        try {
            result = controller.requestSignature();
            } catch (MERC_DocusignService.DocusignServiceException e) {
                // Exception expected here!
                System.debug('YYZ: '+e.message);
                System.assertEquals('ANCHOR_TAB_STRING_NOT_FOUND',e.errorCode,'Unexpected errorCode.');
                System.assertEquals(null,e.message,'Unexpected message received: '+e.message);
            } catch (Exception e) {
                System.assert(false,'Unexpected exception thrown: '+e.getMessage());
            }
        Test.stopTest();
        System.assertEquals(null,result,'Expected exception but none thrown.');
    }

    /*
     * The MERC_DocusignService.getTagAndSendUrl() callout redirects the user to our same page but with certain parameters
     */
    @isTest
    static void testTagAndSendRedirect() {
        System.runAs(testUser) {
            PageReference ref = Page.MERC_RequestHCPSignature;
            ref.getParameters().put('docusignTasStatus', '1');
            ref.getParameters().put('id','contract.Id');
            Test.setCurrentPage(ref);

            Test.startTest();
            MERC_RequestHCPSignatureController controller =
                new MERC_RequestHCPSignatureController(new ApexPages.StandardController(contract));
            Test.stopTest();

            System.assertEquals(true,controller.isSent,'Expected isSent property to be true but it was '+controller.isSent);
        }
    }

    /*
     * Let's test for unexpected Docusign errors
     */
    @isTest
    static void testRequestOtherError() {
        //can't runas test user since initiDocusignt calls setupContractContent which needs access to a content library and that can't be setup in a test
        MERC_RequestHCPSignatureController controller = initDocusign();

        // serialize mock response to mimic MERC_DocusignService.EnvelopeResponse with error
        MERC_DocusignMockMultiResponseObj mockResponse = new MERC_DocusignMockMultiResponseObj();
        mockResponse.errorCode = 'FOOBAR';
        String envelopeResponseJSONString = JSON.serializePretty(mockResponse);
        system.debug(envelopeResponseJSONString);

        MERC_DocusignServiceMock fakeResponse = new MERC_DocusignServiceMock(200, 'Complete', envelopeResponseJSONString, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        Test.startTest();
        PageReference result = controller.requestSignature();
        Test.stopTest();

        System.assertEquals(null,result,'requestSignature returned an unexpected PageReference: '+result);
        System.assertEquals(false, controller.isSent,'Expected isSent property to be false but it was '+controller.isSent);
    }

    /*
     * Conditions for requesting a signature are all fulfilled
     */
    @isTest
    static void contractHasEverythingAndCanRequestSignature() {
        //can't runas test user since setupContractContent needs access to a content library and that can't be setup in a test
        PageReference ref = Page.MERC_RequestHCPSignature;
        Test.setCurrentPage(ref);
        
        Test.startTest();
        MERC_RequestHCPSignatureController controller =
            new MERC_RequestHCPSignatureController(new ApexPages.StandardController(contract));

        contract.Lilly_Internal_Signee_MERC__c = internalSignee.Id;

        setupContractContent();

        System.assertEquals(true, controller.getCanRequestSignature(), 'Unexpected error state: '+ controller.error);
        System.assertEquals(null, controller.error, 'Unexpected error state: Should have been null but was "'+ controller.error+'"');
    }

    //** START ***
    // *
    // *    The NEXT FOUR methods exercise one of each of the possible error states when
    // *  checking the conditions necessary for getCanRequestSignature() to return true

    @isTest
    static void contractMustHaveInternalSignee() {
        System.runAs(testUser) {
            PageReference ref = Page.MERC_RequestHCPSignature;
            Test.setCurrentPage(ref);

            Test.startTest();
            MERC_RequestHCPSignatureController controller =
                new MERC_RequestHCPSignatureController(new ApexPages.StandardController(contract));

            System.assertEquals(false, controller.getCanRequestSignature());
            System.assert(controller.error.contains('does not have a Lilly Internal Signee'),'Unexpected error state: '+ controller.error);
        }
    }

    @isTest
    static void contractMustHaveHCPEmail() {
        MERC_ETSubscriberFutureProcessor.SkipSubscriberUpdates = true;
    
        System.runAs(testUser) {
            PageReference ref = Page.MERC_RequestHCPSignature;
            Test.setCurrentPage(ref);

            Test.startTest();
            MERC_RequestHCPSignatureController controller =
                new MERC_RequestHCPSignatureController(new ApexPages.StandardController(contract));

            contract.Lilly_Internal_Signee_MERC__c = internalSignee.Id;

            String hcpEmail = hcp.PersonEmail;
            hcp.PersonEmail = null;
            update hcp;
            System.assertEquals(false, controller.getCanRequestSignature());
            System.assert(controller.error.contains('HCP does not have a valid e-mail'),'Unexpected error state: '+ controller.error);
        }
    }

    @isTest
    static void contractMustHaveInternalSigneeEmail() {
        MERC_ETSubscriberFutureProcessor.SkipSubscriberUpdates = true;
        
        System.runAs(testUser) {
            PageReference ref = Page.MERC_RequestHCPSignature;
            Test.setCurrentPage(ref);

            Test.startTest();
            MERC_RequestHCPSignatureController controller =
                new MERC_RequestHCPSignatureController(new ApexPages.StandardController(contract));

            contract.Lilly_Internal_Signee_MERC__c = internalSignee.Id;

            String signeeEmail = internalSignee.PersonEmail;
            internalSignee.PersonEmail = null;
            update internalSignee;
            System.assertEquals(false, controller.getCanRequestSignature());
            System.assert(controller.error.contains('Lilly recipient does not have a valid e-mail'),'Unexpected error state: '+ controller.error);
        }
    }

    @isTest
    static void contractMustHavePDF() {
        System.runAs(testUser) {
            PageReference ref = Page.MERC_RequestHCPSignature;
            Test.setCurrentPage(ref);

            Test.startTest();
            MERC_RequestHCPSignatureController controller =
                new MERC_RequestHCPSignatureController(new ApexPages.StandardController(contract));

            contract.Lilly_Internal_Signee_MERC__c = internalSignee.Id;

            System.assertEquals(false, controller.getCanRequestSignature());
            System.assert(controller.error.contains('Could not find HCP Contract PDF'),'Unexpected error state: '+ controller.error);
        }
    }
    /*** END ***
     *
     *  The previous FOUR methods exercised one of each of the possible error states
     */


    /*
     * Setup data necessary for Docusign testing
     */
    private static MERC_RequestHCPSignatureController initDocusign() {
        setDocusignSettings();

        PageReference ref = Page.MERC_RequestHCPSignature;
        Test.setCurrentPage(ref);

        MERC_RequestHCPSignatureController controller =
            new MERC_RequestHCPSignatureController(new ApexPages.StandardController(contract));

        contract.Lilly_Internal_Signee_MERC__c = internalSignee.Id;

        setupContractContent();

        return controller;
    }

    /*
     * Insert expected Custom Settings
     */
    private static void setDocusignSettings() {
        Docusign_Settings_MERC__c settings = new Docusign_Settings_MERC__c();
        settings.Name = 'default';
        settings.Account_ID_MERC__c = '12345';
        settings.Integrator_Key_MERC__c = '12345';
        settings.Password_MERC__c = 'foo';
        settings.Username_MERC__c = 'bar';
        settings.Server_Endpoint_MERC__c = 'https://docusign.com';
        insert settings;
    }

    /*
     *  Insert a fake contract into Content
     */
    private static void setupContractContent() {
        ContentVersion contractCV = new ContentVersion();
        contractCV.VersionData = Blob.valueOf('12345678');
        contractCV.PathOnClient = contract.Id + '.PDF';
        insert contractCV;

        contractCV = [SELECT ContentDocumentId FROM ContentVersion where Id = :contractCV.Id];
        ContentWorkspace library = [SELECT Id FROM ContentWorkspace where Name = 'Mercury' LIMIT 1];
        ContentWorkspaceDoc docLink = new ContentWorkspaceDoc();
        docLink.ContentWorkspaceId = library.Id;
        docLink.ContentDocumentId = contractCV.ContentDocumentId;
        insert docLink;

        contract = [SELECT Name FROM HCP_Contract_MERC__c WHERE Id = :contract.Id];
        contractCV.HCP_Contract_MERC__c = contract.Id;
        contractCV.Title = contract.Name;
        update contractCV;
    }

    //generate signers
    /*
    private static void setupSigners() {
        List<Account> signingAccounts = MERC_TestFactory.insertAccounts(2);
        List<MERC_DocusignService.RequiredSigner> requiredSigners = new List<MERC_DocusignService.RequiredSigner>();
        for (Integer i = 0; i < signingAccounts.size(); i++) {
            MERC_DocusignService.RequiredSigner signer = new MERC_DocusignService.RequiredSigner();
            signer.acc = signingAccounts.get(i);
            signer.order = i+1;
            signer.isLilly = i == 0 ? true : false;
            requiredSigners.add(signer);
        }
    } */
}