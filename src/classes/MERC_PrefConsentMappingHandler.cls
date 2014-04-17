public without sharing class MERC_PrefConsentMappingHandler implements GLBL_TriggerHandler.HandlerInterface
{
	public void handle()
	{
		/*----- Build a map of Pref & Consent record type Ids
		        to the list of field mappings for that record type -----*/
		Map<Id, List<PC_to_Account_Mapping_MERC__c>> mappingsByRecordType = new Map<Id, List<PC_to_Account_Mapping_MERC__c>>();
		for (PC_to_Account_Mapping_MERC__c mapping : PC_to_Account_Mapping_MERC__c.getall().values())
		{
			if (mappingsByRecordType.containsKey(mapping.PC_Record_Type_Id_MERC__c))
			{
				mappingsByRecordType.get(mapping.PC_Record_Type_Id_MERC__c).add(mapping);
			} else {
				mappingsByRecordType.put( mapping.PC_Record_Type_Id_MERC__c, new List<PC_to_Account_Mapping_MERC__c>{mapping});
			}
		}

		/*----- loop over pref & consent records in the trigger and figure
		        out the accounts and record types involved -----*/
		Set<Id> accountIds    = new Set<Id>();
		Set<Id> recordTypeIds = new Set<Id>();
		for (Preferences_and_Consent_GLBL__c pAndC : (List<Preferences_and_Consent_GLBL__c>) Trigger.new)
		{
			accountIds.add(pAndC.Account_GLBL__c);
			recordTypeIds.add(pAndC.RecordTypeId);
		}

		/*----- using the record types, pull out the mappings from
		        mappingsByRecordType so we can get the fields we need to query -----*/
		Set<String> accountFieldApiNames = new Set<String>();
		for (Id recTypeId : recordTypeIds)
		{
			if (mappingsByRecordType.containsKey(recTypeId))
			{
				for (PC_to_Account_Mapping_MERC__c pref : mappingsByRecordType.get(recTypeId))
				{
					accountFieldApiNames.add(pref.Account_Destination_Field_MERC__c);
				}
			}
		}

		/*----- build an account query from the fields that were extracted in the previous step -----*/
		String soqlQuery = 'SELECT Id';
		for (String field : accountFieldApiNames)
		{
			soqlQuery += ', ' + field;
		}
		soqlQuery += ' FROM Account WHERE Id IN (';
		Boolean first = true;
		for (Id accountId : accountIds)
		{
			if (!first) soqlQuery += ', ';
			soqlQuery += '\'' + accountId + '\'';
			if (first) first = false;
		}
		soqlQuery += ')';

		System.debug('\n\n\n>>>>>soqlQuery string is : ' + soqlQuery);

		/*----- query for the accounts and add them to a map -----*/
		Map<Id, Account> accountMap = new Map<Id, Account>( (List<Account>) Database.query(soqlQuery));

		/*----- loop over the pref & consent records in the trigger again, check recod type in mapping and for each
		        mapping copy the value from the P&C record to the associated field on the account-----*/
		List<Account> accountsToUpdate = new List<Account>();
		for (Preferences_and_Consent_GLBL__c pAndC : (List<Preferences_and_Consent_GLBL__c>) Trigger.new)
		{
			/*----- only process a record if a mapping exists for the record type and the account exists -----*/
			if (mappingsByRecordType.containsKey(pAndC.RecordTypeId) && accountMap.containsKey(pAndC.Account_GLBL__c))
			{
				Account a = accountMap.get(pAndC.Account_GLBL__c);
				/*----- for each mapping copy the Pref & Consent field value to the right account field -----*/
				for (PC_to_Account_Mapping_MERC__c mapping : mappingsByRecordType.get(pAndC.RecordTypeId))
				{
					if (String.isNotBlank(mapping.Preference_Type_MERC__c) && pAndC.Preference_Type_MERC__c == mapping.Preference_Type_MERC__c)
					{
						/*----- handle a preference record -----*/
						if (pAndC.Preference_Sub_Type_MERC__c != 'Other')
						{
							//TODO: expand this to a method to handle oddball mappings
							a.put(mapping.Account_Destination_Field_MERC__c, pAndC.Preference_Sub_Type_MERC__c);
						} else {
							a.put(mapping.Account_Destination_Field_MERC__c, pAndC.Preference_Value_MERC__c);
						}
						accountsToUpdate.add(a);
					} else {
						/*----- handle a consent record -----*/

					}

				}
			}
		}
		/*----- update the account records -----*/
		update accountsToUpdate;
	}
}