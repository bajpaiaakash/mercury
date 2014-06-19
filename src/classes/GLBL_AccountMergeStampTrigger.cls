/**
 * @author Kyle Thornton
 *
 * This trigger handler is responsible for stamping the Global Id of the losing account onto the children
 * that are being reparented to the winning account. This will only occur in the event that the delete is
 * due to a salesforce merge operation.
 *
 * The merge operation is done in 4 steps according to salesforce documentation
 *    1. The before delete trigger fires.
 *    2. The system deletes the necessary records due to the merge, assigns new parent records to the
 *       child records, and sets the MasterRecordId field on the deleted records.
 *    3. The after delete trigger fires.
 *    4. The system does the specific updates required for the master record. Normal update triggers apply.
 *
 * Step 2 is critical to this process as it allows us to
 *    1. detect a merge has occurred by checking for a master record id
 *    2. ensures that when we call the update to stamp the custer record id that the triggers will fire
 *       and rollups to the new parent account will be called, thus ensuring that calculated values are
 *       correct on the new winning account.
 */

public with sharing class GLBL_AccountMergeStampTrigger implements GLBL_TriggerHandler.HandlerInterface
{
	/**
	 * This map is used to hold a mapping from deleted account Id to a set of ids for the child objects
	 * that are being reparented as part of a merge operation
	 */
	public static Map<Id, String> childIdToOldCustomerId = new Map<Id, String>();

	// these are state handlers. Need to make sure we only run each method once.
	public static Boolean runAfterUpdate = false;
	public static Boolean beforeDeleteHasRun = false;
	public static Boolean afterDeleteHasRun = false;
	public static Boolean afterUpdateHasRun = false;

	public Boolean isActive()
	{
		return MERC_TriggerHandlerStateManager.isActive(GLBL_AccountMergeStampTrigger.class);
	}

	public void handle()
	{
		if (Trigger.isDelete)
		{
			if (Trigger.isBefore)
			{
				executeBeforeDelete(Trigger.old);
			}
			else
			{
				executeAfterDelete(Trigger.old);
			}
		}
		else
		{
			if (Trigger.isUpdate && Trigger.isAfter)
			{
				executeAfterUpdate();
			}
		}
	}


	/**
	 * In the before context all related record ids, as defined in the account merge related lists
	 * custom setting are gathered up and stored in the childIdToOldCustomerId map. We don't know at this
	 * point whether this delete is due to a merge or just a standard delete action.
	 */
	private void executeBeforeDelete(List<Account> triggerAccounts)
	{
	   	if (beforeDeleteHasRun)
	   	{
	   		return;
	   	}
	   	beforeDeleteHasRun = true;
	   	// gather up the related list objects we need to query
	   	Set<String> accountRelatedObjects = new Set<String>();
	   	for (Account_Merge_Related_Lists_MERC__c setting : Account_Merge_Related_Lists_MERC__c.getAll().values())
	   	{
	   		accountRelatedObjects.add(setting.Account_Relationship_Name__c);
	   	}

	    // Build the soqlQuery to query accounts and all related items
	    String accountSoql = 'SELECT Id, Cust_Id_GLBL__c';
	    for (String s : accountRelatedObjects) {
	    	accountSoql += ', (SELECT Id FROM ' + s + ')';
	    }
	    accountSoql += ' FROM Account WHERE Id IN :triggerAccounts';

	    for (Account a : Database.query(accountSoql)) //loop over the accounts
	    {
	    	if (String.isNotBlank((String)a.get('Cust_Id_GLBL__c'))) // if the acct has a customer id
		  	{
		    	for (String objectName : accountRelatedObjects) // then for each configured related object
		    	{
			    	for (SObject so : a.getSObjects(objectName)) // loop through the related lists
			    	{
		 				// and map the child record id to the customer id to possibly be stamped later
		    			childIdToOldCustomerId.put( (Id)so.get('Id'), (String)a.get('Cust_Id_GLBL__c') );
		    		}
		    	}
			}
	    }
	}

	/**
	 * In the after context we can use the MasterRecordId to determine if the delete was the result
	 * of a merge operation. If the MasterRecordId is populated then this delete is, in fact, the
	 * result of a merge operation and we should proceed with stamping. If not, null out the
	 * childIdToOldCustomerId map so that the executeAfterUpdate() doesn't run.
	 */
	private void executeAfterDelete(List<Account> triggerAccounts)
	{
		if (afterDeleteHasRun)
		{
			return;
		}
		afterDeleteHasRun = true;

		if (String.isNotBlank(triggerAccounts[0].MasterRecordId))
		{
			//this is the result of a merge operation.
			runAfterUpdate = true;
		}

	}

	/**
	 * in the after update context if childIdToOldCustomerId is not null then we can proceed with
	 * the customer id on the sobjects. we can't do this in the afterdelete context because the
	 * update will cause updates against the winning account and we can't edit an account that is
	 * in the middle of a merge. once in the after update context we are safe to update.
	 */
	private void executeAfterUpdate()
	{
		if (!runAfterUpdate || afterUpdateHasRun)
		{
			return;
		}
		afterUpdateHasRun = true;

		Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

		/**
		 * Now that we know we are in a merge context, iterate over the childIdToOldCustomerId map
		 * and create sObjects to update. Populate those SObjects with the id from the keyset and
		 * old customer id from the mapped value
		 */
		List<SObject> sObjectsToUpdate = new List<SObject>();
		for (Id childId : childIdToOldCustomerId.keySet())
		{
			Schema.SObjectType soType = childId.getSObjectType();
			SObject so = soType.newSObject(childId) ;
			so.put('Prior_Parent_Id_GLBL__c', childIdToOldCustomerId.get(childId));
			sObjectsToUpdate.add(so);
		}

		//update sObjectsToUpdate;

		try
		{
			update sObjectsToUpdate;
		}
		catch (Exception ex)
		{
			System.debug('\n\n\nERROR: ' + ex);
			throw ex;
		}
	}
}