/*
* Unit Test to exercise trigger-bound MERC_TeamMemberDeletePMO class
*
* Author: Sean Harrison, Mavens
*/
@isTest
private class MERC_TeamMemberDeletePMOTest {
	
	static final Integer TEST_SET_SIZE = 200;

	static List<Account> accounts;
	static List<User> users;
	static List<Meeting_MERC__c> meetings;

	static {
		users = MERC_TestFactory.insertTestUsers(TEST_SET_SIZE, null);
		meetings = MERC_TestFactory.insertMeetings(TEST_SET_SIZE);
	}

	@isTest 
	static void insertNewPrimaryMeetingOwners() {
<<<<<<< HEAD
		List<Team_Member_MERC__c> members = insertNewPrimaryMeetingOwners(meetings, users, 'Mercury_User_MERC');
=======
		List<Team_Member_MERC__c> members = MERC_TestFactory.insertNewPrimaryMeetingOwners(meetings, users, 'Mercury_User_MERC');
>>>>>>> 038d9c54d876da9a1530fddfc3f8fbb7b4bdc2f5

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

<<<<<<< HEAD
	static List<Team_Member_MERC__c> insertNewPrimaryMeetingOwners(List<Meeting_MERC__c> meets, List<User> members, String RT) {
		if (meets.size()!=members.size()) return null;

		List<Team_Member_MERC__c> result = new List<Team_Member_MERC__c>();

		// clear fields to satisfy validation rule
		meets = [SELECT Meeting_Owner_Email_MERC__c, Prmry_Mtng_Ownr_Nm_MERC__c FROM Meeting_MERC__c WHERE Id in :meets];
		for (Meeting_MERC__c m : meets) {
			m.Meeting_Owner_Email_MERC__c = null;
			m.Prmry_Mtng_Ownr_Nm_MERC__c = null;
		}
		update meets;

		Id recTypeId = [Select ID From RecordType Where SObjectType = 'Team_Member_MERC__c' and DeveloperName = :RT].ID;
		for (Integer n = 0; n<meets.size(); n++) {
			Team_Member_MERC__c tm = new Team_Member_MERC__c();
			tm.RecordTypeId = recTypeId;
			tm.User_MERC__c = members.get(n).Id;
			tm.Meeting_MERC__c = meets.get(n).Id;
			tm.Role_MERC__c	= MERC_TeamMemberDeletePMO.PMO;	
			result.add(tm);
			
			meets.get(n).Meeting_Owner_Email_MERC__c = members.get(n).Email;
			meets.get(n).Prmry_Mtng_Ownr_Nm_MERC__c = members.get(n).FirstName +' '+members.get(n).LastName;
		}
		insert result;
		update meets;

		return result;
	}
=======
>>>>>>> 038d9c54d876da9a1530fddfc3f8fbb7b4bdc2f5
}