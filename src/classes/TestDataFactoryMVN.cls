/*
* TestDataFactoryMVN
* Created By:    Roman Lerman
* Created Date:  3/4/2013
* Description:   This is the data factory used to generate data by all of the test classes
*/
@isTest
public class TestDataFactoryMVN {
    public static Integer TEST_DATA_SIZE = 25;

    public static List<Case> createInteractions() {
        List<Case> cases = new List<Case>();
        for(Integer i=0; i<TEST_DATA_SIZE; i++) {
            cases.add(new Case(
                      Status='Open')
            );
        }
        insert cases;

        return cases;
    }

    public static List<Case> createRequests(List<Case> interactions, String status){
         List<Case> requests = new List<Case>();
         for (Case c : interactions) {
             Case request = c.clone(false);
             request.ParentId = c.id;
             request.Status = status;

             requests.add(request);
             requests.add(request.clone(false));
         }
         insert requests;

         return requests;
    }

    public static Account createTestPersonAccount() {
        Account personAccount = new Account();
        personAccount.FirstName = 'Test';
        personAccount.LastName = 'Account';
        personAccount.Phone = '3333333333';
        personAccount.PersonHomePhone = '4444444444';
        personAccount.PersonMobilePhone = '4444444444';
        personAccount.PersonOtherPhone = '5555555555';
        personAccount.RecordTypeId = [Select ID From RecordType WHERE SobjectType = 'Account' and DeveloperName = 'HCP_GLBL'].ID;
        insert personAccount;

        return personAccount;
    }
    public static Account createTestEmployee() {
        Account personAccount = new Account();
        personAccount.FirstName = 'Johnny';
        personAccount.LastName = 'Employee';
        personAccount.Phone = '4444444444';
        personAccount.RecordTypeId = [Select ID From RecordType WHERE SobjectType = 'Account' and DeveloperName = 'Employee_GLBL'].ID;
        insert personAccount;

        return personAccount;
    }
    public static Account createTestHCP() {
        Account personAccount = new Account();
        personAccount.FirstName = 'Test';
        personAccount.LastName = 'Account';
        personAccount.Mdl_Nm_GLBL__c = 'Little';
        personAccount.Phone = '5555555555';
        personAccount.RecordTypeId = [Select ID From RecordType WHERE SobjectType = 'Account' and DeveloperName = 'HCP_GLBL'].ID;
        insert personAccount;

        return personAccount;
    }

    public static Case createTestCase(Id accountId, Id contactId) {
        Case testCase = new Case();
        testCase.AccountId = accountId;
        testCase.ContactId = contactId;
        insert testCase;

        return testCase;
    }

    public static Case createClosedTestCase() {
        Account personAccount = createTestPersonAccount();

        Case testCase = new Case();
        testCase.AccountId = personAccount.Id;
        testCase.ContactId = [select PersonContactId from Account where Id = :personAccount.Id].PersonContactId;
        testCase.Address_GLBL__c = createTestAddress(personAccount).Id;
        testCase.Status = 'Closed';
        insert testCase;

        return testCase;
    }

    public static Case createClosedTestRequest(Case parentCase) {
        Case testCase = new Case();
        testCase.ParentId = parentCase.Id;
        testCase.AccountId = parentCase.AccountId;
        testCase.ContactId = [select PersonContactId from Account where Id = :parentCase.AccountId].PersonContactId;
        testCase.Address_GLBL__c = parentCase.Address_GLBL__c;
        testCase.Status = 'Closed';
        insert testCase;

        return testCase;
    }

    public static Case createTestCase() {
        Account personAccount = createTestPersonAccount();

        Case testCase = new Case();
        testCase.AccountId = personAccount.Id;
        testCase.ContactId = [select PersonContactId from Account where Id = :personAccount.Id].PersonContactId;
        testCase.Address_GLBL__c = createTestAddress(personAccount).Id;
        insert testCase;

        return testCase;
    }

    public static Case createTestRequest(Case parentCase) {
        Case testCase = new Case();
        testCase.ParentId = parentCase.Id;
        testCase.AccountId = parentCase.AccountId;
        testCase.ContactId = parentCase.ContactId;
        testCase.Address_GLBL__c = parentCase.Address_GLBL__c;
        insert testCase;

        return testCase;
    }

    public static Address_GLBL__c createTestAddress(Account acct){
        Address_GLBL__c address = new Address_GLBL__c(Line_1_Adrs_Txt_GLBL__c = '123 Fake St.');
        address.City_GLBL__c = 'San Francisco Treat';
        address.Zip_Postal_Code_GLBL__c = '94941';
        address.St_Cd_GLBL__c = 'ca';
        address.Adrs_Cntry_Cd_GLBL__c = 'us';
        address.Account_GLBL__c = acct.Id;
//        address.Phone_GLBL__c = '1111111111';
        insert address;

        return address;
    }

    public static Case createTestEmailRequest() {
        Case testCase = new Case();
        testCase.Origin = 'Email';
        testCase.Subject = 'Test';
        testCase.Description = 'Test';
        insert testCase;

        return testCase;
    }

    public static User createTestUser(){
    	User user = new User(alias='ccusysad', email= 'callcentertestusermvn@callcenter.com',
					            emailencodingkey='UTF-8', firstName='Reginald', lastname='Wellington', languagelocalekey='en_US',
					            localesidkey='en_US', profileid = [select Id from Profile where Name = 'System Administrator'].Id,
					            isActive = true, timezonesidkey='America/Los_Angeles', username='callcentertestusermvn@callcenter.com');
    	insert user;

    	return user;
    }

    public static void createSettings(){
        Service_Cloud_Settings_MVN__c mainSettings = new Service_Cloud_Settings_MVN__c();

        mainSettings.Knowledge_Search_Article_Types_MVN__c = 'FAQ_MVN__kav, Medical_Letter_MVN__kav';
        mainSettings.Knowledge_Search_Max_Results_MVN__c = 50;
        mainSettings.Interaction_Record_Type_MVN__c = 'Interaction_MVN';
        mainSettings.Interaction_Create_Origin_MVN__c = 'Email';
        mainSettings.Interaction_Create_Case_Record_Type_MVN__c = 'Request_Email_Case_MVN';
        mainSettings.Interaction_Anonymize_Countries_MVN__c = 'US';
        mainSettings.Request_Record_Type_MVN__c = 'Request_MVN';
        mainSettings.Person_Search_Default_Record_Type_MVN__c = 'HCP_GLBL';
        mainSettings.Person_Search_Record_Types_MVN__c = 'HCP_GLBL,Non_HCP_MERC,Employee_GLBL';
        mainSettings.Employee_Record_Type_MVN__c = 'Employee_GLBL';
        mainSettings.HCP_Record_Type_MVN__c = 'HCP_GLBL';
        mainSettings.Administrator_Email_MVN__c = 'test@test.com';
        mainSettings.Open_Status_MVN__c = 'Open';

        insert mainSettings;
    }
}