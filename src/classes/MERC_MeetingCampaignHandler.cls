public with sharing class MERC_MeetingCampaignHandler implements GLBL_TriggerHandler.HandlerInterface {
	
	public void handle() {
		if (Trigger.isInsert) {
	    	execute((List<Meeting_MERC__c>)Trigger.new);
	   	}
	}

	void execute(List<Meeting_MERC__c> meetings) {
		List<Campaign> campaigns = new List<Campaign>();
		for (Meeting_MERC__c m : meetings) {
			Campaign c = new Campaign();
			c.Name = m.Name;
			c.Status = 'In Progress';
			c.Meeting_MERC__c = m.Id;
			campaigns.add(c);
		}
		insert campaigns;
	}
}