/**
 * @author Joseph Ferraro
 *
 * Controller for VF page that enables Mercury user to send HCP Contract for signature via Docusign
 */

public with sharing class MERC_RequestHCPSignatureController {

	private final HCP_Contract_MERC__c contract;
    private final ApexPages.StandardController stdController;
    private String contractName { get; set {if (value!=null) contractName = value;}}
    public String error { get; private set; }
    public Boolean isSent { get; private set; }

    public MERC_RequestHCPSignatureController(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        if (!Test.isRunningTest()) { this.stdController.addFields(new List<String>{ 'Id', 'Name', 'Account_MERC__c' }); }

        this.contract = (HCP_Contract_MERC__c)stdController.getRecord();

        if (Test.isRunningTest()) contractName = [SELECT Name FROM HCP_Contract_MERC__c WHERE Id = :this.contract.Id].Name;
        contractName = this.contract.Name;

        if (ApexPages.currentPage().getParameters().get('docusignTasStatus') == '1') {
            this.isSent = true;
        } else {
            this.isSent = false;
        }
    }

    //determines whether the user is allowed to request signature
    public Boolean getCanRequestSignature() {

        Account hcpRecipient = [Select Id, PersonEmail From Account Where Id = :this.contract.Account_MERC__c];
        if (contract.Lilly_Internal_Signee_MERC__c == null) {
            this.error = 'Contract does not have a Lilly Internal Signee assigned.';  //TODO label
            return false;
        }
        Account lillyRecipient = [Select Id, PersonEmail From Account Where Id = :this.contract.Lilly_Internal_Signee_MERC__c];
        if (hcpRecipient.PersonEmail == null) {
            this.error = 'HCP does not have a valid e-mail address'; //TODO label
            return false;
        } else if (lillyRecipient.PersonEmail == null) {
            this.error = 'Lilly recipient does not have a valid e-mail address'; //TODO label
            return false;
        } else if ( contractContentVersion == null ) {
            this.error = 'Could not find HCP Contract PDF file. Please use the "Upload Content" button on the HCP Contract record.'; //TODO label
            return false;
        }
        this.error = null;
        return true;
    }

    //retrieves the latest contract content attached to this contract
    public ContentVersion contractContentVersion {
        get {
            try {
                if (contractContentVersion == null) {
                    contractContentVersion = [Select ID, Title, LastModifiedDate, FileType
                        FROM ContentVersion WHERE
                            HCP_Contract_MERC__c = :this.contract.Id AND
                            Title = :contractName AND
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

    //stamp envelopeid on contract and participant
    //@future
    static void stampEnvelope(Id hcpContractId, String envelopeId) {
        system.debug('------->');
        system.debug(envelopeId);

        HCP_Contract_MERC__c contract = [SELECT ID, Meeting_Participant_MERC__c FROM HCP_Contract_MERC__c WHERE ID = :hcpContractId];
        contract.Docusign_Envelope_Id_MERC__c = envelopeId.toLowerCase();
        update contract;

        //only stamp the envelope id on the mp if this is a mp-related contract (non-MSA)
        if (contract.Meeting_Participant_MERC__c != null) {
            Meeting_Participant_MERC__c p = [SELECT ID FROM Meeting_Participant_MERC__c WHERE ID = :contract.Meeting_Participant_MERC__c];
            p.Docusign_Envelope_Id_MERC__c = envelopeId.toLowerCase();
            update p;
        }
    }

    //send contract out for signature via the Docusign API
    public PageReference requestSignature() {
        Blob pdfBlob = [Select VersionData From ContentVersion Where Id = :contractContentVersion.Id].VersionData;
        String pdfBytes = EncodingUtil.base64Encode(pdfBlob);

        Account lillySigner = [Select Id, Name, PersonEmail From Account Where Id = :this.contract.Lilly_Internal_Signee_MERC__c];
        Account hcpSigner = [Select Id, Name, PersonEmail From Account Where Id = :this.contract.Account_MERC__c];

        List<MERC_DocusignService.RequiredSigner> signers = new List<MERC_DocusignService.RequiredSigner>();

        MERC_DocusignService.RequiredSigner s1 = new MERC_DocusignService.RequiredSigner();
        s1.acc = lillySigner;
        s1.isLilly = true;
        s1.order = 1;
        signers.add(s1);

        MERC_DocusignService.RequiredSigner s2 = new MERC_DocusignService.RequiredSigner();
        s2.acc = hcpSigner;
        s2.isLilly = false;
        s2.order = 2;
        signers.add(s2);

        MERC_DocusignService d = new MERC_DocusignService();
        try {
            MERC_DocusignService.EnvelopeResponse r = d.requestSignature(signers, pdfBytes);
            
            
            //TESTING
            MERC_DocusignService.EnvelopeRecipientDetailResponse recipientResponse = d.getEnvelopeRecipientDetails(r.envelopeId);
            system.debug('recipientResponse--> '+recipientResponse);

            stampEnvelope(this.contract.Id, r.envelopeId);


            this.isSent = true;
            return null;
        } catch(MERC_DocusignService.DocusignServiceException e) {
            if (e.errorCode == 'ANCHOR_TAB_STRING_NOT_FOUND') {
                //get tag and send url
                String returnUrl = 'https://' + System.URL.getSalesforceBaseUrl().getHost().remove('-api' ) + '/apex/MERC_RequestHCPSignature?docusignTasStatus=1&id='+this.contract.Id;
                MERC_DocusignService.EnvelopeResponse r2 = d.requestSignature(signers, pdfBytes, True); //send as draft mode
                MERC_DocusignService.TagAndSendResponse tasResponse = d.getTagAndSendUrl(r2, returnUrl); //get tas url
                
                
                //TESTING
                MERC_DocusignService.EnvelopeRecipientDetailResponse recipientResponse = d.getEnvelopeRecipientDetails(r2.envelopeId);
                system.debug('recipientResponse--> '+recipientResponse);


                stampEnvelope(this.contract.Id, r2.envelopeId);

                //redirect to tag and send url
                PageReference p = new PageReference(tasResponse.url);
                return p;
            } else {
                //show error on vf page
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Docusign failed to send the contract for signature. Error code: '+e.errorCode));
                this.isSent = false;
                return null;
            }
        } catch(Exception e) {
            //show error on vf page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Docusign failed to send the contract for signature. Error code: '+e.getMessage()));
            this.isSent = false;
            return null;
        }
    }
}