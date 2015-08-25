public with sharing class MERC_ETMeetingEmailSendExtension {

    private final Meeting_MERC__c meeting;
    public Sonoma_ET_Config__c Config { get; private set; }
    public boolean IsAllChecked { get; set; }
    public boolean DeDup { get; set; }
    public boolean DisableIndividualTracking { get; set; }
    public String SendTime { get; set; }
    public boolean OptIn { get; set; }
    public boolean ShowParticipantGrid { get; set; }
    public String additionalInformationHTML { get; set; }
    public String base64Thumbnail { get; private set; }

    public Set<Id> selectedParticipantIds { get; set; }


    //filters for select participant page
    public List<SelectOption> communicationPreference { 
        get {
            Set<String> communicationPreferenceSet = new Set<String>(); 
            communicationPreference = selectOptionListInitialize();

            String soql  = 'SELECT Account_MERC__r.Communication_Preference_MERC__c, ';
                   soql += '                             Account_MERC__r.Country_of_Residence_GLBL__c, ';
                   soql += '                             Account_MERC__r.Prfrd_Lang_Cd_GLBL__c, ';
                   soql += '                              Status_MERC__c ';
                   soql += '                         FROM Meeting_Participant_MERC__c  ';
                   soql += queryBuilder('communicationPreference','');
            //build select options that are solely based on the participants for the meeting
            for (Meeting_Participant_MERC__c p : (List<Meeting_Participant_MERC__c>) Database.query(soql)) {
                if (p.Account_MERC__r.Communication_Preference_MERC__c != null && !communicationPreferenceSet.contains(p.Account_MERC__r.Communication_Preference_MERC__c)) {
                    communicationPreferenceSet.add(p.Account_MERC__r.Communication_Preference_MERC__c);
                    communicationPreference.add(new SelectOption(p.Account_MERC__r.Communication_Preference_MERC__c,p.Account_MERC__r.Communication_Preference_MERC__c));
                }
            }
            communicationPreference = sortOptionList(communicationPreference);
            return communicationPreference;
        } 
        set; 
    }
    public String communicationPreferenceSelected { get; set; }
    
    public List<SelectOption> countryOfResidence { 
        get {
            Set<String> countryOfResidenceSet = new Set<String>();
            countryOfResidence = selectOptionListInitialize();

            //Retrieve all country of residence info to build labels and values for SelectOptions later.
            Schema.DescribeFieldResult countryOfResidenceFieldResult = Account.Country_of_Residence_GLBL__c.getDescribe();
            List<Schema.PicklistEntry> pleList = countryOfResidenceFieldResult.getPicklistValues();
            Map<String,String> countryOfResidenceLabelMap = new Map<String,String>();
            for (Schema.PicklistEntry ple : pleList) {
                if(ple.getValue() != null && ple.isActive()) {
                    countryOfResidenceLabelMap.put(ple.getValue(),ple.getLabel());
                }
            }
            //build select options that are solely based on the participants for the meeting
            for (Meeting_Participant_MERC__c p : [SELECT Account_MERC__r.Communication_Preference_MERC__c,
                                                         Account_MERC__r.Country_of_Residence_GLBL__c,
                                                         Account_MERC__r.Prfrd_Lang_Cd_GLBL__c,
                                                         Status_MERC__c
                                                    FROM Meeting_Participant_MERC__c 
                                                   WHERE Meeting_MERC__c = :meeting.Id]) {
                if (p.Account_MERC__r.Country_of_Residence_GLBL__c != null && !countryOfResidenceSet.contains(p.Account_MERC__r.Country_of_Residence_GLBL__c)) {
                    countryOfResidenceSet.add(p.Account_MERC__r.Country_of_Residence_GLBL__c);
                    countryOfResidence.add(new SelectOption(p.Account_MERC__r.Country_of_Residence_GLBL__c,countryOfResidenceLabelMap.get(p.Account_MERC__r.Country_of_Residence_GLBL__c)));
                }
            }
            countryOfResidence = sortOptionList(countryOfResidence);
            return countryOfResidence;
        } 
        set; 
    }
    public String countryOfResidenceSelected {get; set;}

    // THIS WILL BE MOVED IT'S HERE FOR EASE OF USE ATM
    public String queryBuilder (String filter, String objectPath) {
        System.debug('#### queryBuilder accessed with filter of ' + filter + ' and ObjectPath of ' + objectPath);
        String  soqlQuery  = ' WHERE ' + objectPath + 'Meeting_MERC__c = \'' + meeting.Id + '\' ';
        soqlQuery += filterSegmentBuilder('dueDate',filter,dueDateSelected,objectPath);
        soqlQuery += filterSegmentBuilder('nextStep',filter,nextStepSelected,objectPath);
        soqlQuery += filterSegmentBuilder('processType',filter,processTypeSelected,objectPath);
        soqlQuery += filterSegmentBuilder('proposalStatus',filter,proposalStatusSelected,objectPath);
        soqlQuery += filterSegmentBuilder('taskStatus',filter,taskStatusSelected,objectPath);

        return soqlQuery;
    }
    // THIS WILL BE MOVED IT'S HERE FOR EASE OF USE ATM
    public String filterSegmentBuilder (String processingFilter, String passedFilter, String selected, String objectPath) {
        Boolean objectPathPresent = (objectPath != '');
        System.debug('#### segmentBuilder accessed with filter of ' + passedFilter + ' and ObjectPath of ' + objectPath);
        String soqlSegment = '';
        if (passedFilter != processingFilter && selected != '-Any-') {
            soqlSegment += ' AND ' + objectPath + 'Id in :' + processingFilter + 'FilterIds';
        }
        return soqlSegment;
    }

    // THIS WILL BE MOVED IT'S HERE FOR EASE OF USE ATM
    public String unfilteredSegmentBuilder () {
        return '';
    }

    public List<SelectOption> dueDate { 
        get {
            System.debug('#### getDueDate.');
            Set<String> dueDateSet = new Set<String>();
            dueDate = selectOptionListInitialize();
            String soql  = ' SELECT Due_Date_Status_MERC__c ';
                   soql += '   FROM Meeting_Tasks_MERC__c ';
                   soql += queryBuilder('dueDate', 'Meeting_Process_MERC__r.Meeting_Participant_MERC__r.');
            System.debug('#### SOQL = ' + soql);
            for (Meeting_Tasks_MERC__c t : (List<Meeting_Tasks_MERC__c>) Database.query(soql)) {
                if (t.Due_Date_Status_MERC__c != null && !dueDateSet.contains(t.Due_Date_Status_MERC__c)) {
                    dueDateSet.add(t.Due_Date_Status_MERC__c);
                    dueDate.add(new SelectOption(t.Due_Date_Status_MERC__c,t.Due_Date_Status_MERC__c));
                }
            }
            dueDate = sortOptionList(dueDate);
            return dueDate;
        } 
        set; 
    }
    public String dueDateSelected {get; set;}

    public List<SelectOption> hasEmail { 
        get {
            //prep the SelectOption list
            hasEmail = selectOptionListInitialize();
            //Build hasEmail selectOption
            hasEmail.add(new SelectOption('Yes','Yes'));
            hasEmail.add(new SelectOption('No','No'));
            return hasEmail;
        }
        set; 
    }
    public String hasEmailSelected {get; set;}

    public List<SelectOption> nextStep { 
        get {
            Set<String> nextStepSet = new Set<String>();
            nextStep = selectOptionListInitialize();
            for (Meeting_Tasks_MERC__c t : [SELECT Next_Step_MERC__c 
                                              FROM Meeting_Tasks_MERC__c 
                                             WHERE Meeting_Process_MERC__r.Meeting_Participant_MERC__r.Meeting_MERC__c = :meeting.Id
                                          ORDER BY Next_Step_MERC__c]) {
                if (t.Next_Step_MERC__c != null && !nextStepSet.contains(t.Next_Step_MERC__c)) {
                    nextStepSet.add(t.Next_Step_MERC__c);
                    nextStep.add(new SelectOption(t.Next_Step_MERC__c,t.Next_Step_MERC__c));
                }
            }
            nextStep = sortOptionList(nextStep);
            return nextStep;
        } 
        set; 
    }
    public String nextStepSelected {get; set;}

    public List<SelectOption> participantStatus { 
        get {
            Set<String> participantStatusSet = new Set<String>();
            participantStatus = selectOptionListInitialize();

            //build select options that are solely based on the participants for the meeting
            for (Meeting_Participant_MERC__c p : [SELECT Account_MERC__r.Communication_Preference_MERC__c,
                                                         Account_MERC__r.Country_of_Residence_GLBL__c,
                                                         Account_MERC__r.Prfrd_Lang_Cd_GLBL__c,
                                                         Status_MERC__c
                                                    FROM Meeting_Participant_MERC__c 
                                                   WHERE Meeting_MERC__c = :meeting.Id]) {
                if (p.Status_MERC__c != null && !participantStatusSet.contains(p.Status_MERC__c)) {
                    participantStatusSet.add(p.Status_MERC__c);
                    participantStatus.add(new SelectOption(p.Status_MERC__c,p.Status_MERC__c));
                }

            }
            participantStatus = sortOptionList(participantStatus);
            return participantStatus;
        } 
        set; 
    }
    public String participantStatusSelected {get; set;}

    public List<SelectOption> preferredLanguage { 
        get {
            Set<String> preferredLanguageSet = new Set<String>(); 
     
            Set<String> statusSet = new Set<String>();

            //prep the SelectOption lists

            preferredLanguage = selectOptionListInitialize();
            recordType = selectOptionListInitialize();

            //find all record types and build SelectOption list
            for(RecordType rt : [SELECT Name FROM RecordType  WHERE SObjectType = 'Meeting_Participant_MERC__c' AND IsActive = TRUE]) {
                recordType.add(new SelectOption(rt.Id,rt.Name));
            }

            //build select options that are solely based on the participants for the meeting
            for (Meeting_Participant_MERC__c p : [SELECT Account_MERC__r.Communication_Preference_MERC__c,
                                                         Account_MERC__r.Country_of_Residence_GLBL__c,
                                                         Account_MERC__r.Prfrd_Lang_Cd_GLBL__c,
                                                         Status_MERC__c
                                                    FROM Meeting_Participant_MERC__c 
                                                   WHERE Meeting_MERC__c = :meeting.Id]) {
                if (p.Account_MERC__r.Prfrd_Lang_Cd_GLBL__c != null && !preferredLanguageSet.contains(p.Account_MERC__r.Prfrd_Lang_Cd_GLBL__c)) {
                    preferredLanguageSet.add(p.Account_MERC__r.Prfrd_Lang_Cd_GLBL__c);
                    preferredLanguage.add(new SelectOption(p.Account_MERC__r.Prfrd_Lang_Cd_GLBL__c,p.Account_MERC__r.Prfrd_Lang_Cd_GLBL__c));
                }

            }

            preferredLanguage = sortOptionList(preferredLanguage);
            return preferredLanguage;
        }
        set; 
    }
    public String preferredLanguageSelected {get; set;}

    public List<SelectOption> processType {
        get {
            Set<String> processTypeSet = new Set<String>(); 
            processType = selectOptionListInitialize();
            //build process type select options that are solely based on the participants for the meeting
            for (Meeting_Process_MERC__c p : [SELECT Process_Type_MERC__c 
                                                FROM Meeting_Process_MERC__c 
                                               WHERE Meeting_Participant_MERC__r.Meeting_MERC__c = :meeting.Id
                                            ORDER BY Process_Type_MERC__c]) {
                if (p.Process_Type_MERC__c != null && !processTypeSet.contains(p.Process_Type_MERC__c)) {
                    processTypeSet.add(p.Process_Type_MERC__c);
                    processType.add(new SelectOption(p.Process_Type_MERC__c,p.Process_Type_MERC__c));
                }
            }
            processType = sortOptionList(processType);
            return processType;
        } 
        set;}
    public String processTypeSelected {get; set;}

    public List<SelectOption> proposalStatus {
        get {
            Set<String> proposalStatusSet = new Set<String>(); 
            proposalStatus = selectOptionListInitialize();
            for (Travel_Itinerary_MERC__c t : [SELECT Status_MERC__c 
                                                 FROM Travel_Itinerary_MERC__c
                                                WHERE Travel_Proposal_MERC__c = null
                                                  AND Meeting_Participant_MERC__r.Meeting_MERC__c = :meeting.Id]) {
                if (t.Status_MERC__c != null && !proposalStatusSet.contains(t.Status_MERC__c)) {
                    proposalStatusSet.add(t.Status_MERC__c);
                    proposalStatus.add(new SelectOption(t.Status_MERC__c,t.Status_MERC__c));
                } 
            }
            proposalStatus = sortOptionList(proposalStatus);
            return proposalStatus;
        } 
        set;
    }
    public String proposalStatusSelected {get; set;}
    public Boolean proposalStatusRender {
        get {
            return (processTypeSelected == 'Travel Proposal');
        }
        private set;
    }

    public List<SelectOption> recordType { 
        get {
            recordType = selectOptionListInitialize();
            //find all record types and build SelectOption list
            for(RecordType rt : [SELECT Name FROM RecordType  WHERE SObjectType = 'Meeting_Participant_MERC__c' AND IsActive = TRUE]) {
                recordType.add(new SelectOption(rt.Id,rt.Name));
            }
            recordType = sortOptionList(recordType);
            return recordType;
        }
        set; 
    }
    public String recordTypeSelected {get; set;}

    public List<SelectOption> taskStatus { 
        get {
            Set<String> taskStatusSet = new Set<String>();
            taskStatus = selectOptionListInitialize();
            for (Meeting_Tasks_MERC__c t : [SELECT Task_Status_MERC__c 
                                              FROM Meeting_Tasks_MERC__c 
                                             WHERE Meeting_Process_MERC__r.Meeting_Participant_MERC__r.Meeting_MERC__c = :meeting.Id
                                               AND Meeting_Process_MERC__r.Process_Type_MERC__c = :processTypeSelected
                                          ORDER BY Task_Status_MERC__c]) {
                if (t.Task_Status_MERC__c != null && !taskStatusSet.contains(t.Task_Status_MERC__c)) {
                    taskStatusSet.add(t.Task_Status_MERC__c);
                    taskStatus.add(new SelectOption(t.Task_Status_MERC__c,t.Task_Status_MERC__c));
                }
            }
            taskStatus = sortOptionList(taskStatus);
            return taskStatus;
        } 
        set; 
    }
    public String taskStatusSelected {get; set;}
    public Boolean taskStatusRender {
        get {
            return (processTypeSelected != '-Any-');
        }
        private set;
    }

    // Sorting suffixes
    public String headerTitleSuffix { 
        get {
            if (sortField == 'Account_MERC__r.Title_Desc_GLBL__c') {
                if (sortDirection == 'ASC') {
                    return '^';
                } else {
                    return 'v';
                }
            }
            else {
                return ' ';
            }
        }
        set; 
    }

    public String headerFirstNameSuffix { 
        get {
            if (sortField == 'Account_MERC__r.FirstName') {
                if (sortDirection == 'ASC') {
                    return '^';
                } else {
                    return 'v';
                }
            }
            else {
                return ' ';
            }
        }
        set; 
    }

    public String headerLastNameSuffix { 
        get {
            if (sortField == 'Account_MERC__r.LastName') {
                if (sortDirection == 'ASC') {
                    return '^';
                } else {
                    return 'v';
                }
            }
            else {
                return ' ';
            }
        }
        set; 
    }

    public String headerSuffixSuffix { 
        get {
            if (sortField == 'Account_MERC__r.Sfx_Nm_GLBL__c') {
                if (sortDirection == 'ASC') {
                    return '^';
                } else {
                    return 'v';
                }
            }
            else {
                return ' ';
            }
        }
        set; 
    }

    public String headerEmailSuffix { 
        get {
            if (sortField == 'Account_MERC__r.PersonEmail') {
                if (sortDirection == 'ASC') {
                    return '^';
                } else {
                    return 'v';
                }
            }
            else {
                return ' ';
            }
        }
        set; 
    }

    public String headerStatusSuffix { 
        get {
            if (sortField == 'Status_MERC__c') {
                if (sortDirection == 'ASC') {
                    return '^';
                } else {
                    return 'v';
                }
            }
            else {
                return ' ';
            }
        }
        set; 
    }

    public String headerRecordTypeSuffix { 
        get {
            if (sortField == 'Record_Type_Name_MERC__c') {
                if (sortDirection == 'ASC') {
                    return '^';
                } else {
                    return 'v';
                }
            }
            else {
                return ' ';
            }
        }
        set; 
    }

    public String headerCommPrefSuffix { 
        get {
            if (sortField == 'Account_MERC__r.Communication_Preference_MERC__c') {
                if (sortDirection == 'ASC') {
                    return '^';
                } else {
                    return 'v';
                }
            }
            else {
                return ' ';
            }
        }
        set; 
    }

    public String headerPrefLangSuffix { 
        get {
            if (sortField == 'Account_MERC__r.Prfrd_Lang_Cd_GLBL__c') {
                if (sortDirection == 'ASC') {
                    return '^';
                } else {
                    return 'v';
                }
            }
            else {
                return ' ';
            }
        }
        set; 
    }

    public String headerCountrySuffix { 
        get {
            if (sortField == 'Account_MERC__r.Country_of_Residence_GLBL__c') {
                if (sortDirection == 'ASC') {
                    return '^';
                } else {
                    return 'v';
                }
            }
            else {
                return ' ';
            }
        }
        set; 
    }

    // these are used to filter participants for filters and data
    public Set<Id> filteredParticipantIds { get; set; }
    public Set<Id> dueDateFilterIds { get; set; }
    public Set<Id> nextStepFilterIds { get; set; }
    public Set<Id> processTypeFilterIds { get; set; }
    public Set<Id> proposalStatusFilterIds { get; set; }
    public Set<Id> taskStatusFilterIds { get; set; }

    //constructor
    public MERC_ETMeetingEmailSendExtension(ApexPages.StandardController stdController) {
        this.meeting = (Meeting_MERC__c)stdController.getRecord();
        if (meeting == null || meeting.Id == null) {
            AddFatalMessage('You must specify a meeting id.');
        }

        emails = new List<MERC_ETObject.EmailFolder>();
        callControl = new MERC_ETCallControl();

        Config = Sonoma_ET_Config__c.getInstance();
        if (Config == null) {
            AddFatalMessage('No configuration object was found. Please contact your administrator.');
        }

        ShowParticipantGrid = false;
        parser = new MERC_ETParseString();
        email = new MERC_ETFolderedEmail();

        SendTime = 'now';

        //set defaults
        resetFilters();
        selectedParticipantIds = new Set<Id>();
        filterParticipants();

    }

    public void filterParticipants () {

        Set<Id> filteredIds = new Set<Id>();
        Boolean filterIdTouched = false;

        String processTypeSoql = '';
        if (processTypeSelected != '-Any-') {
            if (processTypeSelected != 'Travel Proposal') {
                proposalStatusSelected = '-Any-';
            }
            processTypeSoql += ' SELECT Meeting_Participant_MERC__c ';
            processTypeSoql += '   FROM Meeting_Process_MERC__c ';
            processTypeSoql += '  WHERE Meeting_Participant_MERC__r.Meeting_MERC__c = \'' + meeting.Id + '\' ';
            processTypeSoql += '    AND Process_Type_MERC__c = \'' + String.escapeSingleQuotes(processTypeSelected) + '\'';
        } else if (processTypeSelected == '-Any-'){
            proposalStatusSelected = '-Any-';
            taskStatusSelected = '-Any-';
        }
        if (processTypeSoql != '') {
            List<Meeting_Process_MERC__c> processes = Database.query(processTypeSoql);
            if (processes != null) {
                Set<Id> processTypeIds = new Set<Id>();
                for (Meeting_Process_MERC__c process : processes) {
                    processTypeIds.add(process.Meeting_Participant_MERC__c);
                    filteredIds.add(process.Meeting_Participant_MERC__c);
                }
                processTypeFilterIds = processTypeIds;
            }
        }

        String proposalStatusSoql = '';
        if (proposalStatusSelected != '-Any-') {
                proposalStatusSoql += '   SELECT Meeting_Participant_MERC__c '; 
                proposalStatusSoql += '     FROM Travel_Itinerary_MERC__c ';
                proposalStatusSoql += '    WHERE Travel_Proposal_MERC__c = null ';
                proposalStatusSoql += '      AND Meeting_Participant_MERC__r.Meeting_MERC__c = \'' + meeting.Id + '\' ';
                proposalStatusSoql += '     AND Status_MERC__c  = \'' + String.escapeSingleQuotes(proposalStatusSelected) + '\'';
        }
        if (proposalStatusSoql != '') {
            List<Travel_Itinerary_MERC__c> proposals = Database.query(proposalStatusSoql);
            if (proposals != null) {
                Set<Id> proposalStatusIds = new Set<Id>();
                Set<Id> newFilteredIds = new Set<Id>();
                for (Travel_Itinerary_MERC__c proposal : proposals) {
                    proposalStatusIds.add(proposal.Meeting_Participant_MERC__c);
                    if (filterIdTouched) {
                        if (filteredIds.contains(proposal.Meeting_Participant_MERC__c)) {
                            newFilteredIds.add(proposal.Meeting_Participant_MERC__c);
                        }
                    } else {
                        newFilteredIds.add(proposal.Meeting_Participant_MERC__c);
                    }
                }
                filteredIds = new Set<Id>();
                filteredIds = newFilteredIds;
                proposalStatusFilterIds = proposalStatusIds;
            }
        }

        String dueDateSoql = '';
        if (dueDateSelected != '-Any-') {
                dueDateSoql =  'SELECT Meeting_Process_MERC__r.Meeting_Participant_MERC__c ';
                dueDateSoql += '  FROM Meeting_Tasks_MERC__c ';
                dueDateSoql += ' WHERE Meeting_Process_MERC__r.Meeting_Participant_MERC__r.Meeting_MERC__c = \'' + String.escapeSingleQuotes(meeting.Id) + '\'';
            if (dueDateSelected != '-Any-') {
                dueDateSoql += '   AND Due_Date_Status_MERC__c = \'' + String.escapeSingleQuotes(dueDateSelected) + '\'';
            }
        }
        if (dueDateSoql != '') {
            List<Meeting_Tasks_MERC__c> tasks = Database.query(dueDateSoql);
            if (tasks != null) {
                Set<Id> taskIds = new Set<Id>();
                Set<Id> newFilteredIds = new Set<Id>();
                for (Meeting_Tasks_MERC__c task : tasks) {
                    taskIds.add(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c);
                    if (filterIdTouched) {
                        if(filteredIds.contains(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c)) {
                            filteredIds.add(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c);
                        }
                    } else {
                        newFilteredIds.add(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c);
                    }
                }
                filteredIds = new Set<Id>();
                filteredIds = newFilteredIds;
                dueDateFilterIds = taskIds;
            }
        }

        String nextStepSoql = '';
        if (nextStepSelected != '-Any-') {
                nextStepSoql =  'SELECT Meeting_Process_MERC__r.Meeting_Participant_MERC__c ';
                nextStepSoql += '  FROM Meeting_Tasks_MERC__c ';
                nextStepSoql += ' WHERE Meeting_Process_MERC__r.Meeting_Participant_MERC__r.Meeting_MERC__c = \'' + String.escapeSingleQuotes(meeting.Id) + '\'';
            if (nextStepSelected != '-Any-') {
                nextStepSoql += '   AND Next_Step_MERC__c = \'' + String.escapeSingleQuotes(nextStepSelected) + '\'';
            }
        }
        if (nextStepSoql != '') {
            List<Meeting_Tasks_MERC__c> tasks = Database.query(nextStepSoql);
            if (tasks != null) {
                Set<Id> taskIds = new Set<Id>();
                Set<Id> newFilteredIds = new Set<Id>();
                for (Meeting_Tasks_MERC__c task : tasks) {
                    taskIds.add(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c);
                    if (filterIdTouched) {
                        if(filteredIds.contains(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c)) {
                            filteredIds.add(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c);
                        }
                    } else {
                        newFilteredIds.add(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c);
                    }
                }
                filteredIds = new Set<Id>();
                filteredIds = newFilteredIds;
                nextStepFilterIds = taskIds;
            }
        }

        String taskStatusSoql = '';
        if (taskStatusSelected != '-Any-') {
                taskStatusSoql =  'SELECT Meeting_Process_MERC__r.Meeting_Participant_MERC__c ';
                taskStatusSoql += '  FROM Meeting_Tasks_MERC__c ';
                taskStatusSoql += ' WHERE Meeting_Process_MERC__r.Meeting_Participant_MERC__r.Meeting_MERC__c = \'' + String.escapeSingleQuotes(meeting.Id) + '\'';
            if (taskStatusSelected != '-Any-') {
                taskStatusSoql += '   AND Task_Status_MERC__c = \'' + String.escapeSingleQuotes(taskStatusSelected) + '\'';
            }
        }
        if (taskStatusSoql != '') {
            List<Meeting_Tasks_MERC__c> tasks = Database.query(taskStatusSoql);
            if (tasks != null) {
                Set<Id> taskIds = new Set<Id>();
                Set<Id> newFilteredIds = new Set<Id>();
                for (Meeting_Tasks_MERC__c task : tasks) {
                    taskIds.add(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c);
                    if (filterIdTouched) {
                        if(filteredIds.contains(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c)) {
                            filteredIds.add(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c);
                        }
                    } else {
                        newFilteredIds.add(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c);
                    }
                }
                filteredIds = new Set<Id>();
                filteredIds = newFilteredIds;
                taskStatusFilterIds = taskIds;
            }
        }

        filteredParticipantIds = filteredIds;
    }

    private List<SelectOption> selectOptionListInitialize() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('-Any-','-Any-'));
        return result;
    }

    // this opportunity is just to hold the future send date of the email send, so that we can get the standard sfdc
    // date time picker.
    public Event sendDateEvent {
        get {
            if (sendDateEvent == null) {
                sendDateEvent = new Event();
            }
            return sendDateEvent;
        }
        set;
    }

    public List<Meeting_Participant_MERC__c> getSelectedParticipants() { 
        return [SELECT Id, Status_MERC__c, Docusign_Contract_Status_MERC__c, 
                       Record_Type_Name_MERC__c, Has_Signed_Contract_MERC__c, 
                       Account_MERC__r.Name, Account_MERC__r.FirstName, 
                       Account_MERC__r.PersonEmail, 
                       Account_MERC__r.LastName, 
                       Account_MERC__r.Communication_Preference_MERC__c,  
                       Account_MERC__r.Title_Desc_GLBL__c, 
                       Account_MERC__r.Sfx_Nm_GLBL__c,
                       Account_MERC__r.Prfrd_Lang_Cd_GLBL__c
                  FROM Meeting_Participant_MERC__c 
                 WHERE Id in :selectedParticipantIds];
    }

    public Integer getParticipantCount() {
        return selectedParticipantIds.size();
    }

    public PageReference Send() {
        List<Meeting_Participant_MERC__c> parts = new List<Meeting_Participant_MERC__c>();
        for (Meeting_Participant_MERC__c p : getSelectedParticipants()) {
            parts.Add(p);
        }

        if (parts.size() == 0) {
            AddErrorMessage('You must select at least 1 Recipient.');
        }
        if (SendTime == 'none') {
            AddErrorMessage('You must select a send date and time.');
        }
        if (email.Id == null) {
            AddErrorMessage('You must select an email template.');
        }
        else if (email.title == null) {
            AddErrorMessage('The subject must be filled in.');
        }
        if (SendTime != 'now' && (sendDateEvent.ActivityDateTime == null || sendDateEvent.ActivityDateTime <= Datetime.now())) {
            AddErrorMessage('The send date must be in the future.');
        }

        if (ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
            return null;
        }

        MERC_ETSendEmailWrapper wrapper = new MERC_ETSendEmailWrapper(Email, parts, Config.Default_From_Email__c, DeDup, DisableIndividualTracking, SendTime, sendDateEvent.ActivityDateTime, additionalInformationHTML);
        MERC_ETDataExtensionProcessor processor = new MERC_ETDataExtensionProcessor();
        try {
            processor.createDataExtensionForSendEmail(wrapper);
            return new PageReference('/' + meeting.Id);
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
    }

    /*
        - creates standardSetController allowing for pagination of records
        - query is built dynamically based on the Process and Process State Filters
    */
    public ApexPages.StandardSetController meetingParticipants {
        get 
        {

            if (meetingParticipants == null) {
                String  soql =  'SELECT Status_MERC__c, Docusign_Contract_Status_MERC__c, ';
                        soql += '       Record_Type_Name_MERC__c, Has_Signed_Contract_MERC__c, ';
                        soql += '       Account_MERC__r.Name, Account_MERC__r.FirstName, ';
                        soql += '       Account_MERC__r.PersonEmail, Account_MERC__r.LastName, ';
                        soql += '       Account_MERC__r.Communication_Preference_MERC__c, ';
                        soql += '       Account_MERC__r.Prfrd_Lang_Cd_GLBL__c, ';
                        soql += '       Account_MERC__r.Title_Desc_GLBL__c, Account_MERC__r.Sfx_Nm_GLBL__c, ';
                        soql += '       Account_MERC__r.Country_of_Residence_GLBL__c';
                        soql += '  FROM Meeting_Participant_MERC__c ';
                        soql += ' WHERE Meeting_MERC__c = \'' + meeting.Id + '\'';
                if (communicationPreferenceSelected != '-Any-') {
                        soql += '   AND Account_MERC__r.Communication_Preference_MERC__c = \'' + String.escapeSingleQuotes(communicationPreferenceSelected) + '\'';
                }
                if (countryOfResidenceSelected != '-Any-') {
                        soql += '   AND Country_of_Residence_MERC__c = \'' + String.escapeSingleQuotes(countryOfResidenceSelected) + '\'';
                }
                if (participantStatusSelected != '-Any-') {
                        soql += '   AND Status_MERC__c = \'' + String.escapeSingleQuotes(participantStatusSelected) + '\'';
                }
                if (preferredLanguageSelected != '-Any-') {
                        soql += '   AND Account_MERC__r.Prfrd_Lang_Cd_GLBL__c = \'' + String.escapeSingleQuotes(preferredLanguageSelected) + '\'';
                }
                if (recordTypeSelected != '-Any-') {
                        soql += '   AND RecordType.Id = \'' + String.escapeSingleQuotes(recordTypeSelected) + '\'';
                }
                if (hasEmailSelected == 'Yes') {
                        soql += '   AND Account_MERC__r.PersonEmail != null';
                } else if (hasEmailSelected == 'No') {
                        soql += '   AND Account_MERC__r.PersonEmail = null';
                }
                if (processTypeSelected != '-Any-' || proposalStatusSelected != '-Any-' || dueDateSelected != '-Any-' || nextStepSelected != '-Any-' || taskStatusSelected != '-Any-') {
                        soql += '   AND Id in :filteredParticipantIds ';
                }
                        soql += 'ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection);

                meetingParticipants = new ApexPages.StandardSetController(Database.getQueryLocator(soql));
                meetingParticipants.setPageSize(50);

                // If page number is set then update the page number in the meeting tasks
                if (pageNumber != null) {
                    meetingParticipants.setPageNumber(pageNumber);
                }
            }
            return meetingParticipants;
        }
        private set;
    }

    // the current field to sort by. defaults to last name
    public String sortField {
        // To set a Field for sorting.
        get  { 
                if (sortField == null) {
                    sortField = 'Account_MERC__r.LastName';
                }
                return sortField;  
            }
        set {
            if (sortField == value) {
                if (sortDirection == 'ASC') {
                    sortDirection = 'DESC';
                } else {
                    sortDirection = 'ASC';
                }
            }
            sortField = value;
        }
    } 

    public String sortDirection { 
        get {
            if (sortDirection == null) {
                sortDirection = 'ASC';
            }
            return sortDirection;
        } 
        set; 
    }

    // returns a list of wrapper objects for the sObjects in the current page set
    public List<SelectedWrapper> participants {
        get {
            if(participants == null) {
                participants = new List<SelectedWrapper>();
                for (Meeting_Participant_MERC__c participant : (List<Meeting_Participant_MERC__c>)meetingParticipants.getRecords()) {

                    if (selectedParticipantIds.contains(participant.Id)) { 
                        participants.add(new SelectedWrapper(participant, true));
                    } else { 
                        participants.add(new SelectedWrapper(participant));
                    }
                }
            }
            return participants;
        }
        private set;
    }

    private void resetFilters() {
        communicationPreferenceSelected = '-Any-';
        countryOfResidenceSelected = '-Any-';
        dueDateSelected = '-Any-';
        hasEmailSelected = '-Any-';
        nextStepSelected = '-Any-';
        participantStatusSelected = '-Any-';
        preferredLanguageSelected = '-Any-';
        processTypeSelected = '-Any-';
        proposalStatusSelected = '-Any-';
        recordTypeSelected = '-Any-';
        taskStatusSelected = '-Any-';
    }

    /*
        - null out meeting tasks so that the standard set controller can be requeried with new filters
        - null out pageNumber so that the requeried meetingParticipants will start at page 1
    */
    public PageReference clearFilters() {
        resetFilters();
        return updateParticipants();
    }

    /*
        - null out meeting tasks so that the standard set controller can be requeried with new filters
        - null out pageNumber so that the requeried meetingParticipants will start at page 1
    */
    public PageReference updateParticipants() {
        collectParticipantIds();
        filterParticipants();
        meetingParticipants = null;
        participants = null;
        pageNumber = null;
        return null;
    }


    public void collectParticipantIds() {
        for (SelectedWrapper wrapper : participants) {
            if(wrapper.IsSelected) {
                selectedParticipantIds.add(wrapper.Participant.Id);
            } else if (!wrapper.IsSelected && selectedParticipantIds.contains(wrapper.Participant.Id)) {
                selectedParticipantIds.remove(wrapper.Participant.Id);
            }
        }
        System.debug(Logginglevel.ERROR,'#### collectParticipantIds() complete. selectedParticipantIds = ' + selectedParticipantIds);
        participants = null;
    }

    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return (meetingParticipants != null) && meetingParticipants.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return (meetingParticipants != null) && meetingParticipants.getHasPrevious();
        }
        set;
    }

    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return meetingParticipants.getPageNumber();
        }
        set;
    }

    // returns the first page of records
     public void first() {
        collectParticipantIds();
        meetingParticipants.first();
     }

     // returns the last page of records
     public void last() {
        collectParticipantIds();
        meetingParticipants.last();
     }

     // returns the previous page of records
     public void previous() {
        collectParticipantIds();
        meetingParticipants.previous();
     }

     // returns the next page of records
     public void next() {
        collectParticipantIds();
        meetingParticipants.next();
     }

     // returns the PageReference of the original page, if known, or the home page.
     public void cancel() {
        meetingParticipants.cancel();
     }

    public void SelectAllClicked() {
        for (SelectedWrapper w : participants)
            w.IsSelected = IsAllChecked;
    }

    @TestVisible
    private class SelectedWrapper
    {
        public Meeting_Participant_MERC__c Participant { get; private set; }
        public boolean IsSelected { get; set; }

        public SelectedWrapper(Meeting_Participant_MERC__c p) {
            this.Participant = p;
            this.IsSelected = false;
        }

        public SelectedWrapper(Meeting_Participant_MERC__c p, Boolean b) {
            this.Participant = p;
            this.IsSelected = b;
        }
    }

    public void ShowGrid() {
        ShowParticipantGrid = true;
    }

    public void HideGrid() {
        collectParticipantIds();
        ShowParticipantGrid = false;
    }
    /* End region: participants */

    public boolean getHasErrors() {
        return ApexPages.hasMessages(ApexPages.Severity.FATAL);
    }

    private void AddFatalMessage(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, message));
    }

    private void AddErrorMessage(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
    }

    /* FROM ET */
    private et4ae5__Business_Unit__c BusinessUnit
    {
        get
        {
            if (BusinessUnit == null) {
                List<et4ae5__Business_Unit__c> bus = [SELECT et4ae5__Business_Unit_ID__c FROM et4ae5__Business_Unit__c WHERE Name = :Config.ET_BU_Name__c LIMIT 1];
                if (bus.size() == 0) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.format('No ET Business Units with name {0} were defined.', new List<String> { Config.ET_BU_Name__c })));
                }
                else {
                    BusinessUnit = bus[0];
                }
            }
            return BusinessUnit;
        }
        private set;
    }

    public String urlroot
    {
        get
        {
            if (urlroot == null) {
                List<et4ae5__configuration__c> configs =[SELECT et4ae5__url_root__c FROM et4ae5__configuration__c LIMIT 1];
                if (configs != null) {
                    urlroot = configs[0].et4ae5__url_root__c;
                }
                else {
                    urlroot = '';
                }
            }
            return urlroot;
        }
        private set;
    }

    public boolean showEmailChooser { get; set; }
    public List<MERC_ETObject.EmailFolder> emails { get; set; }
    public MERC_ETFolderedEmail email { get; set; }
    public MERC_ETCallControl callControl { get; set; }
    public MERC_ETParseString parser { get; set; }

    public void listExactTargetEmails()
    {
        if ([SELECT et4ae5__integration_type__c FROM et4ae5__configuration__c WHERE isdeleted=false][0].et4ae5__integration_type__c=='Enterprise2.0')
        {
            if (BusinessUnit == null) return;

            emails=callControl.getExactTargetEmails(BusinessUnit.et4ae5__Business_Unit_ID__c);
            showEmailChooser=true;
        }
        else
        {
            emails=callControl.getExactTargetEmails(null);
            showEmailChooser=true;
        }
    }

    public void selectEmailCancel()
    {
        showEmailChooser=false;
    }

    public void expandFolder()
    {
        String searchId=apexPages.currentPage().getParameters().get('folderId');
        et4ae5__configuration__c c=[SELECT et4ae5__integration_type__c,et4ae5__username__c,et4ae5__password__c,et4ae5__auth_api_url__c,et4ae5__retry__c,et4ae5__root_rest_api_url__c FROM et4ae5__configuration__c LIMIT 1];
        String ceScope=[SELECT et4ae5__exacttarget_Oauth_token__c FROM user WHERE id=:userInfo.getUserId() LIMIT 1].et4ae5__exacttarget_Oauth_token__c;
        String token='';
        if(c.et4ae5__integration_type__c=='Enterprise2.0')
        {
            if (BusinessUnit == null) return;

            String mid=BusinessUnit.et4ae5__Business_Unit_ID__c;
            system.debug('mid: '+mid);
            token=callControl.oauthScoped(c.et4ae5__username__c,c.et4ae5__password__c,ceScope,mid,c.et4ae5__auth_api_url__c);
        }
        else
        {
            token=callControl.oauthScopedNoMid(c.et4ae5__username__c,c.et4ae5__password__c,ceScope,c.et4ae5__auth_api_url__c);
        }
        if (emails!=null)
        {
            for (MERC_ETObject.emailFolder efA : emails)
            {
                if (efA.id==searchId)
                {
                    efA.subfolders=parser.getEmailFolderDetails(callControl.callEmailFolders(efA.id,c.et4ae5__root_rest_api_url__c,token).getBody());
                    efA.emails=parser.getEmails(callControl.callEmails(efA.id,c.et4ae5__root_rest_api_url__c,token).getBody());
                    if(efA.emails.size()==0 && efA.subfolders.size()==0)
                    {
                        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING,'There are no emails in the "'+efA.name+'" folder.') );
                        return;
                    }
                }
                if (efA.subfolders!=null)
                {
                    for (MERC_ETObject.emailFolder efB : efA.subfolders)
                    {
                        if (efB.id==searchId)
                        {
                            efB.subfolders=parser.getEmailFolderDetails(callControl.callEmailFolders(efB.id,c.et4ae5__root_rest_api_url__c,token).getBody());
                            efB.emails=parser.getEmails(callControl.callEmails(efB.id,c.et4ae5__root_rest_api_url__c,token).getBody());
                            if(efB.emails.size()==0 && efB.subfolders.size()==0)
                            {
                                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING,'There are no emails in the "'+efB.name+'" folder.') );
                                return;
                            }
                        }
                        if (efB.subfolders!=null)
                        {
                            for (MERC_ETObject.emailFolder efC : efB.subfolders)
                            {
                                if (efC.id==searchId)
                                {
                                    efC.subfolders=parser.getEmailFolderDetails(callControl.callEmailFolders(efC.id,c.et4ae5__root_rest_api_url__c,token).getBody());
                                    efC.emails=parser.getEmails(callControl.callEmails(efC.id,c.et4ae5__root_rest_api_url__c,token).getBody());
                                    if(efC.emails.size()==0 && efC.subfolders.size()==0)
                                    {
                                        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING,'There are no emails in the "'+efC.name+'" folder.') );
                                        return;
                                    }
                                }
                                if (efC.subfolders!=null)
                                {
                                    for (MERC_ETObject.emailFolder efD : efC.subfolders)
                                    {
                                        if (efD.id==searchId)
                                        {
                                            efD.subfolders=parser.getEmailFolderDetails(callControl.callEmailFolders(efD.id,c.et4ae5__root_rest_api_url__c,token).getBody());
                                            efD.emails=parser.getEmails(callControl.callEmails(efD.id,c.et4ae5__root_rest_api_url__c,token).getBody());
                                            if(efD.emails.size()==0 && efD.subfolders.size()==0)
                                            {
                                                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING,'There are no emails in the "'+efD.name+'" folder.') );
                                                return;
                                            }
                                        }
                                        if (efD.subfolders!=null)
                                        {
                                            for (MERC_ETObject.emailFolder efE : efD.subfolders)
                                            {
                                                if (efE.id==searchId)
                                                {
                                                    efE.subfolders=parser.getEmailFolderDetails(callControl.callEmailFolders(efE.id,c.et4ae5__root_rest_api_url__c,token).getBody());
                                                    efE.emails=parser.getEmails(callControl.callEmails(efE.id,c.et4ae5__root_rest_api_url__c,token).getBody());
                                                    if(efE.emails.size()==0 && efE.subfolders.size()==0)
                                                    {
                                                        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING,'There are no emails in the "'+efE.name+'" folder.') );
                                                        return;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public void selectEmail()
    {
        // Get selected id from param
        email=new MERC_ETFolderedEmail();
        email.id=apexPages.currentPage().getParameters().get('emailId');
        email.name=null;
        if (apexPages.currentPage().getParameters().get('emailName')!=null)
        {
            email.name=EncodingUtil.urlDecode(apexPages.currentPage().getParameters().get('emailName'),'UTF-8');
        }
        email.title=null;
        if (apexPages.currentPage().getParameters().get('emailSubject')!=null)
        {
            system.debug('subj: '+apexPages.currentPage().getParameters().get('emailSubject'));
            email.title=EncodingUtil.urlDecode(apexPages.currentPage().getParameters().get('emailSubject'),'UTF-8').replace('\\"','"');
        }
        showEmailChooser=false;
        this.base64Thumbnail = retrieveThumbnailForEmailSend(email.id);
        System.debug('Email = ' + email);
    }

    public String retrieveThumbnailForEmailSend(String emailId) {
        System.debug('retrieveThumbnailForEmailSend: '+emailId);
        // String soapAuthToken = [SELECT et4ae5__exacttarget_Oauth_token__c FROM user WHERE id=:userInfo.getUserId() LIMIT 1].et4ae5__exacttarget_Oauth_token__c;

        et4ae5__configuration__c c=[SELECT et4ae5__integration_type__c,et4ae5__username__c,et4ae5__password__c,et4ae5__auth_api_url__c,et4ae5__retry__c,et4ae5__root_rest_api_url__c FROM et4ae5__configuration__c LIMIT 1];
        String ceScope=[SELECT et4ae5__exacttarget_Oauth_token__c FROM user WHERE id=:userInfo.getUserId() LIMIT 1].et4ae5__exacttarget_Oauth_token__c;
        String token='';
        if(c.et4ae5__integration_type__c=='Enterprise2.0')
        {
            if (BusinessUnit == null) return '';

            String mid=BusinessUnit.et4ae5__Business_Unit_ID__c;
            system.debug('mid: '+mid);
            token=callControl.oauthScoped(c.et4ae5__username__c,c.et4ae5__password__c,ceScope,mid,c.et4ae5__auth_api_url__c);
        }
        else
        {
            token=callControl.oauthScopedNoMid(c.et4ae5__username__c,c.et4ae5__password__c,ceScope,c.et4ae5__auth_api_url__c);
        }

        System.debug('oauth token is: '+token);
        et4ae5__Configuration__c configInfo = [SELECT et4ae5__Root_Rest_API_URL__c, et4ae5__url_root__c, et4ae5__url_part__c
                                       FROM et4ae5__Configuration__c
                                       ORDER BY LastModifiedDate DESC
                                       LIMIT 1];

        String thumbnailURL = configInfo.et4ae5__Root_Rest_API_URL__c;
        thumbnailURL = thumbnailURL.replace('rest', configInfo.et4ae5__url_root__c);
        thumbnailURL += String.format('/{0}/utilities/ImageThumbnailSecure.ashx/?h={1}&w={2}&emailid={3}&oauth_token={4}', 
                                      new List<String> { configInfo.et4ae5__url_part__c, '700', '700', emailId, token });
        System.Debug('thumbnailURL: ' + thumbnailURL);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(thumbnailURL);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(5000);

        Http h = new Http();
        HttpResponse res = h.send(req);
        
        System.debug('res body: ' + res.getBody());
        ImageThumbnailSecureResponse thumbnailResponse = (ImageThumbnailSecureResponse)JSON.deserialize(res.getBody(), ImageThumbnailSecureResponse.class);
        return thumbnailResponse.data;
    }

    public class ImageThumbnailSecureResponse {
        public String data;
    }

    public String getSyncPayload()
    {
        String postBody='{"isOneTime":true,"source":{"salesForce":{"version":"5.0","sourceList":{';
        postBody+='},';
        postBody+='"properties":[{"name":"SubscriberRetentionPeriod","value":"1"},{"name":"ThresholdCount","value":"250"}]}}}';
        system.debug('sync postbody: '+postBody);
        return postBody;
    }

    //  This is a simple quicksort algorithm to sort a SelectOption list by label alphabetically.    
    public List<SelectOption> sortOptionList(List<SelectOption> listToSort)  {
        
        if(listToSort == null || listToSort.size() <= 1) {
            List<SelectOption> result = new List<SelectOption> ();
            result.addAll(listToSort);
            return result;                 
        }
        
        List<SelectOption> Less = new List<SelectOption>();     
        List<SelectOption> Greater = new List<SelectOption>();  
            
        integer pivot = 0;              
        // save the pivot and remove it from the list       
        SelectOption pivotValue = listToSort[pivot];        
        listToSort.remove(pivot);               
        for(SelectOption x : listToSort) {          
            if(x.getLabel().compareTo(pivotValue.getLabel()) <= 0) {
                Less.add(x);
            } else if(x.getLabel().compareTo(pivotValue.getLabel()) > 0) {
                Greater.add(x);
            }   
        }       
        List<SelectOption> result = new List<SelectOption> ();      
        result.addAll(SortOptionList(Less));
        result.add(pivotValue); 
        result.addAll(SortOptionList(Greater)); 
        return result;    
    }
}