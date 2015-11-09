@isTest
private class MERC_ItineraryParticipantUpdateTest {
	
	static Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1)[0];
	static List<Account> accounts = MERC_TestFactory.insertAccounts(3);

	@isTest static void test_participant_should_update_with_null_potential() {

		//insert records with null for Potential_ToV_MERC__c
		List<Meeting_Participant_MERC__c> participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts);
		List<Travel_Itinerary_MERC__c> itineraries = MERC_TestFactory.insertHotelItineraries(participants, Date.today().addDays(1), Date.today().addDays(2));

		List<Id> participantIds = new List<Id>();
		for(Meeting_Participant_MERC__c participant : participants) {
			participantIds.add(participant.Id);
		}

		checkResults(participantIds);
	}

	@isTest static void test_participant_should_update_with_no_potential() {

		//insert participants with no potential
        List<Meeting_Participant_MERC__c> participants = new List<Meeting_Participant_MERC__c>();
        for (Integer i = 0; i < accounts.size(); i++) {
            Meeting_Participant_MERC__c p = new Meeting_Participant_MERC__c();
            p.Account_MERC__c = accounts.get(i).Id;
            p.Meeting_MERC__c = meeting.Id;
            p.Services_Rendered_MERC__c = 'Yes';
            p.Potential_ToV_MERC__c = 'No';
            p.Alliance_MERC__c = 'Not Applicable';  // new process around FMV
            participants.add(p);
        }
        insert participants;		

		List<Travel_Itinerary_MERC__c> itineraries = MERC_TestFactory.insertHotelItineraries(participants, Date.today().addDays(1), Date.today().addDays(2));

		List<Id> participantIds = new List<Id>();
		for(Meeting_Participant_MERC__c participant : participants) {
			participantIds.add(participant.Id);
		}

		checkResults(participantIds);
	}

	static void checkResults(List<Id> participantIds) {
		List<Meeting_Participant_MERC__c> updatedParticipants = new List<Meeting_Participant_MERC__c>();
		updatedParticipants = [SELECT Potential_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id in :participantIds];

		for(Meeting_Participant_MERC__c participant : updatedParticipants) {
			System.assertEquals('Yes',participant.Potential_ToV_MERC__c);
		}
	}
}