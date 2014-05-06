/**
*
* @author Kyle Thornton
*
* Trigger handler to count up the number of designated individuals and contracting Parties attached to a HCP Account.
* Fires for any account with record type of Designated Individual or Contracting Party.
*
**/
public with sharing class MERC_AccountRollupHandler implements GLBL_TriggerHandler.HandlerInterface {

	public void handle() {
		if (Trigger.isInsert || Trigger.isUndelete)
		{
	    	execute(Trigger.new, null);
	   	}
	   	else if (Trigger.isDelete)
	   	{
	   		execute(Trigger.old, null);
	   	}
	   	else if (Trigger.isUpdate)
	   	{
	   		execute(Trigger.new, Trigger.oldMap);
	   	}
	}

	public void execute(List<SObject> sobjects, Map<Id, SObject> sobjectsOld) {
		Map<String,Schema.RecordTypeInfo> acctRecTypes = Schema.SObjectType.Account.getRecordTypeInfosByName();

		Id designatedIndividualRTId = acctRecTypes.get('Designated Individual').getRecordTypeId();
		Id contractingPartyRTId     = acctRecTypes.get('Contracting Party').getRecordTypeId();
		Set<Id> parentAccountIds    = new Set<Id>();

		for (Account acct : (List<Account>)sobjects)
		{
			if (acct.RecordTypeId == designatedIndividualRTId || acct.RecordTypeId == contractingPartyRTId)
			{
				parentAccountIds.add(acct.HCP_Designated_Individuals_MERC__c);
				parentAccountIds.add(acct.HCP_Contracting_Party_MERC__c);
				/*----- If the oldmap was passed in then we are updating and need to also recalcuate the
				        value on any potential old parents in the event that the DI was reparented  -----*/
				if (sobjectsOld != null && sobjectsOld.containsKey(acct.Id))
				{
					parentAccountIds.add( ((Account)sobjectsOld.get(acct.Id)).HCP_Designated_Individuals_MERC__c);
					parentAccountIds.add( ((Account)sobjectsOld.get(acct.Id)).HCP_Contracting_Party_MERC__c);
				}
			}
		}

		/*----- query for all of the parent accounts retrieving all of the "designated individuals" and "Contractying Parties" -----*/
		List<Account> parentAccounts = [SELECT Id
		                                     , Designated_Individual_Counter_MERC__c
		                                     , (SELECT Id FROM Designated_Individuals__r)
		                                     , Contracting_Parties_Counter_MERC__c
		                                     , (SELECT Id FROM HCPs_Contracting_Party__r)
		                                  FROM Account
		                                 WHERE Id IN :parentAccountIds];

		/*----- loop over the parent accounts and set the number of designated individuals and contracting parties for each -----*/
		for (Account acct : parentAccounts)
		{
			acct.Designated_Individual_Counter_MERC__c = acct.Designated_Individuals__r.size();
			acct.Contracting_Parties_Counter_MERC__c   = acct.HCPs_Contracting_Party__r.size();
		}
		update parentAccounts;
	}
}