@isTest
private class MERC_ContentVersionHandlerTest {
	
	static List<Account> accs;
	static List<Meeting_MERC__c> mtgs;
	static List<Meeting_Participant_MERC__c> ps;
	static HCP_Contract_MERC__c contract;

	static {
		accs = MERC_TestFactory.insertAccounts(1);
		mtgs = MERC_TestFactory.insertMeetings(1);
		ps = MERC_TestFactory.insertParticipants(mtgs.get(0).Id, accs);
		contract = MERC_TestFactory.insertHCPContract(accs.get(0).Id);
	}

	@isTest static void upload_content() {
		// ContentWorkspace cw = new ContentWorkspace();
		// cw.Name = 'Mercury';
		// insert cw;

		// ContentVersion c = new ContentVersion();
		// c.HCP_Contract_MERC__c = contract.Id;
		// c.Title = 'foo';
		// c.FirstPublishLocationId = cw.Id;
		// insert c;
	}
	
}