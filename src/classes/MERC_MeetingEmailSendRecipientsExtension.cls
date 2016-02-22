/*
* Description : Searches for and filters Meeting Participants as MeetingEmailSend Recipients
* Authors: 
*   David Helmer (Refactored From Sonoma Partners MERC_ETMeetingEmailSendExtension)
*/
public with sharing class MERC_MeetingEmailSendRecipientsExtension {
    private final Meeting_MERC__c meeting;
    private final Id meetingId;

    private final String RELATED_MEETING_PARTICIPANT = 'Meeting_Participant_MERC__r.';
    private final String RELATED_MEETING_PARTICIPANT_THROUGH_PROCESS = 'Meeting_Process_MERC__r.Meeting_Participant_MERC__r.';
    private final Integer PAGE_SIZE = 50;
    private final String ASCENDING = 'ASC';
    private final String DESCENDING = 'DESC';
    private final String DEFAULT_SORT_FIELD = 'Account_MERC__r.LastName';
    private final String TRAVEL_PROPOSAL = 'Travel Proposal';

    public final String ANY_OPTION = '-Any-';

    public Set<Id> selectedParticipantIds { get; set; }

    private String processTypeSelected;
    private String proposalStatusSelected;
    private String dueDateSelected;
    private String nextStepSelected;
    private String taskStatusSelected;
    private String communicationChannelSelected;
    private String countryOfResidenceSelected;
    private String participantStatusSelected;
    private String preferredLanguageSelected;
    private String recordTypeSelected;
    private String hasEmailSelected;

    private Set<Id> dueDateFilterIds;
    private Set<Id> nextStepFilterIds;
    private Set<Id> processTypeFilterIds;
    private Set<Id> proposalStatusFilterIds;
    private Set<Id> taskStatusFilterIds;

    private Set<Id> queriedParticipantIds;
    private Set<Id> filteredParticipantIds;
    private ApexPages.StandardSetController meetingParticipantsController;
    private Integer currentPageNumber;
    private String sortField;
    private String sortDirection;

	public MERC_MeetingEmailSendRecipientsExtension(ApexPages.StandardController standardController) {
		meetingId = getMeetingId(standardController);
        
        try {
            meeting = queryMeeting(meetingId);
        } catch(QueryException queryException){
            addFatalMessage('No meeting was found.');
        }

        filteredParticipantIds = null;
        queriedParticipantIds = null;

        sortField = DEFAULT_SORT_FIELD;
        sortDirection = ASCENDING;

        if(selectedParticipantIds == null){
            selectedParticipantIds = new Set<Id>();
        }

        initializeFilterIdSets();
        resetSelectedFiltersToAny();
        updateMeetingParticipants();
	}

    private Id getMeetingId(ApexPages.StandardController standardController){
        if(standardController.getRecord() != null){
            return standardController.getRecord().Id;
        } else {
            return null;
        }
    }

    private Meeting_MERC__c queryMeeting(Id meetingId){
        return [SELECT OwnerId,
                       Id
                  FROM Meeting_MERC__c
                 WHERE Id = :meetingId
                 LIMIT 1];
    }

    private void initializeFilterIdSets(){
        dueDateFilterIds = null;
        nextStepFilterIds = null;
        processTypeFilterIds = null;
        proposalStatusFilterIds = null;
        taskStatusFilterIds = null;
    }

    private void resetSelectedFiltersToAny(){
        communicationChannelSelected = ANY_OPTION;
        countryOfResidenceSelected = ANY_OPTION;
        hasEmailSelected = ANY_OPTION;
        participantStatusSelected = ANY_OPTION;
        preferredLanguageSelected = ANY_OPTION;
        recordTypeSelected = ANY_OPTION;
        resetSelectedProcessFiltersToAny();
    }

    private void resetSelectedProcessFiltersToAny(){
        processTypeSelected = ANY_OPTION;
        proposalStatusSelected = ANY_OPTION;
        dueDateSelected = ANY_OPTION;
        nextStepSelected = ANY_OPTION;
        taskStatusSelected = ANY_OPTION;
    }

    private void updateMeetingParticipants(){
        String meetingParticipantQuery = buildMeetingParticipantQuery();

        System.debug(LoggingLevel.DEBUG, 'updateMeetingParticipants: setting the meeting participant query:\n\t' + meetingParticipantQuery);

        meetingParticipantsController = new ApexPages.StandardSetController(Database.getQueryLocator(meetingParticipantQuery));
        meetingParticipantsController.setPageSize(PAGE_SIZE);

        if(currentPageNumber != null){
            meetingParticipantsController.setPageNumber(currentPageNumber);
        }
    }

    private String buildMeetingParticipantQuery(){
        return    'SELECT Id, '
                + '       Status_MERC__c, '
                + '       Docusign_Contract_Status_MERC__c, '
                + '       Record_Type_MERC__c, '
                + '       Has_Signed_Contract_MERC__c, '
                + '       Country_of_Residence_MERC__c, '
                + '       RecordType.Id, '
                + '       RecordType.Name, '
                + '       Account_MERC__r.Name, '
                + '       Account_MERC__r.FirstName, '
                + '       Account_MERC__r.PersonEmail, '
                + '       Account_MERC__r.LastName, '
                + '       Account_MERC__r.Communication_Preference_MERC__c, '
                + '       Account_MERC__r.Prfrd_Lang_Cd_GLBL__c, '
                + '       Account_MERC__r.Title_Desc_GLBL__c, '
                + '       Account_MERC__r.Sfx_Nm_GLBL__c, '
                + '       Account_MERC__r.Communication_Channel_MERC__c'
                + '  FROM Meeting_Participant_MERC__c '
                + ' WHERE Meeting_MERC__c = :meetingId'
                + buildAndByFilterValueClause('Account_MERC__r.Communication_Channel_MERC__c', communicationChannelSelected)
                + buildAndByFilterValueClause('Country_of_Residence_MERC__c', countryOfResidenceSelected)
                + buildAndByFilterValueClause('Status_MERC__c', participantStatusSelected)
                + buildAndByFilterValueClause('Account_MERC__r.Prfrd_Lang_Cd_GLBL__c', preferredLanguageSelected)
                + buildAndByFilterValueClause('RecordType.Id', recordTypeSelected)
                + buildHasEmailClause()
                + buildFilteredIdsClause()
                + buildOrderClause();
    }

    private String buildAndByFilterValueClause (String filterField, String filterValue) {
        return buildByFilterValueClause(' AND ', filterField, filterValue);
    }

    private String buildByFilterValueClause(String andPrefix, String filterField, String filterValue){
        String filterValueClause = '';
        if(isSelected(filterValue)){
            filterValueClause = andPrefix + filterField + '= \'' + String.escapeSingleQuotes(filterValue) + '\'';
        }
        return filterValueClause;
    }

    private Boolean isSelected(String selected){
        return selected != ANY_OPTION;
    }

    private Boolean isNotSelected(String selected){
        return selected == ANY_OPTION;
    }

    private String buildHasEmailClause(){
        String hasEmailClause = '';

        if (hasEmailSelected == 'Yes') {
            hasEmailClause += '   AND Account_MERC__r.PersonEmail != null ';
        } else if (hasEmailSelected == 'No') {
            hasEmailClause += '   AND Account_MERC__r.PersonEmail = null ' ;
        }

        return hasEmailClause;
    }

    private String buildFilteredIdsClause(){
        String filteredIdsClause = '';

        if(filteredParticipantIds != null){
            filteredIdsClause = ' AND Id IN :filteredParticipantIds';
        }

        return filteredIdsClause;
    }

    private String buildOrderClause(){
        return ' ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection);
    }

    private sObject[] attemptQuery(String query){
        try{
            sObject[] results = Database.query(query);
            return results;
        } catch(QueryException queryException){
            System.debug('Query had exception:\n' + query);
            throw queryException;
        }
    }

    public List<SelectableParticipant> getCurrentPageOfSelectableParticipants(){
        List<SelectableParticipant> currentPageOfSelectableParticipants = new List<SelectableParticipant>();
        for(Meeting_Participant_MERC__c participant : getCurrentPageOfParticipants()){
            Boolean isSelected = selectedParticipantIds.contains(participant.Id);
            currentPageOfSelectableParticipants.add(new SelectableParticipant(participant, isSelected));
        }
        return currentPageOfSelectableParticipants;
    }

    private List<Meeting_Participant_MERC__c> getCurrentPageOfParticipants(){
        return (List<Meeting_Participant_MERC__c>)meetingParticipantsController.getRecords();
    }

    public String getProcessTypeSelected(){
        return processTypeSelected;
    }

    public String getProposalStatusSelected(){
        return proposalStatusSelected;
    }

    public String getDueDateSelected(){
        return dueDateSelected;
    }

    public String getNextStepSelected(){
        return nextStepSelected;
    }

    public String getTaskStatusSelected(){
        return taskStatusSelected;
    }

    public Boolean getShouldRenderTaskFilters(){
        return isSelected(processTypeSelected);
    }

    public Boolean getShouldRenderProposalFilter(){
        return processTypeSelected != TRAVEL_PROPOSAL;
    }

    public void setProcessTypeSelected(String processType){
        processTypeSelected = processType;
        onProcessFilterChange();
    }

    private void onProcessFilterChange(){
        refreshParticipantIdFilters();
        System.debug('onProcessFilterChange filteredParticipantIds: ' + filteredParticipantIds);
        updateMeetingParticipants();
        System.debug('Done onProcessFilterChange');
    }

    private void refreshParticipantIdFilters(){
        filteredParticipantIds = null;
        if(isSelected(processTypeSelected)){
            if(processTypeSelected != TRAVEL_PROPOSAL){
                proposalStatusSelected = ANY_OPTION;
            }

            processTypeFilterIds = queryProcessParticipantIdsByType();
            filteredParticipantIds = new Set<Id>(processTypeFilterIds);

            if(isSelected(proposalStatusSelected)){
                proposalStatusFilterIds = queryItineraryParticipantIdsByProposalStatus();
                filteredParticipantIds.retainAll(proposalStatusFilterIds);
            } else {
                proposalStatusFilterIds = null;
            }

            if(isSelected(dueDateSelected)){
                dueDateFilterIds = queryTaskParticipantIdsByDueDate();
                filteredParticipantIds.retainAll(dueDateFilterIds);
            } else {
                dueDateFilterIds = null;
            }

            if(isSelected(nextStepSelected)){
                nextStepFilterIds = queryTaskParticipantIdsByNextStep();
                filteredParticipantIds.retainAll(nextStepFilterIds);
            } else {
                nextStepFilterIds = null;
            }

            if(isSelected(taskStatusSelected)){
                taskStatusFilterIds = queryTaskParticipantIdsByStatus();
                filteredParticipantIds.retainAll(taskStatusFilterIds);
            } else {
                taskStatusFilterIds = null;
            }
        } else {
            processTypeFilterIds = null;
            resetSelectedProcessFiltersToAny();
        }

        System.debug('refreshParticipantIdFilters: filteredParticipantIds = ' + filteredParticipantIds);
    }

    private Set<Id> queryProcessParticipantIdsByType(){
        String query = 'SELECT Meeting_Participant_MERC__c FROM Meeting_Process_MERC__c'
                     +  buildMeetingWhereClause(RELATED_MEETING_PARTICIPANT)
                     +  buildAndByFilterValueClause('Process_Type_MERC__c', processTypeSelected);

        List<Meeting_Process_MERC__c> meetingProcesses = (List<Meeting_Process_MERC__c>)attemptQuery(query);

        Set<Id> participantIds = new Set<Id>();
        for(Meeting_Process_MERC__c meetingProcess : meetingProcesses){
            participantIds.add(meetingProcess.Meeting_Participant_MERC__c);
        }
        System.debug(LoggingLevel.DEBUG, 'queryProcessParticipantIdsByType result:\t' + participantIds);
        return participantIds;
    }

    private Set<Id> queryItineraryParticipantIdsByProposalStatus(){
        String query = 'SELECT Meeting_Participant_MERC__c FROM Travel_Itinerary_MERC__c'
                     +  buildMeetingWhereClause(RELATED_MEETING_PARTICIPANT)
                     +  buildAndByFilterValueClause('Status_MERC__c', proposalStatusSelected);

        List<Travel_Itinerary_MERC__c> itineraries = (List<Travel_Itinerary_MERC__c>)attemptQuery(query);

        Set<Id> participantIds = new Set<Id>();
        for(Travel_Itinerary_MERC__c itinerary : itineraries){
            participantIds.add(itinerary.Meeting_Participant_MERC__c);
        }
        System.debug(LoggingLevel.DEBUG, 'queryItineraryParticipantIdsByProposalStatus result:\t' + participantIds);
        return participantIds;
    }

    private String buildMeetingWhereClause(String objectPath){
        return ' WHERE ' + objectPath + 'Meeting_MERC__c = \'' + meetingId + '\' ';
    }

    private Set<Id> queryTaskParticipantIdsByStatus(){
        return queryTaskParticipantIds(buildAndByFilterValueClause('Task_Status_MERC__c', taskStatusSelected));
    }
    
    private Set<Id> queryTaskParticipantIdsByDueDate(){
        return queryTaskParticipantIds(buildAndByFilterValueClause('Due_Date_Status_MERC__c', dueDateSelected));
    }
    
    private Set<Id> queryTaskParticipantIdsByNextStep(){
        return queryTaskParticipantIds(buildAndByFilterValueClause('Next_Step_MERC__c', nextStepSelected));
    }

    private Set<Id> queryTaskParticipantIds(String filterClause){
        String query = 'SELECT Meeting_Process_MERC__r.Meeting_Participant_MERC__c FROM Meeting_Tasks_MERC__c'
                     +  buildMeetingWhereClause(RELATED_MEETING_PARTICIPANT_THROUGH_PROCESS)
                     +  filterClause;

        List<Meeting_Tasks_MERC__c> meetingTasks = (List<Meeting_Tasks_MERC__c>)attemptQuery(query);

        Set<Id> participantIds = new Set<Id>();
        for(Meeting_Tasks_MERC__c meetingTask : meetingTasks){
            participantIds.add(meetingTask.Meeting_Process_MERC__r.Meeting_Participant_MERC__c);
        }
        System.debug(LoggingLevel.DEBUG, 'queryTaskParticipantIds where ' + filterClause + ' result:\t' + participantIds);
        return participantIds;
    }
    
    public void setProposalStatusSelected(String selectedValue){
        proposalStatusSelected = selectedValue;
        onProcessFilterChange();
    }
    
    public void setDueDateSelected(String selectedValue){
        dueDateSelected = selectedValue;
        onProcessFilterChange();
    }
    
    public void setNextStepSelected(String selectedValue){
        nextStepSelected = selectedValue;
        onProcessFilterChange();
    }
    
    public void setTaskStatusSelected(String selectedValue){
        taskStatusSelected = selectedValue;
        onProcessFilterChange();
    }

    public List<SelectOption> getProcessTypeOptions(){
        List<SelectOption> processTypeOptions = buildSelectOptionsWithAnyOption();
        List<Schema.PicklistEntry> picklistEntries = Meeting_Process_MERC__c.Process_Type_MERC__c.getDescribe().getPicklistValues();
        List<String> processTypeLabels = getPicklistEntriesWhereNotNullAndIsActive(picklistEntries);
        Set<String> validProcessTypes = getProcessTypesByOtherFilters();

        for(String processTypeLabel : processTypeLabels){
            if(validProcessTypes.contains(processTypeLabel)){
                processTypeOptions.add(buildOption(processTypeLabel));
            }
        }

        return processTypeOptions;
    }

    private List<SelectOption> buildSelectOptionsWithAnyOption(){
        List<SelectOption> selectOptions = new List<SelectOption>();
        selectOptions.add(new SelectOption(ANY_OPTION, ANY_OPTION));
        return selectOptions;
    }

    private SelectOption buildOption(String labelAndValue){
        return new SelectOption(labelAndValue, labelAndValue);
    }

    private List<String> getPicklistEntriesWhereNotNullAndIsActive(List<Schema.PicklistEntry> picklistEntries){
        List<String> labelList = new List<String>();
        for (Schema.PicklistEntry picklistEntry : picklistEntries) {
            if(hasLabelAndIsActive(picklistEntry)) {
                labelList.add(picklistEntry.getLabel());
            }
        }
        return labelList;
    }

    private Boolean hasLabelAndIsActive(Schema.PicklistEntry picklistEntry){
        return picklistEntry.getLabel() != null && picklistEntry.isActive();
    }

    private Set<String> getProcessTypesByOtherFilters(){
        Set<String> processTypes = new Set<String>();

        String query = 'SELECT Process_Type_MERC__c FROM Meeting_Process_MERC__c'
                              + buildMeetingWhereClause(RELATED_MEETING_PARTICIPANT)
                              + buildExcludedFilterWhereClause('processTypeFilterIds', RELATED_MEETING_PARTICIPANT);

        List<Meeting_Process_MERC__c> meetingProcesses = (List<Meeting_Process_MERC__c>)attemptQuery(query);
        for(Meeting_Process_MERC__c meetingProcess : meetingProcesses){
            if(meetingProcess.Process_Type_MERC__c != null){
                processTypes.add(meetingProcess.Process_Type_MERC__c);
            }
        }
        return processTypes;
    }

    private String buildExcludedFilterWhereClause(String filterToExclude, String objectPath){
        String whereClause = '';
        String andPrefix = buildAndPrefixWithObjectPath(objectPath);

        if(processTypeFilterIds != null && filterToExclude != 'processTypeFilterIds'){
            whereClause += andPrefix + 'Id in :processTypeFilterIds';
        }
        if(proposalStatusFilterIds != null && filterToExclude != 'proposalStatusFilterIds'){
            whereClause += andPrefix + 'Id in :proposalStatusFilterIds';
        }
        if(dueDateFilterIds != null && filterToExclude != 'dueDateFilterIds'){
            whereClause += andPrefix + 'Id in :dueDateFilterIds';
        }
        if(nextStepFilterIds != null && filterToExclude != 'nextStepFilterIds'){
            whereClause += andPrefix + 'Id in :nextStepFilterIds';
        }
        if(taskStatusFilterIds != null && filterToExclude != 'taskStatusFilterIds'){
            whereClause += andPrefix + 'Id in :taskStatusFilterIds';
        }
        if(filterToExclude != 'communicationChannelSelected'){
            whereClause += buildByFilterValueClause(andPrefix, 'Account_MERC__r.Communication_Channel_MERC__c', communicationChannelSelected);
        }
        if(filterToExclude != 'countryOfResidenceSelected'){
            whereClause += buildByFilterValueClause(andPrefix, 'Country_of_Residence_MERC__c', countryOfResidenceSelected);
        }
        if(filterToExclude != 'participantStatusSelected'){
            whereClause += buildByFilterValueClause(andPrefix, 'Status_MERC__c', participantStatusSelected);
        }
        if(filterToExclude != 'preferredLanguageSelected'){
            whereClause += buildByFilterValueClause(andPrefix, 'Account_MERC__r.Prfrd_Lang_Cd_GLBL__c', preferredLanguageSelected);
        }
        if(filterToExclude != 'recordTypeSelected'){
            whereClause += buildByFilterValueClause(andPrefix, 'RecordType.Id', recordTypeSelected);
        }

        return whereClause;
    }

    private String buildAndPrefixWithObjectPath(String objectPath){
        return ' AND ' + objectPath;
    }

    public List<SelectOption> getProposalStatusOptions(){
        List<SelectOption> proposalStatusOptions = buildSelectOptionsWithAnyOption();

        for(String proposalStatus : getProposalStatuses()){
            proposalStatusOptions.add(buildOption(proposalStatus));
        }

        return proposalStatusOptions;
    }

    private Set<String> getProposalStatuses(){
        Set<String> proposalStatuses = new Set<String>();

        String query = 'SELECT Status_MERC__c FROM Travel_Itinerary_MERC__c'
                     +  buildMeetingWhereClause(RELATED_MEETING_PARTICIPANT)
                     +  buildExcludedFilterWhereClause('proposalStatusFilterIds', RELATED_MEETING_PARTICIPANT);

        List<Travel_Itinerary_MERC__c> itineraries = (List<Travel_Itinerary_MERC__c>)attemptQuery(query);
        for(Travel_Itinerary_MERC__c itinerary : itineraries){
            if(itinerary.Status_MERC__c != null){
                proposalStatuses.add(itinerary.Status_MERC__c);
            }
        }
        return proposalStatuses;
    }

    public List<SelectOption> getDueDateOptions(){
        List<SelectOption> dueDateOptions = buildSelectOptionsWithAnyOption();

        for(String dueDate : getDueDates()){
            dueDateOptions.add(buildOption(dueDate));
        }

        return dueDateOptions;
    }

    private Set<String> getDueDates(){
        Set<String> dueDates = new Set<String>();

        String query = 'SELECT Due_Date_Status_MERC__c FROM Meeting_Tasks_MERC__c'
                     +  buildMeetingWhereClause(RELATED_MEETING_PARTICIPANT_THROUGH_PROCESS)
                     +  buildExcludedFilterWhereClause('dueDateFilterIds', RELATED_MEETING_PARTICIPANT_THROUGH_PROCESS);

        List<Meeting_Tasks_MERC__c> tasks = (List<Meeting_Tasks_MERC__c>)attemptQuery(query);
        for(Meeting_Tasks_MERC__c task : tasks){
            if(task.Due_Date_Status_MERC__c != null){
                dueDates.add(task.Due_Date_Status_MERC__c);
            }
        }
        return dueDates;
    }

    public List<SelectOption> getNextStepOptions(){
        List<SelectOption> nextStepOptions = buildSelectOptionsWithAnyOption();

        for(String nextStep : getNextSteps()){
            nextStepOptions.add(buildOption(nextStep));
        }

        return nextStepOptions;
    }

    private Set<String> getNextSteps(){
        Set<String> nextSteps = new Set<String>();

        String query = 'SELECT Next_Step_MERC__c FROM Meeting_Tasks_MERC__c'
                     +  buildMeetingWhereClause(RELATED_MEETING_PARTICIPANT_THROUGH_PROCESS)
                     +  buildExcludedFilterWhereClause('nextStepFilterIds', RELATED_MEETING_PARTICIPANT_THROUGH_PROCESS);

        List<Meeting_Tasks_MERC__c> tasks = (List<Meeting_Tasks_MERC__c>)attemptQuery(query);
        for(Meeting_Tasks_MERC__c task : tasks){
            if(task.Next_Step_MERC__c != null){
                nextSteps.add(task.Next_Step_MERC__c);
            }
        }
        return nextSteps;
    }

    public List<SelectOption> getTaskStatusOptions(){
        List<SelectOption> taskStatusOptions = buildSelectOptionsWithAnyOption();

        for(String taskStatus : getTaskStatuses()){
            taskStatusOptions.add(buildOption(taskStatus));
        }

        return taskStatusOptions;
    }

    private Set<String> getTaskStatuses(){
        Set<String> taskStatuses = new Set<String>();

        String query = 'SELECT Task_Status_MERC__c FROM Meeting_Tasks_MERC__c'
                     +  buildMeetingWhereClause(RELATED_MEETING_PARTICIPANT_THROUGH_PROCESS)
                     +  buildExcludedFilterWhereClause('taskStatusFilterIds', RELATED_MEETING_PARTICIPANT_THROUGH_PROCESS);

        List<Meeting_Tasks_MERC__c> tasks = (List<Meeting_Tasks_MERC__c>)attemptQuery(query);
        for(Meeting_Tasks_MERC__c task : tasks){
            if(task.Task_Status_MERC__c != null){
                taskStatuses.add(task.Task_Status_MERC__c);
            }
        }
        return taskStatuses;
    }


    public List<SelectOption> getCommunicationChannelOptions(){
        List<SelectOption> processTypeOptions = buildSelectOptionsWithAnyOption();
        List<Schema.PicklistEntry> picklistEntries = Meeting_Process_MERC__c.Process_Type_MERC__c.getDescribe().getPicklistValues();
        List<String> processTypeLabels = getPicklistEntriesWhereNotNullAndIsActive(picklistEntries);
        Set<String> validProcessTypes = getCommunicationChannelsByMeeting();

        for(String processTypeLabel : processTypeLabels){
            if(validProcessTypes.contains(processTypeLabel)){
                processTypeOptions.add(buildOption(processTypeLabel));
            }
        }

        return processTypeOptions;
    }

    private Set<String> getCommunicationChannelsByMeeting(){
        Set<String> processTypes = new Set<String>();
        String query = 'SELECT Process_Type_MERC__c FROM Meeting_Process_MERC__c';
        if(filteredParticipantIds != null){
            query += buildExcludedFilterWhereClause('filteredParticipantIds', RELATED_MEETING_PARTICIPANT);
        }

        List<Meeting_Process_MERC__c> meetingProcesses = (List<Meeting_Process_MERC__c>)attemptQuery(query);
        for(Meeting_Process_MERC__c meetingProcess : meetingProcesses){
            if(meetingProcess.Process_Type_MERC__c != null){
                processTypes.add(meetingProcess.Process_Type_MERC__c);
            }
        }
        return processTypes;
    }

    public Boolean getHasFatalMessages(){
        return ApexPages.hasMessages(ApexPages.Severity.FATAL);
    }

    private void addMessage(ApexPages.Severity severity, String message){
        ApexPages.addMessage(new ApexPages.Message(severity, message));
    }

    private void addFatalMessage(String message){
        addMessage(ApexPages.Severity.FATAL, message);
    }

    private void addWarningMessage(String message){
        addMessage(ApexPages.Severity.WARNING, message);
    }

    private void addErrorMessage(String message){
        addMessage(ApexPages.Severity.ERROR, message);
    }

    @TestVisible
    private class SelectableParticipant
    {
        public Meeting_Participant_MERC__c Participant { get; private set; }
        public Boolean IsSelected { get; set; }

        public SelectableParticipant(Meeting_Participant_MERC__c participant, Boolean isSelected) {
            this.Participant = participant;
            this.IsSelected = isSelected;
        }
    }
}