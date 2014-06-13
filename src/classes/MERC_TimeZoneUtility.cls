/**
 * @author Joseph Ferraro
 *
 * Apex class responsible for translating date/times to/from a specificed time zone/user time zone
 */
public with sharing class MERC_TimeZoneUtility {

	TimeZone userTimeZone = UserInfo.getTimeZone();
	Map<String, Schema.SObjectField> fieldListMap;
	String sobjectAPIName;
	Map<String,String> timeZoneFieldMappings;
	Map<String,String> stampFieldMapping;
	List<String> timeZoneFieldsForObject;

	public MERC_TimeZoneUtility(Schema.SObjectType objectType) {
		Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
		this.sobjectAPIName = objectDescribe.getName();

		Schema.DescribeSObjectResult dResult = objectType.getDescribe();
		this.fieldListMap = dResult.fields.getMap();

		this.timeZoneFieldMappings = MERC_Util.getTimeZoneFieldMapForObject(this.sobjectAPIName);
		this.stampFieldMapping = MERC_Util.getStampFieldMapForObject(this.sobjectAPIName);

		this.timeZoneFieldsForObject = this.timeZoneFieldMappings.values();

		system.debug('>>>>>>>>>>> fieldListMap: '+this.fieldListMap);
		system.debug('>>>>>>>>>>> timeZoneFieldMappings: '+timeZoneFieldMappings);
		system.debug('>>>>>>>>>>> stampFieldMapping: '+stampFieldMapping);
	}

	//map of time zone field api name to sid: 'Meeting_Time_Zone_MERC__c' => 'America/New_York'
	Map<String,String> getTimeZoneFieldAPINameToTimeZoneSid(Sobject record, String timeZoneSidValueOverride) {
		Map<String,String> timeZoneFieldAPINameToTimeZoneSid = new Map<String,String>();
		for (String timeZoneFieldAPIName : this.timeZoneFieldsForObject) {
			String timeZoneSid;
			if (timeZoneSidValueOverride == null) {
				if (record.get(timeZoneFieldAPIName) == null) continue;
				timeZoneSid = (String)record.get(timeZoneFieldAPIName);
			} else {
				timeZoneSid = timeZoneSidValueOverride;
			}
			timeZoneSid = timeZoneSid.split('\\(')[1].replace(')','');
			timeZoneFieldAPINameToTimeZoneSid.put(timeZoneFieldAPIName, timeZoneSid);
		}

		system.debug('>>> '+timeZoneFieldAPINameToTimeZoneSid);
		return timeZoneFieldAPINameToTimeZoneSid;
	}

	String getFieldType(String dateOrTimeFieldApiName) {
		Schema.SObjectField field = fieldListMap.get(dateOrTimeFieldApiName);
		Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
		return String.valueOf(fieldDescribe.getSoaptype()); //DATE or DATETIME
	}

	DateTime getDateTimeValue(Sobject record, String dateOrTimeFieldApiName, String fieldType) {
		DateTime dtValue;
		if (fieldType == 'DATE') {
			dtValue = Datetime.newInstance((Date)record.get(dateOrTimeFieldApiName), Time.newInstance(12, 0, 0, 0));
		} else if (fieldType == 'DATETIME') {
			dtValue = (DateTime)record.get(dateOrTimeFieldApiName);
		}
		return dtValue;
	}

	public void applyTimeZoneSpecificTimestamps(List<Sobject> sobjects, String timeZoneSidValueOverride) {
		for (Sobject record : sobjects) {
			system.debug('...processing object: '+record);

			Map<String,String> timeZoneFieldAPINameToTimeZoneSid = getTimeZoneFieldAPINameToTimeZoneSid(record, timeZoneSidValueOverride);

			//now, for each date or date/time field, we need to calculate the UTC date and (optionally) stamp the time-zone specific value
			for (String dateOrTimeFieldApiName : this.timeZoneFieldMappings.keySet()) {

				system.debug('...processing: '+dateOrTimeFieldApiName); //=> Start_Time_of_Meeting_MERC__c

				if (record.get(dateOrTimeFieldApiName) == null) continue; //if the field is null, skip it
				if (this.stampFieldMapping.get(dateOrTimeFieldApiName) == null) continue; //if the field doesn't stamp anywhere, skip it

				String fieldType = getFieldType(dateOrTimeFieldApiName);
				DateTime dtValue = getDateTimeValue(record, dateOrTimeFieldApiName, fieldType);

				//if record's value of dateOrTimeFieldApiName is null, don't bother processing
				if (dtValue == null) continue;

				//get the time zone field api name associated with this date/time
				String associatedTimeZoneAPIName = timeZoneFieldMappings.get(dateOrTimeFieldApiName); //=> 'Meeting_Time_Zone_MERC__c'
				if (associatedTimeZoneAPIName == null) continue;

				String tzSidValueForAssociatedTimeZone = timeZoneFieldAPINameToTimeZoneSid.get(associatedTimeZoneAPIName);
				if (tzSidValueForAssociatedTimeZone == null) continue;

				system.debug('>>>> ready to stamp, before calculatation dtValue is: ' + dtValue.date());

				if (fieldType == 'DATE') {
					system.debug('>>>> field type is DATE');
					String fieldAPINameToStamp = this.stampFieldMapping.get(dateOrTimeFieldApiName);
					record.put(fieldAPINameToStamp, dtValue.date().format());
				} else if (fieldType == 'DATETIME') {
					system.debug('>>>> field type is DATETIME');
					system.debug('>>>> ready for stamping!');
					String fieldAPINameToStamp = this.stampFieldMapping.get(dateOrTimeFieldApiName);
					String javaDateFormat = 'EEEE, dd MMM yyyy HH:mm z';
					//String javaDateFormat = 'EEE, d MMM yyyy HH:mm, zzzz';
					system.debug('>>>> stamping field: '+fieldAPINameToStamp);
					system.debug('>>>> stamping value: '+dtValue.format(javaDateFormat, tzSidValueForAssociatedTimeZone));

					record.put(fieldAPINameToStamp, dtValue.format(javaDateFormat, tzSidValueForAssociatedTimeZone));
				}
				system.debug('\n\n\nThe Record now is: ' + record);
			}
		}
	}

	public void convertDateTimes(list<Sobject> sobjects, Boolean setDateTimesAccordingToUserLocal) {
		convertDateTimes(sobjects, setDateTimesAccordingToUserLocal, null);
	}

	public void convertDateTimes(List<Sobject> sobjects, Boolean setDateTimesAccordingToUserLocal, String timeZoneSidValueOverride) {

		for (Sobject record : sobjects) {
			system.debug('...processing object: '+record);

			Map<String,String> timeZoneFieldAPINameToTimeZoneSid = getTimeZoneFieldAPINameToTimeZoneSid(record, timeZoneSidValueOverride);

			//now, for each date or date/time field, we need to calculate the UTC date and (optionally) stamp the time-zone specific value
			for (String dateOrTimeFieldApiName : timeZoneFieldMappings.keySet()) {
				system.debug('...processing: '+dateOrTimeFieldApiName);
				//dateOrTimeFieldApiName = 'Start_Time_of_Meeting_MERC__c'

				try {
					if (record.get(dateOrTimeFieldApiName) == null) continue;
				} catch(System.SObjectException e) {
					continue;
				}

				String fieldType = getFieldType(dateOrTimeFieldApiName);
				DateTime dtValue = getDateTimeValue(record, dateOrTimeFieldApiName, fieldType);

				//if record's value of dateOrTimeFieldApiName is null, don't bother processing
				if (dtValue == null) continue;

				//get the time zone field api name associated with this date/time
				String associatedTimeZoneAPIName = timeZoneFieldMappings.get(dateOrTimeFieldApiName); //=> 'Meeting_Time_Zone_MERC__c'
				if (associatedTimeZoneAPIName == null) continue;

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

				system.debug('>>>> ready to convert date/times');

				if (fieldType == 'DATE') {
					system.debug('>>>> field type is DATE');
					record.put(dateOrTimeFieldApiName, correctedDateTime.date());
				} else if (fieldType == 'DATETIME') {
					system.debug('>>>> field type is DATETIME');
					system.debug('>>>> setting field: '+dateOrTimeFieldApiName);
					system.debug('>>>> setting to: '+correctedDateTime);
					record.put(dateOrTimeFieldApiName, correctedDateTime);
				}
			}
		}

	}
}