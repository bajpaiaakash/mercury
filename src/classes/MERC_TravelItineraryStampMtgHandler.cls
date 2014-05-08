/**
 * @author Kyle Thornton
 *
 * Trigger handler to stamp the Participant_ToV_Updated_Date_MERC__c on a meeting when the travel itinerary
 * for a meeting particpant has been marked as Confirm ToV reporting change
 */
public with sharing class MERC_TravelItineraryStampMtgHandler implements GLBL_TriggerHandler.HandlerInterface
{

	public void handle()
	{
		Set<Id> meetingIdsToStamp = new Set<Id>();
		for (Travel_Itinerary_MERC__c ti : (List<Travel_Itinerary_MERC__c>)Trigger.new)
		{
			if (ti.Confirm_ToV_Reporting_Change_MERC__c)
			{
				meetingIdsToStamp.add(ti.Meeting_Id_MERC__c);
			}
		}

		List<Meeting_MERC__c> meetings = new List<Meeting_MERC__c>();
		for (Meeting_MERC__c meeting : [SELECT Id, Participant_ToV_Updated_Date_MERC__c FROM Meeting_MERC__c WHERE ID IN :meetingIdsToStamp])
		{
			meeting.Participant_ToV_Updated_Date_MERC__c = DateTime.now();
			meetings.add(meeting);
		}

		update meetings;
	}
}