/*
*  Classname : Iriss_AssessmentDetailExtnController
*  Created By: Deloitte USI    
*  Created Date: 28-Feb-2014
*  Description: This class is used an extension for the Iriss_AssessmentApprovalResponsePage.
*  Version : 0.1 
*  Change Log
*  Version     Description                         Updated By
*    
*/

public with sharing class IRIS_AssessmentApproval_ControllerExten{
        
    private id submissionAssessmentId{set;get;}
    // the submission belonging to the assessment
    public IRIS_Submission__c oIrissSubmission{set;get;}
    // the ProcessInstanceWorkitem if not null signifies that the record is waiting for approval
    private ProcessInstanceWorkitem processInsWI{set;get;}
    public String popupResponse{set;get;}
    public boolean needsApproval{set;get;}
    public boolean isResponseSuccess{set;get;}
    public Boolean isMailSent{set;get;}
    private Boolean isPdfAttached{set;get;}
        
    public IRIS_AssessmentApproval_ControllerExten(ApexPages.StandardController controller) {
        oIrissSubmission = (IRIS_Submission__c)controller.getRecord();
        submissionAssessmentId = apexpages.currentpage().getparameters().get('subAssessId');
        processInsWI = IRIS_Utility.getProcessInstanceWorkitem(oIrissSubmission.id);
        needsApproval = processInsWI != null ? true : false;
        isMailSent = false;
        isPdfAttached = false;
    }
    
    /* 
     * Method name : doSubmit
     * Description : This method is used to submit the decision along with Reason code from the approval.
     * Param - No parameter 
     * Returns :  null
    */
    
    public PageReference doSubmit()
    {
        if(oIrissSubmission.Decision_Taken__c == IRIS_Constants.SUBMISSION_DECISION_APPROVE){
            oIrissSubmission.Status__c = IRIS_Constants.SUBMISSION_STATUS_APPROVED ;
        }else if(oIrissSubmission.Decision_Taken__c == IRIS_Constants.SUBMISSION_DECISION_REJECT ){
            oIrissSubmission.Status__c = IRIS_Constants.SUBMISSION_STATUS_REJECTED ;
        }
        try{
            if(updateSubmissionRecord())
            {
                processRequest(oIrissSubmission.Decision_Taken__c);
            }
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Iriss_Error_while_approving_assessment));
        }
        
        return null;
    }
    
    /* 
     * Method name : addPdfAsAttachment
     * Description : This method is used to attach PDB of assessment record to the submission record.
     * Param - pdfBlob : PDF of the Assessment record. 
     * Returns :  null
    */
    
    private void addPdfAsAttachment(Blob pdfBlob)
    {
        if(!isPdfAttached){
            Attachment oAttach = new Attachment();
            oAttach.ParentId = oIrissSubmission.id;
            oAttach.Body = pdfBlob;
            oAttach.Name = Label.Iriss_Attachment_Name +'.pdf';
            try{
                insert oAttach;
                isPdfAttached = true;
            }
            catch(Exception exp){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Iriss_error_while_inserting_pdf_as_attachment));
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,exp.getMessage()));
            }
        }
    }
    
    /* 
     * Method name : processRequest
     * Description : This method is used to activate approval process.
     * Param - strResponse : The id of the Assessment record. 
     * Returns :  null
    */
    
    private void processRequest(String strResponse)
    {
        Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
        pwr.setworkitemId(processInsWI.id);
        pwr.setaction(strResponse);
        Approval.ProcessResult result = Approval.process(pwr);
        isResponseSuccess  = result.isSuccess();
        if(isResponseSuccess == true){
            needsApproval = false;
        }
    }
    
    /* 
     * Method name : updateSubmissionRecord
     * Description : This method is used to check if submission record is updated.
     * Param - No parameter 
     * Returns :  isSuccessfulUpdate.
    */
    
    private boolean updateSubmissionRecord()
    {
        boolean isSuccessfulUpdate = false;
        oIrissSubmission.COE_Approver__c = UserInfo.getUserId();
        oIrissSubmission.Decision_Date__c = System.today();
        update oIrissSubmission;
        // if command reaches here, it means that the update is successfull.
            isSuccessfulUpdate = true;
        return isSuccessfulUpdate;
    }
    
    /* 
     * Method name : sendMail
     * Description : This method is used to send email along with the PDF.
     * Param - No parameter 
     * Returns :  null
    */
    
    public PageReference sendMail()
    {
        if(submissionAssessmentId != null)
        {
            // Define the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
    
            // Reference the attachment page and pass in the account ID
            PageReference pdf =  Page.Iris_Assessment_Report;
            pdf.getParameters().put('id',(String)submissionAssessmentId); 
            pdf.setRedirect(true);
    
            // Take the PDF content
            Blob pdfContent = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
            
            
            //add in the pdf as attachment on the submission record
            addPdfAsAttachment(pdfContent);
    
            // Create the email attachment
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(Label.Iriss_Attachment_Name +'.pdf');
            efa.setBody(pdfContent);
            
            IRIS_Submission__c oIrissSub = [Select COE_Category__c,COE_Assessor__r.name,COE_Approver__r.name,Status__c,
                                                    name,Document_Owner__r.email,Document_Owner__c,
                                                    Document_Owner__r.name,Document_Submitter__r.email, Document_Name__c
                                             from IRIS_Submission__c where id=: oIrissSubmission.id];
    
            //List<String> toAddresses = new List<String>{oIrissSub.Document_Owner_Iriss__r.email};
    
            // Sets the paramaters of the email
            email.setSubject(oIrissSub.COE_Category__c + ' ' + Label.Iriss_Assessment_Report_Subject_Suffix);
            //email.setToAddresses( toAddresses );
            email.saveAsActivity = false;
            email.setTargetObjectId(oIrissSub.Document_Owner__c);
            email.setHtmlBody('<html><body><style type="text/css">body {font-family: Courier; size: 12pt;}</style>' + 
                                   oIrissSub.Document_Owner__r.name +': <br/><br/> ' +
                                   oIrissSub.Document_Name__c + ' ' + Label.Iriss_Assessment_Report_Body_Part_1 + ' ' 
                                   + oIrissSub.COE_Assessor__r.name + ' ' + Label.Iriss_Assessment_Report_Body_Part_2 + ' ' 
                                   + oIrissSub.COE_Approver__r.name+'.  ' + Label.Iriss_Assessment_Report_Body_Part_3 + 
                                 '. <br/><br/>' +  Label.Iriss_Assessment_Report_Body_Part_4 + '<br/><br/>'
                                 + Label.Iriss_Assessment_Report_Body_Part_5 + '</body></html>');
    
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            
            try{
                OrgWideEmailAddress orgWideEmailAddress = [select id, Address, DisplayName 
                                                        from OrgWideEmailAddress
                                                        where DisplayName = :Label.Iriss_Org_Wide_Email_Address_Display_Name 
                                                            /*and Address = :Label.Iriss_Org_Wide_Email_Address*/ limit 1];
                email.setOrgWideEmailAddressId(orgWideEmailAddress.id);
                // Sends the email
                Messaging.SendEmailResult [] result = 
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                    
                isMailSent = true;
            }
            catch(Exception exp){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Iriss_Error_while_sending_email));
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,exp.getMessage()));
            }
        }
        
        return null;
    }
    
}