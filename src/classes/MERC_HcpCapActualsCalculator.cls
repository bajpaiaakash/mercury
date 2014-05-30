/**
 * @author Joseph Ferraro
 *
 * Sends meeting participants to the RollupService to calculate Cap Actuals based on activity
 */

public with sharing class MERC_HcpCapActualsCalculator implements GLBL_TriggerHandler.HandlerInterface {

	Schema.SobjectType triggeredSobjectType;

	public Boolean isActive() {
	    return MERC_TriggerHandlerStateManager.isActive(MERC_HcpCapActualsCalculator.class);
	}

	public MERC_HcpCapActualsCalculator(Schema.SobjectType sobjectType) {
		this.triggeredSobjectType = sObjectType;
	}

	public void handle() {
		if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
	    	execute(Trigger.new);
	   	} else if (Trigger.isDelete) {
	   		execute(Trigger.old);
	   	}
	}

	void execute(List<SObject> sobjects) {
		List<Sobject> participantsToRollup;

		if (this.triggeredSobjectType == Meeting_MERC__c.SobjectType) {
			List<Meeting_MERC__c> meetings = (List<Meeting_MERC__c>)sobjects;
			Set<Id> meetingIdsToProcess = new Set<Id>();
			for (Meeting_MERC__c m : meetings) {
				if (
					Trigger.oldMap.get(m.Id).get('Meeting_Status_MERC__c') != m.Meeting_Status_MERC__c ||
					Trigger.oldMap.get(m.Id).get('End_Date_of_Event_MERC__c') != m.End_Date_of_Event_MERC__c
				) {
					meetingIdsToProcess.add(m.Id);
				}
			}
			if (meetingIdsToProcess.size() > 0) {
				participantsToRollup = [SELECT ID, Account_MERC__c, Meeting_MERC__c FROM Meeting_Participant_MERC__c WHERE
											Meeting_MERC__c in :meetingIdsToProcess];

			} else {
				participantsToRollup = new List<Meeting_Participant_MERC__c>();
			}
		} else if (this.triggeredSobjectType == Meeting_Participant_MERC__c.SobjectType) {
			participantsToRollup = sobjects;
		}

		if (participantsToRollup.size() > 0)
			GLBL_RollupService.asyncTriggerHandler(participantsToRollup);
	}
}