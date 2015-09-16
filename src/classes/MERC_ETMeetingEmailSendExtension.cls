/*
* MERC_ETMeetingEmailSendExtension
* Description : Controller extension which provides functionality for MeetingSendEmail page.
* Author: Sonoma Partners
* Modified By: Rick Locke, Kyle Thornton & Joseph Ferraro
* Modified Date: August 26, 2015
*/
public with sharing class MERC_ETMeetingEmailSendExtension {

    private final Boolean isEnterprise;
    private final Meeting_MERC__c meeting;
    public Sonoma_ET_Config__c Config { get; private set; }
    public boolean IsAllChecked { get; set; }
    public boolean DeDup { get; set; }
    public boolean DisableIndividualTracking { get; set; }
    public String SendTime { get; set; }
    public boolean OptIn { get; set; }
    public boolean ShowParticipantGrid { get; set; }
    public String additionalInformationHTML { get; set; }
    public String additionalInformationText { get; set; }
    public String base64Thumbnail { get; private set; }

    public String fromSendOption { get; set; }
    public List<SelectOption> fromEmailOptions { get; set; }
    public String fromEmailSelected { get; set; }
    public List<SelectOption> fromClassificationOptions { get; set;}
    public String fromClassicationSelected { get; set; }

    public Set<Id> selectedParticipantIds { get; set; }

    public Boolean isGeneratingDocuments {
        get {
            return ApexPages.currentPage().getParameters().get('generatedocuments') == '1';
        }
    }

    /*
     * The following getters and setters are used by the MeetingSendEmail page
     * filters. The SelectOptions are the picklists and the Strings are the
     * selections within the picklists.
     */
    public List<SelectOption> communicationChannel {
        get {
            Set<String> communicationChannelSet = new Set<String>();
            communicationChannel = selectOptionListInitialize();

            String soql  = 'SELECT Account_MERC__r.Communication_Channel_MERC__c ';
                   soql += '  FROM Meeting_Participant_MERC__c  ';
                   soql += queryBuilder('communicationChannel','');
            for (Meeting_Participant_MERC__c p : (List<Meeting_Participant_MERC__c>) Database.query(soql)) {
                if (p.Account_MERC__r.Communication_Channel_MERC__c != null && !communicationChannelSet.contains(p.Account_MERC__r.Communication_Channel_MERC__c)) {
                    communicationChannelSet.add(p.Account_MERC__r.Communication_Channel_MERC__c);
                    communicationChannel.add(new SelectOption(p.Account_MERC__r.Communication_Channel_MERC__c,p.Account_MERC__r.Communication_Channel_MERC__c));
                }
            }
            communicationChannel = sortOptionList(communicationChannel);
            return communicationChannel;
        }
        set;
    }
    public String communicationChannelSelected { get; set; }

    public List<SelectOption> countryOfResidence {
        get {
            Set<String> countryOfResidenceSet = new Set<String>();
            countryOfResidence = selectOptionListInitialize();

            //Retrieve all country of residence info to build labels and values for SelectOptions later.
            Map<String,String> countryOfResidenceLabelMap = new Map<String,String>();
            for (Schema.PicklistEntry ple : Account.Country_of_Residence_GLBL__c.getDescribe().getPicklistValues()) {
                if(ple.getValue() != null && ple.isActive()) {
                    countryOfResidenceLabelMap.put(ple.getValue(),ple.getLabel());
                }
            }
            String soql  = 'SELECT Account_MERC__r.Country_of_Residence_GLBL__c ';
                   soql += '  FROM Meeting_Participant_MERC__c  ';
                   soql += queryBuilder('countryOfResidence','');
            for (Meeting_Participant_MERC__c p :  (List<Meeting_Participant_MERC__c>) Database.query(soql)) {
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

    public List<SelectOption> dueDate {
        get {
            Set<String> dueDateSet = new Set<String>();
            dueDate = selectOptionListInitialize();
            String soql  = ' SELECT Due_Date_Status_MERC__c ';
                   soql += '   FROM Meeting_Tasks_MERC__c ';
                   soql += queryBuilder('dueDate', 'Meeting_Process_MERC__r.Meeting_Participant_MERC__r.');
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
            hasEmail = selectOptionListInitialize();
            Boolean hasTrue = false;
            Boolean hasFalse = false;
            String soql  = 'SELECT Account_MERC__r.PersonEmail ';
                   soql += '  FROM Meeting_Participant_MERC__c  ';
                   soql += queryBuilder('hasEmail','');
            for (Meeting_Participant_MERC__c p :  (List<Meeting_Participant_MERC__c>) Database.query(soql)) {
                if (!hasTrue && p.Account_MERC__r.PersonEmail != null) {
                    hasTrue = true;
                } else if (!hasFalse && p.Account_MERC__r.PersonEmail == null) {
                    hasFalse = true;
                }
                if (hasTrue && hasFalse) {
                    break;
                }
            }
            //prep the SelectOption list
            if (hasTrue && hasFalse) {
                hasEmail = selectOptionListInitialize();
                hasEmail.add(new SelectOption('Yes','Yes'));
                hasEmail.add(new SelectOption('No','No'));
            } else if (!hasTrue && !hasFalse) {
                hasEmail = selectOptionListInitialize();
            } else {
                hasEmail = selectOptionListInitialize();
                if(hasTrue) {
                    hasEmail.add(new SelectOption('Yes','Yes'));
                } else if(hasFalse) {
                    hasEmail.add(new SelectOption('No','No'));
                }
            }

            //Build hasEmail selectOption
            return hasEmail;
        }
        set;
    }
    public String hasEmailSelected {get; set;}

    public List<SelectOption> nextStep {
        get {
            Set<String> nextStepSet = new Set<String>();
            nextStep = selectOptionListInitialize();
            String soql  = ' SELECT Next_Step_MERC__c ';
                   soql += '   FROM Meeting_Tasks_MERC__c ';
                   soql += queryBuilder('nextStep', 'Meeting_Process_MERC__r.Meeting_Participant_MERC__r.');
            for (Meeting_Tasks_MERC__c t : (List<Meeting_Tasks_MERC__c>) Database.query(soql)) {
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
            String soql  = 'SELECT Status_MERC__c ';
                   soql += '  FROM Meeting_Participant_MERC__c  ';
                   soql += queryBuilder('participantStatus','');
            for (Meeting_Participant_MERC__c p :  (List<Meeting_Participant_MERC__c>) Database.query(soql)) {
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
            preferredLanguage = selectOptionListInitialize();
            String soql  = ' SELECT Account_MERC__r.Prfrd_Lang_Cd_GLBL__c ';
                   soql += '   FROM Meeting_Participant_MERC__c  ';
                   soql += queryBuilder('preferredLanguage','');
            for (Meeting_Participant_MERC__c p :  (List<Meeting_Participant_MERC__c>) Database.query(soql)) {
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
            List<String> processTypeLabelList = new List<String>();
            for (Schema.PicklistEntry ple : Meeting_Process_MERC__c.Process_Type_MERC__c.getDescribe().getPicklistValues()) {
                if(ple.getLabel() != null && ple.isActive()) {
                    processTypeLabelList.add(ple.getLabel());
                }
            }

            String soql  = ' SELECT Process_Type_MERC__c ';
                   soql += '   FROM Meeting_Process_MERC__c ';
                   soql += queryBuilder('processType', 'Meeting_Participant_MERC__r.');
                   System.debug('#### SOQL = ' + soql);
            for (Meeting_Process_MERC__c p : (List<Meeting_Process_MERC__c>) Database.query(soql)) {
                if (p.Process_Type_MERC__c != null && !processTypeSet.contains(p.Process_Type_MERC__c)) {
                    processTypeSet.add(p.Process_Type_MERC__c);
                }
            }

            processType = selectOptionListInitialize();
            for (String processTypeLabel : processTypeLabelList) {
                if (processTypeSet.contains(processTypeLabel)) {
                    processType.add(new SelectOption(processTypeLabel,processTypeLabel));
                }
            }

            return processType;
        }
        set;
    }
    public String processTypeSelected {get; set;}

    public List<SelectOption> proposalStatus {
        get {
            Set<String> proposalStatusSet = new Set<String>();
            proposalStatus = selectOptionListInitialize();
            String soql  = ' SELECT Status_MERC__c ';
                   soql += '   FROM Travel_Itinerary_MERC__c ';
                   soql += queryBuilder('proposalStatus', 'Meeting_Participant_MERC__r.');
                   soql += '    AND Travel_Proposal_MERC__c = null ';
            for (Travel_Itinerary_MERC__c t : (List<Travel_Itinerary_MERC__c>) Database.query(soql)) {
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
            Set<Id> recordTypeSet = new Set<Id>();
            recordType = selectOptionListInitialize();
            //find all record types and build SelectOption list
            String soql  = ' SELECT RecordType.Id, RecordType.Name ';
                   soql += '   FROM Meeting_Participant_MERC__c ';
                   soql += queryBuilder('recordType', '');
            for (Meeting_Participant_MERC__c p : (List<Meeting_Participant_MERC__c>) Database.query(soql)) {
                if (!recordTypeSet.contains(p.RecordType.Id)) {
                    recordTypeSet.add(p.RecordType.Id);
                    recordType.add(new SelectOption(p.RecordType.Id,p.RecordType.Name));
                }
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
            String soql  = ' SELECT Task_Status_MERC__c ';
                   soql += '   FROM Meeting_Tasks_MERC__c ';
                   soql += queryBuilder('nextStep', 'Meeting_Process_MERC__r.Meeting_Participant_MERC__r.');
            for (Meeting_Tasks_MERC__c t : (List<Meeting_Tasks_MERC__c>) Database.query(soql)) {
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

    public List<SelectOption> getFromSendOptions() {
        List<SelectOption> sendOptions = new List<SelectOption>();
        sendOptions.add(new SelectOption(Label.et4ae5.emailAddr,Label.et4ae5.emailAddr));
        sendOptions.add(new SelectOption(Label.et4ae5.sendClass,Label.et4ae5.sendClass));
        return sendOptions;
    }
    
    public Boolean fromSourceIsEmail { 
        get { return fromSendOption == Label.et4ae5.emailAddr; }
    }

    /*
     * sortField
     * The field the participants query is sorted by. This is type of
     * sorting functionality is not typical design, however
     * it is necessitated by pagination requiring requering
     * for each sort.
     */
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
            } else {
                sortDirection = 'ASC';
            }
            sortField = value;
        }
    }

    /*
     * sortDirection
     * The direction the participants query is sorted by.
     */
    public String sortDirection {
        get {
            if (sortDirection == null) {
                sortDirection = 'ASC';
            }
            return sortDirection;
        }
        set;
    }

    /*
     * The following setters and getters create the ^ or v sorting
     * suffix in the participant data on the page.
     */
    public String headerTitleSuffix {
        get {
            return suffixBuilder('Account_MERC__r.Title_Desc_GLBL__c');
        }
        set;
    }

    public String headerFirstNameSuffix {
        get {
            return suffixBuilder('Account_MERC__r.FirstName');
        }
        set;
    }

    public String headerLastNameSuffix {
        get {
            return suffixBuilder('Account_MERC__r.LastName');
        }
        set;
    }

    public String headerSuffixSuffix {
        get {
            return suffixBuilder('Account_MERC__r.Sfx_Nm_GLBL__c');
        }
        set;
    }

    public String headerEmailSuffix {
        get {
            return suffixBuilder('Account_MERC__r.PersonEmail');
        }
        set;
    }

    public String headerStatusSuffix {
        get {
            return suffixBuilder('Status_MERC__c');
        }
        set;
    }

    public String headerRecordTypeSuffix {
        get {
            return suffixBuilder('Record_Type_MERC__c');
        }
        set;
    }

    public String headerCommPrefSuffix {
        get {
            return suffixBuilder('Account_MERC__r.Communication_Preference_MERC__c');
        }
        set;
    }

    public String headerPrefLangSuffix {
        get {
            return suffixBuilder('Account_MERC__r.Prfrd_Lang_Cd_GLBL__c');
        }
        set;
    }

    public String headerCountrySuffix {
        get{
            return suffixBuilder('Account_MERC__r.Country_of_Residence_GLBL__c');
        }
        set;
    }

    /* The following getters and setters are used to collect
     * the current set of participant IDs that each filter
     * is allowing for query. This is done for 2 significant
     * reasons:
     * 1.) The inner select field in WHERE clauses cannot have
     *     more than one level of relationships.
     * 2.) Simplify the continuous rebuilding of the picklists.
     *     Perform the inner select query once then used ID sets
     *     in the WHERE clauses rather than using inner selects.
     */
    public Set<Id> filteredParticipantIds { get; set; }
    public Set<Id> dueDateFilterIds { get; set; }
    public Set<Id> nextStepFilterIds { get; set; }
    public Set<Id> processTypeFilterIds { get; set; }
    public Set<Id> proposalStatusFilterIds { get; set; }
    public Set<Id> taskStatusFilterIds { get; set; }

    /*
     * This opportunity is just to hold the future send date of the email send, so
     * that we can get the standard sfdc date time picker.
     */
    public Event sendDateEvent {
        get {
            if (sendDateEvent == null) {
                sendDateEvent = new Event();
            }
            return sendDateEvent;
        }
        set;
    }

    /*
     * filterFieldMap
     * map of the selectOption name to the field name
     * needed to build queries for the dynamic
     * SelectOption lists.
     */
    private final map<String,String> filterFieldMap;

    /*
     * CONSTRUCTOR
     */
    public MERC_ETMeetingEmailSendExtension(ApexPages.StandardController stdController) {
        isEnterprise = [SELECT et4ae5__integration_type__c FROM et4ae5__configuration__c WHERE isdeleted=false][0].et4ae5__integration_type__c=='Enterprise2.0';
        if (!Test.isRunningTest()) {
            stdController.addFields(new List<String>{ 'Date_of_Event_MERC__c', 'Days_Until_Meeting_MERC__c', 'End_Date_of_Event_MERC__c', 'Name' });
        }
        this.meeting = [SELECT OwnerId, 
                               Id 
                          FROM Meeting_MERC__c 
                         WHERE Id = :stdController.getRecord().Id][0];
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

        fromSendOption = Label.et4ae5.emailAddr;
        initializeClassifications();
        initializeEmails();

        //build map used in the query builder
        map<String,String> tempFilterFieldMap = new map<String,String>();
        tempFilterFieldMap.put('dueDate','Due_Date_Status_MERC__c');
        tempFilterFieldMap.put('nextStep','Next_Step_MERC__c');
        tempFilterFieldMap.put('processType','Process_Type_MERC__c');
        tempFilterFieldMap.put('proposalStatus','Status_MERC__c');
        tempFilterFieldMap.put('taskStatus','Task_Status_MERC__c');
        tempFilterFieldMap.put('communicationChannel','Account_MERC__r.Communication_Channel_MERC__c');
        tempFilterFieldMap.put('countryOfResidence','Account_MERC__r.Country_of_Residence_GLBL__c');
        tempFilterFieldMap.put('participantStatus','Status_MERC__c');
        tempFilterFieldMap.put('preferredLanguage','Account_MERC__r.Prfrd_Lang_Cd_GLBL__c');
        tempFilterFieldMap.put('recordType','RecordType.Id');
        filterFieldMap = tempFilterFieldMap;

        //set defaults
        resetFilters();
        selectedParticipantIds = new Set<Id>();
        filterParticipants();

        if (isGeneratingDocuments) {
            //Just show the grid, we are using this page to select records to generate documents for
            ShowGrid();
        }

    }

    private void initializeClassifications(){
        List<MERC_ETObject.SendClassification> sendClassifications = null;
        fromClassificationOptions = new List<SelectOption>();
        fromClassificationOptions.add(new SelectOption('', Label.et4ae5.slctChoose));
        if(isEnterprise)
        {
            if (BusinessUnit == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'There is no BusinessUnit specified for this Exact Target enterprise configuration.'));
                return;
            }

            sendClassifications = callControl.getClassifications(BusinessUnit.et4ae5__Business_Unit_ID__c);
        }
        else
        {
            sendClassifications = callControl.getClassifications(null);
        }

        if(sendClassifications == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No Send Classifications Available.'));
            return;
        }

        for(MERC_ETObject.SendClassification sendClassification : sendClassifications){
            fromClassificationOptions.add(new SelectOption(
                sendClassification.id + ',' + sendClassification.senderProfileId,
                ((MERC_ETObject.ETEntry)sendClassification).name));
        }
    }

    private void initializeEmails(){
        fromEmailOptions = new List<SelectOption>();

        String userName = UserInfo.getUserName();
        User activeUser = [Select Email From User where Username = :userName limit 1];
        String userEmail = activeUser.Email;
        String userFullName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        fromEmailOptions.add(new SelectOption(getEmailValue(userEmail, userFullName),
            getEmailKey(userEmail, userFullName)));

        List<OrgWideEmailAddress> orgWideEmails = [SELECT Address, DisplayName, Id FROM OrgWideEmailAddress];
        if(orgWideEmails != null){
            for(OrgWideEmailAddress orgWideEmail : orgWideEmails){
                fromEmailOptions.add(new SelectOption(getEmailValue(orgWideEmail.Address, orgWideEmail.DisplayName),
                    getEmailKey(orgWideEmail.Address, orgWideEmail.DisplayName)));
            }
        }

        User ownerUser = [SELECT Email, FirstName, LastName FROM User WHERE Id = :this.meeting.OwnerId][0];
        if(ownerUser != null){
            String ownerFullName = ownerUser.FirstName + ' ' + ownerUser.LastName;
            fromEmailOptions.add(new SelectOption(getEmailValue(ownerUser.Email, ownerFullName),
                getEmailKey(ownerUser.Email, ownerFullName)));
        }
    
    }

    public void fromSendOptionChanged(){
        return;
    }

    private String getEmailValue(String emailAddress, String fullName){
        return emailAddress + ',' + fullName;
    }

    private String getEmailKey(String emailAddress, String fullName){
        return fullName + ' <' + emailAddress + '>';
    }

    private MERC_ETObject.SenderProfile senderProfileById(String senderProfileId){
        List<MERC_ETObject.SenderProfile> senderProfiles = null;
        if(isEnterprise)
        {
            if (BusinessUnit == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'There is no BusinessUnit specified for this Exact Target enterprise configuration.'));
                return null;
            }

            senderProfiles = callControl.getSenders(senderProfileId, BusinessUnit.et4ae5__Business_Unit_ID__c);
        }
        else
        {
            senderProfiles = callControl.getSenders(senderProfileId, null);
        }

        if(senderProfiles == null || senderProfiles.isEmpty()){
            return null;
        }

        return senderProfiles.get(0);
    }

    public String suffixBuilder (String suffixField) {
        if (sortField == suffixField) {
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

    /*
     * queryBuilder
     * This method takes the filter and path to the Meeting Participant object
     * and builds the WHERE clause of the SOQL needed to dynamically build that
     * SelectOption list.
     */
    public String queryBuilder (String filter, String objectPath) {
        System.debug('#### queryBuilder accessed with filter of ' + filter + ' and ObjectPath of ' + objectPath);
        String  soqlQuery  = ' WHERE ' + objectPath + 'Meeting_MERC__c = \'' + meeting.Id + '\' ';
        soqlQuery += filteredSegmentBuilder('dueDate',filter,dueDateSelected,objectPath);
        soqlQuery += filteredSegmentBuilder('nextStep',filter,nextStepSelected,objectPath);
        soqlQuery += filteredSegmentBuilder('processType',filter,processTypeSelected,objectPath);
        soqlQuery += filteredSegmentBuilder('proposalStatus',filter,proposalStatusSelected,objectPath);
        soqlQuery += filteredSegmentBuilder('taskStatus',filter,taskStatusSelected,objectPath);
        soqlQuery += unfilteredSegmentBuilder('communicationChannel',filter,communicationChannelSelected,objectPath);
        soqlQuery += unfilteredSegmentBuilder('countryOfResidence',filter,countryOfResidenceSelected,objectPath);
        soqlQuery += unfilteredSegmentBuilder('participantStatus',filter,participantStatusSelected,objectPath);
        soqlQuery += unfilteredSegmentBuilder('preferredLanguage',filter,preferredLanguageSelected,objectPath);
        soqlQuery += unfilteredSegmentBuilder('recordType',filter,recordTypeSelected,objectPath);
        if (filter != 'hasEmail' && hasEmailSelected == 'Yes') {
            soqlQuery += ' AND ' + objectPath + 'Account_MERC__r.PersonEmail != null ';
        } else if (filter != 'hasEmail' && hasEmailSelected == 'No') {
            soqlQuery += ' AND ' + objectPath + 'Account_MERC__r.PersonEmail = null ';
        }

        return soqlQuery;
    }

    /*
     * filteredSegmentBuilder
     * This method builds the AND statements for fields that have filter ID sets.
     */
    public String filteredSegmentBuilder (String processingFilter, String passedFilter, String selected, String objectPath) {
        Boolean objectPathPresent = (objectPath != '');
        String soqlSegment = '';
        if (passedFilter != processingFilter && selected != '-Any-') {
            soqlSegment += ' AND ' + objectPath + 'Id in :' + processingFilter + 'FilterIds';
        }
        return soqlSegment;
    }

    /*
     * unfilteredSegmentBuilder
     * This method builds the AND statements for fields that must be queried because there is no filter ID sets.
     */
    public String unfilteredSegmentBuilder (String processingFilter, String passedFilter, String selected, String objectPath) {
        Boolean objectPathPresent = (objectPath != '');
        String soqlSegment = '';
        if (passedFilter != processingFilter && selected != '-Any-') {
            soqlSegment += ' AND ' + objectPath + filterFieldMap.get(processingFilter) + '= \'' + selected + '\'';
        }
        return soqlSegment;
    }

    public PageReference generateDocuments() {
        collectParticipantIds();

        if (selectedParticipantIds.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Please Select at least one participant.'));
            return null;
        }

        if (selectedParticipantIds.size() > 100) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Please Select no more than 100 participants.'));
            return null;
        }

        PageReference generateDocs = new PageReference('/apex/loop__masslooplus');
        generateDocs.getParameters().put('retUrl', ApexPages.currentPage().getParameters().get('Id'));
        generateDocs.getParameters().put('sessionId', UserInfo.getSessionId());
        List<Id> selectedIds = new List<Id>();
        for (Id selectedParticipantId : selectedParticipantIds) {
            //URLs in IE9 should be limited to 2083 characters. this means that if we use the 15 digit id we can
            //safely allow for selection of more ids
            selectedIds.add(((String)selectedParticipantId).subString(0,15));
        }
        generateDocs.getParameters().put('recordIds', String.join(selectedIds, ','));
        generateDocs.setRedirect(true);
        return generateDocs;
    }

    /*
     * filterParticipants
     * Fill the filter Id sets with participant IDs later used in
     * queries multiple allowing for query. This is done for 2
     * main reasons:
     * 1.) The inner select field in WHERE clauses cannot have
     *     more than one level of relationships.
     * 2.) Simplify the continuous rebuilding of the picklists.
     *     Perform the inner select query once then used ID sets
     *     in the WHERE clauses rather than using inner selects.
     */
    public void filterParticipants () {

        filteredParticipantIds = new Set<Id>();

        // Find the eligible IDs for the Process_Type_MERC__c filter
        String processTypeSoql = '';
        if (processTypeSelected != '-Any-') {
            if (processTypeSelected != 'Travel Proposal') {
                proposalStatusSelected = '-Any-';
            }
            processTypeSoql += ' SELECT Meeting_Participant_MERC__c ';
            processTypeSoql += '   FROM Meeting_Process_MERC__c ';
            processTypeSoql += '  WHERE Meeting_Participant_MERC__r.Meeting_MERC__c = \'' + meeting.Id + '\' ';
            processTypeSoql += '    AND Process_Type_MERC__c = \'' + String.escapeSingleQuotes(processTypeSelected) + '\'';
            processTypeFilterIds = new Set<Id>();
            for(Meeting_Process_MERC__c process : Database.query(processTypeSoql)) {
                processTypeFilterIds.add(process.Meeting_Participant_MERC__c);
            }
            filteredParticipantIds = processTypeFilterIds;

            // Find the eligible IDs for the Travel_Itinerary_MERC__c.Status_MERC__c filter
            String proposalStatusSoql = '';
            if (proposalStatusSelected != '-Any-') {
                proposalStatusSoql += '   SELECT Meeting_Participant_MERC__c ';
                proposalStatusSoql += '     FROM Travel_Itinerary_MERC__c ';
                proposalStatusSoql += '    WHERE Travel_Proposal_MERC__c = null ';
                proposalStatusSoql += '      AND Meeting_Participant_MERC__r.Meeting_MERC__c = \'' + meeting.Id + '\' ';
                proposalStatusSoql += '      AND Status_MERC__c  = \'' + String.escapeSingleQuotes(proposalStatusSelected) + '\'';
                proposalStatusFilterIds = new Set<Id>();
                for (Travel_Itinerary_MERC__c proposal : Database.query(proposalStatusSoql)) {
                    proposalStatusFilterIds.add(proposal.Meeting_Participant_MERC__c);
                }
                filteredParticipantIds = compareIdSets(proposalStatusFilterIds);
            }

            // Find the eligible IDs for the Meeting_Tasks_MERC__c.Due_Date_Status_MERC__c filter.
            String dueDateSoql = '';
            if (dueDateSelected != '-Any-') {
                dueDateSoql =  'SELECT Meeting_Process_MERC__r.Meeting_Participant_MERC__c ';
                dueDateSoql += '  FROM Meeting_Tasks_MERC__c ';
                dueDateSoql += ' WHERE Meeting_Process_MERC__r.Meeting_Participant_MERC__r.Meeting_MERC__c = \'' + String.escapeSingleQuotes(meeting.Id) + '\'';
                dueDateSoql += '   AND Due_Date_Status_MERC__c = \'' + String.escapeSingleQuotes(dueDateSelected) + '\'';
                dueDateFilterIds = new Set<Id>();
                for (Meeting_Tasks_MERC__c task : Database.query(dueDateSoql)) {
                    dueDateFilterIds.add(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c);
                } 
                filteredParticipantIds = compareIdSets(dueDateFilterIds);
            }

            // Find the eligible IDs for the Meeting_Tasks_MERC__c.Next_Step_MERC__c filter
            String nextStepSoql = '';
            if (nextStepSelected != '-Any-') {
                nextStepSoql =  'SELECT Meeting_Process_MERC__r.Meeting_Participant_MERC__c ';
                nextStepSoql += '  FROM Meeting_Tasks_MERC__c ';
                nextStepSoql += ' WHERE Meeting_Process_MERC__r.Meeting_Participant_MERC__r.Meeting_MERC__c = \'' + String.escapeSingleQuotes(meeting.Id) + '\'';
                nextStepSoql += '   AND Next_Step_MERC__c = \'' + String.escapeSingleQuotes(nextStepSelected) + '\'';
                nextStepFilterIds = new Set<Id>();
                for(Meeting_Tasks_MERC__c task : Database.query(nextStepSoql)) {
                    nextStepFilterIds.add(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c);
                }
                filteredParticipantIds = compareIdSets(nextStepFilterIds);
            }

            // Find the eligible IDs for the Meeting_Tasks_MERC__c.Task_Status_MERC__c filter
            String taskStatusSoql = '';
            if (taskStatusSelected != '-Any-') {
                taskStatusSoql =  'SELECT Meeting_Process_MERC__r.Meeting_Participant_MERC__c ';
                taskStatusSoql += '  FROM Meeting_Tasks_MERC__c ';
                taskStatusSoql += ' WHERE Meeting_Process_MERC__r.Meeting_Participant_MERC__r.Meeting_MERC__c = \'' + String.escapeSingleQuotes(meeting.Id) + '\'';
                taskStatusSoql += '   AND Task_Status_MERC__c = \'' + String.escapeSingleQuotes(taskStatusSelected) + '\'';
                taskStatusFilterIds = new Set<Id>();
                for (Meeting_Tasks_MERC__c task : Database.query(taskStatusSoql)) {
                    taskStatusFilterIds.add(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c);
                }
                filteredParticipantIds = compareIdSets(taskStatusFilterIds);
            }

        // if ProcessType is -Any- than all other process filters should be -Any-
        } else if (processTypeSelected == '-Any-') {
            proposalStatusSelected = '-Any-';
            dueDateSelected = '-Any-';
            nextStepSelected = '-Any-';
            taskStatusSelected = '-Any-';
        }
    }

    /*
     * compareIdSets
     * In the filterParticipants method we find the participants that are being filtered
     * by each filter. The results are then used to build the filters on the page. 
     * Rather than requerying again, we run through the sets looking for 
     * matches for the final result of filtered Ids.
     */
    private Set<Id> compareIdSets (Set<Id> singleFilteredIds) {
        Set<Id> result = new Set<Id>();

        for (Id filteredId : filteredParticipantIds) {
            if (singleFilteredIds.contains(filteredId)) {
                result.add(filteredId);
            }
        }

        return result;
    }

    /*
     * selectOptionListInitialize
     * Initializes SelectOption lists and makes -any- as the first SelectOption.
     */
    private List<SelectOption> selectOptionListInitialize() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('-Any-','-Any-'));
        return result;
    }

    /*
     * getSelectedParticpants
     * Used by the MeetingEmailSend page to retrieve the selected
     * participants whose IDs are in the selectedParticipants.
     */
    public List<Meeting_Participant_MERC__c> getSelectedParticipants() {
        return [SELECT Id, Status_MERC__c, Docusign_Contract_Status_MERC__c,
                       Record_Type_MERC__c, Has_Signed_Contract_MERC__c,
                       Account_MERC__r.Name, Account_MERC__r.FirstName,
                       Account_MERC__r.PersonEmail,
                       Account_MERC__r.LastName,
                       Account_MERC__r.Communication_Channel_MERC__c,
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

        String fromEmail = Config.Default_From_Email__c;
        String fromName = Config.Default_From_Name__c;
        String fromClassificationId = null;
        if(!fromSourceIsEmail){
            if(String.isBlank(fromClassicationSelected)){
                AddErrorMessage('A Classification must be selected.');
            } else {
                String[] classificationIds  = fromClassicationSelected.split(',');
                fromClassificationId = classificationIds[0];
                String fromSenderProfileId = classificationIds[1];
                MERC_ETObject.SenderProfile senderProfile = senderProfileById(fromSenderProfileId);
                if(senderProfile == null){
                    AddErrorMessage('A Sender Profile was not found for the selected Classification.');
                } else {
                    fromEmail = senderProfile.fromEmail;
                    fromName = senderProfile.fromName;
                }
            }
        } else {
            if(String.isBlank(fromEmailSelected)){
                AddErrorMessage('A From Email must be selected.');
            } else {
                String[] emailDetails = fromEmailSelected.split(',');
                fromEmail = emailDetails[0];
                fromName = emailDetails[1];
            }
        }

        if (ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
            return null;
        }

        MERC_ETSendEmailWrapper wrapper = new MERC_ETSendEmailWrapper(
                                                        Email, parts, fromEmail, fromName,
                                                        DeDup, DisableIndividualTracking, SendTime,
                                                        sendDateEvent.ActivityDateTime,
                                                        additionalInformationHTML, additionalInformationText);
        wrapper.FromClassificationId = fromClassificationId;
        MERC_ETDataExtensionProcessor processor = new MERC_ETDataExtensionProcessor();
        try {
            System.debug('wrapper: ' + wrapper);
            processor.createDataExtensionForSendEmail(wrapper);
            return new PageReference('/' + meeting.Id);
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
    }

    /*
     * meetingParticipants
     * Creates standardSetController allowing for pagination of records.
     * Query is built dynamically based on the filters.
     */
    public ApexPages.StandardSetController meetingParticipants {
        get
        {

            if (meetingParticipants == null) {
                String  soql =  'SELECT Status_MERC__c, Docusign_Contract_Status_MERC__c, ';
                        soql += '       Record_Type_MERC__c, Has_Signed_Contract_MERC__c, ';
                        soql += '       Account_MERC__r.Name, Account_MERC__r.FirstName, ';
                        soql += '       Account_MERC__r.PersonEmail, Account_MERC__r.LastName, ';
                        soql += '       Account_MERC__r.Communication_Preference_MERC__c, ';
                        soql += '       Account_MERC__r.Prfrd_Lang_Cd_GLBL__c, ';
                        soql += '       Account_MERC__r.Title_Desc_GLBL__c, Account_MERC__r.Sfx_Nm_GLBL__c, ';
                        soql += '       Account_MERC__r.Country_of_Residence_GLBL__c';
                        soql += '  FROM Meeting_Participant_MERC__c ';
                        soql += ' WHERE Meeting_MERC__c = \'' + meeting.Id + '\'';
                if (communicationChannelSelected != '-Any-') {
                        soql += '   AND Account_MERC__r.Communication_Channel_MERC__c = \'' + String.escapeSingleQuotes(communicationChannelSelected) + '\'';
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
                        soql += '   AND Account_MERC__r.PersonEmail != null ';
                } else if (hasEmailSelected == 'No') {
                        soql += '   AND Account_MERC__r.PersonEmail = null ' ;
                }
                if (processTypeSelected != '-Any-' || proposalStatusSelected != '-Any-' || dueDateSelected != '-Any-' || nextStepSelected != '-Any-' || taskStatusSelected != '-Any-') {
                        soql += '   AND Id in :filteredParticipantIds ';
                }
                        soql += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection);

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

    /*
     * resetFilters
     * Resets all the filter selections to -any-
     */
    private void resetFilters() {
        communicationChannelSelected = '-Any-';
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
     * clearFilters
     * Call resetFilters then call updateParticipants and return the result.
     */
    public PageReference clearFilters() {
        resetFilters();
        return updateParticipants();
    }

    /*
     * updateParticipants
     * Save the checked participants' Ids.
     * Build the filter ID sets needed for queries.
     * Null out meeting tasks so that the standard set controller can be requeried with new filters
     * Null out pageNumber so that the requeried meetingParticipants will start at page 1
     */
    public PageReference updateParticipants() {
        collectParticipantIds();
        filterParticipants();
        meetingParticipants = null;
        participants = null;
        pageNumber = null;
        return null;
    }

    /*
     * collectParticipantIds
     * Everytime you change page or filter records the selected records are lost.
     * This will collect the selected records' IDs.
     */
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

    public PageReference goToSelectParticipants() {
        // ShowParticipantGrid = true;
        // return Page.MeetingEmailSendSelectRecipients;
        PageReference selectParticipantsPage = Page.MeetingEmailSendSelectRecipients;
        selectParticipantsPage.getParameters().put('id', meeting.Id);
        return selectParticipantsPage;
    }

    public PageReference selectParticipants() {
        collectParticipantIds();
        PageReference emailSendPage = Page.MeetingEmailSend;
        emailSendPage.getParameters().put('id', meeting.Id);
        return emailSendPage;
    }

    public PageReference backToSendPage() {
        PageReference emailSendPage = Page.MeetingEmailSend;
        emailSendPage.getParameters().put('id', meeting.Id);
        return emailSendPage;
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
        if (isEnterprise)
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
        req.setTimeout(30000);

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