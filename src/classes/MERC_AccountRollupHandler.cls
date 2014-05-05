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
				parentAccountIds.add(acct.HCP_MERC__c);
				/*----- If the oldmap was passed in then we are updating and need to also recalcuate the
				        value on any potential old parents in the event that the DI was reparented  -----*/
				if (sobjectsOld != null && sobjectsOld.containsKey(acct.Id))
				{
					parentAccountIds.add( ((Account)sobjectsOld.get(acct.Id)).HCP_MERC__c);
				}
			}
		}

		/*----- query for all of the parent accounts retrieving all of the "designated individuals" -----*/
		List<Account> parentAccounts = [SELECT Id
		                                     , Designated_Individual_Counter_MERC__c
		                                     , Contracting_Parties_Counter_MERC__c
		                                     , (SELECT Id, RecordTypeId FROM Designated_Individuals__r)
		                                  FROM Account
		                                 WHERE Id IN :parentAccountIds];

		/*----- loop over the designated individual records for each account and count up the number of
		        designated individuals and contracting parties -----*/
		for (Account acct : parentAccounts)
		{
			Integer designatedIndvidualCounter = 0;
			Integer contractingPartyCounter    = 0;

			for (Account relatedAccount : acct.Designated_Individuals__r)
			{
				if (relatedAccount.RecordTypeId == designatedIndividualRTId)
				{
					designatedIndvidualCounter++;
				}
				else if (relatedAccount.RecordTypeId == contractingPartyRTId)
				{
					contractingPartyCounter++;
				}

			}

			acct.Designated_Individual_Counter_MERC__c = designatedIndvidualCounter;
			acct.Contracting_Parties_Counter_MERC__c   = contractingPartyCounter;
		}
		update parentAccounts;
	}
}