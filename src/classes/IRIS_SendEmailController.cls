/*
Class Name : Iriss_SendEmailController
Description : This class is related to Custom Email sending from Compliance Submission 
Created By : Abhishek Kumar(abhishekkumar3@deloitte.com)
Created Date : 19-Mar-2014
Modification Log:
-------------------------------------------------------------------------
Developer        Date            Modification ID        Description
-------------------------------------------------------------------------
Abhishek Kumar    19-Mar-2014                           Initial Version
*************************************************************************/
public class IRIS_SendEmailController{

    public Id submissionId{get;set;}
    public string sCC{get;set;}
    public string sBCC{get;set;}
    public IRIS_Submission__c submission{get;set;}
    public string emailSubject{get;set;}
    public string emailBody{get;set;}
    public List<AttachmentWrapper> attachWrapList{get;set;}
    public List<SelectOption> filesCountList {get; set;}
    public set<id> selectedAttachmentIdSet;   
    public String selectedUserEmail{set;get;}
    public String selectedUserIds{set;get;}
    public String selectedUserNames{set;get;}
    //Selected count of the number of attachment/s   
    public String FileCount {get; set;}
    // list of the selected attachment/s
    public List<Attachment> allFileList {get; set;}
    
    public IRIS_SendEmailController(ApexPages.StandardController controller)
    { 
        submissionId = ApexPages.currentPage().getParameters().get('subId');
        // pre-populating the BCC with curent user id
        sBCC= UserInfo.getUserEmail() + ',';
        selectedUserNames = Label.Iriss_Pre_Text_For_User;
        selectedUserIds = '';
        selectedUserEmail ='';
        fetchAttachment();
        filesCountList = new List<SelectOption>();
        FileCount = '';
        allFileList = new List<Attachment>() ;
        
        //Adding values count list - you can change this according to your need   
        Integer maxFilesCount = 10;
        if(Label.Iriss_Maximum_Attachments_Allowed.isNumeric()) maxFilesCount = Integer.valueOf(Label.Iriss_Maximum_Attachments_Allowed);
        for(Integer i = 1 ; i <= maxFilesCount ; i++) {  
            filesCountList.add(new SelectOption(''+i , ''+i)) ;  
        }
    }
    
    /* 
         * Method name : fetchAttachment
         * Description : This method is used to fetch the attachments which are under the submission record.
         * Param - No parameter 
         * Returns : void
    */
    // method to fetch Attachments associated with Record
    public void fetchAttachment()
    {
        if(attachWrapList == null){
            attachWrapList = new List<AttachmentWrapper>();
            for(Attachment attach : [select Id,Name from attachment where ParentId =:submissionId])
            {
                attachWrapList.add(new AttachmentWrapper(attach));
            }
        }
        
    }
    
    // Wrapper class to display and select attachments
    public class AttachmentWrapper
    {
        public boolean selected{get;set;}
        public attachment attach{get;set;}
        
        public AttachmentWrapper(Attachment attach)
        {
            this.selected = false;
            this.attach = attach;
        }     
    }
    
    // method invoked on click of cancel button
    public PageReference cancel(){ 
        PageReference PageRef  = new PageReference ('/'+submissionId);
        return PageRef ;
    } 
    
    // method invoked on click of SendEmail Button
    public pageReference send(){
        // either of To or CC should be populated.
        if(String.isBlank(selectedUserEmail) && String.isBlank(sCC)){
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Iriss_Select_Either_To_or_CC));
              return null;
        }
        // the subject of the email should be populated
        if(String.isBlank(emailSubject)){
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Iriss_provide_email_subject));
              return null;
        }
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        // sets the To adressess
        if(String.isNotBlank(selectedUserEmail)){
            email.setToAddresses(selectedUserEmail.split(';')); 
            if(String.isNotBlank(sCC)){
                email.setCcAddresses(sCC.split(';'));
            }
        }
        else if(String.isNotBlank(sCC)){
            email.setToAddresses(sCC.split(';'));   
        }
        
        // sets BCC Receipient
        if(String.isNotBlank(sBCC)){
            email.setBccAddresses(sBCC.split(';')); 
        }
        
        
        //Set email file attachments
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        selectedAttachmentIdSet = new set<id>();
        Messaging.Emailfileattachment efa = null;
        // Add attachment file to the list if it is selected
        for(AttachmentWrapper attWrap:attachWrapList)
        {
            if(attWrap.selected==true)
            { 
                selectedAttachmentIdSet.add(attWrap.attach.id);        
            }
        }
        // querying the attachments again to get the body.
        // earlier we didn't queried the body to prevent view state exception
        for(Attachment attach: [select Id,Name,Body from attachment where Id IN: selectedAttachmentIdSet])
        { 
            efa = new Messaging.Emailfileattachment();
            efa.setFileName(attach.Name); 
            efa.setBody(attach.Body);
            fileAttachments.add(efa);       
            
        }
        
        // creating the file attachment for the attachments which are browsed and uploaded.
        if(allFileList != null && allFileList.size()>0){
            for(Attachment att : allFileList)
            {
                if(att.name != null && att.Body != null){
                    efa = new Messaging.Emailfileattachment();
                    efa.setFileName(att.Name);
                    efa.setBody(att.Body);
                    fileAttachments.add(efa);   
                }
            }
        }
        
        // Sets the paramaters of the email
        try{
            email.setPlainTextBody(emailBody);
            email.setWhatId(submissionId);
            email.setFileAttachments(fileAttachments);
            // Sends the email
            Messaging.SendEmailResult [] r = 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
            createActivity();
            
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Iriss_Error_while_sending_email));
        }
        PageReference PageRef = null;
        if(!(ApexPages.hasMessages(ApexPages.Severity.ERROR))){
            PageRef = new PageReference ('/'+submissionId);
            PageRef.setRedirect(true);
        }
        return PageRef ;       
    }
    
    
    /* 
         * Method name : ChangeCount
         * Description : This method is used to add multiple attachments instance.
         * Param - No parameter 
         * Returns : null
    */
    public PageReference ChangeCount()   
    {   
        allFileList.clear() ;   
        if(FileCount != null && FileCount.isNumeric()){
            //Adding multiple attachments instance   
            for(Integer i = 1 ; i <= Integer.valueOf(FileCount) ; i++)   
                allFileList.add(new Attachment()) ;   
        } 
        return null ;   
    }
    
    /* 
         * Method name : createActivity
         * Description : This method is used to create an activity record under the submission.
         * Param - No parameter 
         * Returns : void
    */
    private void createActivity()
    {
        Task oTask = new Task(
            ActivityDate = Date.today(),
            Subject = emailSubject,
            WhatId = submissionId ,
            OwnerId = UserInfo.getUserId(),
            Status='Completed');

        insert oTask;
     
    }
    
}