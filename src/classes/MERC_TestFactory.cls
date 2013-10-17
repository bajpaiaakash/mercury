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
		}
		return accs;
		
	}
}