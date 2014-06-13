/**
* @author Kyle Thornton
*
* This trigger handler is responsible for parsing a value placed in Account_Field_Update_MERC__c in the format
* <api_name>=<value> where api_name is the api name of the account field on the parent account to write to and
* value is the actual value to write to that field.
*
* The purpose of this functionality is to allow for Preference and Consent values to be written to the account.
* This trigger remains "dumb" to business process and allows for workflows to be configured to handle the
* business logic that defines what values should be copied to which fields.
*
* This trigger also fires on delete. It will remove all values from the account and then retrigger the remaining
* pref and consent records to write their values back to the account.
*/
public without sharing class MERC_PrefConsentMappingHandler implements GLBL_TriggerHandler.HandlerInterface
{
	public Boolean isActive()
	{
		return true;
	}

	public void handle()
	{
		if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete)
			executeCopy();
		else if (Trigger.isDelete)
			executeDelete();
	}

	private void executeCopy()
	{
		/*----- loop over pref & consent records in the trigger and figure
		        out which ones need to be processed -----*/
		Set<Preferences_and_Consent_GLBL__c> pAndCsToProcess = new Set<Preferences_and_Consent_GLBL__c>();
		Set<String> accountFieldsToQuery = new Set<String>();
		Set<Id> accountIds = new Set<Id>();
		for (Preferences_and_Consent_GLBL__c pAndC : (List<Preferences_and_Consent_GLBL__c>) Trigger.new)
		{
			if (String.isNotBlank(pAndC.Account_Field_Update_MERC__c))
			{
				pAndCsToProcess.add(pAndC);
				accountFieldsToQuery.add(pAndC.Account_Field_Update_MERC__c.left(pAndC.Account_Field_Update_MERC__c.indexOf('=')).trim());
				accountIds.add(pAndC.Account_GLBL__c);
			}
		}

		/*----- if nothing to process then return -----*/
		if (pAndCsToProcess.isEmpty())
		{
			return;
		}

		/*----- build a queryString to query the parent accounts -----*/
		String soqlQuery = 'SELECT Id ';
		for (String field : accountFieldsToQuery)
		{
			soqlQuery += ',' + field;
		}
		soqlQuery += ' FROM Account WHERE Id IN (';
		for (Id acctId : accountIds)
		{
			soqlQuery += '\'' + acctId + '\',';
		}
 		/*----- remove the last comma -----*/
		soqlQuery = soqlQuery.left(soqlQuery.length()-1);
		soqlQuery += ')';

		/*----- query the accounts into a map -----*/
		Map<Id, Account> acctMap = new Map<Id, Account>((List<Account>)Database.query(soqlQuery));

		/*----- loop over the Pref and Consent records, parse the Account_Field_Update_MERC__c and update the correct account -----*/
		for (Preferences_and_Consent_GLBL__c pAndC : pAndCsToProcess)
		{
			if (acctMap.containsKey(pAndC.Account_GLBL__c))
			{
				String field = pAndC.Account_Field_Update_MERC__c.left(pAndC.Account_Field_Update_MERC__c.indexOf('=')).trim();
				String value = pAndC.Account_Field_Update_MERC__c.substring(pAndC.Account_Field_Update_MERC__c.indexOf('=')+1).trim();
				acctMap.get(pAndC.Account_GLBL__c).put(field, value);
			}
		}

		try
		{
			update acctMap.values();
		}
		catch (System.DMLException ex)
		{
			System.debug('\n\n\n' + ex + '\n\n\n');
			throw new MERC_Exception('An error has occurred updating an associated account.\n' + ex);
		}
	}

	private void executeDelete()
	{
		/*----- find any accounts for deleted pref and consent records -----*/
		Set<Id> accountIds = new Set<Id>();
		for (SObject pAndC : Trigger.old)
		{
			if (pAndC.get('Account_GLBL__c') != null)
			{
				accountIds.add((Id)pAndC.get('Account_GLBL__c'));
			}
		}

		if (accountIds.isEmpty())
		{
			return;
		}
		/*----- query for the fields to clear out on the account ----*/
		Schema.FieldSet fieldsToClear = Schema.SObjectType.Account.fieldSets.Pref_Consent_Mapped_Fields;
		String soql = 'SELECT ';
		for (Schema.FieldSetMember fsm : fieldsToClear.getFields())
		{
			soql += fsm.getFieldPath() + ', ';
		}
		soql += 'Id FROM Account WHERE Id IN (';
		for (Id acctId : accountIds)
		{
			soql += '\'' + acctId + '\',';
		}
		soql = soql.substring(0, soql.length()-1) + ')';

		system.debug(soql);

		/*----- loop over the accounts and null out the values for the mapped fields -----*/
		List<Account> accounts = Database.query(soql);
		for (Account a : accounts)
		{
			for (FieldSetMember fsm : fieldsToClear.getFields())
			{
				a.put(fsm.getFieldPath(), null);
			}
		}
		update accounts;

		/*----- update the pref and consent records to get the workflow/trigger to refire and repopulate values on account -----*/
		update [SELECT Id FROM Preferences_and_Consent_GLBL__c WHERE Account_GLBL__c IN :accountIds];

	}
}