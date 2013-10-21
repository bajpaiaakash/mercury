public with sharing class MERC_TestFactory {
	
	static Id hcpRecordTypeId = [Select ID From RecordType Where SObjectType = 'Account' and Name = 'HCP'].ID;

	public static List<Account> insertAccounts(Integer numberOfAccounts) {
		List<Account> accs = new List<Account>();
		for (Integer i = 0; i < numberOfAccounts; i++) {
			Account a = new Account();
			a.FirstName = 'UnitTest';
			a.LastName = 'Smith'+numberOfAccounts;
			a.RecordTypeId = hcpRecordTypeId;
			a.PersonEmail = 'unittest'+i+'@gmail.com';
			accs.add(a);
		}
		insert accs;
		return accs;
	}

	public static List<Meeting_MERC__c> insertMeetings(Integer numberOfMeetings) {
		List<Meeting_MERC__c> mtgs = new List<Meeting_MERC__c>();
		for (Integer i = 0; i < numberOfMeetings; i++) {
			Meeting_MERC__c m = new Meeting_MERC__c();
			m.Date_of_Event_MERC__c = Date.today().addDays(2);
			m.Name = 'Event Name'+i;
			mtgs.add(m);
		}
		insert mtgs;
		return mtgs;
	}

	public static List<User> insertTestUsers(Integer numberOfUsers, String profileName) {
		List<User> users = new List<User>();

		if (profileName == null) {
			profileName = 'Mercury TCS';
		}

        Profile p = [SELECT id from Profile WHERE Profile.Name =  :profileName limit 1];   
        
        for (Integer i = 0; i < numberOfUsers; i++) {
	        String testemail = 'testuser'+i+'@unittest.com';
	        User u = new User(profileId = p.id, username = testemail, email = testemail, 
	                           emailencodingkey = 'UTF-8', localesidkey = 'en_US', 
	                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', 
	                           alias='utuser'+i, lastname='lastname');
	        users.add(u);
	    }
        
        Database.insert(users);
        return users;
	}
}