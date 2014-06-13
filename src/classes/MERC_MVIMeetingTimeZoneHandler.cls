/**
 * @author Kyle Thornton
 *
 * Description: Veeva Meetings are created using picklists for the start and end times. A workflow uses the picklist
 * values along with date fields to create datetime values. Those values in veeva are relative to the timezone set
 * on the meeting. When the integration moves the values over the datetime values represent the time in the meeting
 * time zone. The MERC_TimestampHandler assumes that the fields where these values are stamped are GMT values.
 *
 * The purpose of this trigger is to convert the values sent through MVI to GMT so that the MERC_TimeStampHandler
 * can run correctly. The trigger will only run once (Static variable to control) and only for the MVI user. It is
 * assumed that any other user is entering these values in this system and the value is stored as GMT.
 */
public with sharing class MERC_MVIMeetingTimeZoneHandler implements GLBL_TriggerHandler.HandlerInterface
{
	/* Control variable */
	public static Boolean hasRun=false;

	/* implemented per interface. Should never need to turn this trigger off*/
	public Boolean isActive()
	{
		return true;
	}

	public void handle()
	{
		/* ensure the trigger hasn't run and that we are in a before insert or update context.
		   also we don't want to run this in an @future context as it might duplicate our calculations
		   since we can't control the hasRun variable in that context */
		if (!hasRun && Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate) && !System.isFuture())
		{
			User mviUser = [SELECT Id FROM User WHERE Alias='MercVeev'];

			if (mviUser.Id != UserInfo.getUserId())
			{
				return;
			}
			else
			{
				execute();
			}
		}
	}

	private void execute()
	{
		hasRun = true;

		/* get a field describe so we can figure out whether we are working with date or date/time fields */
		Map<String, Schema.SObjectField> meetingFieldsMap = Schema.describeSObjects(new LIST<String> {'Meeting_MERC__c'}).get(0).fields.getMap();

		/* query the custom setting to figure out which fields need to be converted */
		Map<String,String> fieldNameToTimeZoneMapping = new Map<String,String>();
		for (Time_Zone_Field_Mappings_MERC__c tzfm : [SELECT Time_Zone_Field_API_Name_MERC__c, Field_API_Name_MERC__c
			                                            FROM Time_Zone_Field_Mappings_MERC__c
			                                           WHERE Object_API_Name_MERC__c='Meeting_MERC__c'])
		{
			fieldNameToTimeZoneMapping.put(tzfm.Field_API_Name_MERC__c, tzfm.Time_Zone_Field_API_Name_MERC__c);
		}

		/* iterate over the meetings in the trigger and convert any neccessary fields */
		for (Meeting_MERC__c meeting : (List<Meeting_MERC__c>)Trigger.new)
		{
			for (String field : fieldNameToTimeZoneMapping.keySet())
			{
				if (meetingFieldsMap.get(field).getDescribe().getType() != Schema.DisplayType.DateTime)
				{
					continue; /* for this functionalty we will only set dates and date/time values from configured date/time values (skip dates) */
				}

				String mtz = (String)meeting.get(fieldNameToTimeZoneMapping.get(field)); // ex => Greenwich Mean Time (Europe/Dublin)
				TimeZone t = TimeZone.getTimeZone(mtz.substring(mtz.indexof('(')+1, mtz.length()-1)); // parse out value in parens, ex => Europe/Dublin
				DateTime dt = (DateTime)meeting.get(field); //get the value for this field

				dt = dt.addSeconds(-1*t.getOffset(dt)/1000); // figure out the offset of the date based on the timezone given. and apply it to the date
				System.debug('\n\n\nStamping ' + field + ' with ' + dt +'\n\n\n');
				meeting.put(field, dt);
			}
		}
	}
}