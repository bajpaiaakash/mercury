/**
 * @author Kyle Thornton
 *
 * sets the "Anonymise" checkbox on the Meeting Participant and related records for a non-hcp when
 * the meeting has been closed
 */


public with sharing class MERC_AnonymiseNonHCPDataHandler implements GLBL_TriggerHandler.HandlerInterface
{
    public void handle()
    {
        List<sObject> toProcess = new List<sObject>();

        /*-----  If a meeting is updatd to Complete closed/cancelled then we need to process it to remove anonymous data -----*/
        for (Meeting_MERC__c meeting : (List<Meeting_MERC__c>)Trigger.new)
        {
            if ((meeting.Meeting_Status_MERC__c == 'Complete - Closed' || meeting.Meeting_Status_MERC__c == 'Complete - Cancelled')
                 && (Trigger.isInsert || Trigger.oldMap.get(meeting.Id).get('Meeting_Status_MERC__c') != meeting.Meeting_Status_MERC__c))
            {
                toProcess.add(meeting);
            }
        }

        if (!toProcess.isEmpty())
        {
            execute(toProcess);
        }
    }

    private void execute(List<Meeting_MERC__c> meetings)
    {
        List<sObject> sObjectsToAnonymise = new List<SObject>();
        List<Travel_Itinerary_MERC__c> itinerariesToAnonymise   = new List<Travel_Itinerary_MERC__c>();
        List<Participant_Agenda_MERC__c> agendaItemsToAnonymise = new List<Participant_Agenda_MERC__c>();

        /*-----  Query for the meeting participants Id, the related account id
                 and their related travel itinerary and participant session ids -----*/
        List<Meeting_Participant_MERC__c> participants = [SELECT Id
                                                               , Anonymise_Record_MERC__c
                                                               , Account_MERC__c
                                                               , (SELECT Id, Anonymise_Record_MERC__c FROM Travel_Itineraries_MERC__r)
                                                               , (SELECT Id, Anonymise_Record_MERC__c FROM Participant_Sessions__r)
                                                            FROM Meeting_Participant_MERC__c
                                                           WHERE Meeting_MERC__c IN :meetings
                                                             AND Participant_Typ_MERC__c = 'Non-HCP'];


        Set<Id> accountIdsToAnonymise = new Set<Id>();

        /*----- loop over the particpants and add the id and the ids of all reated travel itineraries and participant
                sessions to a set of ids to Anonymise. Add the account id to a list of account ids to Anonymise
                To avoid chuncking we need to group items in the sObjectsToAnonymise by object type  -----*/
        for (Meeting_Participant_MERC__c participant : participants)
        {
            sObjectsToAnonymise.add(participant);
            for (Travel_Itinerary_MERC__c ti : participant.Travel_Itineraries_MERC__r)
            {
                itinerariesToAnonymise.add(ti);
            }
            for (Participant_Agenda_MERC__c ps : participant.Participant_Sessions__r)
            {
                agendaItemsToAnonymise.add(ps);
            }
            accountIdsToAnonymise.add(participant.Account_MERC__c);
        }

        for (Travel_Itinerary_MERC__c i : itinerariesToAnonymise)
        {
            sObjectsToAnonymise.add(i);
        }
        for (Participant_Agenda_MERC__c p : agendaItemsToAnonymise)
        {
            sObjectsToAnonymise.add(p);
        }

        /*----- query for the account ids as well as the realted cases and related addresses for those accounts in the
                accountIdsToAnonymise set -----*/
        List<Account> accountsToAnonymise = [SELECT Id
                                                  , Anonymise_Record_MERC__c
                                                  , (SELECT Id, Anonymise_Record_MERC__c FROM Cases)
                                                  , (SELECT Id, Anonymise_Record_MERC__c FROM Addresses_GLBL__r)
                                               FROM Account
                                              WHERE Id IN :accountIdsToAnonymise];

        List<Case> casesToAnonymise = new List<Case>();
        List<Address_GLBL__c> addressesToAnonymise = new List<Address_GLBL__c>();

        /*----- add the account id, and the ids of any related cases and addresses to the recordIdsToAnonymise set -----*/
        for (Account acct : accountsToAnonymise)
        {
            sObjectsToAnonymise.add(acct);
            for (Case c : acct.Cases)
            {
                casesToAnonymise.add(c);
            }
            for (Address_GLBL__c addr : acct.Addresses_GLBL__r)
            {
                addressesToAnonymise.add(addr);
            }
        }
        for (Case c : casesToAnonymise)
        {
            sObjectsToAnonymise.add(c);
        }
        for (Address_GLBL__c a : addressesToAnonymise)
        {
            sObjectsToAnonymise.add(a);
        }

        /*----- we now have a list of objects that should be Anonymised. Iterate over the list and set
                the Anonymise_Record_MERC__c flag for each to true -----*/
        for (SObject so : sObjectsToAnonymise)
        {
            so.put('Anonymise_Record_MERC__c', true);
        }
        update sObjectsToAnonymise;
    }
}