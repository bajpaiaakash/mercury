/**
 * @author Kyle Thornton
 *
 * sets the "anonymize" checkbox on the Meeting Participant and related records for a non-hcp when
 * the meeting has been closed
 */


public with sharing class MERC_AnonymizeNonHCPDataHandler implements GLBL_TriggerHandler.HandlerInterface
{
	public MERC_AnonymizeNonHCPDataHandler()
	{

	}

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
		List<sObject> sObjectsToAnonymize = new List<SObject>();
		List<Travel_Itinerary_MERC__c> itinerariesToAnonymize   = new List<Travel_Itinerary_MERC__c>();
		List<Participant_Agenda_MERC__c> agendaItemsToAnonymize = new List<Participant_Agenda_MERC__c>();

		/*-----  Query for the meeting participants Id, the related account id
		         and their related travel itinerary and participant session ids -----*/
		List<Meeting_Participant_MERC__c> participants = [SELECT Id
															   , Anonymize_Record_MERC__c
		                                                       , Account_MERC__c
		                                                       , (SELECT Id, Anonymize_Record_MERC__c FROM Travel_Itineraries_MERC__r)
		                                                       , (SELECT Id, Anonymize_Record_MERC__c FROM Participant_Sessions__r)
		                                                    FROM Meeting_Participant_MERC__c
		                                                   WHERE Meeting_MERC__c IN :meetings];


		Set<Id> accountIdsToAnonymize = new Set<Id>();

		/*----- loop over the particpants and add the id and the ids of all reated travel itineraries and participant
		        sessions to a set of ids to anonymize. Add the account id to a list of account ids to anonymize
		        To avoid chuncking we need to group items in the sObjectsToAnonymize by object type  -----*/
		for (Meeting_Participant_MERC__c participant : participants)
		{
			sObjectsToAnonymize.add(participant);
			for (Travel_Itinerary_MERC__c ti : participant.Travel_Itineraries_MERC__r)
			{
				itinerariesToAnonymize.add(ti);
			}
			for (Participant_Agenda_MERC__c ps : participant.Participant_Sessions__r)
			{
				agendaItemsToAnonymize.add(ps);
			}
			accountIdsToAnonymize.add(participant.Account_MERC__c);
		}

		for (Travel_Itinerary_MERC__c i : itinerariesToAnonymize)
		{
			sObjectsToAnonymize.add(i);
		}
		for (Participant_Agenda_MERC__c p : agendaItemsToAnonymize)
		{
			sObjectsToAnonymize.add(p);
		}

		/*----- query for the account ids as well as the realted cases and related addresses for those accounts in the
		        accountIdsToAnonymize set -----*/
		List<Account> accountsToAnonymize = [SELECT Id
		                                          , Anonymize_Record_MERC__c
		                                          , (SELECT Id, Anonymize_Record_MERC__c FROM Cases)
		                                          , (SELECT Id, Anonymize_Record_MERC__c FROM Addresses_GLBL__r)
		                                       FROM Account
		                                      WHERE Id IN :accountIdsToAnonymize];

   		List<Case> casesToAnonymize = new List<Case>();
   		List<Address_GLBL__c> addressesToAnonymize = new List<Address_GLBL__c>();

		/*----- add the account id, and the ids of any related cases and addresses to the recordIdsToAnonymize set -----*/
		for (Account acct : accountsToAnonymize)
		{
			sObjectsToAnonymize.add(acct);
			for (Case c : acct.Cases)
			{
				casesToAnonymize.add(c);
			}
			for (Address_GLBL__c addr : acct.Addresses_GLBL__r)
			{
				addressesToAnonymize.add(addr);
			}
		}
 		for (Case c : casesToAnonymize)
 		{
			sObjectsToAnonymize.add(c);
		}
		for (Address_GLBL__c a : addressesToAnonymize)
		{
			sObjectsToAnonymize.add(a);
		}

		/*----- we now have a list of objects that should be anonymized. Iterate over the list and set
		        the Anonymize_Record_MERC__c flag for each to true -----*/
		for (SObject so : sObjectsToAnonymize)
		{
			so.put('Anonymize_Record_MERC__c', true);
		}
		update sObjectsToAnonymize;
	}
}