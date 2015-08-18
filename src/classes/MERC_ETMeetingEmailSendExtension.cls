public with sharing class MERC_ETMeetingEmailSendExtension {

    private final Meeting_MERC__c meeting;
    public Sonoma_ET_Config__c Config { get; private set; }
    public boolean IsAllChecked { get; set; }
    public boolean DeDup { get; set; }
    public boolean DisableIndividualTracking { get; set; }
    public String SendTime { get; set; }
    public boolean OptIn { get; set; }
    public boolean ShowParticipantGrid { get; set; }
    public String base64Thumbnail { get; private set; }

    //filters for select participant page
    public List<SelectOption> processType { get; set; }
    public String processTypeSelected {get; set;}
    
    public List<SelectOption> communicationPreference { get; set; }
    public String communicationPreferenceSelected {get; set;}
    
    public List<SelectOption> countryOfResidence { get; set; }
    public String countryOfResidenceSelected {get; set;}
    
    public List<SelectOption> status { get; set; }
    public String statusSelected {get; set;}

    public List<SelectOption> preferredLanguage { get; set; }
    public String preferredLanguageSelected {get; set;}

    public List<SelectOption> hasEmail { get; set; }
    public String hasEmailSelected {get; set;}

    public List<SelectOption> recordType { get; set; }
    public String recordTypeSelected {get; set;}

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

        Set<string> communicationPreferenceSet = new Set<string>(); //used for checking for dupes
        
        //prep the SelectOption lists
        communicationPreference = anySelectOptionBuilder();
        preferredLanguage = anySelectOptionBuilder();

        //build select options that are solely based on the participants for the meeting
        for( Meeting_Participant_MERC__c p : [SELECT Id, Status_MERC__c, Docusign_Contract_Status_MERC__c, 
                                                     Record_Type_MERC__c, Has_Signed_Contract_MERC__c, 
                                                     Account_MERC__r.Name, Account_MERC__r.FirstName, 
                                                     Account_MERC__r.PersonEmail, 
                                                     Account_MERC__r.LastName, 
                                                     Account_MERC__r.Communication_Preference_MERC__c,  
                                                     Account_MERC__r.Title_Desc_GLBL__c, 
                                                     Account_MERC__r.Sfx_Nm_GLBL__c,
                                                     Account_MERC__r.Prfrd_Lang_Cd_GLBL__c
                                                FROM Meeting_Participant_MERC__c 
                                               WHERE Meeting_MERC__c = :meeting.Id]) {
            if (p.Account_MERC__r.Communication_Preference_MERC__c != null && !communicationPreferenceSet.contains(p.Account_MERC__r.Communication_Preference_MERC__c)) {
                communicationPreference.add(new SelectOption(p.Account_MERC__r.Communication_Preference_MERC__c,p.Account_MERC__r.Communication_Preference_MERC__c));
                preferredLanguage.add(new SelectOption(p.Account_MERC__r.Prfrd_Lang_Cd_GLBL__c,p.Account_MERC__r.Prfrd_Lang_Cd_GLBL__c));
            }
        }

        // prep the record type SelectOption list
        recordType = anySelectOptionBuilder();

        //find all record types and build SelectOption list
        for(RecordType rt : [SELECT Name FROM RecordType  WHERE SObjectType = 'Meeting_Participant_MERC__c' AND IsActive = TRUE]) {
            recordType.add(new SelectOption(rt.Id,rt.Name));
        }

        //Retrieve all process type info.        
        Schema.DescribeFieldResult processTypeFieldResult = Meeting_Process_MERC__c.Process_Type_MERC__c.getDescribe();
        List<Schema.PicklistEntry> processTypePLE = processTypeFieldResult.getPicklistValues();
        processType = selectOptionListBuilder(processTypePLE);

        //Retrieve all country of residence info.        
        Schema.DescribeFieldResult countryOfResidenceFieldResult = Account.Country_of_Residence_GLBL__c.getDescribe();
        List<Schema.PicklistEntry> countryOfResidencePLE = countryOfResidenceFieldResult.getPicklistValues();
        countryOfResidence = selectOptionListBuilder(countryOfResidencePLE);

        //Retrieve all participant status info.        
        Schema.DescribeFieldResult statusFieldResult = Meeting_Participant_MERC__c.Status_MERC__c.getDescribe();
        List<Schema.PicklistEntry> statusPLE = statusFieldResult.getPicklistValues();
        status = selectOptionListBuilder(statusPLE);

        //Build hasEmail selectOption
        hasEmail = anySelectOptionBuilder();
        hasEmail.add(new SelectOption('Yes','Yes'));
        hasEmail.add(new SelectOption('No','No'));

        processTypeSelected = 'Any';
        communicationPreferenceSelected = 'Any';
        countryOfResidenceSelected = 'Any';
        statusSelected = 'Any';
        preferredLanguageSelected = 'Any';
        hasEmailSelected = 'Any';
        recordTypeSelected = 'Any';
    }

    private List<SelectOption> selectOptionListBuilder(List<Schema.PicklistEntry> pleList) {
        List<SelectOption> result = anySelectOptionBuilder();
        for (Schema.PicklistEntry ple : pleList) {
                if(ple.getValue() != null && ple.isActive()) {
                result.add(new SelectOption(ple.getValue(),ple.getLabel()));
            }
        }
        return result;
    }

    private List<SelectOption> anySelectOptionBuilder() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('Any','Any'));
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


    public Integer getParticipantCount() {
        Integer totalParticipants = 0;
        for (SelectedWrapper w : participants) {
            if (w.IsSelected)
                totalParticipants++;
        }
        return totalParticipants;
    }

    public PageReference Send() {
        List<Meeting_Participant_MERC__c> parts = new List<Meeting_Participant_MERC__c>();
        for (SelectedWrapper w : participants) {
            if (w.IsSelected) {
                parts.Add(w.Participant);
            }
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

        MERC_ETSendEmailWrapper wrapper = new MERC_ETSendEmailWrapper(Email, parts, Config.Default_From_Email__c, DeDup, DisableIndividualTracking, SendTime, sendDateEvent.ActivityDateTime);
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
                String  soql =  'SELECT Id, Status_MERC__c, Docusign_Contract_Status_MERC__c, ';
                        soql += '       Record_Type_MERC__c, Has_Signed_Contract_MERC__c, ';
                        soql += '       Account_MERC__r.Name, Account_MERC__r.FirstName, ';
                        soql += '       Account_MERC__r.PersonEmail, Account_MERC__r.LastName, ';
                        soql += '       Account_MERC__r.Communication_Preference_MERC__c, ';
                        soql += '       Account_MERC__r.Prfrd_Lang_Cd_GLBL__c, ';
                        soql += '       Account_MERC__r.Title_Desc_GLBL__c, Account_MERC__r.Sfx_Nm_GLBL__c, ';
                        soql += '       Account_MERC__r.Country_of_Residence_GLBL__c';
                        soql += '  FROM Meeting_Participant_MERC__c ';
                        soql += ' WHERE Meeting_MERC__c = \'' + meeting.Id + '\'';
                if (processTypeSelected != 'Any') {
                        soql += '   AND Id in (SELECT Meeting_Participant_MERC__c ';
                        soql += '                FROM Meeting_Process_MERC__c ';
                        soql += '               WHERE Meeting_Participant_MERC__r.Meeting_MERC__c = \'' + meeting.Id + '\' ';
                        soql += '                 AND Process_Type_MERC__c = \'' + processTypeSelected + '\')';
                }
                if (communicationPreferenceSelected != 'Any') {
                        soql += '   AND Account_MERC__r.Communication_Preference_MERC__c = \'' + communicationPreferenceSelected + '\'';
                }
                if (countryOfResidenceSelected != 'Any') {
                        soql += '   AND Country_of_Residence_MERC__c = \'' + countryOfResidenceSelected + '\'';
                }
                if (statusSelected != 'Any') {
                        soql += '   AND Status_MERC__c \'' + statusSelected + '\'';
                }
                if (preferredLanguageSelected != 'Any') {
                        soql += '   AND Account_MERC__r.Prfrd_Lang_Cd_GLBL__c \'' + preferredLanguageSelected + '\'';
                }
                if (recordTypeSelected != 'Any') {
                        soql += '   AND RecordType.Id = \'' + recordTypeSelected + '\'';
                }
                if (hasEmailSelected == 'Yes') {
                        soql += '   AND Account_MERC__r.PersonEmail != null';
                } else if (hasEmailSelected == 'No') {
                        soql += '   AND Account_MERC__r.PersonEmail = null';
                }

                meetingParticipants = new ApexPages.StandardSetController(Database.getQueryLocator(soql));
                meetingParticipants.setPageSize(20);

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
            participants = new List<SelectedWrapper>();
            for (Meeting_Participant_MERC__c participant : (List<Meeting_Participant_MERC__c>)meetingParticipants.getRecords())
                participants.add(new SelectedWrapper(participant));
            return participants;
        }
        private set;
    }

    /*
        - null out meeting tasks so that the standard set controller can be requeried with new filters
        - null out pageNumber so that the requeried meetingParticipants will start at page 1
    */
    public PageReference updateParticipants() {
        meetingParticipants = null;
        pageNumber = null;
        return null;
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
         meetingParticipants.first();
     }

     // returns the last page of records
     public void last() {
         meetingParticipants.last();
     }

     // returns the previous page of records
     public void previous() {
         meetingParticipants.previous();
     }

     // returns the next page of records
     public void next() {
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
    }

    public void ShowGrid() {
        ShowParticipantGrid = true;
    }

    public void HideGrid() {
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
        string searchId=apexPages.currentPage().getParameters().get('folderId');
        et4ae5__configuration__c c=[SELECT et4ae5__integration_type__c,et4ae5__username__c,et4ae5__password__c,et4ae5__auth_api_url__c,et4ae5__retry__c,et4ae5__root_rest_api_url__c FROM et4ae5__configuration__c LIMIT 1];
        string ceScope=[SELECT et4ae5__exacttarget_Oauth_token__c FROM user WHERE id=:userInfo.getUserId() LIMIT 1].et4ae5__exacttarget_Oauth_token__c;
        string token='';
        if(c.et4ae5__integration_type__c=='Enterprise2.0')
        {
            if (BusinessUnit == null) return;

            string mid=BusinessUnit.et4ae5__Business_Unit_ID__c;
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
        string ceScope=[SELECT et4ae5__exacttarget_Oauth_token__c FROM user WHERE id=:userInfo.getUserId() LIMIT 1].et4ae5__exacttarget_Oauth_token__c;
        string token='';
        if(c.et4ae5__integration_type__c=='Enterprise2.0')
        {
            if (BusinessUnit == null) return '';

            string mid=BusinessUnit.et4ae5__Business_Unit_ID__c;
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

    public string getSyncPayload()
    {
        string postBody='{"isOneTime":true,"source":{"salesForce":{"version":"5.0","sourceList":{';
        postBody+='},';
        postBody+='"properties":[{"name":"SubscriberRetentionPeriod","value":"1"},{"name":"ThresholdCount","value":"250"}]}}}';
        system.debug('sync postbody: '+postBody);
        return postBody;
    }
}