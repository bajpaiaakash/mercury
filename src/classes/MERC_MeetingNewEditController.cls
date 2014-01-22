/**
 * @author Joseph Ferraro
 *
 * Controller to enable user to create/edit meetings
 * we're overriding so we can control UX as it relates to Date/Times
 */

public with sharing class MERC_MeetingNewEditController extends GLBL_BaseEditController {
    
    MERC_TimeZoneUtility tz = new MERC_TimeZoneUtility(Meeting_MERC__c.sObjectType);

    public MERC_MeetingNewEditController(ApexPages.StandardController controller) {
        super(controller, Meeting_MERC__c.SobjectType);
        //if the time zones have not been set yet, set according to user's locale
        if (Apexpages.currentPage().getUrl().contains('/apex/MERC_MeetingNewEdit')) {
            Schema.DescribeFieldResult meetingTimeZoneFieldDescribe = Meeting_MERC__c.Meeting_Time_Zone_MERC__c.getDescribe();
            String userTimeZoneDefault = MERC_Util.getTimeZonePicklistValueForCurrentUser(meetingTimeZoneFieldDescribe);
            if (this.mySobject.get('Meeting_Time_Zone_MERC__c') == null)
                this.mySobject.put('Meeting_Time_Zone_MERC__c', userTimeZoneDefault);
        }
    }

    public Map<String,String> fieldSetLabels {
        get {
            if (fieldSetLabels == null) {
                fieldSetLabels = MERC_Util.getFieldSetLabels(
                    Meeting_MERC__c.SobjectType, 
                    new List<String> {
                        'Meeting_Date_Time_Edit_MERC'
                    }
                );
            }
            return fieldSetLabels;
        }
        private set;
    }

    public void setTimeZones() {
        tz.convertDateTimes(new List<Sobject>{this.mySobject}, false); //sets date/times based on meeting time/zone, for UX purposes
    }

    public PageReference save() {
        try {
            tz.convertDateTimes(new List<Sobject>{this.mySobject}, true); //sets date/times based on UTC
            if (this.mySobject.Id == null) {
                insert this.mySobject;
            } else {
                update this.mySobject; 
            }
        } catch(Exception e) {
            ApexPages.addMessages(e); //doesn't show ugly error text
            return null;
        }
        PageReference p = new PageReference('/'+this.mySobject.Id);
        return p;
    }

}