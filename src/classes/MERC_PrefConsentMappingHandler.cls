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
*/
public without sharing class MERC_PrefConsentMappingHandler implements GLBL_TriggerHandler.HandlerInterface
{
	public void handle()
	{

		/*----- loop over pref & consent records in the trigger and figure
		        out which ones need to be processed -----*/
		Set<Preferences_and_Consent_GLBL__c> pAndCsToProcess = new Set<Preferences_and_Consent_GLBL__c>();
		Set<String> accountFieldsToQuery = new Set<String>();
		Set<Id> accountIds = new Set<Id>();
		for (Preferences_and_Consent_GLBL__c pAndC : (List<Preferences_and_Consent_GLBL__c>) Trigger.new)
		{
			if (String.isNotBlank(pAndC.Account_Field_Update_MERC__c)
				&& ( Trigger.isInsert ||
					(Trigger.isUpdate && ((Preferences_and_Consent_GLBL__c)Trigger.oldMap.get(pAndC.Id)).Account_Field_Update_MERC__c != pAndC.Account_Field_Update_MERC__c)))
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
}