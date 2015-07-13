/*
 * Author: Kyle Thornton - Mavens Consulting
 * Created Date: 19 Jun 2015
 * Description : This class handles cancellation of all Meeting Processes for meeting participants when they
 *               either decline a meeting, their status is cancelled or the meeting is cancelled
*/
public with sharing class MERC_CancelDelegateMgmtProcesses implements GLBL_TriggerHandler.HandlerInterface{

    public Boolean isActive() {
        return MERC_TriggerHandlerStateManager.isActive(MERC_CancelDelegateMgmtProcesses.class);
    }

    Schema.SobjectType triggeredSobjectType;

    public MERC_CancelDelegateMgmtProcesses(Schema.SObjectType objectType) {
        this.triggeredSobjectType = objectType;
    }

    public void handle() {
	    if (Trigger.isAfter) {
	    	Set<Id> cancelParticipantIds = new Set<Id>();

	    	if (triggeredSobjectType == Meeting_MERC__c.SObjectType) {
	    		List<Meeting_MERC__c> cancelledMeetings =  new List<Meeting_MERC__c>();

	    		for (Meeting_MERC__c meeting : (List<Meeting_MERC__c>)Trigger.new) {
	    			if (meeting.Meeting_Status_MERC__c == 'Complete - Cancelled') {
	    				cancelledMeetings.add(meeting);
	    			}
	    		}

	    		Map<Id, Meeting_Participant_MERC__c> cancelledMeetingParticipants
	    			= new Map<Id, Meeting_Participant_MERC__c>(
	    				[SELECT Id FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c IN :cancelledMeetings]
	    			);

				//add all meeting participant Ids to the set
	    		cancelParticipantIds.addAll(cancelledMeetingParticipants.keySet());
	    	}

	    	if (triggeredSobjectType == Meeting_Participant_MERC__c.SObjectType) {
	    		for (Meeting_Participant_MERC__c participant : (List<Meeting_Participant_MERC__c>)Trigger.new) {
	    			if (participant.Status_MERC__c == 'Declined' || participant.Status_MERC__c == 'Cancelled'){
	    				cancelParticipantIds.add(participant.Id);
	    			}
	    		}
	    	}

	    	if (!cancelParticipantIds.isEmpty()) {
	    		MERC_CancelDelegateMgmtProcesses.execute(cancelParticipantIds);
	    	}
	    }
	}

	static void execute(Set<Id> paricipantIds) {
		List<Meeting_Tasks_MERC__c> tasksToCancel = [SELECT Id,
		                                                    Task_Status_MERC__c
		                                               FROM Meeting_Tasks_MERC__c
		                                              WHERE Meeting_Process_MERC__r.Meeting_Participant_MERC__c IN :paricipantIds
		                                                AND Task_Status_MERC__c LIKE 'Incomplete%'];
		for (Meeting_Tasks_MERC__c task : tasksToCancel) {
			task.Task_Status_MERC__c = 'Completed - Process Cancelled';
		}

		MERC_LockedRecordHandler.overrideLockCheck = true;
		update tasksToCancel;
	}
}