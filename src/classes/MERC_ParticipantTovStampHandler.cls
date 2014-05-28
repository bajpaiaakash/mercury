/**
 * @author Kyle Thornton
 *
 * Trigger handler to stamp the Participant_ToV_Updated_Date_MERC__c on a meeting when the travel itinerary
 * or Daily attendence for a meeting particpant has been marked as Confirm ToV reporting change
 */
public with sharing class MERC_ParticipantTovStampHandler implements GLBL_TriggerHandler.HandlerInterface
{
	private Schema.SobjectType triggeredSobjectType;

	public MERC_ParticipantTovStampHandler(Schema.SobjectType sobjectType)
	{
		this.triggeredSobjectType = sObjectType;
		if (Trigger.isInsert || Trigger.isUpdate ) {
	    	execute(Trigger.new);
	   	}
	}
	
	public Boolean isActive() 
	{
		return true;
	}

	public void handle()
	{
		if (Trigger.isInsert || Trigger.isUpdate ) {
	    	execute(Trigger.new);
	   	}
	}

	private void execute(List<SObject> sObjects)
	{
		Set<Id> meetingIdsToStamp = new Set<Id>();

		if (this.triggeredSobjectType == Travel_Itinerary_MERC__c.SObjectType)
		{
			for (Travel_Itinerary_MERC__c ti : (List<Travel_Itinerary_MERC__c>)sObjects)
			{
				if (ti.Confirm_ToV_Reporting_Change_MERC__c)
				{
					meetingIdsToStamp.add(ti.Meeting_Id_MERC__c);
				}
			}
		}

		if (this.triggeredSobjectType == Daily_Attendance_TOV_MERC__c.SObjectType)
		{
			for (Daily_Attendance_TOV_MERC__c tov : (List<Daily_Attendance_TOV_MERC__c>)sObjects)
			{
				if (tov.Confirm_ToV_Reporting_Change_MERC__c)
				{
					meetingIdsToStamp.add(tov.Meeting_Id_MERC__c);
				}
			}
		}

		List<Meeting_MERC__c> meetings = new List<Meeting_MERC__c>();
		for (Meeting_MERC__c meeting : [SELECT Id, Participant_ToV_Updated_Date_MERC__c, Participant_Tov_Final_MERC__c
			                              FROM Meeting_MERC__c
			                             WHERE ID IN :meetingIdsToStamp
			                               AND Participant_Tov_Final_MERC__c = 'Yes'])
		{
			if (meeting.Participant_Tov_Final_MERC__c == 'Yes') {
				meeting.Participant_ToV_Updated_Date_MERC__c = DateTime.now();
				meetings.add(meeting);
			}
		}

		update meetings;
	}
}