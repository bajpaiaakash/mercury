/**
 * @author Joseph Ferraro
 * @author Rick Locke
 * 
 * Responsible for setting overall status of Meeting Participant based on their attendance at a meeting
 * 	- if they attend ANY days, their overall status is "Attended"
 * 	- if they miss all days, their overall status is "No Show"
 */

public with sharing class MERC_ParticipantStatusCalculator implements GLBL_TriggerHandler.HandlerInterface {
	
	public Boolean isActive() {
		return true;
	}

	public void handle() {
		if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
	    	execute((List<Daily_Attendance_TOV_MERC__c>)Trigger.new);
	   	} else if (Trigger.isDelete) {
	   		execute((List<Daily_Attendance_TOV_MERC__c>)Trigger.old);
	   	}
	}

	public void execute(List<Daily_Attendance_TOV_MERC__c> tovRecords) {        
		
		Set<Id> meetingParticipantIds = new Set<Id>();
		for (Daily_Attendance_TOV_MERC__c tov : tovRecords) {
			meetingParticipantIds.add(tov.Meeting_Participant_MERC__c);
		}

		List<Meeting_Participant_MERC__c> participantsToUpdate = new List<Meeting_Participant_MERC__c>();
		for (Meeting_Participant_MERC__c p : [SELECT 
													Id, 
													(SELECT ID, Status_MERC__c FROM Daily_Attendance_TOV_MERC__r) 
														FROM Meeting_Participant_MERC__c 
															WHERE ID in :meetingParticipantIds]) {
			Integer numberOfNoShows = 0;
			Integer numberOfAttended = 0;

			for (Daily_Attendance_TOV_MERC__c tov : p.Daily_Attendance_TOV_MERC__r) {
				if (tov.Status_MERC__c == 'Attended') {
					numberOfAttended++;
					break;
				} else if (tov.Status_MERC__c == 'No Show') {
					numberOfNoShows++;
				}
			}

			if (numberOfAttended > 0) {
				p.Override_MP_Status_Validation_MERC__c = TRUE;
				p.Status_MERC__c = 'Attended';
			} else if (numberOfNoShows == p.Daily_Attendance_TOV_MERC__r.size()) {
				p.Override_MP_Status_Validation_MERC__c = TRUE;
				p.Status_MERC__c = 'No Show';
			}
			participantsToUpdate.add(p);
		}

		if (Trigger.isAfter) {
			update participantsToUpdate;
		}
	}
}