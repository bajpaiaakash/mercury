public with sharing class MERC_MeetingParticipantCampaignHandler implements GLBL_TriggerHandler.HandlerInterface {
	
	public void handle() {
		if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
	    	execute((List<Meeting_Participant_MERC__c>)Trigger.new);
	   	} else if (Trigger.isDelete) {
	   		execute((List<Meeting_Participant_MERC__c>)Trigger.old);
	   	}
	}

	void execute(List<Meeting_Participant_MERC__c> participants) {
		List<CampaignMember> campaignMembers = new List<CampaignMember>();

		if (Trigger.isInsert) {
			Set<Id> meetingIds = new Set<Id>();
			for (Meeting_Participant_MERC__c mp : participants) {
				meetingIds.add(mp.Meeting_MERC__c);
			}
			Map<Id, Id> meetingIdToCampaignId = new Map<Id, Id>();
			for (Campaign c : [SELECT ID, Meeting_MERC__c FROM Campaign WHERE Meeting_MERC__c IN :meetingIds]) {
				meetingIdToCampaignId.put(c.Meeting_MERC__c, c.Id);
			}
			for (Meeting_Participant_MERC__c mp : participants) {
				if (meetingIdToCampaignId.get(mp.Meeting_MERC__c) != null) {
					CampaignMember member = new CampaignMember();
					member.CampaignId = meetingIdToCampaignId.get(mp.Meeting_MERC__c);
					member.ContactId = mp.Person_Contact_Id_MERC__c;
					member.Status = 'Sent';
					campaignMembers.add(member);
				}
			}
			if (campaignMembers.size() > 0)
				insert campaignMembers;
		}		
	}
}