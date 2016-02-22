/**
 * @author Joseph Ferraro and Sean Harrison
 *
 * Controller for VF page that searches CST and enables user to add Accounts to Meeting as Participants
 */

public with sharing class MERC_AddMeetingParticipantsController {

    public String searchId;
    public String searchStatus;
    public String errorDescription;
    public GLBL_CustomerSearchToolService cstService = new GLBL_CustomerSearchToolService();
    public GLBL_CustomerSearchToolService.SearchRequest searchRequest { get; set; }
    public Boolean hasError { get; private set; }
    private String oldParticipantRecordTypeId { get; set; }
    public Meeting_Participant_MERC__c meetingParticipant { get; set; }
    public Boolean searching { get; private set; }
    public Boolean searchPerformed { get; private set; }
    public String meetingRecordTypeName { get; set; }

    public MERC_AddMeetingParticipantsController(ApexPages.StandardSetController controller) {
        this.searchRequest = new GLBL_CustomerSearchToolService.SearchRequest();
        meetingParticipant = new Meeting_Participant_MERC__c();
        searching = false;
        searchPerformed = false;
    }

    //if cst token is expired, it will grab a new one
    public void ensureCstToken() {
        try {
            this.cstService.refreshToken(); 
        } catch(Exception ex) {
            System.debug('CST TOKEN EXCEPTION CAUGHT >>>> ' + ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CST_Service_Error));
        }
    }

    /**
    * Getter and setter for meeting record if null query for current record.
    * @return Meeting_MERC__c returned via getter.
    */
    public Meeting_MERC__c meeting {
        get {
            if (meeting == null) {
                for(Meeting_MERC__c m : [Select Id, Name, Type_MERC__c, RecordType.DeveloperName From Meeting_MERC__c Where Id = :ApexPages.currentPage().getParameters().get('id')]) {
                    meeting = m;
                    meetingRecordTypeName = m.RecordType.DeveloperName;
                }
            }
            return meeting;
        }
        private set;
    }

    /**
    * Getter for the ApexPages.StandardSetController
    * @return ApexPages.StandardSetController returned via query in getter.
    */
    public ApexPages.StandardSetController setCon {
        get {
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                [SELECT ID, Account_MERC__c, Services_Rendered_MERC__c, Account_MERC__r.Name, Status_MERC__c FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :ApexPages.currentPage().getParameters().get('id')]));
            return setCon;
        }
        set;
    }   

    /**
    * Getter for number participants associated to current meeting.
    * @return Integer representing number of Meeting_Participant_MERC__c records associated to current meeting retrieved via query
    */
    public Integer getMpCount() {
        return [SELECT count() FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meeting.Id];
    }

    /**
    * Getter for number search results.
    * @return Integer representing number of search results.
    */
    public Integer getSrCount() {
        if (this.searchResults == null)
            return 0;
        return searchResults.size();
    }

    /**
    * Return list of Meeting Participants from setCon
    * @return List<Meeting_Participant_MERC__c>
    */
    public List<Meeting_Participant_MERC__c> getMeetingParticipants() {
        return (List<Meeting_Participant_MERC__c>) setCon.getRecords();
    }

    /**
    * Getter and setter for the List of SelectOption that represent the RecordType options.
    * @return List<SelectOption> that is the list of RecordType options.
    */
    public List<SelectOption> recordTypeOptions {
        get {
            Meeting_MERC__c m = meeting;
            Add_Meeting_Participant_Record_Type_MERC__c setting = Add_Meeting_Participant_Record_Type_MERC__c.getInstance();
            Schema.DescribeSObjectResult objSchema = Add_Meeting_Participant_Record_Type_MERC__c.sObjectType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getMap();
            List<String> devNameStringList = new List<String>();

            for (String fieldName : fieldMap.keySet()){
                if(meetingRecordTypeName == Schema.getGlobalDescribe().get('Add_Meeting_Participant_Record_Type_MERC__c').getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel()) {
                    String devNameString = (String) setting.get(fieldName);
                    devNameStringList = devNameString.split(',');
                    break;
                }
            }

            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--Select--'));
            for (RecordType rt : [SELECT ID, Name From RecordType WHERE SobjectType = 'Meeting_Participant_MERC__c' AND DeveloperName in :devNameStringList]) {
                options.add(new SelectOption(rt.Id, rt.Name));
            }
            return options;
        }
    }

    /**
    * Getter and setter for a set of strings that is the meetingParticipantAccountIds. IDs are retrieved via query if the set is null.
    * @return Set<String> String of Meeting Participant Account IDs.
    */
    public Set<String> meetingParticipantAccountIds {
        get {
            if (meetingParticipantAccountIds == null) {
                meetingParticipantAccountIds = new Set<String>();
                for (Meeting_Participant_MERC__c mp : [SELECT ID, Account_MERC__c FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :this.Meeting.Id AND Account_MERC__c != null]) {
                    meetingParticipantAccountIds.add(mp.Account_MERC__c);
                }
            }
            return meetingParticipantAccountIds;
        }
        set;
    }

    /* the following set up the select options based on CST settings */
    public List<SelectOption> specialtyPriorityRanks {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Specialty_priority_rank_CUST__c', false);
        }
    }

    public List<SelectOption> affiliationPriorityRanks {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Affiliation_Priority_Rank_Nbr_CUST__c', false);
        }
    }

    public List<SelectOption> affiliationRoleTypes {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Affiliation_Role_Types_CUST__c', false);
        }
    }

    public List<SelectOption> accountClassifications {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Account_Clsfctn_Cd_CUST__c', false);
        }
    }

    public List<SelectOption> accountStatusTypes {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Account_Status_Types_CUST__c', false);
        }
    }

    public List<SelectOption> specialties {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Specialty_Spclty_Cd_CUST__c', false);
        }
    }

    public List<SelectOption> alternateIdTypes {
        get {
            return MERC_Util.getCSTPicklistValuesForFieldName('Altid_Altrnt_Id_Typ_Cd_CUST__c', false);
        }
    }

    /**
     * For countries to appear in the user select list, util methods are called to check the following:
     *   - User is a member of a territory
     *   - That territory and its children have a custom ISO country fields
     *   - The value of the ISO country fields are each contained in the availble picklist values of
     *         CST_User_Settings_CUST__c.Country_Code_CUST__c
     */
    public List<SelectOption> countries {
        get {
           return MERC_Util.getCountryPicklistValuesForCurrentUser(true);
        }
    }

    public List<SelectOption> dummy {
        get {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('',''));
            return options;
        }
    }

    public List<GLBL_CustomerSearchToolService.SearchResult> searchResults {
        get {
            if (searchResults != null) {
                for (GLBL_CustomerSearchToolService.SearchResult result : searchResults) {
                    result.selectable = !meetingParticipantAccountIds.contains(result.sfid);
                }
            }
            return searchResults;
        }
        private set {
            searchResults = value;
        }
    }

    /* doSearch
     * This initiates the search in the GLBL_CustomerSearchToolService 
     * and then sets the searchId which will be needed to retrieve the results
     * in the retrieveResults method.
     */
    public PageReference doSearch() {
        try{
            p('Entering doSearch!!!!!!');
            searching = true;
            searchPerformed = true;
            system.debug('>>>>>> '+this.searchRequest);
            searchId = this.cstService.doSearch(this.searchRequest);
            // if error, returns null & cstService.error will be available
            if (searchId=='' && this.cstService.error != null) {
                this.hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, this.cstService.error.Error+': '+this.cstService.error.Message));
            }
            
        } catch(Exception ex){
            System.debug('CST EXCEPTION CAUGHT >>>> ' + ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CST_Service_Error));
        }

        return null;

    }

    /**
     * Retieves the results from the search via the retrieveResults method in the GLBL_CustomerSerachToolSearvice class.
     */
    public PageReference retrieveResults() {
        try {
            p('Entering retrieveResult!!!!!!');
            system.debug('>>>>>> searchId = '+searchId);
            this.searchResults = this.cstService.retrieveResults(searchId);
            searching = this.cstService.searching;
            searchStatus = this.cstService.searchStatus;
            errorDescription = this.cstService.errorDescription;
            // if error, returns null & cstService.error will be available
            if (this.searchResults==null && this.cstService.error != null) {
                this.hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, this.cstService.error.Error+': '+this.cstService.error.Message));
            }
            this.searchRequest = new GLBL_CustomerSearchToolService.SearchRequest();
        } catch(Exception ex) {
            System.debug('CST EXCEPTION CAUGHT >>>> ' + ex.getMessage());
            this.cstService.searchStatus = null;
            searching = this.cstService.searching;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CST_Retrieve_Results_Error));
        }
        return null;
    }

    static void p(String m) {
        System.debug('\n\n\nYYZ - '+m+'\n\n\n\n');
    }


    /**
    * Returns a list of required fields to be used in the UI.
    * @return List<Schema.FieldSetMember> - List of required fields to be used in the UI.
    */
    public List<Schema.FieldSetMember> requiredFields {
        get {
            // new page or record type changed so reset the meeting participant
            if (String.isBlank(meetingParticipant.RecordTypeId) || meetingParticipant.RecordTypeId != oldParticipantRecordTypeId) {
                oldParticipantRecordTypeId = meetingParticipant.RecordTypeId;
                meetingParticipant = new Meeting_Participant_MERC__c(RecordTypeId=meetingParticipant.RecordTypeId);
            }

            List<Schema.FieldSetMember> requiredFields = new List<Schema.FieldSetMember>();

            // get the developer name for the record type that has been selected
            List<RecordType> recType = [SELECT Id
                                             , DeveloperName
                                          FROM RecordType
                                         WHERE Id=:meetingParticipant.RecordTypeId
                                           AND SobjectType = 'Meeting_Participant_MERC__c'];
            System.debug('\n\n\nrecType: ' + recType + '\n\n\n');

            if (!recType.isEmpty()) {
                // find the custom setting that is configured for the record type by developer name
                List<Add_Participant_Rec_Type_Req_Fields_MERC__c> reqFields = [SELECT Id
                                                                                    , Meeting_Participant_Field_Set_MERC__c
                                                                                FROM Add_Participant_Rec_Type_Req_Fields_MERC__c
                                                                                WHERE Record_Type_Developer_Name_MERC__c =: recType.get(0).DeveloperName];

                System.debug('\n\n\nrecFields: ' + reqFields + '\n\n\n');

                // if we have a custom setting, find the configured field set and return those fields.
                if (!reqFields.isEmpty()) {
                    for (Schema.FieldSetMember fsm : Schema.SObjectType.Meeting_Participant_MERC__c.fieldSets.getMap().get(reqFields.get(0).Meeting_Participant_Field_Set_MERC__c).getFields()) {
                        requiredFields.add(fsm);
                    }
                }
            }
            return requiredFields;
        }
        set;
    }

    public PageReference addToMeetingAndRedirect(){
        Id participantId = addAcctToMeeting();
        System.debug('Participant Id: ' + participantId);
        if(participantId != null){
            PageReference page = new PageReference('/' + participantId + '/e');
            return page;
        } else{
            return null;
        }
    }

    public PageReference addToMeeting() {
        addAcctToMeeting();
        return null;
    }

    public Id addAcctToMeeting(){
        try {
            String accountId = MERC_Util.getUrlParam('aid');
            if (String.isBlank(meetingParticipant.RecordTypeId))
            {
                throw new MERC_Exception('A Record Type is required to add an account to the meeting.');
            }
            meetingParticipant.Account_MERC__c = accountId;
            meetingParticipant.Meeting_MERC__c = meeting.Id;
            //meetingParticipant.RecordTypeId = newParticipantRecordTypeId;
            System.debug(meetingParticipant);
            insert meetingParticipant;
            this.meetingParticipantAccountIds.add(accountId);
        } catch(Exception e) {
            System.debug(e);
            //this.newParticipantRecordTypeId = null;
            this.hasError = true;
            ApexPages.addMessages(e);
            return null;
        }

        Id meetingParticipantId = meetingParticipant.Id;

        //this.newParticipantRecordTypeId = null;
        this.meetingParticipant = new Meeting_Participant_MERC__c();
        this.hasError = false;
        return meetingParticipantId;
    }

    public PageReference removeFromMeeting() {
        try {
            String meetingParticipantId = MERC_Util.getUrlParam('pid');
            Meeting_Participant_MERC__c mp = [SELECT Id, Account_MERC__c, Status_MERC__c FROM Meeting_Participant_MERC__c WHERE ID = :meetingParticipantId];
            mp.Status_MERC__c = 'Cancelled';
            update mp;
            //String accountId = mp.Account_MERC__c;
            //delete mp;
            //this.meetingParticipantAccountIds.remove(accountId);
        } catch(Exception e) {
            this.hasError = true;
            ApexPages.addMessages(e);
            return null;
        }
        this.hasError = false;
        return null;
    }

    public List<GLBL_CustomerSearchToolService.SearchResult> results {
        get {
            return null;
        }
    }
}