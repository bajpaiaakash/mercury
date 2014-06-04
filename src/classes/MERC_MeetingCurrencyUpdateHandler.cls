/**
 * @author Kyle Thornton
 *
 * this trigger handler processes currency changes to a meeting by propagating the change down to the child
 * Meeting Participant, Meeting Day, Daily TOV, budget, budget line item and Hotel Allocation records.
 */

public with sharing class MERC_MeetingCurrencyUpdateHandler implements GLBL_TriggerHandler.HandlerInterface
{

	public Boolean isActive()
	{
		return MERC_TriggerHandlerStateManager.isActive(MERC_MeetingCurrencyUpdateHandler.class);
	}

	public void handle()
	{
		Set<Id> meetingIdsWithCurrencyChange = new Set<Id>();
		for (Meeting_MERC__c meeting : (List<Meeting_MERC__c>)Trigger.new)
		{
			if (meeting.CurrencyIsoCode != Trigger.oldMap.get(meeting.Id).get('CurrencyIsoCode'))
			{
				meetingIdsWithCurrencyChange.add(meeting.Id);
			}
		}

		List<Meeting_MERC__c> meetingsToProcess = [SELECT Id, CurrencyIsoCode,
		                                                      (SELECT Id, CurrencyIsoCode, Confirm_ToV_Reporting_Change_MERC__c FROM Meeting_Participants_del__r),
		                                                      (SELECT Id, CurrencyIsoCode, Confirm_ToV_Reporting_Change_MERC__c FROM Meeting_Days__r),
		                                                      (SELECT Id, CurrencyIsoCode FROM Budgets__r),
		                                                      (SELECT Id, CurrencyIsoCode, Confirm_ToV_Reporting_Change_MERC__c FROM Meeting_Vendors__r)
		                                                 FROM Meeting_MERC__c
		                                                WHERE Id IN :meetingIdsWithCurrencyChange];

		List<Meeting_Participant_MERC__c> participantsToUpdate = new List<Meeting_Participant_MERC__c>();
		List<Meeting_Day_MERC__c> meetingDaysToUpdate = new List<Meeting_Day_MERC__c>();
		List<Budget_MERC__c> budgetsToUpdate = new List<Budget_MERC__c>();
		List<Meeting_Vendor_MERC__c> vendorsToUpdate = new List<Meeting_Vendor_MERC__c>();



		for (Meeting_MERC__c meeting : meetingsToProcess)
		{
			for (Meeting_Participant_MERC__c participant : meeting.Meeting_Participants_del__r)
			{
				participant.CurrencyIsoCode = meeting.CurrencyIsoCode;
				participant.Confirm_ToV_Reporting_Change_MERC__c = true;
				participantsToUpdate.add(participant);
			}

			for (Meeting_Day_MERC__c meetingDay : meeting.Meeting_Days__r)
			{
				meetingDay.CurrencyIsoCode = meeting.CurrencyIsoCode;
				meetingDay.Confirm_ToV_Reporting_Change_MERC__c = true;
				meetingDaysToUpdate.add(meetingDay);
			}

			for (Budget_MERC__c budget : meeting.Budgets__r)
			{
				budget.CurrencyIsoCode = meeting.CurrencyIsoCode;
				budgetsToUpdate.add(budget);
			}

			for (Meeting_Vendor_MERC__c vendor : meeting.Meeting_Vendors__r)
			{
				vendor.CurrencyIsoCode = meeting.CurrencyIsoCode;
				vendor.Confirm_ToV_Reporting_Change_MERC__c = true;
				vendorsToUpdate.add(vendor);
			}
		}

		List<Travel_Itinerary_MERC__c> itinerariesToUpdate = new List<Travel_Itinerary_MERC__c>();
		for (Travel_Itinerary_MERC__c itinerary : [SELECT Id, CurrencyIsoCode, Meeting_Participant_MERC__r.Meeting_MERC__r.CurrencyIsoCode, Confirm_ToV_Reporting_Change_MERC__c
			                                         FROM Travel_Itinerary_MERC__c
			                                        WHERE Meeting_Participant_MERC__c IN :participantsToUpdate])
		{
			itinerary.CurrencyIsoCode = itinerary.Meeting_Participant_MERC__r.Meeting_MERC__r.CurrencyIsoCode;
			itinerary.Confirm_ToV_Reporting_Change_MERC__c = true;
			itinerariesToUpdate.add(itinerary);
		}

		List<Daily_Attendance_TOV_MERC__c> tovsToUpdate = new List<Daily_Attendance_TOV_MERC__c>();
		for (Daily_Attendance_TOV_MERC__c tov : [SELECT Id, CurrencyIsoCode, Meeting_Day_MERC__r.Meeting_MERC__r.CurrencyIsoCode, Confirm_ToV_Reporting_Change_MERC__c
			                                       FROM Daily_Attendance_TOV_MERC__c
			                                      WHERE Meeting_Day_MERC__c IN :meetingDaysToUpdate])
		{
			tov.CurrencyIsoCode = tov.Meeting_Day_MERC__r.Meeting_MERC__r.CurrencyIsoCode;
			tov.Confirm_ToV_Reporting_Change_MERC__c = true;
			tovsToUpdate.add(tov);
		}

		List<Hotel_Allocation_MERC__c> allocationsToUpdate = new List<Hotel_Allocation_MERC__c>();
		for (Hotel_Allocation_MERC__c allocation : [SELECT Id, CurrencyIsoCode, Meeting_Day_MERC__r.Meeting_MERC__r.CurrencyIsoCode FROM Hotel_Allocation_MERC__c WHERE Meeting_Day_MERC__c IN :meetingDaysToUpdate])
		{
			allocation.CurrencyIsoCode = allocation.Meeting_Day_MERC__r.Meeting_MERC__r.CurrencyIsoCode;
			allocationsToUpdate.add(allocation);
		}

		List<Budget_Line_Item_MERC__c> budgetLineItemsToUpdate = new List<Budget_Line_Item_MERC__c>();
		for (Budget_Line_Item_MERC__c bli : [SELECT Id, CurrencyIsoCode, Budget_MERC__r.Meeting_Merc__r.CurrencyIsoCode FROM Budget_Line_Item_MERC__c WHERE Budget_MERC__c IN :budgetsToUpdate])
		{
			bli.CurrencyIsoCode = bli.Budget_MERC__r.Meeting_Merc__r.CurrencyIsoCode;
			budgetLineItemsToUpdate.add(bli);
		}

		List<SObject> objectsToUpdate = new List<SObject>();
		objectsToUpdate.addAll((List<SObject>)participantsToUpdate);
		objectsToUpdate.addAll((List<SObject>)meetingDaysToUpdate);
		objectsToUpdate.addAll((List<SObject>)budgetsToUpdate);
		objectsToUpdate.addAll((List<SObject>)budgetLineItemsToUpdate);
		objectsToUpdate.addAll((List<SObject>)tovsToUpdate);
		objectsToUpdate.addAll((List<SObject>)vendorsToUpdate);
		objectsToUpdate.addAll((List<SObject>)allocationsToUpdate);
		objectsToUpdate.addAll((List<SObject>)itinerariesToUpdate);
		try
		{
			update objectsToUpdate;
		}
		catch (System.DMLException ex)
		{
			ApexPages.addMessages(ex);
		}
	}
}