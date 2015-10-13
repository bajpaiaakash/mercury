@isTest
private class MERC_PrimaryAffiliationTest {

    static List<Account> accounts;
    static List<Account> hcpaccounts;
    static List<Affiliation_GLBL__c> affiliations;
    

    static {
        accounts = MERC_TestFactory.insertHcpAccountsInCountry(1, 'GB'); 
        hcpaccounts= MERC_TestFactory.insertAccounts(1);
        affiliations= MERC_TestFactory.newAffiliation(accounts[0],hcpaccounts[0]);
    }

    @isTest
    static void test_should_populate_primary_affilaition() {
        Test.startTest();
        MERC_PrimaryAffiliation pf= new MERC_PrimaryAffiliation();
        pf.isActive();
        pf.execute(affiliations);
        Test.stopTest();
    }

}