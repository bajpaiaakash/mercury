public with sharing class MERC_MeetingDateTimesController {

	private Meeting_MERC__c meeting { get; private set; }
    ApexPages.StandardController stdController;
    MERC_TimeZoneCalculator tz = new MERC_TimeZoneCalculator('Meeting_MERC__c');
    
    public MERC_MeetingDateTimesController(ApexPages.StandardController c) {
        this.meeting = (Meeting_MERC__c)c.getRecord();
        this.stdController = c;
    }

    public void setTimeZones() {
        tz.execute(new List<Sobject>{this.meeting}, false); //sets date/times based on meeting time/zone, for UX purposes
    }

    public PageReference save() {
        try {
            tz.execute(new List<Sobject>{this.meeting}, true); //sets date/times based on UTC, stamps static text with "user-friendly" date/time values
            update this.meeting; 
        } catch(Exception e) {
            return null;
        }
        return stdController.view();
    }

    public PageReference cancel() {
        return stdController.view();
    }
}