/**
 * @author Kyle Thornton
 *
 * Trigger handler that adds a mercury user to the meeting team as a Primary Meeting Owner
 *   when they create a new meeting.
 */

public with sharing class MERC_PrimaryMeetingOwnerHandler implements GLBL_TriggerHandler.HandlerInterface{

    public Boolean isActive() 
    {
        return MERC_TriggerHandlerStateManager.isActive(MERC_PrimaryMeetingOwnerHandler.class);
    }

	public void handle()
    {
        List<Team_Member_MERC__c> primaryOwnerTeamMembers = new List<Team_Member_MERC__c>();
    	for (Meeting_MERC__c m : (List<Meeting_MERC__c>)Trigger.new)
    	{
    		if (m.Source_MERC__c == 'Mercury')
    		{
				Team_Member_MERC__c teamMember = new Team_Member_MERC__c();
				teamMember.User_MERC__c        = m.CreatedById;
				teamMember.Role_MERC__c        = 'Primary Meeting Owner';
				teamMember.Meeting_MERC__c     = m.id;
    			primaryOwnerTeamMembers.add(teamMember);
    		}
    	}

    	if (MERC_TestFactory.adjustForSFDCSetMockBug) {insertThePOTMs(JSON.serialize(primaryOwnerTeamMembers));} else {insert primaryOwnerTeamMembers;}
    }

    // sean is testing something...
    @future
    static void insertThePOTMs(String potmString)
    {
        List<Team_Member_MERC__c> primaryOwnerTeamMembers = new List<Team_Member_MERC__c>();
        primaryOwnerTeamMembers.addAll((List<Team_Member_MERC__c>) JSON.deserialize(potmString, List<Team_Member_MERC__c>.class));
        insert primaryOwnerTeamMembers;
    }
}