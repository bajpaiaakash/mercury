/*
* MERC_MeetingRegistrationReviewController
* Authors: David Helmer
*/
public with sharing class MERC_MeetingRegistrationReviewController {
    public String meetingId { get; set; }
	public MERC_ParticipantListDataObject participantsToReview { get; set; }
    public Boolean confirmSelectAndSaveParticipant { get; set; }
    public Meeting_Participant_MERC__c selectedParticipant { get; set; }
    public List<Registration_Question_MERC__c> selectedParticipantQuestions { get; set; }
    public Map<Id, List<Response_MERC__c>> selectedParticipantResponses { get; set; }

    private Meeting_Participant_MERC__c originalParticipant;
    private List<Registration_Question_MERC__c> registrationQuestions { get; set; }

    private final String MISSING_MEETING_ID = 'Missing id parameter. Please pass a meeting record id in as the id parameter';
    private final String REGISTRATION_STATUS_FILTERS = '(\'Incomplete\',\'Pending Review\')';
    private final Integer PAGE_SIZE = 10;
    private final Set<Integer> PAGE_SIZE_SET = null;
    private final Set<String> DEFAULT_MEETING_PARTICIPANT_FIELDS = new Set<String> { 'Id', 'Account_MERC__r.isPersonAccount', 'Account_MERC__r.Name', 'Registration_Status_MERC__c' };
    private final Set<String> MEETING_PARTICIPANT_FIELD_SETS = new Set<String> {
        'Meeting_Group_Result_Fields_MERC',
        'Registration_Review_Edit_Fields_MERC',
        'Registration_Review_View_Field_MERC'
    };
    private final Set<String> DEFAULT_QUESTION_FIELDS = new Set<String> { 'Id' };
    private final Set<String> QUESTION_FIELD_SETS = new Set<String> {
        'Registration_Questions_Review_Flds_MERC'
    };
    private final Set<String> DEFAULT_RESPONSE_FIELDS = new Set<String> { 'Id', 'Registration_Question_MERC__c' };
    private final Set<String> RESPONSE_FIELD_SETS = new Set<String> {
        'Registration_Question_Response_Edit_MERC'
    };

    public MERC_MeetingRegistrationReviewController() {
		meetingId = getMeetingIdFromParameters();

        if(String.isBlank(meetingId)){
            ApexPages.addMessage(buildErrorMessage(MISSING_MEETING_ID));
        }

        initializeParticipantsToReview();
        initializeQuestions();
	}

    private String getMeetingIdFromParameters(){
        return ApexPages.currentPage().getParameters().get('id');
    }

    private ApexPages.Message buildErrorMessage(String message){
        return new ApexPages.Message(ApexPages.Severity.ERROR, message);
    }

    private void initializeParticipantsToReview(){
        String participantWhereClause = 'Meeting_MERC__c = \'' + meetingId + '\' '
                                      + 'AND Registration_Status_MERC__c IN ' + REGISTRATION_STATUS_FILTERS;
        participantsToReview = new MERC_ParticipantListDataObject(participantWhereClause, PAGE_SIZE, PAGE_SIZE_SET);
    }

    private void initializeQuestions(){
        String query = getQuestionStringQuery();
        registrationQuestions = (List<Registration_Question_MERC__c>)Database.query(query);
    }

    private String getQuestionStringQuery() {
        String query = 'SELECT ';
        query += getSelectFieldQuery(getQuestionFields());
        query += ' FROM Registration_Question_MERC__c WHERE Meeting_MERC__c = \'' + meetingId.replace('\'','') + '\'';

        System.debug(LoggingLevel.FINE, 'getQuestionStringQuery.query: ' + query);
        return query;
    }

    private Set<String> getQuestionFields(){
        return getFieldsFor(
            Schema.SObjectType.Registration_Question_MERC__c.fieldSets.getMap(),
            QUESTION_FIELD_SETS,
            DEFAULT_QUESTION_FIELDS);
    }

    private Set<String> getFieldsFor(Map<String, Schema.FieldSet> fieldSetMap, Set<String> fieldSets, Set<String> defaultFields){
        Set<String> fieldSet = new Set<String>(defaultFields);
        for(String fieldSetName : fieldSets){
            for(Schema.FieldSetMember field : fieldSetMap.get(fieldSetName).getFields()){
                fieldSet.add(field.getFieldPath());
            }
        }
        return fieldSet;
    }

    private String getSelectFieldQuery(Set<String> fields){
        return String.join(new List<String>(fields), ', ');
    }

    public Boolean getHasQuestions(){
        return selectedParticipantQuestions != null && selectedParticipantQuestions.size() > 0 || true;
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
        String selectedParticipantId = participantsToReview.selectedParticipantId;
        String participantQuery = getParticipantQueryString(selectedParticipantId);
        selectedParticipant = (Meeting_Participant_MERC__c)Database.query(participantQuery)[0];
        originalParticipant = selectedParticipant.clone(true, true, true, true);
        selectedParticipantResponses = getResponseMap(selectedParticipantId);
        selectedParticipantQuestions = getParticipantQuestions(selectedParticipantResponses.keySet());
    }

    private String getParticipantQueryString(String selectedParticipantId) {
        String query = 'SELECT ';
        query += getSelectFieldQuery(getMeetingParticipantFields());
        query += ' FROM Meeting_Participant_MERC__c WHERE Id = \'' + selectedParticipantId.replace('\'','') + '\' LIMIT 1';

        system.debug(query);
        return query;
    }

    private Set<String> getMeetingParticipantFields(){
        return getFieldsFor(
            Schema.SObjectType.Meeting_Participant_MERC__c.fieldSets.getMap(),
            MEETING_PARTICIPANT_FIELD_SETS,
            DEFAULT_MEETING_PARTICIPANT_FIELDS);
    }

    private Map<Id, List<Response_MERC__c>> getResponseMap(String selectedParticipantId){
        Map<Id, List<Response_MERC__c>> responseMap = new Map<Id, List<Response_MERC__c>>();
        List<Response_MERC__c> responses = (List<Response_MERC__c>)Database.query(getResponseQueryString(selectedParticipantId));
        for(Response_MERC__c response : responses){
            if(!responseMap.containsKey(response.Registration_Question_MERC__c)){
                responseMap.put(response.Registration_Question_MERC__c, new List<Response_MERC__c>());    
            }
            responseMap.get(response.Registration_Question_MERC__c).add(response);
        }

        return responseMap;
    }

    private String getResponseQueryString(String selectedParticipantId){
        String query = 'SELECT ';
        query += getSelectFieldQuery(getResponseFields());
        query += ' FROM Response_MERC__c WHERE Meeting_Participant_MERC__c = \'' + selectedParticipantId.replace('\'','') + '\'';

        system.debug(query);
        return query;
    }

    private Set<String> getResponseFields(){
        return getFieldsFor(
            Schema.SObjectType.Response_MERC__c.fieldSets.getMap(),
            RESPONSE_FIELD_SETS,
            DEFAULT_RESPONSE_FIELDS);
    }

    private List<Registration_Question_MERC__c> getParticipantQuestions(Set<Id> questionIds){
        List<Registration_Question_MERC__c> questions = new List<Registration_Question_MERC__c>();
        for(Registration_Question_MERC__c question : registrationQuestions){
            if(questionIds.contains(question.Id)){
                questions.add(question);
            }
        }
        return questions;
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

    public void registrationComplete(){
        selectedParticipant.Registration_Status_MERC__c = 'Complete';
        saveParticipant();
        participantsToReview.initializeParticipantList();
        selectedParticipant = null;
        originalParticipant = null;
    }

    public void registrationIncomplete(){
        selectedParticipant.Registration_Status_MERC__c = 'Incomplete';
        saveParticipant();
        participantsToReview.initializeParticipantList();
    }
}