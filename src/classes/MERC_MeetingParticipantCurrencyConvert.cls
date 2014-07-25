/**
 * @author Kyle Thornton
 *
 * Description: this trigger handler will convert the value stored in "rollup" fields to the currency
 * of the associated meeting. The values come from objects that are controlled to match the currency
 * of the meeting. On the meeting participant the values are captured in the Meeting currency but
 * if we store the values in currency fields they will be converted to the currency of the meeting
 * partcipant which may differ from the meeting. By writing the rollup values to "rollup" fields we
 * can then query the currency table and make the correct conversion.
 */

public with sharing class MERC_MeetingParticipantCurrencyConvert implements GLBL_TriggerHandler.HandlerInterface
{

	private static Id IndvSponsRecTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Meeting_Participant_MERC__c' AND DeveloperName='Individual_Sponsorship' limit 1].Id;

	public Boolean isActive()
	{
		return true; //before trigger so we should never need to deactivate since it won't trigger other updates
	}

	public void handle()
	{
		if (Trigger.isUpdate && Trigger.isBefore)
		{
			execute();
	   	}
	}

	private void execute()
	{
		Map<String, Decimal> countryCurrencyConversion = new Map<String, Decimal>();
		for (CurrencyType ct : [SELECT IsoCode, ConversionRate FROM CurrencyType])
		{
			countryCurrencyConversion.put(ct.IsoCode, ct.ConversionRate);
		}
// moved to static variable - getting too many SOQL queries error
//		Id IndvSponsRecTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Meeting_Participant_MERC__c' AND DeveloperName='Individual_Sponsorship' limit 1].Id;

		for (Meeting_Participant_MERC__c mp : (List<Meeting_Participant_MERC__c>)Trigger.new)
		{
			if (mp.RecordTypeId != IndvSponsRecTypeId)
			{
				if (mp.Total_Food_Beverage_ToV_Rollup_MERC__c != null)
				{
					mp.Total_Food_Beverage_ToV_MERC__c = mp.Total_Food_Beverage_ToV_Rollup_MERC__c * countryCurrencyConversion.get(mp.ToV_Currency_MERC__c);
				} else {
					mp.Total_Food_Beverage_ToV_MERC__c = null;
				}

				if (mp.Total_Ground_Transport_ToV_Rollup_MERC__c != null)
				{
					mp.Total_Ground_Transporation_ToV_MERC__c = mp.Total_Ground_Transport_ToV_Rollup_MERC__c * countryCurrencyConversion.get(mp.ToV_Currency_MERC__c);
				} else {
					mp.Total_Ground_Transporation_ToV_MERC__c = null;
				}

				if (mp.Total_Hotel_ToV_Rollup_MERC__c != null)
				{
					mp.Total_Hotel_ToV_MERC__c = mp.Total_Hotel_ToV_Rollup_MERC__c * countryCurrencyConversion.get(mp.ToV_Currency_MERC__c);
				} else {
					mp.Total_Hotel_ToV_MERC__c = null;
				}

				if (mp.Total_Registration_ToV_Rollup_MERC__c != null)
				{
					mp.Total_Registration_ToV_MERC__c = mp.Total_Registration_ToV_Rollup_MERC__c * countryCurrencyConversion.get(mp.ToV_Currency_MERC__c);
				} else {
					mp.Total_Registration_ToV_MERC__c = null;
				}
			}
		}
	}
}