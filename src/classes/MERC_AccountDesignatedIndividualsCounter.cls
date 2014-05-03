/**
*
* @author Kyle Thornton
*
* Trigger handler to count up the number of designated individuals attached to a HCP Account. fires for any
* account with record type of Designated Individual.
*
**/
public with sharing class MERC_AccountDesignatedIndividualsCounter implements GLBL_TriggerHandler.HandlerInterface {

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
		//GLBL_Rollup.RollupService.triggerHandler(sobjects);
		Id      designatedIndividualRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Designated Individual').getRecordTypeId();
		Set<Id> parentAccountIds         = new Set<Id>();

		for (Account acct : (List<Account>)sobjects)
		{
			if (acct.RecordTypeId == designatedIndividualRTId )
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

		List<Account> parentAccounts = [SELECT Id
		                                     , Designated_Individual_Counter_MERC__c
		                                     , (SELECT Id FROM Designated_Individuals__r)
		                                  FROM Account
		                                 WHERE Id IN :parentAccountIds];

		for (Account acct : parentAccounts)
		{
			acct.Designated_Individual_Counter_MERC__c = acct.Designated_Individuals__r.size();
		}
		update parentAccounts;
	}
}