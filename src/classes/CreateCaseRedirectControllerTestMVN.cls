/*
* CreateCaseRedirectControllerTestMVN
* Created By: Roman Lerman
* Created Date: 3/6/2013
* Description: Test class for CreateCaseRedirectControllerMVN
*/
@isTest
private class CreateCaseRedirectControllerTestMVN {
    static testMethod void testCreateCase(){
        TestDataFactoryMVN.createSettings();
        
        Case cs = new Case();
        
        ApexPages.StandardController con = new ApexPages.StandardController(cs);

        CreateCaseRedirectControllerMVN extension = new CreateCaseRedirectControllerMVN(con);
        
        Test.startTest();
            extension.getRedirect();
        Test.stopTest();
        
        System.assertNotEquals(null, extension.newCase.Id);        
    }

    static testMethod void testCreateCaseReadOnly(){
    	TestDataFactoryMVN.createSettings();
        
        Case cs = new Case();
        
        ApexPages.StandardController con = new ApexPages.StandardController(cs);

        CreateCaseRedirectControllerMVN extension = new CreateCaseRedirectControllerMVN(con);
        
        Test.startTest();
        	Test.setReadOnlyApplicationMode(true);
            extension.getRedirect();
        Test.stopTest();
        
        System.assertEquals(null, extension.newCase.Id);
    }

    static testMethod void createCaseWithAccount(){
        TestDataFactoryMVN.createSettings();
        
        Case cs = new Case();

        Account testAccount = new Account();

        testAccount.FirstName = 'Test';
        testAccount.LastName = 'Account';

        insert testAccount;
        
        ApexPages.StandardController con = new ApexPages.StandardController(cs);

        ApexPages.currentPage().getParameters().put('def_account_id', testAccount.Id);

        CreateCaseRedirectControllerMVN extension = new CreateCaseRedirectControllerMVN(con);
        
        Test.startTest();
            extension.getRedirect();
        Test.stopTest();
        
        System.assertNotEquals(null, extension.newCase.Id);

        System.assertEquals(testAccount.Id, extension.newCase.AccountId);

        Id contactId = [select ContactId from Case where Id = :extension.newCase.Id].ContactId;

        testAccount = [select Id, PersonContactId from Account where Id = :testAccount.Id];

        System.assertEquals(testAccount.PersonContactId, contactId);        
    }
}