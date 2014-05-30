public with sharing class MeetingEmailSendExtension {
    public MeetingEmailSendExtension(ApexPages.StandardController stdController) {
        this.meeting = (Meeting_MERC__c)stdController.getRecord();
        if (meeting == null || meeting.Id == null) {
            AddFatalMessage('You must specify a meeting id.');
        }

        emails = new List<ETObject.EmailFolder>();
        callControl = new etCallControl();

        Config = Sonoma_ET_Config__c.getInstance();
        if (Config == null) {
            AddFatalMessage('No configuration object was found. Please contact your administrator.');
        }

        ShowParticipantGrid = false;
        parser = new parseString();
        email = new folderedEmail();

        SendTime = 'now';
    }

    public boolean IsAllChecked { get; set; }
    public boolean DeDup { get; set; }
    public boolean DisableIndividualTracking { get; set; }
    public String SendTime { get; set; }
    public boolean OptIn { get; set; }
    public boolean ShowParticipantGrid { get; set; }

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

    private final Meeting_MERC__c meeting;
    public Sonoma_ET_Config__c Config { get; private set; }

    public Integer getParticipantCount() {
        Integer totalParticipants = 0;
        for (SelectedWrapper w : Participants) {
            if (w.IsSelected)
                totalParticipants++;
        }
        return totalParticipants;
    }

    public PageReference Send() {
        List<Meeting_Participant_MERC__c> parts = new List<Meeting_Participant_MERC__c>();
        for (SelectedWrapper w : Participants) {
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

        SendEmailWrapper wrapper = new SendEmailWrapper(Email, parts, Config.Default_From_Email__c, DeDup, DisableIndividualTracking, SendTime, sendDateEvent.ActivityDateTime);
        ETDataExtensionProcessor processor = new ETDataExtensionProcessor();
        try {
            processor.createDataExtensionForSendEmail(wrapper);
            return new PageReference('/' + meeting.Id);
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
    }

    /* Region: participants */
    public List<SelectedWrapper> Participants {
        get 
        {
            if (Participants == null) {
                List<Meeting_Participant_MERC__c> ps = [SELECT Id, Status_MERC__c, Docusign_Contract_Status_MERC__c, 
                                                            Participant_Typ_MERC__c, Has_Signed_Contract_MERC__c,
                                                            Account_MERC__r.Name, Account_MERC__r.FirstName,
                                                            Account_MERC__r.PersonEmail, Account_MERC__r.LastName,
                                                            Account_MERC__r.Communication_Preference_MERC__c,
                                                            Account_MERC__r.Prfrd_Lang_Cd_GLBL__c
                                                        FROM Meeting_Participant_MERC__c 
                                                        WHERE Meeting_MERC__c = :meeting.Id];

                Participants = new List<SelectedWrapper>();
                for (Meeting_Participant_MERC__c p : ps) {
                    Participants.add(new SelectedWrapper(p));
                }
            }
            return Participants;
        }
        private set;
    }

    public void SelectAllClicked() {
        for (SelectedWrapper w : Participants)
            w.IsSelected = IsAllChecked;
    }

    @TestVisible
    private class SelectedWrapper
    {
        public SelectedWrapper(Meeting_Participant_MERC__c p) {
            this.Participant = p;
            this.IsSelected = false;
        }

        public Meeting_Participant_MERC__c Participant { get; private set; }
        public boolean IsSelected { get; set; }
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
    public List<ETObject.EmailFolder> emails { get; set; }
    public FolderedEmail email { get; set; }
    public etCallControl callControl { get; set; }
    public parseString parser { get; set; }

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
            for (etObject.emailFolder efA : emails)
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
                    for (etObject.emailFolder efB : efA.subfolders)
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
                            for (etObject.emailFolder efC : efB.subfolders)
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
                                    for (etObject.emailFolder efD : efC.subfolders)
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
                                            for (etObject.emailFolder efE : efD.subfolders)
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
        email=new folderedEmail();
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
        System.debug('Email = ' + email);
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