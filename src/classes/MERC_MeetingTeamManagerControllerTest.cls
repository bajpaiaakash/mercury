@isTest
private class MERC_MeetingTeamManagerControllerTest {

	static User runningUser = MERC_TestFactory.getRunningUser();
	static User testUser = MERC_TestFactory.getTestingUser();
	static Meeting_MERC__c meeting;
	static ApexPages.StandardSetController ssc;
	static List<Account> employeeAccounts;
	static
	{
		System.runAs(runningUser)
		{
			meeting = MERC_TestFactory.insertMeetings(1).get(0);
			employeeAccounts = insertEmployeeAccounts(10);
		}
		ssc = new ApexPages.StandardSetController(new List<Meeting_MERC__c>{meeting});
		PageReference testPage = Page.MERC_MeetingTeamManager;
		testPage.getParameters().put('id', meeting.Id);
		Test.setCurrentPage(testPage);
	}

	@isTest static void test_should_be_able_to_add_mercury_user_as_team_member() {
		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);

			/*----- get the team member size before starting. This way we can tell if it increases by 1
			        and is agnostic of other processes such as the primary meeting owner trigger -----*/
			Integer teamMemberSizeBefore = [SELECT COUNT() FROM Team_Member_MERC__c WHERE Meeting_MERC__c=:meeting.id];

			Integer childrenSize = controller.childrenMap.get('Mercury_User_MERC').size();
			ApexPages.currentPage().getParameters().put('rtdn', 'Mercury_User_MERC');
			controller.add();
			System.assertEquals(childrenSize+1, controller.childrenMap.get('Mercury_User_MERC').size());

			/* populate the new record */
			controller.childrenMap.get('Mercury_User_MERC').get(childrenSize).so.put('User_MERC__c', [SELECT Id from User where IsActive=true limit 1].Id);
			controller.save();


			System.assertEquals(teamMemberSizeBefore+1, [SELECT COUNT() FROM Team_Member_MERC__c WHERE Meeting_MERC__c=:meeting.id]);
			Test.stopTest();
		}
	}

	@isTest static void test_should_be_able_to_catch_exceptions() {
		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);

			/*----- get the team member size before starting. This way we can tell if it increases by 1
			        and is agnostic of other processes such as the primary meeting owner trigger -----*/
			Integer teamMemberSizeBefore = [SELECT COUNT() FROM Team_Member_MERC__c WHERE Meeting_MERC__c=:meeting.id];

			Integer childrenSize = controller.childrenMap.get('Mercury_User_MERC').size();
			ApexPages.currentPage().getParameters().put('rtdn', 'Mercury_User_MERC');
			controller.add();
			System.assertEquals(childrenSize+1, controller.childrenMap.get('Mercury_User_MERC').size());

			/* populate the new record */
			controller.childrenMap.get('Mercury_User_MERC').get(childrenSize).so.put('User_MERC__c', [SELECT Id from User where IsActive=true limit 1].Id);
			Test.setReadOnlyApplicationMode(true);
			System.assertEquals(null, controller.save());
			System.assert(ApexPages.getMessages().size() > 0);

			Test.stopTest();
		}
	}

	@isTest static void test_should_be_able_to_add_external_user_as_team_member() {
		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);

			/*----- get the team member size before starting. This way we can tell if it increases by 1
			        and is agnostic of other processes such as the primary meeting owner trigger -----*/
			Integer teamMemberSizeBefore = [SELECT COUNT() FROM Team_Member_MERC__c WHERE Meeting_MERC__c=:meeting.id];

			Integer childrenSize = controller.childrenMap.get('External_User_MERC').size();
			ApexPages.currentPage().getParameters().put('rtdn', 'External_User_MERC');
			controller.add();
			System.assertEquals(childrenSize+1, controller.childrenMap.get('External_User_MERC').size());

			/* populate the new record */
			controller.childrenMap.get('External_User_MERC').get(childrenSize).so.put('Account_MERC__c', employeeAccounts.get(0).Id);
			controller.save();


			System.assertEquals(teamMemberSizeBefore+1, [SELECT COUNT() FROM Team_Member_MERC__c WHERE Meeting_MERC__c=:meeting.id]);
			Test.stopTest();
		}
	}

	@isTest static void test_should_be_able_to_mass_add_external_employees() {
		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);

			/*----- get the team member size before starting. This way we can tell if it increases by 1
			        and is agnostic of other processes such as the primary meeting owner trigger -----*/
			Integer teamMemberSizeBefore = [SELECT COUNT() FROM Team_Member_MERC__c WHERE Meeting_MERC__c=:meeting.id];

			controller.doSearch();
			for (Integer i=0; i<5; i++) {
				controller.searchResults.get(i).selected = true;
			}
			ApexPages.currentPage().getParameters().put('rtdn', 'External_User_MERC');
			controller.addSelected();
			System.assertEquals(teamMemberSizeBefore+5, [SELECT COUNT() FROM Team_Member_MERC__c WHERE Meeting_MERC__c=:meeting.id]);

			/*----- ensure search results now only lists 5 results -----*/
			System.assertEquals(5, controller.searchResults.size());
			Test.stopTest();
		}
	}

	@isTest static void test_should_return_select_options_for_radio() {
		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);
			System.assertEquals(2, controller.getRadioOptions().size());
			Test.stopTest();
		}
	}

	@isTest static void test_should_return_employees_on_search() {
		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);
			controller.doSearch();
			System.assertEquals(10,controller.searchResults.size());
			Test.stopTest();
		}
	}
	/*----- First name search tests -----*/
	@isTest static void test_should_return_employees_on_first_name_search() {
		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);
			controller.firstName = 'UnitTe';
			controller.doSearch();
			System.assertEquals(10,controller.searchResults.size());
			Test.stopTest();
		}
	}

	@isTest static void test_should_not_return_employees_on_bad_first_name_search() {
		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);
			controller.firstName = 'Not a First Name';
			controller.doSearch();
			System.assertEquals(0,controller.searchResults.size());
			Test.stopTest();
		}
	}

	/*----- Last name search tests -----*/
	@isTest static void test_should_return_employees_on_last_name_search() {
		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);
			controller.lastName = 'Smith';
			controller.doSearch();
			System.assertEquals(10,controller.searchResults.size());
			Test.stopTest();
		}
	}

	@isTest static void test_should_not_return_employees_on_bad_last_name_search() {
		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);
			controller.lastName = 'Not A Last Name';
			controller.doSearch();
			System.assertEquals(0,controller.searchResults.size());
			Test.stopTest();
		}
	}

	/*----- Email search tests -----*/
	@isTest static void test_should_return_employees_on_email_search() {
		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);
			controller.email = employeeAccounts.get(0).PersonEmail;
			controller.doSearch();
			System.assertEquals(1,controller.searchResults.size());
			Test.stopTest();
		}
	}

	@isTest static void test_should_not_return_employees_on_bad_email_search() {
		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);
			controller.email = 'bademail@unittest.com';
			controller.doSearch();
			System.assertEquals(0,controller.searchResults.size());
			Test.stopTest();
		}
	}

	/*----- Territory Id search tests -----*/
	@isTest static void test_should_return_employees_on_territory_id_search() {
		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);
			controller.territoryId = 'territory Id - ';
			controller.doSearch();
			System.assertEquals(10,controller.searchResults.size());
			Test.stopTest();
		}
	}

	@isTest static void test_should_not_return_employees_on_bad_territory_id_search() {
		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);
			controller.territoryId = 'Not a territory';
			controller.doSearch();
			System.assertEquals(0,controller.searchResults.size());
			Test.stopTest();
		}
	}

	/*----- Territory Code search tests -----*/
	@isTest static void test_should_return_employees_on_territory_code_search() {
		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);
			controller.territoryCode = 'territory code - ';
			controller.doSearch();
			System.assertEquals(10,controller.searchResults.size());
			Test.stopTest();
		}
	}

	@isTest static void test_should_not_return_employees_on_bad_territory_code_search() {
		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);
			controller.territoryCode = 'Not a code';
			controller.doSearch();
			System.assertEquals(0,controller.searchResults.size());
			Test.stopTest();
		}
	}

	/*----- Territory description search tests -----*/
	@isTest static void test_should_return_employees_on_territory_desc_search() {
		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);
			controller.territoryDesc = 'territory description - ';
			controller.doSearch();
			System.assertEquals(10,controller.searchResults.size());
			Test.stopTest();
		}
	}

	@isTest static void test_should_not_return_employees_on_bad_territory_desc_search() {
		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);
			controller.territoryDesc = 'Not a description';
			controller.doSearch();
			System.assertEquals(0,controller.searchResults.size());
			Test.stopTest();
		}
	}

	/*---- Exiting team member search result reconciliation -----*/
	@isTest static void test_should_return_employees_conditionally_based_on_onlyFieldUsers_flag() {
		for (Integer i=0; i<5; i++) {
			employeeAccounts[i].Territory_Id_GLBL__c = null;
		}
		update employeeAccounts;

		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);
			controller.doSearch();
			System.assertEquals(5,controller.searchResults.size());

			/*----- toggle searchForUsers to search for all employees -----*/
			controller.searchForUsers = 'all';
			controller.doSearch();
			System.assertEquals(10,controller.searchResults.size());
			Test.stopTest();
		}
	}

	@isTest static void test_should_only_return_search_results_for_accounts_that_arent_already_team_members() {
		List<Team_Member_MERC__c> teamMembers = new List<Team_Member_MERC__c>();
		Id externalUsersRecordTypeId = [SELECT Id
                                          FROM RecordType
	                                     WHERE SObjectType = 'Team_Member_MERC__c'
	                                       AND DeveloperName='External_User_MERC' LIMIT 1].Id;

		for (Integer i=0; i<5; i++) {
			teamMembers.add(new Team_Member_MERC__c( RecordTypeId    = externalUsersRecordTypeId
				                                   , Account_MERC__c = employeeAccounts.get(i).Id
				                                   , Meeting_MERC__c = meeting.Id));
		}
		insert teamMembers;

		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);
			controller.doSearch();
			System.assertEquals(5,controller.searchResults.size());
			Test.stopTest();
		}
	}

	@isTest static void test_should_getCountryOptions() {
		System.runAs(testUser) {
			Test.startTest();
			MERC_MeetingTeamManagerController controller = new MERC_MeetingTeamManagerController(ssc);
			System.assert(controller.getCountryOptions().size() > 0);
			Test.stopTest();
		}
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