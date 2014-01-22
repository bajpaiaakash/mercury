/**
 * @author Joseph Ferraro
 *
 * Stamps static text field with a user-friendly date/time value
 */
public with sharing class MERC_TimestampHandler implements GLBL_TriggerHandler.HandlerInterface {
	
	Schema.SobjectType triggeredSobjectType;

	public MERC_TimestampHandler(Schema.SobjectType sobjectType) {
		this.triggeredSobjectType = sObjectType;
	}

	public void handle() {
		if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
	    	execute(Trigger.new);
	   	} else if (Trigger.isDelete) {
	   		execute(Trigger.old);
	   	}
	}

	void execute(List<SObject> sobjects) {		
		if (
			this.triggeredSobjectType == Meeting_MERC__c.sObjectType ||
			this.triggeredSobjectType == Travel_Itinerary_MERC__c.sObjectType
		) {
			MERC_TimeZoneUtility tz = new MERC_TimeZoneUtility(this.triggeredSobjectType);
			tz.applyTimeZoneSpecificTimestamps(sobjects, null);
		} else if (
			this.triggeredSobjectType == Agenda_Item_MERC__c.sObjectType || 
			this.triggeredSobjectType == Meeting_Day_MERC__c.sObjectType
		) {
			MERC_TimeZoneUtility tz = new MERC_TimeZoneUtility(this.triggeredSobjectType);

			Set<Id> meetingIds = new Set<Id>();
			for (Sobject s : sobjects)
				meetingIds.add((Id)s.get('Meeting_MERC__c'));

			Map<Id,String> meetingToMeetingTimeZone = new Map<Id,String>();
			for (Meeting_MERC__c m : [SELECT Id, Meeting_Time_Zone_MERC__c FROM Meeting_MERC__c WHERE ID in :meetingIds]) {
				meetingToMeetingTimeZone.put(m.Id, m.Meeting_Time_Zone_MERC__c);
			}	
					
			for (Sobject s : sobjects) {
				String meetingTimeZone = (String)meetingToMeetingTimeZone.get((Id)s.get('Meeting_MERC__c'));
				tz.applyTimeZoneSpecificTimestamps(new List<Sobject>{s}, meetingTimeZone);
			}
		} 
	}
}