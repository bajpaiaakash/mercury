@isTest
private class MERC_PrimaryAffiliationTest {

    static List<Account> accounts;
    static List<Account> hcpaccounts;
    static List<Affiliation_GLBL__c> affiliations;
	static User testUser = MERC_TestFactory.getTestingUser();
    

    static {
        accounts = MERC_TestFactory.insertHcpAccountsInCountry(1, 'GB'); 
        hcpaccounts= MERC_TestFactory.insertAccounts(1);
        affiliations= MERC_TestFactory.newAffiliation(accounts[0],hcpaccounts[0]);
    }

    @isTest
    static void test_should_populate_primary_affilaition() {
	 System.runAs(testUser) {
        Test.startTest();
        MERC_PrimaryAffiliation pf= new MERC_PrimaryAffiliation();
        pf.isActive();
        pf.execute(affiliations);
        Test.stopTest();
		System.assertEquals(1, [Select Priority_Rank_Nbr_GLBL__c From Affiliation_GLBL__c WHERE ID = :affiliations[0].Id].Priority_Rank_Nbr_GLBL__c);
    }
	}

}