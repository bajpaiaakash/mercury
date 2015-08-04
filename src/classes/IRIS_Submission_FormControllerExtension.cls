/*
*  Classname : Iriss_SubmissionFormExtensionController
*       Created By: Deloitte USI        
*       Created Date: 20-Feb-2014
*       Description: This class is used an extension for the Iriss_SUbmission_Form page
*       Version : 0.1 
*       Change Log
*       Version         Description                                                     Updated By
*        
*/

public with sharing class IRIS_Submission_FormControllerExtension
{
    
    public IRIS_Submission__c oSubmission{set;get;}
    //Picklist of tnteger values to hold file count   
    public List<SelectOption> filesCountList {get; set;}   
    //Selected count   
    public String FileCount {get; set;}   
    public String selectedCountryIds{set;get;}
    public String selectedRegionIds{set;get;}
    public String submissionName{set;get;}
           
    public List<Attachment> allFileList {get; set;}  
    public boolean isFormSubmitted{set;get;}
    public boolean showCountry{set;get;}
    public boolean showRegion{set;get;}
    public boolean isBack{set;get;}
    public IRIS_Submission_FormControllerExtension(ApexPages.StandardController controller) 
    {
        //Initialize     
        filesCountList = new List<SelectOption>() ;   
        FileCount = '' ;
        selectedCountryIds = '';  
        selectedRegionIds = ''; 
        allFileList = new List<Attachment>() ; 
        
        User oCurrentUser = [select id,profile.name from user where id = : Userinfo.getUserid()];
        IRIS_Access_Buttons__c oAccessButtons = new IRIS_Access_Buttons__c();
            
            // If profile is system admin then dont query permission sets and directly check the custom settings
            if(oCurrentUser.profile.name == IRIS_Constants.IRIS_SYSTEM_ADMIN){
                oAccessButtons = IRIS_Access_Buttons__c.getInstance(IRIS_Constants.IRIS_SYSTEM_ADMIN);
            }
            // If profile is not system admin then query permission sets and check the custom settings
            else{    
                List<PermissionSetAssignment> lPermissionSetAssign = [SELECT Assignee.name, PermissionSet.name,PermissionSetId FROM PermissionSetAssignment where 
                                                                            PermissionSet.name like : '%'+IRIS_Constants.IRIS+'%' and 
                                                                            AssigneeId =: Userinfo.getUserid() Limit 1];
                                
                if(lPermissionSetAssign.size()>0)
                    oAccessButtons = IRIS_Access_Buttons__c.getInstance(lPermissionSetAssign[0].PermissionSet.name);    
            }
        
        //isBack = IRIS_Access_Buttons__c.getInstance(Userinfo.getprofileid()).Back__c;
        isBack = oAccessButtons.Back__c;    
               
        //Adding values count list - you can change this according to your need   
        Integer maxFilesCount = 10;
        if(Label.Iriss_Maximum_Attachments_Allowed.isNumeric()) maxFilesCount = Integer.valueOf(Label.Iriss_Maximum_Attachments_Allowed);
        for(Integer i = 1 ; i <= maxFilesCount ; i++) {  
            filesCountList.add(new SelectOption(''+i , ''+i)) ;  
        }
        oSubmission = (IRIS_Submission__c)controller.getRecord();
        //oSubmission.Status_Iriss__c = Iriss_Constants.SUBMISSION_STATUS_SUBMITTED;
        oSubmission.Submission_Date__c = System.today();
        oSubmission.Document_Submitter__c = UserInfo.getUserId();
        isFormSubmitted = false;
        showCountry = false;
        showRegion = false;
        oSubmission.Region_Text__c = Label.Iriss_Pre_Text_For_Region;
        oSubmission.Country_Text__c = Label.Iriss_Pre_Text_For_Country;
    }
    
    
    /* 
     * Method name : doSubmit
         * Description : This method is used to insert the submission record and attach a document to it.
         * Param - No parameter 
         * Returns :  void
        */
    public void doSubmit()  
    {
        if(verifyAttachmentsSelected() && !(ApexPages.hasMessages(ApexPages.Severity.ERROR)))
        {
            processRegionCountry();
            SavePoint sp = Database.setSavepoint();
            try {
                insert oSubmission;
                SaveAttachments();
                createSubCountryRegion();
                submissionName = [select name from IRIS_Submission__c where id =: oSubmission.id].name;
                // setting the conditions to change the owner to the respective queue
                update new IRIS_Submission__c(id = oSubmission.id , Status__c = Iris_Constants.SUBMISSION_STATUS_SUBMITTED);
                isFormSubmitted = true;
            } catch (Exception e) {
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Iriss_Following_Error_occured));
                
                List<String> lstErrormsg = e.getmessage().split(',',4);
                List<String> lstErr = lstErrormsg[1].split(':',2);
                
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,lstErr[0]));
                isFormSubmitted = false;
                return;
            }
             finally {
                //clear the view state
                ChangeCount();
            }
        }
        else
        {
            ChangeCount();
        }
    }
    
    /* 
     * Method name : processRegionCountry
         * Description : This method is used to set the Submission Name according to Intended Audience.
         * Param - No parameter 
         * Returns :  void
    */
    private void processRegionCountry(){
        oSubmission.Document_Name__c = oSubmission.COE_Category__c + '_' + oSubmission.Sub_Category__c + '_';
        if(oSubmission.Intended_Audience__c == Iris_Constants.SUBMISSION_INTENDED_AUDIENCE_GLOBAL){
            oSubmission.Region_Text__c = null;
            oSubmission.Country_Text__c = null;
            oSubmission.Document_Name__c += oSubmission.Intended_Audience__c;
        }
        else if(oSubmission.Intended_Audience__c == Iris_Constants.SUBMISSION_INTENDED_AUDIENCE_LOCAL){
            oSubmission.Document_Name__c += oSubmission.Country_Text__c;
            List<IRIS_Region__c> lstRegions = Iris_Utility.getAssociatedRegions(selectedCountryIds);
            if(lstRegions != null && lstRegions.size()>0){
                oSubmission.Region_Text__c = '';
                selectedRegionIds = ''; 
                for(IRIS_Region__c region : lstRegions){
                    oSubmission.Region_Text__c += region.name + ';' ;  
                    selectedRegionIds += region.id + ';' ;
                }
                oSubmission.Region_Text__c = oSubmission.Region_Text__c.removeEnd(';');
            }
        }else if(oSubmission.Intended_Audience__c == Iris_Constants.SUBMISSION_INTENDED_AUDIENCE_REGIONAL){
            oSubmission.Document_Name__c += oSubmission.Region_Text__c;
            List<IRIS_Country__c> lstCountries = Iris_Utility.getAssociatedCountries(selectedRegionIds);
            if(lstCountries != null && lstCountries.size()>0){
                oSubmission.Country_Text__c = '';
                selectedCountryIds = '';
                for(IRIS_Country__c country : lstCountries){
                    oSubmission.Country_Text__c += country.name + ';' ;
                    selectedCountryIds += country.id + ';';
                }
                oSubmission.Country_Text__c = oSubmission.Country_Text__c.removeEnd(';');
            }
        }
        if(oSubmission.Document_Name__c.length()>(255-12))
                oSubmission.Document_Name__c = oSubmission.Document_Name__c.subString(0,(255-12));
        oSubmission.Document_Name__c += '_' + datetime.now().format('dd-MMM-yyyy');
    }
    
    /*   * Method name : createSubCountryRegion
         * Description : This method is used to create either Submission Regions or Submission Countries depending on the intended audience.
         * Param - No parameter 
         * Returns :  void
    */
    private void createSubCountryRegion(){
        if(oSubmission.Intended_Audience__c == Iris_Constants.SUBMISSION_INTENDED_AUDIENCE_LOCAL || 
                oSubmission.Intended_Audience__c == Iris_Constants.SUBMISSION_INTENDED_AUDIENCE_REGIONAL){
            createSubmissionCountries(oSubmission.id , selectedCountryIds);
            createSubmissionRegions(oSubmission.id , selectedRegionIds);
        }
    }
    
    /*   * Method name : createSubmissionRegions
         * Description : This method is used to Submission Region Records.
         * Param - No parameter 
         * Returns :  void
    */
    private void createSubmissionRegions(Id SubmissionId , String regionIds){
        if(SubmissionId != null && String.isNotBlank(regionIds)){
            List<IRIS_Submission_Region__c> lstSubRegions = new List<IRIS_Submission_Region__c>();
            for(String regionId : regionIds.split(';')){
                lstSubRegions.add(new IRIS_Submission_Region__c(Compliance_Submission__c = SubmissionId, Region__c = regionId));
            }
            if(lstSubRegions.size()>0){
                insert lstSubRegions;
            }
        }
    }
    
    /*   * Method name : createSubmissionCountries
         * Description : This method is used to Submission Country Records.
         * Param - No parameter 
         * Returns :  void
    */
    private void createSubmissionCountries(Id SubmissionId , String countryIds){
        if(SubmissionId != null && String.isNotBlank(countryIds)){
            List<IRIS_Submission_Country__c> lstSubCountries = new List<IRIS_Submission_Country__c>();
            for(String countryId : countryIds.split(';')){
                lstSubCountries.add(new IRIS_Submission_Country__c(Compliance_Submission__c = SubmissionId, Country__c = countryId));
            }
            if(lstSubCountries.size()>0){
                insert lstSubCountries;
            }
        }
    }
   
    
    /* 
         * Method name : doReload
         * Description : This method is used to reload the Iriss_SUbmission_Form page 
         * Param - No parameter 
         * Returns : PageReference
    */
    public PageReference doReload()
    {
        PageReference submissionForm = new PageReference('/apex/IRIS_Submission_Form');
        submissionForm.setRedirect(true);
        return submissionForm;
    }
    
    /* 
         * Method name : doBack
         * Description : This method is used to redirect user to the Compliance Submission tab 
         * Param - No parameter 
         * Returns : PageReference
    */
        
    public PageReference doBack(){
        
        PageReference compTab = new PageReference('/'+IRIS_Submission__c.sObjectType.getDescribe().getKeyPrefix()+'/o');
        compTab.setRedirect(true);
        return compTab;
    }
    
    /* 
         * Method name : verifyAttachmentsSelected
         * Description : This method is used to check if the document is uploaded.
         * Param - No parameter 
         * Returns : hasAttachments
    */
    
    private boolean verifyAttachmentsSelected()
    {
        boolean hasAttachments = false;
        if(FileCount == null || FileCount == '')
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,Label.Iriss_Please_select_Uploading_files));
            return hasAttachments;
        }  
        
        List<Attachment> listToInsert = new List<Attachment>() ;   
           
        for(Attachment att : allFileList)   
        {   
            if(att.name != null && att.name != '' && att.body != null)   
                listToInsert.add(new Attachment(parentId = oSubmission.id, name = att.name, body = att.body)) ;   
        } 
        
        
        if(listToInsert.size() < 1)   
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,Label.Iriss_Please_select_at_least_one_file));
            hasAttachments = false;
        }
        else
            hasAttachments = true;
        return hasAttachments;
    }
    
    /* 
         * Method name : SaveAttachments
         * Description : This method is used to save attachment.
         * Param - No parameter 
         * Returns : null
    */
    
    public Pagereference SaveAttachments()   
    {     
        List<Attachment> listToInsert = new List<Attachment>() ;   
           
        for(Attachment att : allFileList)   
        {   
            if(att.name != null && att.name != '' && att.body != null)   
                listToInsert.add(new Attachment(parentId = oSubmission.id, name = att.name, body = att.body)) ;   
        }   
           
         
        insert listToInsert ;   
        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.INFO, listToInsert.size() + Label.Iriss_file_s_are_uploaded_successfully));   
       
        return null;   
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
         * Method name : checkAudience
         * Description : This method is used to render country or region based on Intended Audience selected.
         * Param - No parameter 
         * Returns : null
    */

    
    public void checkAudience()
    {
        if(oSubmission.Intended_Audience__c== Iris_Constants.SUBMISSION_INTENDED_AUDIENCE_REGIONAL)
        {
                showRegion = true;
                showCountry = false;
        }
        if(oSubmission.Intended_Audience__c== Iris_Constants.SUBMISSION_INTENDED_AUDIENCE_LOCAL)
        {
                showCountry = true;
                ShowRegion = false;
        }
        if(oSubmission.Intended_Audience__c== Iris_Constants.SUBMISSION_INTENDED_AUDIENCE_GLOBAL)
        {
                showRegion = false;
                showCountry = false;
        }
    }  
}