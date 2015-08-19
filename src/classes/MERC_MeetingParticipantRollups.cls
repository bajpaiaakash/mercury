/*
	MERC_MeetingParticipantRollups
	@author : Kyle Thornton, Mavens Consulting
	@created : 13 Jul 2015
	@description : This class will take a list of participants and calculate rollups for TOV
	               from child Daily Attendance records and also count Contracts.
	               This class implements the Queueable interface which allows other queueable
	               jobs to be called. It will call the GLBL_AccountRollups class passing in
	               the accounts for each of the meeting participants.
	@modified by :
	@modified date :

*/
public class MERC_MeetingParticipantRollups implements Queueable {

	private Set<Id> participantIds;
	@TestVisible private MERC_AccountRollups accountRollup;

	public MERC_MeetingParticipantRollups(Set<Id> theParticipantIds) {
		participantIds = theParticipantIds;
	}

	public void execute(QueueableContext context) {
		Integer MAX_ATTEMPTS = 3;
		List<Meeting_Participant_MERC__c> participants;
		Integer attempts = MAX_ATTEMPTS;
		//query for participants, may need to retry attempt if records are locked by another asynchronous process
		while (attempts > 0) {
			try {
				attempts--;
				participants = [SELECT Id,
									   Account_MERC__c,
									   Total_Hotel_ToV_MERC__c,
									   Total_Food_Beverage_ToV_MERC__c,
									   Total_Ground_Transporation_ToV_MERC__c,
									   Total_Individual_Transport_ToV_MERC__c,
									   Total_Registration_ToV_MERC__c,
									   Number_of_Contracts_MERC__c,
									   Number_of_Completed_Contracts_MERC__c,
									   (SELECT Est_Hotel_ToV_MERC__c,
									   		   Est_Food_Bev_ToV_MERC__c,
									   		   Est_Grp_Grnd_Transp_MERC__c,
									   		   Est_Indv_Transfer_MERC__c,
									   		   Est_Reg_Amt_ToV_MERC__c
									   	  FROM Daily_Attendance_TOV_MERC__r),
									   (SELECT Contract_Request_Status_MERC__c
									   	  FROM HCP_Contracts__r)
							      FROM Meeting_Participant_MERC__c
							     WHERE Id IN :participantIds
							     FOR UPDATE];
				attempts = 0;
			} catch (System.QueryException qEx) {
				if (!qEx.getMessage().contains('Record Currently Unavailable') || attempts == 0) {
	               	attempts = 0;  // exit on any other exception
					throw qEx;  // throw exception after MAX_ATTEMPTS attempts
				}
			}
		}

		Set<Id> participantAccountIds = new Set<Id>();

		for (Meeting_Participant_MERC__c participant : participants) {
			//add the account id to the set of participant account ids
			participantAccountIds.add(participant.Account_MERC__c);

			//Calculate TOV; Start each out as null
			participant.Total_Hotel_ToV_MERC__c            = null;
		    participant.Total_Food_Beverage_ToV_MERC__c    = null;
		    participant.Total_Ground_Transporation_ToV_MERC__c = null;
		    participant.Total_Individual_Transport_ToV_MERC__c  = null;
		    participant.Total_Registration_ToV_MERC__c     = null;

			for (Daily_Attendance_TOV_MERC__c attendance : participant.Daily_Attendance_TOV_MERC__r) {
				//Hotel TOV
				if (attendance.Est_Hotel_ToV_MERC__c != null) {
					if (participant.Total_Hotel_ToV_MERC__c == null) {
						participant.Total_Hotel_ToV_MERC__c = 0;
					}
					participant.Total_Hotel_ToV_MERC__c += attendance.Est_Hotel_ToV_MERC__c;
				}

				//Food & Beverage TOV
			    if (attendance.Est_Food_Bev_ToV_MERC__c != null) {
			    	if (participant.Total_Food_Beverage_ToV_MERC__c == null) {
			    		participant.Total_Food_Beverage_ToV_MERC__c = 0;
			    	}
			    	participant.Total_Food_Beverage_ToV_MERC__c += attendance.Est_Food_Bev_ToV_MERC__c;
			    }

			    //Ground Transporation TOV
			    if (attendance.Est_Grp_Grnd_Transp_MERC__c != null) {
			    	if (participant.Total_Ground_Transporation_ToV_MERC__c == null) {
			    		participant.Total_Ground_Transporation_ToV_MERC__c = 0;
			    	}
			    	participant.Total_Ground_Transporation_ToV_MERC__c += attendance.Est_Grp_Grnd_Transp_MERC__c;
			    }

			    //Individual Travel TOV
			    if (attendance.Est_Indv_Transfer_MERC__c != null) {
			    	if (participant.Total_Individual_Transport_ToV_MERC__c == null) {
			    		participant.Total_Individual_Transport_ToV_MERC__c = 0;
			    	}
			    	participant.Total_Individual_Transport_ToV_MERC__c += attendance.Est_Indv_Transfer_MERC__c;
			    }

			    //Registration TOV
			    if (attendance.Est_Reg_Amt_ToV_MERC__c != null) {
			    	if (participant.Total_Registration_ToV_MERC__c == null) {
			    		participant.Total_Registration_ToV_MERC__c = 0;
			    	}
			    	participant.Total_Registration_ToV_MERC__c += attendance.Est_Reg_Amt_ToV_MERC__c;
			    }
			}


			//Total Number of HCP Contracts
			participant.Number_of_Contracts_MERC__c = participant.HCP_Contracts__r.size();

			//Total Number of Completed HCP Contacts
			participant.Number_of_Completed_Contracts_MERC__c = 0;
			for (HCP_Contract_MERC__c contract : participant.HCP_Contracts__r) {
				if (contract.Contract_Request_Status_MERC__c == 'Completed') {
					participant.Number_of_Completed_Contracts_MERC__c++;
				}
			}
		}

		//Mercury has a lot going on and occassionaly the system will run into locked rows.
		MERC_TriggerHandlerStateManager.deactivateAll();

		//update participants, may need to retry attempt if records are locked by another asynchronous process
		attempts = MAX_ATTEMPTS;
		while(attempts > 0) {
			try {
				attempts--;
				update participants;
				attempts = 0;
			} catch (System.DmlException dmlEx) {
	       	    if (!dmlEx.getMessage().contains('UNABLE_TO_LOCK_ROW') || attempts == 0) {
	               	attempts = 0;  // exit on any other exception
					throw dmlEx;  // throw exception after MAX_ATTEMPTS
				}
	       	} // end of catch
		} // end of while retry loop


		participantAccountIds.remove(null);

		//unit tests will fail if chained
		if (!participantAccountIds.isEmpty() && !Test.isRunningTest() && Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
			System.enqueueJob(new MERC_AccountRollups(participantAccountIds));
		}
	}
}