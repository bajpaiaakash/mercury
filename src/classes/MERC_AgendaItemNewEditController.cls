public with sharing class MERC_AgendaItemNewEditController {

	private final Agenda_Item_MERC__c agendaItem;
    ApexPages.StandardController stdController;
    MERC_TimeZoneCalculator tz = new MERC_TimeZoneCalculator('Agenda_Item_MERC__c');

    public MERC_AgendaItemNewEditController(ApexPages.StandardController c) {
        this.agendaItem = (Agenda_Item_MERC__c)c.getRecord();
        this.stdController = c;
    }

    //sets date/times based on meeting time/zone, for UX purposes
    public void setTimeZones() {
        tz.execute(new List<Sobject>{this.agendaItem}, false);
    }

    public Meeting_MERC__c meeting {
        get {
            return [SELECT ID, Name, Meeting_Time_Zone_MERC__C FROM Meeting_MERC__c WHERE ID = :this.agendaItem.Meeting_MERC__c];
        }
    }

    public PageReference save() {
        try {
            tz.execute(new List<Sobject>{this.agendaItem}, true); //sets date/times based on UTC, stamps static text with "user-friendly" date/time values
            if (this.agendaItem.Id == null) {
                insert this.agendaItem;
            } else {
                update this.agendaItem; 
            }
        } catch(Exception e) {
            return null;
        }
        return stdController.view();
    }

    public PageReference cancel() {
        return stdController.view();
    }

}