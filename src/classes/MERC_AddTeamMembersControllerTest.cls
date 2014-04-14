@isTest
private class MERC_AddTeamMembersControllerTest {

	static Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1).get(0);
	static ApexPages.StandardController stdMeeting = new ApexPages.StandardController(meeting);
	static List<Account> employeeAccounts = insertEmployeeAccounts(10);
	static MERC_AddTeamMembersController controller = new MERC_AddTeamMembersController(stdMeeting);


	@isTest static void test_should_return_employees_on_search() {
		Test.startTest();
		controller.performSearch();
		System.assertEquals(10,controller.searchResults.size());
		Test.stopTest();
	}
	/*----- First name search tests -----*/
	@isTest static void test_should_return_employees_on_first_name_search() {
		Test.startTest();
		controller.searchAccount.FirstName = 'UnitTe';
		controller.performSearch();
		System.assertEquals(10,controller.searchResults.size());
		Test.stopTest();
	}

	@isTest static void test_should_not_return_employees_on_bad_first_name_search() {
		Test.startTest();
		controller.searchAccount.FirstName = 'Not a First Name';
		controller.performSearch();
		System.assertEquals(0,controller.searchResults.size());
		Test.stopTest();
	}

	/*----- Last name search tests -----*/
	@isTest static void test_should_return_employees_on_last_name_search() {
		Test.startTest();
		controller.searchAccount.LastName = 'Smith';
		controller.performSearch();
		System.assertEquals(10,controller.searchResults.size());
		Test.stopTest();
	}

	@isTest static void test_should_not_return_employees_on_bad_last_name_search() {
		Test.startTest();
		controller.searchAccount.LastName = 'Not A Last Name';
		controller.performSearch();
		System.assertEquals(0,controller.searchResults.size());
		Test.stopTest();
	}

	/*----- Email search tests -----*/
	@isTest static void test_should_return_employees_on_email_search() {
		Test.startTest();
		controller.searchAccount.PersonEmail = employeeAccounts.get(0).PersonEmail;
		controller.performSearch();
		System.assertEquals(1,controller.searchResults.size());
		Test.stopTest();
	}

	@isTest static void test_should_not_return_employees_on_bad_email_search() {
		Test.startTest();
		controller.searchAccount.PersonEmail = 'bademail@unittest.com';
		controller.performSearch();
		System.assertEquals(0,controller.searchResults.size());
		Test.stopTest();
	}

	/*----- Territory Id search tests -----*/
	@isTest static void test_should_return_employees_on_territory_id_search() {
		Test.startTest();
		controller.searchAccount.Territory_Id_GLBL__c = 'territory Id - ';
		controller.performSearch();
		System.assertEquals(10,controller.searchResults.size());
		Test.stopTest();
	}

	@isTest static void test_should_not_return_employees_on_bad_territory_id_search() {
		Test.startTest();
		controller.searchAccount.Territory_Id_GLBL__c = 'Not a territory';
		controller.performSearch();
		System.assertEquals(0,controller.searchResults.size());
		Test.stopTest();
	}

	/*----- Territory Code search tests -----*/
	@isTest static void test_should_return_employees_on_territory_code_search() {
		Test.startTest();
		controller.searchAccount.Trtry_Cd_GLBL__c = 'territory code - ';
		controller.performSearch();
		System.assertEquals(10,controller.searchResults.size());
		Test.stopTest();
	}

	@isTest static void test_should_not_return_employees_on_bad_territory_code_search() {
		Test.startTest();
		controller.searchAccount.Trtry_Cd_GLBL__c = 'Not a code';
		controller.performSearch();
		System.assertEquals(0,controller.searchResults.size());
		Test.stopTest();
	}

	/*----- Territory description search tests -----*/
	@isTest static void test_should_return_employees_on_territory_desc_search() {
		Test.startTest();
		controller.searchAccount.Trtry_Desc_GLBL__c = 'territory description - ';
		controller.performSearch();
		System.assertEquals(10,controller.searchResults.size());
		Test.stopTest();
	}

	@isTest static void test_should_not_return_employees_on_bad_territory_desc_search() {
		Test.startTest();
		controller.searchAccount.Trtry_Desc_GLBL__c = 'Not a description';
		controller.performSearch();
		System.assertEquals(0,controller.searchResults.size());
		Test.stopTest();
	}

	/*---- Exiting team member search result reconciliation -----*/
	@isTest static void test_should_return_employees_conditionally_based_on_onlyFieldUsers_flag() {
		for (Integer i=0; i<5; i++) {
			employeeAccounts[i].Territory_Id_GLBL__c = null;
		}
		update employeeAccounts;

		Test.startTest();
		controller.performSearch();
		System.assertEquals(5,controller.searchResults.size());

		/*----- toggle onlyFieldUsers. it's defaulted to true -----*/
		controller.onlyFieldUsers = false;
		controller.performSearch();
		System.assertEquals(10,controller.searchResults.size());
		Test.stopTest();
	}

	@isTest static void test_should_only_return_search_results_for_accounts_that_arent_already_team_members() {
		List<Team_Member_MERC__c> teamMembers = new List<Team_Member_MERC__c>();
		for (Integer i=0; i<5; i++) {
			teamMembers.add(new Team_Member_MERC__c( RecordTypeId    = MERC_AddTeamMembersController.externalUsersRecordTypeId
				                                   , Account_MERC__c = employeeAccounts.get(i).Id
				                                   , Meeting_MERC__c = meeting.Id));
		}
		insert teamMembers;

		Test.startTest();
		/*----- reinstantiate the controller -----*/
		controller = new MERC_AddTeamMembersController(stdMeeting);
		controller.performSearch();
		System.assertEquals(5,controller.searchResults.size());
		Test.stopTest();
	}

	private static List<Account> insertEmployeeAccounts(Integer numberOfAccounts) {
		List<Account> accs = new List<Account>();
		for (Integer i = 0; i < numberOfAccounts; i++) {
			String randomString    = MERC_Util.generateRandomString(8);
			Account a              = new Account();
			a.FirstName            = 'UnitTest';
			a.LastName             = 'Smith' + String.valueOf(i);
			a.RecordTypeId         = MERC_TestFactory.employeeRecordTypeId;
			a.PersonEmail          = 'ut-'+randomString+'@gmail.com';
			a.Territory_Id_GLBL__c = 'territory Id - ' + String.valueOf(i);
			a.Trtry_Cd_GLBL__c     = 'territory code - ' + String.valueOf(i);
			a.Trtry_Desc_GLBL__c   = 'territory description - ' + String.valueOf(i);
			accs.add(a);
		}
		insert accs;
		return accs;
	}
}