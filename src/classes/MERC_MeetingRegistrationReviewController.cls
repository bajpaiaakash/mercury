/*
* MERC_MeetingRegistrationReviewController
* Authors: David Helmer
*/
public with sharing class MERC_MeetingRegistrationReviewController {
	public MERC_ParticipantListDataObject participantsToReview { get; set; }
    public Meeting_Participant_MERC__c selectedParticipant { get; set; }
    private Meeting_Participant_MERC__c originalParticipant;

    private final String MISSING_MEETING_ID = 'Missing id parameter. Please pass a meeting record id in as the id parameter';
    private final String REGISTRATION_STATUS_FILTERS = '(\'Incomplete\',\'Pending Review\')';
    private final Integer PAGE_SIZE = 10;
    private final Set<Integer> PAGE_SIZE_SET = null;

    public MERC_MeetingRegistrationReviewController() {
		String meetingId = getMeetingIdFromParameters();

        if(String.isBlank(meetingId)){
            ApexPages.addMessage(buildErrorMessage(MISSING_MEETING_ID));
        }

        String participantWhereClause = 'Meeting_MERC__c = \'' + meetingId + '\' '
                                      + 'AND Registration_Status_MERC__c IN ' + REGISTRATION_STATUS_FILTERS;
        participantsToReview = new MERC_ParticipantListDataObject(participantWhereClause, PAGE_SIZE, PAGE_SIZE_SET);
	}

    private String getMeetingIdFromParameters(){
        return ApexPages.currentPage().getParameters().get('id');
    }

    private ApexPages.Message buildErrorMessage(String message){
        return new ApexPages.Message(ApexPages.Severity.ERROR, message);
    }

    private String getQueryString(String selectedParticipantId) {
        String query = 'SELECT ';
        for (Schema.FieldSetMember field : getFieldSetFields()) {
            query += field.getFieldPath() + ', ';
        }

        // include isPersonAccount so exception isn't thrown when page block table renders
        query += 'Id, Account_MERC__r.isPersonAccount, Account_MERC__r.Name FROM Meeting_Participant_MERC__c WHERE Id = \'' + selectedParticipantId + '\' LIMIT 1';

        system.debug(query);
        return query;
    }

    public List<Schema.FieldSetMember> getFieldSetFields() {
        return Schema.SObjectType.Meeting_Participant_MERC__c.fieldSets.getMap().get('Meeting_Group_Result_Fields_MERC').getFields();
    }

    public Boolean getHasErrors(){
        return ApexPages.hasMessages(ApexPages.Severity.ERROR);
    }

    public void selectParticipant(){
        if(selectedParticipant != null){
            saveParticipant();
        }
        String participantQuery = getQueryString(participantsToReview.selectedParticipantId);
        selectedParticipant = (Meeting_Participant_MERC__c)Database.query(participantQuery)[0];
        originalParticipant = selectedParticipant.clone();
    }

    public Boolean getHasSelectedParticipant(){
        return selectedParticipant != null;
    }

    public void saveParticipant(){
        update selectedParticipant;
        participantsToReview.initializeParticipantList();
    }

    public void reviewComplete(){
        selectedParticipant.Registration_Status_MERC__c = 'Complete';
        saveParticipant();
    }

    public void reviewIncomplete(){
        selectedParticipant.Registration_Status_MERC__c = 'Incomplete';
        saveParticipant();
    }
}