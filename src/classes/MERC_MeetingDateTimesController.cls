/**
 * @author Joseph Ferraro
 *
 * Controller to enable user to create/edit meeting date/times
 * we're overriding so we can control UX as it relates to Date/Times
 */
public with sharing class MERC_MeetingDateTimesController {

	private Meeting_MERC__c meeting { get; private set; }
    ApexPages.StandardController stdController;
    MERC_TimeZoneUtility tz = new MERC_TimeZoneUtility(Meeting_MERC__c.sObjectType);
    
    public MERC_MeetingDateTimesController(ApexPages.StandardController c) {
        this.meeting = (Meeting_MERC__c)c.getRecord();
        this.stdController = c;
        //if the meeting time zone hasn't been set yet, set to user's time zone
        String vfUrl = Apexpages.currentPage().getUrl().toLowerCase();
        if (this.meeting.Meeting_Time_Zone_MERC__c == null && vfUrl.contains('/apex/merc_meetingdatetimesedit')) {
            Schema.DescribeFieldResult meetingTimeZoneFieldDescribe = Meeting_MERC__c.Meeting_Time_Zone_MERC__c.getDescribe();
            this.meeting.Meeting_Time_Zone_MERC__c = MERC_Util.getTimeZonePicklistValueForCurrentUser(meetingTimeZoneFieldDescribe);
        }
    }

    public void setTimeZones() {
        tz.convertDateTimes(new List<Sobject>{this.meeting}, false); //sets date/times based on meeting time/zone, for UX purposes
    }

    public PageReference save() {
        try {
            tz.convertDateTimes(new List<Sobject>{this.meeting}, true); //sets date/times based on UTC
            update this.meeting; 
        } catch(Exception e) {
            setTimeZones();
            ApexPages.addMessages(e); //doesn't show ugly error text
            return null;
        }
        return stdController.view();
    }

    public PageReference cancel() {
        return stdController.view();
    }
}