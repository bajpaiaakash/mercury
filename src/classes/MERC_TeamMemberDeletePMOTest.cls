/*
* Unit Test to exercise trigger-bound MERC_TeamMemberDeletePMO class
*
* Author: Sean Harrison, Mavens
*/
@isTest
private class MERC_TeamMemberDeletePMOTest {
	
	static final Integer TEST_SET_SIZE = 200;

	static User testUser;
	static List<Account> accounts;
	static List<User> users;
	static List<Meeting_MERC__c> meetings;

	static {
		System.runAs(new User(Id=UserInfo.getUserId())) {
			users = MERC_TestFactory.insertTestUsers(TEST_SET_SIZE, null);
			testUser = MERC_TestFactory.getTestingUser();
		}

		System.runAs(testUser) {
			meetings = MERC_TestFactory.insertMeetings(TEST_SET_SIZE);
		}	
	}

	@isTest 
	static void insertNewPrimaryMeetingOwners() {
		List<Team_Member_MERC__c> members = MERC_TestFactory.insertNewPrimaryMeetingOwners(meetings, users, 'Mercury_User_MERC');

		meetings = [SELECT Meeting_Owner_Email_MERC__c, Prmry_Mtng_Ownr_Nm_MERC__c FROM Meeting_MERC__c WHERE Id in :meetings];
		for (Meeting_MERC__c m : meetings) {
			System.assert(m.Meeting_Owner_Email_MERC__c!=null && m.Prmry_Mtng_Ownr_Nm_MERC__c!=null,'Oops:'+m);
		}

		Test.startTest();
		MERC_DeleteNotifyService.skipCallout = true;
		delete members;
		Test.stopTest();

		meetings = [SELECT Meeting_Owner_Email_MERC__c, Prmry_Mtng_Ownr_Nm_MERC__c FROM Meeting_MERC__c WHERE Id in :meetings];
		for (Meeting_MERC__c m : meetings) {
			System.assert(m.Meeting_Owner_Email_MERC__c==null && m.Prmry_Mtng_Ownr_Nm_MERC__c==null,'Meeting fields not getting cleared. e.g. '+m);
		}
	}
}