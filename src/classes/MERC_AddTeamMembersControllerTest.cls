@isTest
private class MERC_AddTeamMembersControllerTest {

	static Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1).get(0);
	static ApexPages.StandardController stdMeeting = new ApexPages.StandardController(meeting);

	@isTest static void test_should_return_employees_on_search() {
		Merc_TestFactory.insertEmployeeAccounts(10);
		MERC_AddTeamMembersController controller = new MERC_AddTeamMembersController(stdMeeting);
		controller.performSearch();
		System.assertEquals(10,controller.searchResults.size());
	}

	@isTest static void test_should_return_employees_on_first_name_search() {
		Merc_TestFactory.insertEmployeeAccounts(10);
		MERC_AddTeamMembersController controller = new MERC_AddTeamMembersController(stdMeeting);
		controller.firstName = 'UnitTe';
		controller.performSearch();
		System.assertEquals(10,controller.searchResults.size());
	}

	@isTest static void test_should_not_return_employees_on_bad_first_name_search() {
		Merc_TestFactory.insertEmployeeAccounts(10);
		MERC_AddTeamMembersController controller = new MERC_AddTeamMembersController(stdMeeting);
		controller.firstName = 'Not a First Name';
		controller.performSearch();
		System.assertEquals(0,controller.searchResults.size());
	}

	@isTest static void test_should_return_employees_on_last_name_search() {
		Merc_TestFactory.insertEmployeeAccounts(10);
		MERC_AddTeamMembersController controller = new MERC_AddTeamMembersController(stdMeeting);
		controller.lastName = 'Smith';
		controller.performSearch();
		System.assertEquals(10,controller.searchResults.size());
	}

	@isTest static void test_should_not_return_employees_on_bad_last_name_search() {
		Merc_TestFactory.insertEmployeeAccounts(10);
		MERC_AddTeamMembersController controller = new MERC_AddTeamMembersController(stdMeeting);
		controller.lastName = 'Not A Last Name';
		controller.performSearch();
		System.assertEquals(0,controller.searchResults.size());
	}
}