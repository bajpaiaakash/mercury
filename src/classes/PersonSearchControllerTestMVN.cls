/*
* PersonSearchControllerTestMVN
* Created By: Roman Lerman
* Created Date: 3/7/2013
* Description: This is the test class for the PersonSearchControllerMVN
*/
@isTest
private class PersonSearchControllerTestMVN {
  
    static {
    
        TestDataFactoryMVN.createSettings();


        //Product_vod__c product = new Product_vod__c(Name='Test Product', External_ID_vod__c = 'testid');
        //insert product;

        Account hcp = TestDataFactoryMVN.createTestHCP();
        Account employee = TestDataFactoryMVN.createTestEmployee();
    
        TestDataFactoryMVN.createTestAddress(hcp);
        TestDataFactoryMVN.createTestAddress(employee);
  }

  static Case interaction = new Case(); 
  static PersonSearchControllerMVN controller;
  
  /**
   * Narrative
   * In order to: track a customer
   * As a: Call center agent
   * I want to: find contacts and associate an account with the case
   */
  
  /**
   * Scenario 1: Account search should return according to term. 
   * Given: an HCP calls the call center
   * And: They exist in the database
   * When I search for Contacts
   * Then only the contacts that have this information should appear
   */
  
  /* Scenario 1 */
  static testMethod void accountSearchShouldReturnAccordingToTerm(){
    repReceivesCallandOpensSearch();
    repEntersContactInformation();
    searchTheAccounts();
    theAccountsReturnedShouldContainTheTerm();
  }

  public static void repReceivesCallandOpensSearch(){
    //Create a new request and controller
    interaction = TestDataFactoryMVN.createTestCase();
    Test.setCurrentPage(new PageReference('/apex/PersonSearchMVN?caseId='+interaction.Id));
    ApexPages.standardController stdController = new ApexPages.standardController(interaction);
    controller = new PersonSearchControllerMVN(stdController);
  }

  public static void repEntersContactInformation(){
    //"enter" the person's info.
    controller.searchAccount.FirstName  = 'Test';
    controller.searchAccount.LastName = 'Account';
    controller.searchAccount.Mdl_Nm_GLBL__c   = 'Lit*';
    controller.searchAddress.Line_1_Adrs_Txt_GLBL__c   = '1';
    controller.searchAddress.Line_2_Adrs_Txt_GLBL__c   = 'St.';
    controller.searchAddress.City_GLBL__c     = 'San Fran*';
    controller.searchAddress.Adrs_Cntry_Cd_GLBL__c    = 'US';
    controller.searchAddress.St_Cd_GLBL__c    = 'ca';
    controller.searchAddress.Zip_Postal_Code_GLBL__c      = '9*';
  }

  public static void searchTheAccounts(){
    //Search The accounts
    controller.doSearch();
  }

  public static void theAccountsReturnedShouldContainTheTerm(){
    //Confirm the results contain test in the first name and account in the last. 
    System.assert(controller.searchResults.size() > 0);
    for (PersonSearchResultMockMVN resultAddress : controller.searchResults){
      System.debug('resultAddress: ' + resultAddress);
      System.assertEquals(true,resultAddress.firstName.containsIgnoreCase('test'));
      System.assertEquals(true,resultAddress.lastName.containsIgnoreCase('account'));
    }
  }
  /**/

  /**
   * Scenario 2: Attach an HCP to a case.
   * Given an HCP identified in a search
   * When I select the address
   * The Account is attached to the case. 
   */
  
  static testMethod void selectedAddressAttachesAccountToCase(){
    repReceivesCallandOpensSearch();
    repEntersContactInformation();
    searchTheAccounts();
    selectAnAccount();
    theSelectedAddressAttachesTheAccountToTheCase();
  }

  public static void selectAnAccount(){
    //Pick a contact and add it to the case.
    controller.actId = controller.searchResults[0].acctId;
    controller.addId = controller.searchResults[0].addrId;
    controller.updateCase();
  }

  public static void theSelectedAddressAttachesTheAccountToTheCase(){
    System.assertEquals(controller.cs.AccountId,controller.searchResults[0].acctId);
  }


  /**
   * Scenario 3: Search for Employee and attach to case.
   * Given a Employee identified in a search
   * Attach them to a case.
   */
  
  static testMethod void searchForEmployeeAndAttachToCase(){
    repReceivesCallandOpensSearch();
    repEntersEmployeeInformation();
    repSetsTheRecordTypeToEmployee();
    searchTheEmployeeAccount();
    selectTheEmployee();
    theSelectedEmployeeIsAttachedToTheCase();

    controller.removeRequester();
    System.assertEquals(null,controller.cs.AccountId);
  }

  public static void repEntersEmployeeInformation(){
    controller.searchAccount.LastName   = 'Employee*';
    controller.searchAccount.FirstName  = 'Jo*';
  }

  public static void repSetsTheRecordTypeToEmployee(){
    controller.recordTypeText = [select Id from RecordType where SObjectType = 'Account' and DeveloperName = 'Employee_GLBL'][0].Id;
    controller.changeRecordType();
  }

  public static void searchTheEmployeeAccount(){
    controller.doSearch();
  }

  public static void selectTheEmployee(){
    controller.actId = controller.searchResults[0].acctId;
    controller.addId = controller.searchResults[0].addrId;
    controller.updateCase();
  }

  public static void theSelectedEmployeeIsAttachedToTheCase(){
    System.assertEquals(controller.cs.AccountId,controller.searchResults[0].acctId);
  }
  /***********/
  
  /**
   * Scenario 4: Search for Employee, employee isn't found, so a new Employee is created and attached to the Case.
   */
  static testMethod void createEmployeeAndAttachToCase(){
    repReceivesCallandOpensSearch();
    repEntersNewEmployeeInformation();
    repSetsTheRecordTypeToEmployee();
    searchTheEmployeeAccount();
    employeeNotFound();
    createEmployee();
    theCreatedEmployeeIsAttachedToTheCase();
  }
  public static void repEntersNewEmployeeInformation(){
    controller.searchAccount.LastName   = 'Employee';
    controller.searchAccount.FirstName  = 'Peter';
    controller.searchAddress.Line_1_Adrs_Txt_GLBL__c = '123 Test St';
  }
  public static void employeeNotFound(){
    System.assertEquals(0, controller.searchResults.size());
  }
  public static void createEmployee(){
    controller.updateNewPerson();
    controller.createAccount();
  }
  public static void theCreatedEmployeeIsAttachedToTheCase(){
    System.assertEquals([select Account.FirstName from Case where Id =: interaction.Id].Account.FirstName, 'Peter');
    System.assertEquals([select Account.LastName from Case where Id =: interaction.Id].Account.LastName, 'Employee');
  }
  
  /**
   * Scenario 5: Account search on phone should return according to term. 
   * Given: an HCP calls the call center
   * And: They exist in the database
   * When I search for phone number
   * Then only the contacts that have this information should appear
   */
  static testMethod void accountSearchShouldReturnAccordingToPhone(){
    //Define sosl search results
    Map<Id,Account> fixedSearchResults = new Map<Id,Account>([select Id from Account where Phone='5555555555']);
    Test.setFixedSearchResults(new List<Id>(fixedSearchResults.keySet()));


    repReceivesCallandOpensSearch();
    repEntersPhoneInformation();
    searchTheAccounts();
    theAccountsReturnedShouldContainThePhone();
  }

  public static void repEntersPhoneInformation(){
    //"enter" the person's info.
    controller.searchAccount.Phone = '5555555';
  }

  public static void theAccountsReturnedShouldContainThePhone(){
    //Confirm the results contain test in the first name and account in the last. 
    System.assert(controller.searchResults.size() > 0);
  }

  /**********/
  
  /**
   * Scenario 7: Search for Employee and add a referred by
   * Given: a rep calls on behalf of an HCP
   * And: They exist in the database
   * I can search and find them
   * I can then add them as a referred by
   */
  static testMethod void findEmployeeAndAttachToCase(){
    repReceivesCallandOpensSearch();
    repSetsEmployeeInformation();
    repSetsTheRecordTypeToEmployee();
    searchTheEmployeeAccount();
    employeeFound();
    addReferredBy();
    theEmployeeIsAttachedToTheCase();
  }
  public static void repSetsEmployeeInformation(){
    controller.searchAccount.LastName   = 'Employee';
    controller.searchAccount.FirstName  = 'Johnny';
  }
  public static void employeeFound(){
    System.assertEquals(1, controller.searchResults.size());
  }
  public static void addReferredBy(){
    controller.refId = controller.searchResults[0].acctId;
    controller.addReferredBy();
  }
  public static void theEmployeeIsAttachedToTheCase(){
    System.assertEquals([select Referred_By_GLBL__r.FirstName from Case where Id =: interaction.Id].Referred_By_GLBL__r.FirstName, 'Johnny');
    System.assertEquals([select Referred_By_GLBL__r.LastName from Case where Id =: interaction.Id].Referred_By_GLBL__r.LastName, 'Employee');
  }
  
  /**
   * Scenario 8: Remove Employee as Referred By
   * Given: a rep calls on behalf of an HCP
   * And: They exist in the database
   * I can search and find them
   * I can then add them as a referred by
   * But then I need to remove them since I picked the wrong rep
   */
  static testMethod void removeEmployeeFromCase(){
    repReceivesCallandOpensSearch();
    repSetsEmployeeInformation();
    repSetsTheRecordTypeToEmployee();
    searchTheEmployeeAccount();
    employeeFound();
    addReferredBy();
    theEmployeeIsAttachedToTheCase();
    removeReferredBy();
    checkThanReferredByIsRemoved();
    
  }
  public static void removeReferredBy(){
    controller.removeReferredBy();
  }
  public static void checkThanReferredByIsRemoved(){
    System.assertEquals([select Referred_By_GLBL__c from Case where Id =: interaction.Id].Referred_By_GLBL__c, null);
  }
  
  static testMethod void testViewRecordTypeSelections(){
    repReceivesCallandOpensSearch();

    RecordType rType = [select Id from RecordType where SObjectType='Account' and DeveloperName='HCP_GLBL' limit 1];
    
    System.assertEquals(rType.Id, controller.recordTypeText);
    System.debug(controller.recordTypeSelectOptions);
    System.assert(1 < controller.recordTypeSelectOptions.size());
        
    System.assertEquals(controller.recordTypeSelectOptions[0].getValue(), rType.Id);
  }

  static testMethod void testResultMock () {
    PersonSearchResultMockMVN psr = new PersonSearchResultMockMVN();

    psr.lastName = 'Smith';
    System.assertEquals('Smith',psr.getAccount().LastName);

    psr.city = 'Chicago';
    System.assertEquals('Chicago',psr.getAddress().City_GLBL__c);

    psr.setAccount(new Account(LastName='Jones'));
    System.assertEquals('Jones',psr.lastName);

    psr.setAddress(new Address_GLBL__c(Line_1_Adrs_Txt_GLBL__c='123 Main'));
    System.assertEquals('123 Main', psr.addressLine1);
  }

  static testMethod void testStandAloneSearch(){
    Case interactionEmpty = new Case();
    ApexPages.standardController stdController = new ApexPages.standardController(interactionEmpty);
    controller = new PersonSearchControllerMVN(stdController);

    System.assertEquals(true, controller.standAloneSearch);
    //System.assertEquals(null, controller.cs); TODO

    controller.searchAccount.LastName   = 'Employee';
    controller.searchAccount.FirstName  = 'Peter';
    controller.searchAccount.Fax  = '5555555';
    controller.searchAddress.Line_1_Adrs_Txt_GLBL__c = '123 Test St';

    controller.updateNewPerson();
    controller.enterAccount();

    List<Case> noCase = [select Id from Case where AccountId = :controller.createAccount.Id];

    System.assertEquals(true, noCase.isEmpty());

  }

  static testMethod void shortPhoneSearch(){
    repReceivesCallandOpensSearch();
    controller.searchAccount.Phone = '5';

    searchTheAccounts();

    System.assert(!ApexPages.getMessages().isEmpty());
  }

  static testMethod void doPhoneSearch(){
    interaction = TestDataFactoryMVN.createTestCase();
    Test.setCurrentPage(new PageReference('/apex/PersonSearchMVN?caseId='+interaction.Id+'&phoneSearch=true'));
    ApexPages.standardController stdController = new ApexPages.standardController(interaction);
    controller = new PersonSearchControllerMVN(stdController);
  }

  static testMethod void reachSearchLimit(){
    Service_Cloud_Settings_MVN__c settings = Service_Cloud_Settings_MVN__c.getInstance();
    settings.Knowledge_Search_Max_Results_MVN__c = 0;
    insert settings;
    
    repReceivesCallandOpensSearch();
    repEntersContactInformation();
    searchTheAccounts();
    
    System.assert(!ApexPages.getMessages().isEmpty());
  }

  static testMethod void testExceptions(){
    repReceivesCallandOpensSearch();

    Test.setReadOnlyApplicationMode(true);
    controller.removeRequester();
    controller.removeReferredBy();
    controller.addReferredBy();

    repEntersContactInformation();
    searchTheAccounts();
    controller.actId = controller.searchResults[0].acctId;
    controller.addId = controller.searchResults[0].addrId;

    controller.updateCase();
    Test.setReadOnlyApplicationMode(false);

    controller.searchAccount.LastName   = 'Employee';
    controller.searchAccount.FirstName  = 'Peter';
    controller.searchAccount.Fax  = '5555555';
    controller.searchAccount.Phone  = '5555555';
    controller.searchAddress.Line_1_Adrs_Txt_GLBL__c = '123 Test St';
    controller.searchAddress.City_GLBL__c = 'Chicago';

    controller.recordTypeText = 'All';  

    controller.doSearch();

    controller.updateNewPerson();

    //Test no Employee record types for requester or referred by
    controller.createAccount.RecordTypeId = controller.employeeRecordTypeId;

    controller.enterAccount();

    System.assert(!ApexPages.getMessages().isEmpty());

    ApexPages.getMessages().clear();

    //Test no empty record type
    controller.createAccount.RecordTypeId = null;

    controller.enterAccount();

    System.assert(!ApexPages.getMessages().isEmpty());

    ApexPages.getMessages().clear();  

    //Test bad email
    controller.searchAccount.PersonEmail  = 'asfljaksd';
    controller.createAccount.RecordTypeId = controller.hcpRecordTypeId;

    controller.enterAccount();

    System.assert(!ApexPages.getMessages().isEmpty());

    //Error creating Account
    controller.createAccount.FirstName = '';
    controller.createAccount.LastName = '';
    controller.searchAccount.PersonEmail  = 'test@test.com';
    controller.createAccount();

    //Search Term Required
    controller.searchAccount = new Account();
    controller.searchAddress = new Address_GLBL__c();

    controller.doSearch();
  }
}