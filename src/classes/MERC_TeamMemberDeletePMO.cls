public class MERC_TeamMemberDeletePMO  implements GLBL_TriggerHandler.HandlerInterface {

    public static final String PMO = 'Primary Meeting Owner';

    public void handle() {
        if (Trigger.isDelete) {
            execute(Trigger.old);
        }
    }

    public void execute(List<Sobject> sObjects) { 
        List<Team_Member_MERC__c> teamMembers = (List<Team_Member_MERC__c>) sObjects;

        List<Id> meetIds = new List<Id>();
        for (Team_Member_MERC__c tm : teamMembers) {
            if (tm.Role_MERC__c == PMO) meetIds.add(tm.Meeting_MERC__c);
        }

        List<Meeting_MERC__c> meetingsToUpdate = new List<Meeting_MERC__c>([
                SELECT Id, Meeting_Owner_Email_MERC__c, Prmry_Mtng_Ownr_Nm_MERC__c FROM Meeting_MERC__c 
                WHERE Id in :meetIds
            ]);
        for (Meeting_MERC__c m : meetingsToUpdate) {
            m.Meeting_Owner_Email_MERC__c = null;
            m.Prmry_Mtng_Ownr_Nm_MERC__c = null;
        }
        update meetingsToUpdate;
    }
}