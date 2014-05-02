public with sharing class MeetingEmailSendExtension {
    public MeetingEmailSendExtension(ApexPages.StandardController stdController) {
        this.meeting = (Meeting_MERC__c)stdController.getRecord();
        FromAddress = 'donotreply@lilly.com';
        emails = new List<ETObject.EmailFolder>();
    }

    public boolean IsAllChecked { get; set; }
    public String Subject { get; set; }
    public String FromAddress { get; private set; }
    public boolean DeDup { get; set; }
    public boolean DisableIndividualTracking { get; set; }
    public String SendTime { get; set; }
    public boolean OptIn { get; set; }

    // TODO
    private final Meeting_MERC__c meeting;

    public List<SelectedWrapper> Participants {
        get 
        {
            if (Participants == null) {
                List<Meeting_Participant_MERC__c> ps = [SELECT Id FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meeting.Id];
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
        // TODO
    }

    private class SelectedWrapper
    {
        public SelectedWrapper(Meeting_Participant_MERC__c p) {
            this.Participant = p;
            this.IsSelected = false;
        }

        public Meeting_Participant_MERC__c Participant { get; private set; }
        public boolean IsSelected { get; set; }
    }

    /* FROM ET */
    public boolean showEmailChooser { get; set; }
    public List<ETObject.EmailFolder> emails { get; set; }
    public FolderedEmail email { get; set; }
    public etCallControl callControl { get; set; }

    public void listExactTargetEmails()
    {
        //if ([SELECT integration_type__c FROM configuration__c WHERE isdeleted=false][0].integration_type__c=='Enterprise2.0')
        //{
        //    list<business_unit__c> selectedBU=[SELECT business_unit_id__c FROM business_unit__c WHERE id=:send.business_unit__c];
        //    if (selectedBU.size() == 1)
        //    {
        //        emails=callControl.getExactTargetEmails(selectedBU[0].business_unit_id__c);
        //        showEmailChooser=true;
        //    }
        //}
        //else 
        //{
        //    emails=callControl.getExactTargetEmails(null);
        //    showEmailChooser=true;
        //}
    }

    public void selectEmailCancel()
    {
        showEmailChooser=false;
    }

    public void expandFolder()
    {
        //string searchId=apexPages.currentPage().getParameters().get('folderId');
        //configuration__c c=[SELECT integration_type__c,username__c,password__c,auth_api_url__c,retry__c,root_rest_api_url__c FROM configuration__c LIMIT 1];
        //string ceScope=[SELECT exacttarget_oauth_token__c FROM user WHERE id=:userInfo.getUserId() LIMIT 1].exacttarget_oauth_token__c;
        //string token='';
        //if(c.integration_type__c=='Enterprise2.0')
        //{
        //    string mid=[SELECT business_unit_id__c FROM business_unit__c WHERE id=:send.business_unit__c][0].business_unit_id__c;
        //    system.debug('mid: '+mid);
        //    token=callControl.oauthScoped(c.username__c,c.password__c,ceScope,mid,c.auth_api_url__c);
        //}
        //else
        //{
        //    token=callControl.oauthScopedNoMid(c.username__c,c.password__c,ceScope,c.auth_api_url__c);
        //}
        //if (emails!=null)
        //{
        //    for (etObject.emailFolder efA : emails)
        //    {
        //        if (efA.id==searchId)
        //        {
        //            efA.subfolders=parser.getEmailFolderDetails(callControl.callEmailFolders(efA.id,c.root_rest_api_url__c,token).getBody());
        //            efA.emails=parser.getEmails(callControl.callEmails(efA.id,c.root_rest_api_url__c,token).getBody());
        //            if(efA.emails.size()==0 && efA.subfolders.size()==0)
        //            {
        //                pageMessages.addMessage( new pageMessages.pageMessage( pageMessages.Severity.WARN,label.msg0052+' "'+efA.name+'" '+label.folder+'.') );
        //                return;
        //            }
        //        }
        //        if (efA.subfolders!=null)
        //        {
        //            for (etObject.emailFolder efB : efA.subfolders)
        //            {
        //                if (efB.id==searchId)
        //                {
        //                    efB.subfolders=parser.getEmailFolderDetails(callControl.callEmailFolders(efB.id,c.root_rest_api_url__c,token).getBody());
        //                    efB.emails=parser.getEmails(callControl.callEmails(efB.id,c.root_rest_api_url__c,token).getBody());
        //                    if(efB.emails.size()==0 && efB.subfolders.size()==0)
        //                    {
        //                        pageMessages.addMessage( new pageMessages.pageMessage( pageMessages.Severity.WARN,label.msg0052+' "'+efB.name+'" '+label.folder+'.') );
        //                        return;
        //                    }
        //                }
        //                if (efB.subfolders!=null)
        //                {
        //                    for (etObject.emailFolder efC : efB.subfolders)
        //                    {
        //                        if (efC.id==searchId)
        //                        {
        //                            efC.subfolders=parser.getEmailFolderDetails(callControl.callEmailFolders(efC.id,c.root_rest_api_url__c,token).getBody());
        //                            efC.emails=parser.getEmails(callControl.callEmails(efC.id,c.root_rest_api_url__c,token).getBody());
        //                            if(efC.emails.size()==0 && efC.subfolders.size()==0)
        //                            {
        //                                pageMessages.addMessage( new pageMessages.pageMessage( pageMessages.Severity.WARN,label.msg0052+' "'+efC.name+'" '+label.folder+'.') );
        //                                return;
        //                            }
        //                        }
        //                        if (efC.subfolders!=null)
        //                        {
        //                            for (etObject.emailFolder efD : efC.subfolders)
        //                            {
        //                                if (efD.id==searchId)
        //                                {
        //                                    efD.subfolders=parser.getEmailFolderDetails(callControl.callEmailFolders(efD.id,c.root_rest_api_url__c,token).getBody());
        //                                    efD.emails=parser.getEmails(callControl.callEmails(efD.id,c.root_rest_api_url__c,token).getBody());
        //                                    if(efD.emails.size()==0 && efD.subfolders.size()==0)
        //                                    {
        //                                        pageMessages.addMessage( new pageMessages.pageMessage( pageMessages.Severity.WARN,label.msg0052+' "'+efD.name+'" '+label.folder+'.') );
        //                                        return;
        //                                    }
        //                                }
        //                                if (efD.subfolders!=null)
        //                                {
        //                                    for (etObject.emailFolder efE : efD.subfolders)
        //                                    {
        //                                        if (efE.id==searchId)
        //                                        {
        //                                            efE.subfolders=parser.getEmailFolderDetails(callControl.callEmailFolders(efE.id,c.root_rest_api_url__c,token).getBody());
        //                                            efE.emails=parser.getEmails(callControl.callEmails(efE.id,c.root_rest_api_url__c,token).getBody());
        //                                            if(efE.emails.size()==0 && efE.subfolders.size()==0)
        //                                            {
        //                                                pageMessages.addMessage( new pageMessages.pageMessage( pageMessages.Severity.WARN,label.msg0052+' "'+efE.name+'" '+label.folder+'.') );
        //                                                return;
        //                                            }
        //                                        }
        //                                    }
        //                                }
        //                            }
        //                        }
        //                    }
        //                }
        //            }
        //        }
        //    }
        //}
    }

    public void selectEmail()
    {
        // Get selected id from param
        folderedEmail email=new folderedEmail();
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
        if (apexPages.currentPage().getParameters().get('xEmail')==null)
        {
            this.email=email;
        }
        showEmailChooser=false;
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