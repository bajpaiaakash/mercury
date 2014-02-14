/**
 * @author Joseph Ferraro
 *
 * Controller for VF Page that enables users to create/edit an agenda item
 */


public with sharing class MERC_AgendaItemNewEditController {

	private final Agenda_Item_MERC__c agendaItem;
    ApexPages.StandardController stdController;
    MERC_TimeZoneUtility tz = new MERC_TimeZoneUtility(Agenda_Item_MERC__c.sObjectType);

    public MERC_AgendaItemNewEditController(ApexPages.StandardController c) {
        this.agendaItem = (Agenda_Item_MERC__c)c.getRecord();
        this.stdController = c;
        if (this.agendaItem.Id == null) {
            this.agendaItem.Start_Time_MERC__c = meeting.Start_Time_of_Meeting_MERC__c;
            this.agendaItem.End_Time_MERC__c = meeting.End_Time_of_Meeting_MERC__c;
        }
    }

    //sets date/times based on meeting time/zone, for UX purposes
    public void setTimeZones() {
        tz.convertDateTimes(new List<Sobject>{this.agendaItem}, false, meeting.Meeting_Time_Zone_MERC__c);
    }

    public Meeting_MERC__c meeting {
        get {
            if (meeting == null) {
                try {
                    meeting = [SELECT ID, Name, Start_Time_of_Meeting_MERC__c, End_Time_of_Meeting_MERC__c, Meeting_Time_Zone_MERC__C FROM Meeting_MERC__c WHERE ID = :this.agendaItem.Meeting_MERC__c];
                } catch(System.QueryException e) {
                    throw new MERC_Exception('You must provide a valid Agenda Item Id (MERC_AgendaItemNewEdit?id=agenda_item_id)');
                }
            }
            return meeting;
        }
        private set;
    }

    public PageReference save() {
        try {
            tz.convertDateTimes(new List<Sobject>{this.agendaItem}, true, meeting.Meeting_Time_Zone_MERC__c); //sets date/times based on UTC, stamps static text with "user-friendly" date/time values
            if (this.agendaItem.Id == null) {
                insert this.agendaItem;
            } else {
                update this.agendaItem; 
            }
        } catch(Exception e) {
            ApexPages.addMessages(e); //doesn't show ugly error text
            return null;
        }
        PageReference p = new PageReference('/'+this.agendaItem.Id);
        return p;
    }
}