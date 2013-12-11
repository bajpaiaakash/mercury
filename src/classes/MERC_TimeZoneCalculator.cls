public with sharing class MERC_TimeZoneCalculator implements GLBL_TriggerHandler.HandlerInterface {

	public static Boolean timeZoneOffsetCalculated = false;
	String triggeredSobjectAPIName;

	public MERC_TimeZoneCalculator(String objApiName) {
		this.triggeredSobjectAPIName = objApiName;
	}

	public void handle() {
		if (!MERC_TimeZoneCalculator.timeZoneOffsetCalculated) {
			if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
		    	execute(Trigger.new, true);
		   	} else if (Trigger.isDelete) {
		   		execute(Trigger.old, true);
		   	}
		}
	}

	public void execute(list<Sobject> sobjects, Boolean setDateTimesAccordingToUserLocal) {        
		if (this.triggeredSobjectAPIName == null)
			this.triggeredSobjectAPIName = MERC_Util.getSobjectAPIName(sobjects.get(0));

		TimeZone userTimeZone = UserInfo.getTimeZone(); //for example: America/Los_Angeles
		
		Schema.SObjectType objectType = sobjects.get(0).getSObjectType();
		Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
		String objectNameString = objectDescribe.getName();

		Map<String, Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
		Schema.sObjectType sObjType = globalDescription.get(objectNameString); 
		Schema.DescribeSObjectResult r1 = sObjType.getDescribe();  
		Map<String, Schema.SObjectField> fieldListMap = r1.fields.getMap();  

		system.debug('>>>>>>>>>>> '+fieldListMap);

		//if (this.triggeredSobjectAPIName == 'Meeting_MERC__c') {
		Map<String,String> timeZoneFieldMappings = MERC_Util.getTimeZoneFieldMapForObject(this.triggeredSobjectAPIName);
		Map<String,String> stampFieldMapping = MERC_Util.getStampFieldMapForObject(this.triggeredSobjectAPIName);

		List<String> timeZoneFieldsForObject = timeZoneFieldMappings.values();

		for (Sobject m : sobjects) {
		//for (Meeting_MERC__c m : (List<Meeting_MERC__c>)sobjects) {
			
			//create map of time zone field api name to sid: 'Meeting_Time_Zone_MERC__c' => 'America/New_York' 
			Map<String,String> timeZoneFieldAPINameToTimeZoneSid = new Map<String,String>();

			for (String timeZoneFieldAPIName : timeZoneFieldsForObject) {
				if (m.get(timeZoneFieldAPIName) == null) continue;
				String meetingTimeZoneSid = (String)m.get(timeZoneFieldAPIName);
				meetingTimeZoneSid = meetingTimeZoneSid.split('\\(')[1].replace(')','');
				timeZoneFieldAPINameToTimeZoneSid.put(timeZoneFieldAPIName, meetingTimeZoneSid);
			}

			system.debug('>>> '+timeZoneFieldAPINameToTimeZoneSid);

			for (String s : timeZoneFieldMappings.keySet()) { 
				//s = 'Start_Time_of_Meeting_MERC__c'
				if (m.get(s) == null) continue;
				
				Schema.SObjectField field = fieldListMap.get(s);
				Schema.DescribeFieldResult fieldDescribe = field.getDescribe(); 
				String fieldType = String.valueOf(fieldDescribe.getSoaptype());

				DateTime dtValue;
				if (fieldType == 'DATE') {
					dtValue = Datetime.newInstance((Date)m.get(s), Time.newInstance(12, 0, 0, 0));
				} else if (fieldType == 'DATETIME') {
					dtValue = (DateTime)m.get(s);
				}
				
				//if record's value of s is null, don't bother processing
				if (dtValue == null) continue;

				String associatedTimeZoneAPIName = timeZoneFieldMappings.get(s); //=> 'Meeting_Time_Zone_MERC__c'
				if (associatedTimeZoneAPIName == null) continue;

				if (Trigger.isExecuting) {
					if (Trigger.isUpdate) {
						if (
							Trigger.oldmap.get(m.Id).get(s) == Trigger.newMap.get(m.Id).get(s)
							&&
							Trigger.oldmap.get(m.Id).get(associatedTimeZoneAPIName) == Trigger.newMap.get(m.Id).get(associatedTimeZoneAPIName)
						) continue;
					}
				}

				String tzSidValueForAssociatedTimeZone = timeZoneFieldAPINameToTimeZoneSid.get(associatedTimeZoneAPIName);
				if (tzSidValueForAssociatedTimeZone == null) continue;

				TimeZone associatedTimeZoneValue = TimeZone.getTimeZone(tzSidValueForAssociatedTimeZone);

				Integer userGmtOffset = userTimeZone.getOffset(dtValue); //gets user's offset to gmt
				Integer associatedFieldGmtOffset = associatedTimeZoneValue.getOffset(dtValue); //gets meeting's offset to gmt
				system.debug('>>>> '+userGmtOffset);
				system.debug('>>>> '+associatedFieldGmtOffset);
				
				Integer correction;
				if (setDateTimesAccordingToUserLocal) {
					correction = userGmtOffset - associatedFieldGmtOffset;
				} else {
					correction = associatedFieldGmtOffset - userGmtOffset;
				}
				
				DateTime correctedDateTime = dtValue.addMinutes(correction / (1000 * 60));

				if (fieldType == 'DATE') {
					m.put(s, correctedDateTime.date());
					if (stampFieldMapping.get(s) != null) {
						String fieldAPINameToStamp = stampFieldMapping.get(s);
						m.put(fieldAPINameToStamp, correctedDateTime.date().format());
					}
				} else if (fieldType == 'DATETIME') {
					m.put(s, correctedDateTime);
					if (stampFieldMapping.get(s) != null) {
						String fieldAPINameToStamp = stampFieldMapping.get(s);
						String javaDateFormat = 'EEEE, dd MMM yyyy HH:mm z';
						//String javaDateFormat = 'EEE, d MMM yyyy HH:mm, zzzz';
						m.put(fieldAPINameToStamp, correctedDateTime.format(javaDateFormat, tzSidValueForAssociatedTimeZone));
					}
				}
			}
		}
		//}
		MERC_TimeZoneCalculator.timeZoneOffsetCalculated = true;
	}
}