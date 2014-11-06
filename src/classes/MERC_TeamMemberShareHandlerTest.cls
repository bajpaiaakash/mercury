/**
 * @author Joseph Ferraro & Kyle Thornton
 *
 * This is the unit test class for the MERC_TeamMemberShareHandler and the MERC_TeamMemberShareHandlerUtility
 * The utility is a without sharing utility that runs asynchronously to avoid hierarchy issues when creating
 * team member shares.
 */
@isTest
private class MERC_TeamMemberShareHandlerTest {

	static List<User> testUsers;
	static Id mercuryUserRecordTypeId;
	static Id nonMercuryUserRecordTypeId;
	static List<Account> employeeAccs;

	static {
		System.runAs(new User(Id=UserInfo.getUserId())) {
			testUsers = MERC_TestFactory.insertTestUsers(3, null);
		}
		mercuryUserRecordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = 'Mercury_User_MERC' AND SobjectType = 'Team_Member_MERC__c'].ID;
		nonMercuryUserRecordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = 'External_User_MERC' AND SobjectType = 'Team_Member_MERC__c'].ID;
		employeeAccs = MERC_TestFactory.insertEmployeeAccounts(1);
	}

	@isTest static void test_should_handle_update() {
		Meeting_MERC__c mtg = MERC_TestFactory.insertMeetings(1).get(0);

		//deactivate trigger so we can manually create data and cirumvent the delay introduced by @future methods
		MERC_TriggerHandlerStateManager.deactivate(MERC_TeamMemberShareHandler.class);

		List<Team_Member_MERC__c> members = new List<Team_Member_MERC__c>{
			new Team_Member_MERC__c(User_MERC__c = testUsers.get(0).Id, Meeting_MERC__c = mtg.Id, RecordTypeId = mercuryUserRecordTypeId),
			new Team_Member_MERC__c(User_MERC__c = testUsers.get(1).Id, Meeting_MERC__c = mtg.Id, RecordTypeId = mercuryUserRecordTypeId)
		};
		insert members;

		List<Meeting_MERC__Share> shares = new List<Meeting_MERC__Share>{
			new Meeting_MERC__Share(ParentId=mtg.Id, UserOrGroupId=testUsers.get(0).Id,AccessLevel = 'Edit'),
			new Meeting_MERC__Share(ParentId=mtg.Id, UserOrGroupId=testUsers.get(1).Id,AccessLevel = 'Edit')
		};
		insert shares;

		System.assertEquals(2, [SELECT count() FROM Meeting_MERC__Share WHERE ParentId = :mtg.Id AND AccessLevel = 'Edit']);

		MERC_TriggerHandlerStateManager.activate(MERC_TeamMemberShareHandler.class);

		Test.startTest();
		members.get(0).User_MERC__c = testUsers.get(1).Id;
		members.get(1).User_MERC__c = testUsers.get(2).Id;
		update members;
		Test.stopTest();

		System.assertEquals(2, [SELECT count() FROM Meeting_MERC__Share WHERE ParentId = :mtg.Id AND AccessLevel = 'Edit']);
		System.assertEquals(1, [SELECT count()
									FROM Meeting_MERC__Share WHERE
										ParentId = :mtg.Id AND AccessLevel = 'Edit' AND UserOrGroupId = :testUsers.get(1).Id]);

		System.assertEquals(1, [SELECT count()
									FROM Meeting_MERC__Share WHERE
										ParentId = :mtg.Id AND AccessLevel = 'Edit' AND UserOrGroupId = :testUsers.get(2).Id]);

	}

	@isTest static void test_should_handle_delete() {
		Meeting_MERC__c mtg = MERC_TestFactory.insertMeetings(1).get(0);

		//deactivate trigger so we can manually create data and cirumvent the delay introduced by @future methods
		MERC_TriggerHandlerStateManager.deactivate(MERC_TeamMemberShareHandler.class);

		List<Team_Member_MERC__c> members = new List<Team_Member_MERC__c>{
			new Team_Member_MERC__c(User_MERC__c = testUsers.get(0).Id, Meeting_MERC__c = mtg.Id, RecordTypeId = mercuryUserRecordTypeId),
			new Team_Member_MERC__c(User_MERC__c = testUsers.get(1).Id, Meeting_MERC__c = mtg.Id, RecordTypeId = mercuryUserRecordTypeId)
		};
		insert members;

		List<Meeting_MERC__Share> shares = new List<Meeting_MERC__Share>{
			new Meeting_MERC__Share(ParentId=mtg.Id, UserOrGroupId=testUsers.get(0).Id,AccessLevel = 'Edit'),
			new Meeting_MERC__Share(ParentId=mtg.Id, UserOrGroupId=testUsers.get(1).Id,AccessLevel = 'Edit')
		};
		insert shares;

		System.assertEquals(2, [SELECT count() FROM Meeting_MERC__Share WHERE ParentId = :mtg.Id AND AccessLevel = 'Edit']);
		MERC_TriggerHandlerStateManager.activate(MERC_TeamMemberShareHandler.class);

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MERC_DeleteNotifyMock());
		MERC_DeleteNotifyService.skipCallout = true;
		delete members;
		Test.stopTest();
		System.assertEquals(0, [SELECT count() FROM Meeting_MERC__Share WHERE ParentId = :mtg.Id AND AccessLevel = 'Edit']);
	}

	@isTest static void test_should_add_team_member_share_records() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MERC_DeleteNotifyMock());
		Meeting_MERC__c mtg = MERC_TestFactory.insertMeetings(1).get(0);

		List<Team_Member_MERC__c> members = new List<Team_Member_MERC__c> {
			new Team_Member_MERC__c(User_MERC__c = testUsers.get(0).Id, Meeting_MERC__c = mtg.Id, RecordTypeId = mercuryUserRecordTypeId),
			new Team_Member_MERC__c(User_MERC__c = testUsers.get(1).Id, Meeting_MERC__c = mtg.Id, RecordTypeId = mercuryUserRecordTypeId),
			new Team_Member_MERC__c(Account_MERC__c = employeeAccs.get(0).Id, Meeting_MERC__c = mtg.Id, RecordTypeId = nonMercuryUserRecordTypeId)
		};
		insert members;
		Test.stopTest();

		System.assertEquals(2, [SELECT count()
									FROM Meeting_MERC__Share
										WHERE
											ParentId = :mtg.Id AND
											AccessLevel = 'Edit' AND
											(UserOrGroupId = :members.get(0).User_MERC__c OR UserOrGroupId = :members.get(1).User_MERC__c)]);

	}

	@isTest static void test_should_add_and_remove_team_member_share_records() {

		Meeting_MERC__c mtg = MERC_TestFactory.insertMeetings(1).get(0);

		//deactivate trigger so we can manually create data and cirumvent the delay introduced by @future methods
		MERC_TriggerHandlerStateManager.deactivate(MERC_TeamMemberShareHandler.class);

		List<Team_Member_MERC__c> members = new List<Team_Member_MERC__c>{
			new Team_Member_MERC__c(User_MERC__c = testUsers.get(0).Id, Meeting_MERC__c = mtg.Id),
			new Team_Member_MERC__c(User_MERC__c = testUsers.get(1).Id, Meeting_MERC__c = mtg.Id)
		};
		insert members;

		List<Meeting_MERC__Share> shares = new List<Meeting_MERC__Share>{
			new Meeting_MERC__Share(ParentId=mtg.Id, UserOrGroupId=testUsers.get(0).Id,AccessLevel = 'Edit'),
			new Meeting_MERC__Share(ParentId=mtg.Id, UserOrGroupId=testUsers.get(1).Id,AccessLevel = 'Edit')
		};
		insert shares;
		System.assertEquals(2, [SELECT count() FROM Meeting_MERC__Share WHERE ParentId = :mtg.Id AND AccessLevel = 'Edit']);

		//reactivate the trigger an start the test
		MERC_TriggerHandlerStateManager.activate(MERC_TeamMemberShareHandler.class);

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MERC_DeleteNotifyMock());
		MERC_DeleteNotifyService.skipCallout = true;
		delete members.get(0);
		Test.stopTest();

		System.assertEquals(1, [SELECT count() FROM Meeting_MERC__Share WHERE ParentId = :mtg.Id AND AccessLevel = 'Edit']);
		System.assertEquals(0, [SELECT count()
									FROM Meeting_MERC__Share WHERE
										ParentId = :mtg.Id AND AccessLevel = 'Edit' AND UserOrGroupId = :members.get(0).User_MERC__c]);

		System.assertEquals(1, [SELECT count()
									FROM Meeting_MERC__Share WHERE
										ParentId = :mtg.Id AND AccessLevel = 'Edit' AND UserOrGroupId = :members.get(1).User_MERC__c]);
	}

	@isTest static void test_should_prove_updates_to_team_members() {

		Meeting_MERC__c mtg = MERC_TestFactory.insertMeetings(1).get(0);

		//deactivate trigger so we can manually create data and cirumvent the delay introduced by @future methods
		MERC_TriggerHandlerStateManager.deactivate(MERC_TeamMemberShareHandler.class);

		List<Team_Member_MERC__c> members = new List<Team_Member_MERC__c>{
			new Team_Member_MERC__c(User_MERC__c = testUsers.get(0).Id, Meeting_MERC__c = mtg.Id),
			new Team_Member_MERC__c(User_MERC__c = testUsers.get(1).Id, Meeting_MERC__c = mtg.Id)
		};
		insert members;

		List<Meeting_MERC__Share> shares = new List<Meeting_MERC__Share>{
			new Meeting_MERC__Share(ParentId=mtg.Id, UserOrGroupId=testUsers.get(0).Id,AccessLevel = 'Edit'),
			new Meeting_MERC__Share(ParentId=mtg.Id, UserOrGroupId=testUsers.get(1).Id,AccessLevel = 'Edit')
		};
		insert shares;
		System.assertEquals(2, [SELECT count() FROM Meeting_MERC__Share WHERE ParentId = :mtg.Id AND AccessLevel = 'Edit']);

		//reactivate the trigger an start the test
		MERC_TriggerHandlerStateManager.activate(MERC_TeamMemberShareHandler.class);

		Test.startTest();
		members.get(1).User_MERC__c = testUsers.get(2).Id;
		update members.get(1);
		Test.stopTest();

		System.assertEquals(2, [SELECT count() FROM Meeting_MERC__Share WHERE ParentId = :mtg.Id AND AccessLevel = 'Edit'], [SELECT UserOrGroupId FROM Meeting_MERC__Share WHERE ParentId = :mtg.Id AND AccessLevel = 'Edit']);
		System.assertEquals(0, [SELECT count()
									FROM Meeting_MERC__Share WHERE
										ParentId = :mtg.Id AND AccessLevel = 'Edit' AND UserOrGroupId = :testUsers.get(1).Id]);

		System.assertEquals(1, [SELECT count()
									FROM Meeting_MERC__Share WHERE
										ParentId = :mtg.Id AND AccessLevel = 'Edit' AND UserOrGroupId = :testUsers.get(2).Id]);



	}

}