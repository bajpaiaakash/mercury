/*
* MERC_MeetingRegistrationReviewController
* Authors: David Helmer
*/
public with sharing class MERC_MeetingRegistrationReviewController {
	public MERC_ParticipantListDataObject participantsToReview { get; set; }
    public Boolean confirmSelectAndSaveParticipant { get; set; }
    public Meeting_Participant_MERC__c selectedParticipant { get; set; }
    private Meeting_Participant_MERC__c originalParticipant;

    private final String MISSING_MEETING_ID = 'Missing id parameter. Please pass a meeting record id in as the id parameter';
    private final String REGISTRATION_STATUS_FILTERS = '(\'Incomplete\',\'Pending Review\')';
    private final Integer PAGE_SIZE = 10;
    private final Set<Integer> PAGE_SIZE_SET = null;
    private final Set<String> DEFAULT_FIELDS = new Set<String> { 'Id', 'Account_MERC__r.isPersonAccount', 'Account_MERC__r.Name' };

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

    public Boolean getHasErrors(){
        return ApexPages.hasMessages(ApexPages.Severity.ERROR);
    }
    
    public void saveAndSelectParticipant(){
        confirmSelectAndSaveParticipant = false;
        update selectedParticipant;
        selectParticipant();
    }

    public void confirmOrSelectParticipant(){
        if(selectedParticipant != null && selectedParticipant != originalParticipant){
            confirmSelectAndSaveParticipant = true;
        } else {
            selectParticipant();
        }
    }

    public void selectParticipant(){
        confirmSelectAndSaveParticipant = false;
        String participantQuery = getParticipantQueryString(participantsToReview.selectedParticipantId);
        selectedParticipant = (Meeting_Participant_MERC__c)Database.query(participantQuery)[0];
        originalParticipant = selectedParticipant.clone(true, true, true, true);
    }

    private String getParticipantQueryString(String selectedParticipantId) {
        String query = 'SELECT ';
        Set<String> fields = getMeetingParticipantFields();
        fields.addAll(DEFAULT_FIELDS);
        
        query += String.join(new List<String>(fields), ', ');

        query += ' FROM Meeting_Participant_MERC__c WHERE Id = \'' + selectedParticipantId.replace('\'','') + '\' LIMIT 1';

        system.debug(query);
        return query;
    }

    public Set<String> getMeetingParticipantFields() {
        Set<String> fieldPaths = new Set<String>();
        Map<String, Schema.FieldSet> participantFieldSets = Schema.SObjectType.Meeting_Participant_MERC__c.fieldSets.getMap();
        
        for(Schema.FieldSetMember field : participantFieldSets.get('Meeting_Group_Result_Fields_MERC').getFields()){
            fieldPaths.add(field.getFieldPath());
        }
        for(Schema.FieldSetMember field : participantFieldSets.get('Registration_Review_Edit_Fields_MERC').getFields()){
            fieldPaths.add(field.getFieldPath());
        }
        for(Schema.FieldSetMember field : participantFieldSets.get('Registration_Review_View_Field_MERC').getFields()){
            fieldPaths.add(field.getFieldPath());
        }
        return fieldPaths;
    }

    public Boolean getHasSelectedParticipant(){
        return selectedParticipant != null;
    }

    public void saveParticipant(){
        update selectedParticipant;
    }

    public void reviewComplete(){
        selectedParticipant.Registration_Status_MERC__c = 'Complete';
        saveParticipant();
        participantsToReview.initializeParticipantList();
        selectedParticipant = null;
        originalParticipant = null;
    }

    public void reviewIncomplete(){
        selectedParticipant.Registration_Status_MERC__c = 'Incomplete';
        saveParticipant();
        participantsToReview.initializeParticipantList();
    }
}