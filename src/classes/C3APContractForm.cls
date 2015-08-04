/*
* @Name: C3AP_Contract_Form
* @Description: Developed for the Customized Edit page for a Contract Request Record
* @date Latest:Sep 24, 2014
* @author Teena Susan Philip 
*/

public with sharing class C3APContractForm {

    public List<Attachment> lstDocument{get; set;}{lstDocument=new List <Attachment>();}
    public integer NumberOfAttachments{get; set;}{NumberOfAttachments=0;}
    public C3AP_Contract_Request__c contractrequest {get; set;}
    public List <C3AP_Affiliate_Questions__c> lstAtcQuestions;
    public List <C3AP_Contract_Request_Answer__c> lstContractAnswers;
    public Map<Id, boolean> mapQuesIdAns = new Map<Id,boolean>();
    
    public Boolean renderTemplate {get; set;} {renderTemplate=false;}
    public Boolean renderError {get; set;} {renderError=false;}
    public Boolean renderUpload {get; set;} {renderUpload=false;}
    public Boolean legalDone {get; set;} {legalDone=false;}
    public Boolean atcRequired {get; set;} {atcRequired=false;}
    
    public Boolean isReadOnly {get; set;} {isReadOnly=false;}
    public Attachment forUpload {get; set;} {forUpload = new Attachment();}
    public string affiliateId;
    public C3AP_Affiliate__c affiliateName;
    public Boolean isATCApprover {get; set;} {isATCApprover=false;}
    public Boolean isATSApprover {get; set;} {isATSApprover=false;}
    public Boolean isLegalApprover {get; set;} {isLegalApprover=false;}
    public Boolean isContractInitiator {get; set;} {isContractInitiator=false;}
    public Boolean isExpiryDateEditable {get; set;} {isExpiryDateEditable=false;}
    public Boolean isReminderDateEditable {get; set;} {isReminderDateEditable=false;}
    public Boolean isAmendRequest {get; set;} {isAmendRequest = false;}
    public Boolean isAdmin {get; set;}{isAdmin = false;}
    public String attachmentType {set; get;}
    public Map<Id,C3AP_Affiliate_Approvers__c> approverToUserMap;

    public C3APContractForm(ApexPages.StandardController controller) {   
        String cid;
        lstAtcQuestions = new List <C3AP_Affiliate_Questions__c>();
        lstContractAnswers = new List <C3AP_Contract_Request_Answer__c>();     
        if((ApexPages.currentPage().getParameters().containsKey('ContractId'))||(ApexPages.currentPage().getParameters().containsKey('id'))){
            if(ApexPages.currentPage().getParameters().containsKey('ContractId'))
                cid = ApexPages.currentPage().getParameters().get('ContractId');          
            else
                cid = ApexPages.currentPage().getParameters().get('id');      
            
             
            contractrequest = [Select id, Name, OwnerId, C3AP_Affiliate__c, Affiliate__c, C3AP_ATC_Approver_Feedback__c, 
                                      C3AP_ATC_Approver_ID__c, C3AP_ATC_Approver__c, C3AP_ATS_Approver_ID__c, C3AP_ATS_Approver__c, 
                                      C3AP_Commencement_Date__c, C3AP_Contract_Template__c, C3AP_Contract_Type__c, C3AP_Department__c,  
                                      C3AP_ETP_Contact_Name__c, C3AP_ETP_Contact_Number__c, C3AP_ETP_Entity_Name__c, C3AP_ETP_ID__c, 
                                      C3AP_Legal_Answered__c, C3AP_ATC_Approval_Required__c, C3AP_Legal_Approver_Required__c,
                                      C3AP_Legal_Approver_ID__c, C3AP_Legal_Approver__c, C3AP_Reminder_Date__c, C3AP_Services__c, 
                                      toLabel(C3AP_Status__c), C3AP_Owner__c, C3AP_Final_Sign__c, C3AP_Contract_Save_Toggle__c, C3AP_Expiry_Date__c,
                                      C3AP_Is_Amend_Transaction__c
                                      From C3AP_Contract_Request__c 
                                      where id = :cid];                               

            if((contractrequest.C3AP_Legal_Approver__c==Userinfo.getuserid()|| 
                contractrequest.C3AP_ATC_Approver__c==Userinfo.getuserid()||
                contractrequest.C3AP_ATS_Approver__c==Userinfo.getuserid())||
            (contractrequest.OwnerId==Userinfo.getuserid() && contractrequest.C3AP_Status__c!=System.Label.C3AP_Status_Not_Submitted)) {
                isReadOnly = true;
            } 
            if(contractrequest.C3AP_Legal_Approver__c==Userinfo.getuserid()) {
                isLegalApprover = true;
            }
            if(contractrequest.C3AP_ATC_Approver__c==Userinfo.getuserid()) {
                isATCApprover = true;
            }
            if(contractrequest.C3AP_ATS_Approver__c==Userinfo.getuserid()) {
                isATSApprover = true;
            }
            if(contractrequest.OwnerId==Userinfo.getuserid()) {
                isContractInitiator = true;
            } 
            if((isLegalApprover && contractrequest.C3AP_Status__c==Label.C3AP_Status_Pending_Legal_Approval) 
                || (isATSApprover && contractrequest.C3AP_Status__c==Label.C3AP_Status_Pending_ATS_Approval) 
                || (isATCApprover && contractrequest.C3AP_Status__c==Label.C3AP_Status_Pending_ATC_Approval) 
                || (isContractInitiator 
                    && (contractrequest.C3AP_Status__c==Label.C3AP_Status_NOT_Submitted 
                    || contractrequest.C3AP_Status__c==Label.C3AP_Status_Pending_Final_Signatures 
                    || contractrequest.C3AP_Status__c==Label.C3AP_Status_Completed 
                    || contractrequest.C3AP_Status__c==Label.C3AP_Status_Expired 
                    || contractrequest.C3AP_Status__c==Label.C3AP_Status_Not_Approved_By_Legal 
                    ||contractrequest.C3AP_Status__c==Label.C3AP_Status_Not_Approved_By_ATS 
                    ||contractrequest.C3AP_Status__c==Label.C3AP_Status_Not_Approved_By_ATC))){
                isReminderDateEditable = true;
            }
            if(contractrequest.C3AP_Status__c==Label.C3AP_Status_NOT_Submitted 
               || contractrequest.C3AP_Status__c==Label.C3AP_Status_Pending_Final_Signatures 
               || contractrequest.C3AP_Status__c==Label.C3AP_Status_Completed 
               || contractrequest.C3AP_Status__c==Label.C3AP_Status_Expired){
                    isExpiryDateEditable = true;
            }
            if(ApexPages.currentPage().getParameters().containsKey('sfdc.override') && Integer.valueOf(ApexPages.currentPage().getParameters().get('sfdc.override'))==1){
                contractRequest.C3AP_Is_Amend_Transaction__c = false;
            }
            if(contractRequest.C3AP_Is_Amend_Transaction__c){
                isAmendRequest = true;          
            }
            
            if(C3APContractRequestUtilityClass.isUserAdmin(UserInfo.getUserId())){
                isAdmin = true;
            }
            
            legalDone=contractrequest.C3AP_Legal_Answered__c;
            affiliateid = contractrequest.C3AP_Affiliate__c;
            AffiliateName = [SELECT id, Name 
                             FROM C3AP_Affiliate__c 
                             WHERE id = :affiliateid];
            contractrequest.Affiliate__c = AffiliateName.Name;
            
            approverToUserMap = new Map<Id,C3AP_Affiliate_Approvers__c>([Select Id,C3AP_Approver_Name__c 
                                                                         FROM C3AP_Affiliate_Approvers__c
                                                                         WHERE C3AP_Affiliate__c =: affiliateid]);
            
            NumberOfAttachments = [Select Count() from Attachment where ParentId =:contractrequest.id];    
            System.debug('--> Display variables: isAmendRequest: ' + isAmendRequest + 
                ', isAdmin: ' + isAdmin + ', isATSApprover: ' + isATSApprover + ', isATCApprover: ' + isATCApprover + 
                ', isLegalApprover: ' + isLegalApprover + ', isContractInitiator: ' + isContractInitiator +
                ', isExpiryDateEditable: ' + isExpiryDateEditable +
                ', isReminderDateEditable: ' + isReminderDateEditable + ', isReadOnly: ' + isReadOnly);
        }          
    } 
 
    
     /* 
     * Method name : cancel
     * Description :  To cancel changes and navigate back to Detail page 
     * Param :  None
     * Returns :  PageReference 
    */
    
    public PageReference cancel(){   
        PageReference detailPage = new PageReference('/'+contractrequest.id);
        detailPage.setRedirect(true);
        return detailPage;          
    }
    
    
    /* 
     * Method name : toLegal
     * Description : To navigate to the Legal Review Page 
     * Param :  None
     * Returns :  PageReference 
    */
    public PageReference toLegal(){
        PageReference legal = null;
        if(updateContractDML()){
            legal = new PageReference(System.Label.C3AP_Legal_Review_URL+contractrequest.id);
            legal.setRedirect(true);
        }
        return legal;          
    }
    
        /* 
     * Method name : toLegal
     * Description : To navigate to the Legal Review Page 
     * Param :  None
     * Returns :  PageReference 
    */
    public PageReference toIntroductory(){
        PageReference intro = null;
        if(updateContractDML()){
            intro = new PageReference('/apex/C3AP_Contract_Initiation?contractId='+contractrequest.id+'&affiliateId='+affiliateId);
            intro.setRedirect(true);    
        }  
        return intro;          
    }

   /* 
     * Method name : upload
     * Description : To upload and save attachments to the Contract Request record
     * Param :  None
     * Returns :  PageReference 
    */
    public PageReference upload(){     
        renderError=true;  
        if(attachmentType == '' || attachmentType == null){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.C3AP_Please_Select_Attachment_Type));
                forUpload.body = null;
                return null;
        }     
        if(forUpload.ParentId == null){
            forUpload.OwnerId=UserInfo.getUserId();
            forUpload.ParentId=contractrequest.id;
            forUpload.Description = Label.C3AP_Attachment_Type + ' : '+attachmentType+'\n'+ Label.C3AP_Comments+' : '+forUpload.Description;
        }
        Savepoint sp = Database.setSavepoint(); 
        try {
            upsert forUpload;
        } 
        catch (Exception e) {
            Database.rollback(sp); 
            forUpload= forUpload.clone(false);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.C3AP_Error_Uploading_Attachment));         
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(   Error_Datetime__c= DateTime.Now(),
                                                                Error_Message__c= e.getMessage(),
                                                                Running_User__c = UserInfo.getUserId() ,
                                                                Stack_Trace__c = e.getStackTraceString(),
                                                                Additional_Information__c = 'Error uploading Attachment : C3AP_Contract_Form - upload, Contract Request ID:'+contractrequest.id
                                                               
                                                                );  
            insert errlog;   
            NumberOfAttachments = [Select Count() 
                                   FROM Attachment 
                                   WHERE ParentId =:contractrequest.id];
            forUpload.body = null;
            return null;
        } 
        
        forUpload.body = null;
        forUpload = new Attachment();
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,System.Label.C3AP_Error_Attachment_Uploaded_Successfully));
        NumberOfAttachments = [Select Count() 
                               FROM Attachment 
                               WHERE ParentId =:contractrequest.id];
        renderUpload=false;
        return null;
    }     
   
    
    /* 
     * Method name : save
     * Description : To save the Contract Request record and navigate the User back to the detail page
     * Param :  None
     * Returns :  PageReference 
    */
    public PageReference save(){
        PageReference detailPage=null;
        if(forupload.body!=null){
            forupload.body = null;
            forupload = new Attachment();                
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,System.Label.C3AP_Contract_Form_Attachment_Handling));
            return null;
        }       
        //Checks if Contract Type is Null
        if(contractrequest.C3AP_Contract_Type__c==null) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Contract Type: You must enter a value'));
            return null;
        } 
         
        /* To update the ATC,Legal,ATS Approver fields which are User lookup fields based on the value in the ATC, Legal, ATS Approver ID fields which 
        are lookups to Affiliate Approvers */       
        if (contractrequest.C3AP_ATC_Approver_ID__c!=null && approverToUserMap.get(contractrequest.C3AP_ATC_Approver_ID__c) != null) {             
            contractrequest.C3AP_ATC_Approver__c = approverToUserMap.get(contractrequest.C3AP_ATC_Approver_ID__c).C3AP_Approver_Name__c;
        }
        
        if (contractrequest.C3AP_Legal_Approver_ID__c!=null && approverToUserMap.get(contractrequest.C3AP_Legal_Approver_ID__c) != null) {            
             contractrequest.C3AP_Legal_Approver__c = approverToUserMap.get(contractrequest.C3AP_Legal_Approver_ID__c).C3AP_Approver_Name__c;    
        } 
        
        if (contractrequest.C3AP_ATS_Approver_ID__c!=null && approverToUserMap.get(contractrequest.C3AP_ATS_Approver_ID__c) != null) {            
             contractrequest.C3AP_ATS_Approver__c = approverToUserMap.get(contractrequest.C3AP_ATS_Approver_ID__c).C3AP_Approver_Name__c;
        }
        if(contractrequest.C3AP_Contract_Save_Toggle__c==false)
            contractrequest.C3AP_Contract_Save_Toggle__c=true;
        else
            contractrequest.C3AP_Contract_Save_Toggle__c=false;
        contractRequest.C3AP_Is_Amend_Transaction__c = false;
        
        if(updateContractDML()){                 
            detailPage = new PageReference('/'+contractrequest.id);
            detailPage.setRedirect(true);
        }                  
        return detailPage;          
    }
 
     /* 
     * Method name : getTemplate
     * Description : This method attaches the template to the Contract Request
     * Param :  None
     * Returns :  PageReference 
    */
    
    public PageReference getTemplate(){    
        if(contractrequest.C3AP_Contract_Type__c==null) {
            renderError=true;
            renderTemplate=false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Contract Type: You must enter a value'));
        } 
        else {
            renderTemplate=true;
            renderError=false;
            lstDocument = [SELECT Name, Body, ContentType 
                           FROM Attachment 
                           WHERE Parentid=:contractrequest.C3AP_Contract_Type__c];
        }
        return null;
    }
    
    
    /* 
     * Method name : preUpload
     * Description : This method opens the Attachment upload section on clicking 'Contract Attachments' button
     * Param :  None
     * Returns :  PageReference 
    */
    public PageReference preUpload(){
        renderUpload=true;
        renderTemplate=false;
        return null;
    }
    
   
    /* 
     * Method name : closeUpload
     * Description : This method closes the Attachment upload section on clicking 'Close Upload' button
     * Param :  None
     * Returns :  PageReference 
    */
    
    public PageReference closeUpload(){
        renderUpload=false;
        if(forupload.body!=null) {
            forupload.body = null;
            forupload = new Attachment();
        }    
        return null;
    }
    

    /* 
     * Method name : getAttachmentTypes
     * Description :  This method sets up the list of Attachment Types that can be selected during an attachment upload
     * Param :  None
     * Returns :  List<SelectOption> 
    */
    public List<SelectOption> getAttachmentTypes() {
        List<SelectOption> options = new List<SelectOption>();         
        options.add(new SelectOption('',Label.C3AP_Select_Attachment_Type)); 
        options.add(new SelectOption(Label.C3AP_Contract_Under_Development,Label.C3AP_Contract_Under_Development)); 
        options.add(new SelectOption(Label.C3AP_Final_Contract,Label.C3AP_Final_Contract)); 
        options.add(new SelectOption(Label.C3AP_Due_Diligence,Label.C3AP_Due_Diligence)); 
        if(isContractInitiator && isAmendRequest){  
            options.add(new SelectOption(Label.C3AP_Amendment,Label.C3AP_Amendment));
        }
        options.add(new SelectOption(Label.C3AP_Other,Label.C3AP_Other)); 
        return options; 
    }
    

    
    
    public boolean updateContractDML(){
        try {            
            update contractrequest;  
            return true ;           
        }        
        catch(Exception e) {   
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(   Error_Datetime__c= DateTime.Now(),
                                                                Error_Message__c= e.getMessage(),
                                                                Running_User__c = UserInfo.getUserId() ,
                                                                Stack_Trace__c = e.getStackTraceString(),
                                                                Additional_Information__c = 'Error updating Contract Request : C3AP_Contract_Form - Save, Contract Request ID:'+contractrequest.id                                                                
                                                                );  
            insert errlog;  
            return false;
        }
        return null;
    }         
}