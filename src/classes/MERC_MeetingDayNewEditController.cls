public with sharing class MERC_MeetingDayNewEditController {

	private final Meeting_Day_MERC__c meetingDay;
    ApexPages.StandardController stdController;
    MERC_TimeZoneUtility tz = new MERC_TimeZoneUtility(Meeting_Day_MERC__c.sObjectType);

    public MERC_MeetingDayNewEditController(ApexPages.StandardController c) {
        this.meetingDay = (Meeting_Day_MERC__c)c.getRecord();
        this.stdController = c;
        if (this.meetingDay.Id == null) {
            this.meetingDay.Date_MERC__c = meeting.Date_of_Event_MERC__c;
        }
    }

    //sets date/times based on meeting time/zone, for UX purposes
    public void setTimeZones() {
        tz.convertDateTimes(new List<Sobject>{this.meetingDay}, false, meeting.Meeting_Time_Zone_MERC__c);
    }

    public Meeting_MERC__c meeting {
        get {
            if (meeting == null) {
                meeting = [SELECT ID, Name, Date_of_Event_MERC__c, Meeting_Time_Zone_MERC__C FROM Meeting_MERC__c WHERE ID = :this.meetingDay.Meeting_MERC__c];
            }
            return meeting;
        }
        private set;
    }

    public Map<String,String> fieldSetLabels {
    	get {
    		if (fieldSetLabels == null) {
    			fieldSetLabels = MERC_Util.getFieldSetLabels(
	    			Meeting_Day_MERC__c.SobjectType, 
	    			new List<String> {
	    				'Meeting_Day_Daily_Amounts_MERC',
	    				'Meeting_Day_Basic_Information_MERC',
	    				'Meeting_Day_Date_Information_MERC'
	    			}
	    		);
    		}
    		return fieldSetLabels;
    	}
    	private set;
    }

    public PageReference save() {
        try {
            tz.convertDateTimes(new List<Sobject>{this.meetingDay}, true, meeting.Meeting_Time_Zone_MERC__c); //sets date/times based on UTC, stamps static text with "user-friendly" date/time values
            if (this.meetingDay.Id == null) {
                insert this.meetingDay;
            } else {
                update this.meetingDay; 
            }
        } catch(Exception e) {
            ApexPages.addMessages(e); //doesn't show ugly error text
            return null;
        }
        PageReference p = new PageReference('/'+this.meetingDay.Id);
        return p;
    }
}