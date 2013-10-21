@isTest
private class MERC_TeamMemberShareHandlerTest {
	
	static List<User> testUsers;

	static {
		testUsers = MERC_TestFactory.insertTestUsers(3, null);
	}

	@isTest static void test_should_handle_bulk() {
		Test.startTest();
		Meeting_MERC__c mtg = MERC_TestFactory.insertMeetings(1).get(0);
		
		List<Team_Member_MERC__c> members = new List<Team_Member_MERC__c>();

		Team_Member_MERC__c member1 = new Team_Member_MERC__c();
		member1.User_MERC__c = testUsers.get(0).Id;
		member1.Meeting_MERC__c = mtg.Id;
		members.add(member1);

		Team_Member_MERC__c member2 = new Team_Member_MERC__c();
		member2.User_MERC__c = testUsers.get(1).Id;
		member2.Meeting_MERC__c = mtg.Id;
		members.add(member2);

		insert members;

		System.assertEquals(2, [SELECT count() FROM Meeting_MERC__Share WHERE ParentId = :mtg.Id AND AccessLevel = 'Edit']);

		member1.User_MERC__c = testUsers.get(1).Id;
		member2.User_MERC__c = testUsers.get(2).Id;

		update members;

		System.assertEquals(2, [SELECT count() FROM Meeting_MERC__Share WHERE ParentId = :mtg.Id AND AccessLevel = 'Edit']);
		System.assertEquals(1, [SELECT count() 
									FROM Meeting_MERC__Share WHERE 
										ParentId = :mtg.Id AND AccessLevel = 'Edit' AND UserOrGroupId = :testUsers.get(1).Id]);

		System.assertEquals(1, [SELECT count() 
									FROM Meeting_MERC__Share WHERE 
										ParentId = :mtg.Id AND AccessLevel = 'Edit' AND UserOrGroupId = :testUsers.get(2).Id]);

		
		delete members;
		System.assertEquals(0, [SELECT count() FROM Meeting_MERC__Share WHERE ParentId = :mtg.Id AND AccessLevel = 'Edit']);

		Test.stopTest();

	}

	@isTest static void test_should_add_team_member_share_records() {
		Test.startTest();
		Meeting_MERC__c mtg = MERC_TestFactory.insertMeetings(1).get(0);
		
		Team_Member_MERC__c member1 = new Team_Member_MERC__c();
		member1.User_MERC__c = testUsers.get(0).Id;
		member1.Meeting_MERC__c = mtg.Id;
		insert member1;

		Team_Member_MERC__c member2 = new Team_Member_MERC__c();
		member2.User_MERC__c = testUsers.get(1).Id;
		member2.Meeting_MERC__c = mtg.Id;
		insert member2;

		Test.stopTest();

		System.assertEquals(2, [SELECT count() 
									FROM Meeting_MERC__Share 
										WHERE 
											ParentId = :mtg.Id AND 
											AccessLevel = 'Edit' AND 
											(UserOrGroupId = :member1.User_MERC__c OR UserOrGroupId = :member2.User_MERC__c)]);

	}

	@isTest static void test_should_add_and_remove_team_member_share_records() {
		Test.startTest();
		Meeting_MERC__c mtg = MERC_TestFactory.insertMeetings(1).get(0);
		
		Team_Member_MERC__c member1 = new Team_Member_MERC__c();
		member1.User_MERC__c = testUsers.get(0).Id;
		member1.Meeting_MERC__c = mtg.Id;
		insert member1;

		Team_Member_MERC__c member2 = new Team_Member_MERC__c();
		member2.User_MERC__c = testUsers.get(1).Id;
		member2.Meeting_MERC__c = mtg.Id;
		insert member2;

		System.assertEquals(2, [SELECT count() FROM Meeting_MERC__Share WHERE ParentId = :mtg.Id AND AccessLevel = 'Edit']);

		delete member1;

		System.assertEquals(1, [SELECT count() FROM Meeting_MERC__Share WHERE ParentId = :mtg.Id AND AccessLevel = 'Edit']);
		System.assertEquals(0, [SELECT count() 
									FROM Meeting_MERC__Share WHERE 
										ParentId = :mtg.Id AND AccessLevel = 'Edit' AND UserOrGroupId = :member1.User_MERC__c]);

		System.assertEquals(1, [SELECT count() 
									FROM Meeting_MERC__Share WHERE 
										ParentId = :mtg.Id AND AccessLevel = 'Edit' AND UserOrGroupId = :member2.User_MERC__c]);



		Test.stopTest();
	}

	@isTest static void test_should_prove_updates_to_team_members() {
		Test.startTest();
		Meeting_MERC__c mtg = MERC_TestFactory.insertMeetings(1).get(0);
		
		Team_Member_MERC__c member1 = new Team_Member_MERC__c();
		member1.User_MERC__c = testUsers.get(0).Id;
		member1.Meeting_MERC__c = mtg.Id;
		insert member1;

		Team_Member_MERC__c member2 = new Team_Member_MERC__c();
		member2.User_MERC__c = testUsers.get(1).Id;
		member2.Meeting_MERC__c = mtg.Id;
		insert member2;

		System.assertEquals(2, [SELECT count() FROM Meeting_MERC__Share WHERE ParentId = :mtg.Id AND AccessLevel = 'Edit']);

		member2.User_MERC__c = testUsers.get(2).Id;
		update member2;

		Test.stopTest();

		System.assertEquals(2, [SELECT count() FROM Meeting_MERC__Share WHERE ParentId = :mtg.Id AND AccessLevel = 'Edit']);
		System.assertEquals(0, [SELECT count() 
									FROM Meeting_MERC__Share WHERE 
										ParentId = :mtg.Id AND AccessLevel = 'Edit' AND UserOrGroupId = :testUsers.get(1).Id]);

		System.assertEquals(1, [SELECT count() 
									FROM Meeting_MERC__Share WHERE 
										ParentId = :mtg.Id AND AccessLevel = 'Edit' AND UserOrGroupId = :testUsers.get(2).Id]);



	}

}