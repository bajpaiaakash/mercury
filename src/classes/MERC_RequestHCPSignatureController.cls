public with sharing class MERC_RequestHCPSignatureController {

	private final HCP_Contract_MERC__c contract;
    private final ApexPages.StandardController stdController;
    public String error { get; private set; }
    public Boolean isSent { get; private set; }

    public MERC_RequestHCPSignatureController(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        if (!Test.isRunningTest()) {
            this.stdController.addFields(new List<String>{ 'Id', 'Name', 'Account_MERC__c' });
        }
        this.contract = (HCP_Contract_MERC__c)stdController.getRecord();
        if (ApexPages.currentPage().getParameters().get('docusignTasStatus') == '1') {
            this.isSent = true;
        } else {
            this.isSent = false;
        }
    }

    public Boolean getCanRequestSignature() {
        Account recipient = [Select Id, PersonEmail From Account Where Id = :this.contract.Account_MERC__c];
        if (recipient.PersonEmail == null) {
            this.error = 'HCP does not have a valid e-mail address'; //TODO label
            return false;
        } else if ( contractContentVersion == null ) {
            this.error = 'Could not find HCP Contract PDF file. Please use the "Upload Content" button on the HCP Contract record.'; //TODO label
            return false;
        }
        this.error = null;
        return true;
    }

    public ContentVersion contractContentVersion {
        get {
            try {
                if (contractContentVersion == null) {
                    contractContentVersion = [Select ID, Title, LastModifiedDate, FileType 
                        FROM ContentVersion WHERE 
                            HCP_Contract_MERC__c = :this.contract.Id AND 
                            FileType = 'PDF' AND 
                            PublishStatus = 'P' AND 
                            IsLatest = True ORDER BY CreatedDate desc LIMIT 1];
                } 
                return contractContentVersion;   
            } catch (Exception e) {
                return null;
            }
        }   
        private set;
    }

    public PageReference requestSignature() {
        Blob pdfBlob = [Select VersionData From ContentVersion Where Id = :contractContentVersion.Id].VersionData;
        String pdfBytes = EncodingUtil.base64Encode(pdfBlob);

        List<Account> signingAccounts = [Select Id, Name, PersonEmail From Account Where Id = :this.contract.Account_MERC__c];

        List<MERC_DocusignService.RequiredSigner> signers = new List<MERC_DocusignService.RequiredSigner>();
        for (Integer i=0; i < signingAccounts.size(); i++) {
            MERC_DocusignService.RequiredSigner s = new MERC_DocusignService.RequiredSigner();
            s.acc = signingAccounts.get(i);
            s.order = i+1;  
            signers.add(s);
        }

        MERC_DocusignService d = new MERC_DocusignService();
        MERC_DocusignService.EnvelopeResponse r = d.requestSignature(signers, pdfBytes);
        if (r.errorCode != null) {
            if (r.errorCode == 'ANCHOR_TAB_STRING_NOT_FOUND') {
                //get tag and send url
                String returnUrl = 'https://' + System.URL.getSalesforceBaseUrl().getHost().remove('-api' ) + '/apex/MERC_RequestHCPSignature?docusignTasStatus=1&id='+this.contract.Id;
                MERC_DocusignService.EnvelopeResponse r2 = d.requestSignature(signers, pdfBytes, True); //send as draft mode
                MERC_DocusignService.TagAndSendResponse tasResponse = d.getTagAndSendUrl(r2, returnUrl); //get tas url
                
                //redirect to tag and send url                
                PageReference p = new PageReference(tasResponse.url);
                return p;
            } else {
                //show error on vf page
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Docusign failed to send the contract for signature. Error code: '+r.errorCode));
                this.isSent = false;
                return null;
            }
        } else {
            this.isSent = true;
            return null;
        }
    }

}