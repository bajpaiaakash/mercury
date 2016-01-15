/*
 Author: Vijay Garg 
 Dated: On 14-JAN-2016 for US-39525
*/
@isTest
private class MERC_HCPContractCancellationTest{
    
    static User runningUser = MERC_TestFactory.getRunningUser();
    static User testUser = MERC_TestFactory.getTestingUser();
    static Account acc;
    static HCP_Contract_MERC__c hcpContract;
    
    
    static {
    System.runAs(runningUser) {
        Docusign_Settings_MERC__c settings = new Docusign_Settings_MERC__c();
        settings.Name = 'default';
        settings.Account_ID_MERC__c = '12345';
        settings.Integrator_Key_MERC__c = '12345';
        settings.Password_MERC__c = 'foo';
        settings.Username_MERC__c = 'bar';
        settings.Server_Endpoint_MERC__c = 'https://docusign.com';
        insert settings;
        acc = Merc_TestFactory.insertAccounts(1)[0];
        hcpContract = Merc_TestFactory.insertHCPContract(acc.id);  
    }
    }
    
    @isTest
    static void testLoginAccount() {
        Test.startTest();

        MERC_DocusignService.LoginAccount loginAccountObject = new MERC_DocusignService.LoginAccount(
            'A test name',
            'a test account id',
            'a baseurl',
            'true',
            'my username',
            'my userid',
            'my email',
            ''
        );
        MERC_DocusignService.LoginInformation loginInformation = new MERC_DocusignService.LoginInformation();
        loginInformation.loginAccounts = new List<MERC_DocusignService.LoginAccount>{loginAccountObject};

        String loginAccountResponse = JSON.serializePretty(loginInformation);
        system.debug(loginAccountResponse);

        MERC_DocusignServiceMock fakeResponse = new MERC_DocusignServiceMock(200, 'Complete', loginAccountResponse, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        MERC_DocusignService d = new MERC_DocusignService();
        d.login();
        Test.stopTest();

        System.assertEquals(1, d.loginInfo.loginAccounts.size());
        System.assertEquals(loginAccountObject.email, d.loginInfo.loginAccounts[0].email);
        System.assertEquals(loginAccountObject.userName, d.loginInfo.loginAccounts[0].userName);
    }
    
    
    @isTest 
    static void testvoidenvelop() {
        Test.startTest();
        //serialize mock response
        MERC_DocusignService.EnvelopeResponse mockResponse = new MERC_DocusignService.EnvelopeResponse();
        mockResponse.envelopeId = '7f7de730-811d-458a-97a3-deeef96b38d0';
        mockResponse.status = 'Completed';
        mockResponse.statusDateTime = '2013-10-11T17:17:55.5470518Z';
        mockResponse.uri = '/envelopes/7f7de730-811d-458a-97a3-deeef96b38d0';
        String envelopeResponseJSONString = JSON.serializePretty('');
        system.debug(envelopeResponseJSONString);

        MERC_DocusignServiceMock fakeResponse = new MERC_DocusignServiceMock(300, 'Complete', envelopeResponseJSONString, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        MERC_DocusignService.voidEnvelope(mockResponse.envelopeId, mockResponse.status);
        System.assertEquals('7f7de730-811d-458a-97a3-deeef96b38d0', mockResponse.envelopeId);
        Test.stopTest();
    }
    
    
    @isTest 
     static void hcpContractUpdateTest() {
        
        System.runAs(testUser) {
        MERC_DocusignService.EnvelopeResponse mockResponse = new MERC_DocusignService.EnvelopeResponse();
        mockResponse.envelopeId = '7f7de730-811d-458a-97a3-deeef96b38d0';
        String envelopeResponseJSONString = JSON.serializePretty('');
        system.debug(envelopeResponseJSONString);

        MERC_DocusignServiceMock fakeResponse = new MERC_DocusignServiceMock(300, 'Complete', envelopeResponseJSONString, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        hcpContract.Docusign_Envelope_Id_MERC__c = mockResponse.envelopeId;
        update hcpContract;        
        
        hcpContract.Contract_Request_Status_MERC__c = 'Contract cancelled';
        update hcpContract;
        
        System.assertEquals('Contract cancelled', hcpContract.Contract_Request_Status_MERC__c);
    
    }
    }
    
    @isTest 
     static PageReference hcpContractsave() {
         
        PageReference pageRef = Page.MERC_HCPContractNewEdit;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',hcpContract.id);
         ApexPages.StandardController stdController = new ApexPages.StandardController(hcpContract);
        MERC_HCPContractNewEditController controller = new MERC_HCPContractNewEditController(stdController);
        MERC_DocusignService.EnvelopeResponse mockResponse = new MERC_DocusignService.EnvelopeResponse();
        mockResponse.envelopeId = '7f7de730-811d-458a-97a3-deeef96b38d0';
        String envelopeResponseJSONString = JSON.serializePretty('');
        system.debug(envelopeResponseJSONString);

        MERC_DocusignServiceMock fakeResponse = new MERC_DocusignServiceMock(300, 'Complete', envelopeResponseJSONString, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        hcpContract.Docusign_Envelope_Id_MERC__c = mockResponse.envelopeId;
      
        pageRef = controller.save();
       
        hcpContract.Contract_Request_Status_MERC__c = 'Contract cancelled';

        pageRef = controller.save();

        hcpContract.Contract_Request_Status_MERC__c = 'Completed';

        pageRef = controller.save();

        hcpContract.Contract_Request_Status_MERC__c = 'Contract in progress';
        pageRef = controller.save();

        
        return pageRef;
        
     }
     
    
    
    
    
}