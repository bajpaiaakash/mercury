/*
*  Classname : Iriss_AssessmentExtensionController
*   Created By: Deloitte USI    
*   Created Date: 21-Feb-2014
*   Description: This class is used an extension for the Iriss_Assessment page
*   Version : 0.1 
*   Change Log
*   Version     Description                         Updated By
*    
*/

public with sharing class IRIS_Assessment_ExtensionController
{
    private boolean isNewAssessment{set;get;}
    @TestVisible
    private boolean isSaveSuccessful{set;get;}
    public boolean isCompleted{set;get;}
    public boolean showEditPage{set;get;}
    public boolean isAsessmentPresent{set;get;}
    public boolean needsApproval{set;get;}
    private transient SavePoint sp;
    public IRIS_Submission_Assessment__c oSubAssessment{set;get;}
    public IRIS_Submission__c oSubmission{set;get;}
    private List<IRIS_Assessment_Questions__c> lstAssessQues{set;get;}
    public List<IRIS_Assessment_Data__c> lstAssessData{set;get;}
    public boolean isSend{get;set;}
    public boolean isApprove{get;set;}
    public List<SelectOption> lstRatings
    {
        set;
        get{
            if(lstRatings == null){
                lstRatings = getRatingPicklistVales();
            }
            return lstRatings;
        }
    }
    private String returnUrl{set;get;}
    private String prefixId{set;get;}
    private String assessRecId{set;get;}
    public String assessmentSubTitle{set;
        get{
                if(oSubmission != null && oSubmission.Sub_Category__c != null){
                        if(oSubmission.Sub_Category__c.containsIgnoreCase(Label.Iriss_Assessment_SubTitle_Suffix)){
                                return oSubmission.Sub_Category__c;
                        }
                        else{
                                return oSubmission.Sub_Category__c + ' ' + Label.Iriss_Assessment_SubTitle_Suffix;
                        }
                }
                return ' ';
        }
    }
    
    private Id submissionId{set;get;}
    
    public IRIS_Assessment_ExtensionController(ApexPages.StandardController controller) {
        // addFields is not coverabe from a test class
        if( !Test.isRunningTest() ){
                //adding the fields which are required in the controller and may not be present on the visualforce page
                controller.addFields(new List<String>{'name','Assessment__c','Submission__c','Status__c'});
        }
        oSubAssessment = (IRIS_Submission_Assessment__c)controller.getRecord();
        isSaveSuccessful = false;
        isAsessmentPresent = false;
        showEditPage = true;
        // checking if the submission assessment is completed or not
        isCompleted = oSubAssessment.Status__c == Iris_Constants.SUBMISSION_ASSESSMENT_STATUS_COMPLETED ?true:false;
        returnUrl = apexpages.currentpage().getparameters().get('retURL');
        
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
        
        //isSend = IRIS_Access_Buttons__c.getInstance(Userinfo.getprofileid()).Submit_for_Approval__c;
        if(oAccessButtons!=null ){
        isSend = oAccessButtons.Submit_for_Approval__c;
        }
        
        //isApprove = IRIS_Access_Buttons__c.getInstance(Userinfo.getprofileid()).Approve_Reject__c;
        if(oAccessButtons!=null ){
        isApprove = oAccessButtons.Approve_Reject__c;
        }
        
        try{
            if(oSubAssessment.id == null){
                // as Submission assessment id is not present, it is a new assessment.
                isNewAssessment = true;
                needsApproval = false;
                if(returnUrl != null){
                    submissionId = returnUrl.subString(1,16);
                    // checking if there is an assessment already present for that submission
                    if(!isSubAssessmentAlreadyPresent(submissionId)){
                        oSubmission = getSubmissionDetails(submissionId);
                        if(oSubmission != null && oSubmission.Sub_Category__c != null){
                            // querying the assessment with the name matching with the sub-category of the submission
                            List<IRIS_Assessment__c> lstAssessments = [SELECT id, isActive__c, Name 
                                                                                FROM IRIS_Assessment__c 
                                                                                WHERE Name=: oSubmission.Sub_Category__c
                                                                                  and isActive__c = true order by createdDate desc 
                                                                                limit :Limits.getLimitQueryRows()];
                            if(lstAssessments != null && lstAssessments.size()>0){
                                assessRecId = lstAssessments[0].id;
                                lstAssessQues = getAssessmentQuestions(assessRecId);
                                if(lstAssessQues != null && lstAssessQues.size()>0){
                                    getlstAssessmentData();
                                    // setting the boolean isAsessmentPresent to true as we found the assessment and its questions
                                    isAsessmentPresent = true;
                                }                   
                            }
                        }
                        if(!isAsessmentPresent){
                            showEditPage = false;
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Iriss_Assessment_Not_Present));       
                        }   
                    }
                }
            }
            else{
                // submission assessment id is present
                isNewAssessment = false;
                submissionId = oSubAssessment.Submission__c;
                oSubmission = getSubmissionDetails(submissionId);
                assessRecId = oSubAssessment.Assessment__c;
                // query assessment data
                queryAssessmentData(oSubAssessment.id);
                needsApproval = Iris_Utility.getProcessInstanceWorkitem(submissionId) != null ? true : false;
                isAsessmentPresent = true;
                
                // adding a space after ';' to the multi select picklist for formatting on the pdf
                if(apexpages.currentpage().getUrl().containsIgnoreCase(Page.Iris_Assessment_Report.getUrl()))
                {
                    if(oSubmission.Country_Text__c != null) oSubmission.Country_Text__c = oSubmission.Country_Text__c.replace(';','; ');
                    if(oSubmission.Region_Text__c != null) oSubmission.Region_Text__c = oSubmission.Region_Text__c.replace(';','; ');
                    if(oSubmission.Function__c != null) oSubmission.Function__c = oSubmission.Function__c.replace(';','; ');
                    if(oSubmission.Business_Unit__c != null) oSubmission.Business_Unit__c = oSubmission.Business_Unit__c.replace(';','; ');
                    if(oSubmission.Document_Name__c != null) oSubmission.Document_Name__c = oSubmission.Document_Name__c.replace('_',' ');
                }
            }
        }
        catch(Exception exp){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Iriss_unexpected_error));
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,exp.getMessage()));
        }
    }
    
    /* 
     * Method name : isSubAssessmentAlreadyPresent
     * Description : This method is used to query and check if the submission assessment record is already present for the Submission.
     * Param - submissionId : The id of the Submission record. 
     * Returns :  a boolean to indicate if Submission Assessment is already present or not.
    */
    private boolean isSubAssessmentAlreadyPresent(Id submissionId){
        // querying to see if there is an submission assessment already present for the compliance submission
        List<IRIS_Submission_Assessment__c> lstSubAssessment = [Select name 
                                                                 from IRIS_Submission_Assessment__c 
                                                                 where Submission__c =: submissionId];
        if(lstSubAssessment != null && lstSubAssessment.size()>0){
            showEditPage = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,Label.Iriss_Only_One_Submission_Assessment));
            return true;
        }
        return false;
    }
    
    private void queryAssessmentData(Id submissionAssessmentId)
    {
        // querying the assessment data for the submission assessment
        lstAssessData = [Select Assessment_Question__c, Question_Number__c, Question__c, Rating__c, 
                                    Comments__c, Recommendations__c, Sequence__c, Rating_Colour__c,Total_Score__c  
                         From IRIS_Assessment_Data__c 
                         where Assessment__c = : submissionAssessmentId
                         order by Sequence__c asc];
    }
    /* 
     * Method name : getAssessmentQuestions
     * Description : This method is used to query the assessment questions based on the assessment Id.
     * Param - assessId : The id of the Assessment record. 
     * Returns :  List of Assessment question records.
    */
    private List<IRIS_Assessment_Questions__c> getAssessmentQuestions(String assessId)
    {
        //querying the assessment questions related to the queried assessment
        lstAssessQues = [SELECT Question__c,Question__r.Question__c,Sequence__c,Total_Score__c,
                                Question__r.Question_Number__c 
                         FROM IRIS_Assessment_Questions__c
                         where Assessment__c  =: assessId and Question__r.Active__c = true 
                         order by Sequence__c asc limit 1000];
        return lstAssessQues;
    }
    
    /* 
     * Method name : getlstAssessmentData
     * Description : This method is used to generate a list of Assessment Data records based on the assessment questions.
     * Param - No parameter.
     * Returns :  void
    */
    private void getlstAssessmentData()
    {
        lstAssessData = new List<IRIS_Assessment_Data__c>();
        // looping the assessment questions and generating assessment data records
        for(IRIS_Assessment_Questions__c assessQues :  lstAssessQues)
        {
            lstAssessData.add(new IRIS_Assessment_Data__c(Assessment_Question__c = assessQues.id,
                                                             Question_Number__c = assessQues.Question__r.Question_Number__c,
                                                             Question__c = assessQues.Question__r.Question__c,
                                                             Sequence__c = assessQues.Sequence__c,
                                                             Total_Score__c = assessQues.Total_Score__c));
        }
    }
    
     /* 
     * Method name : getSubmissionDetails
     * Description : This method is used to query the submission record details based on the submission Id.
     * Param - SubId : The id of the Submission record. 
     * Returns :  The Submission record.
    */
    private IRIS_Submission__c getSubmissionDetails(Id SubId)
    {
        // the following list contains the fields which are required in this controller
        // the following fields might not be present on the field set and hence might throw an exception if not queried. 
        List<String> lstRequiredFields = new List<String>{'COE_Assessor__c','Decision_Comments__c',
                                                             'Document_Name__c','Sub_Category__c',
                                                             'Decision_Taken__c','Reason_Code__c',
                                                             'Region_Text__c','Country_Text__c',
                                                             'Function__c','Business_Unit__c'};
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        // adding the fields required in the controller if they are not part of the field set
        for(String strField : lstRequiredFields)
        {
            if(!query.contains(strField+','))
            {
                query += strField + ', ';
            }   
        }
        // removing the last ', ' from the string
        query = query.substring(0, query.length()-2);
        query += ' FROM IRIS_Submission__c where id =: SubId';
        return Database.query(query);
    }
   
    /* 
     * Method name : populateAssessmentRatings
     * Description : This method is used to get the actual score from the ratting given to the assessment question
     * Param - No Parameter. 
     * Returns :  void
    */
    private void populateAssessmentRatings()
    {
        // looping the assessment data records to get the actual score based on the rating given by the assessor
        if(lstAssessData!=null){
        for(IRIS_Assessment_Data__c assessData : lstAssessData)
        {
            if(assessData.Rating__c != null)
            {
                assessData.Actual_Score__c = Decimal.valueOf(assessData.Rating__c.subString(0,1));  
            }
        }
    }
}
    
    /* 
     * Method name : doSave
     * Description : This method is used to insert the Submission Assessment record along with the list of Assessment Data record/s.
     * Param - No Parameter. 
     * Returns :  The Submission detail page.
    */
    private void doSave(String strStatus)
    {
        isSaveSuccessful = false;
        oSubAssessment.Status__c = strStatus;
        // populate assessment rating
        populateAssessmentRatings();
        // the submission assessment is saved for the first time we need to populate the submission id and the assessment id
        if(isNewAssessment && oSubAssessment.Submission__c == null && oSubAssessment.Assessment__c == null)
        {
            oSubAssessment.Submission__c = submissionId;
            oSubAssessment.Assessment__c = assessRecId;
        }
        sp = Database.setSavepoint();
        try 
        {
            upsert oSubAssessment;
            if(isNewAssessment)
            {
                if(lstAssessData!=null){
                for(IRIS_Assessment_Data__c assessData : lstAssessData)
                {
                    assessData.Assessment__c = oSubAssessment.id;
                } 
            upsert lstAssessData;
            }
            }
            if(oSubmission!=null){
            if(oSubmission.COE_Assessor__c != UserInfo.getUserId())
            {
                oSubmission.COE_Assessor__c = UserInfo.getUserId();
                update oSubmission;
            }
        }
        } catch (DMLException e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Iriss_Error_while_saving_assessment));
            return;
        }
        isSaveSuccessful = true;
    }
    
    /* 
     * Method name : doSaveAsDraft
     * Description : This method is used to save the submission assessment in draft mode with status as in progress.
     * Param - No Parameter. 
     * Returns :  The Submission detail page.
    */
    public PageReference doSaveAsDraft()
    {
        doSave(Iris_Constants.SUBMISSION_ASSESSMENT_STATUS_IN_PROGRESS );
        if(isSaveSuccessful)
        {
            return getAssessmentPage();
        }
        return null;
    }
    
    /* 
     * Method name : doSubmitForApproval
     * Description : This method is used to save the submission assessment and then submit it for approval.
     * Param - No Parameter. 
     * Returns :  The Submission detail page.
    */
    public PageReference doSubmitForApproval()
    {
        // checking if the rating is populated for all asessment data
        if(lstAssessData!=null){
        for(IRIS_Assessment_Data__c assessData : lstAssessData)
        {
            if(assessData.Rating__c == null)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Iriss_Please_select_rating));
                return null;
            }   
        }
    }
        // saving the submission assessment
        doSave(IRIS_Constants.SUBMISSION_ASSESSMENT_STATUS_COMPLETED );
        if(isSaveSuccessful)
        {
            // update the assessment date on the submission record
            updateSubmissionRecord(submissionId);
            
            // Create an approval request for the Submission
            Approval.ProcessSubmitRequest req1 = 
                new Approval.ProcessSubmitRequest();
            req1.setComments(Label.Iriss_Submitting_request_for_approval);
            req1.setObjectId(submissionId);
            
            try
            {
                // Submit the approval request for the account
                Approval.ProcessResult result = Approval.process(req1);
            }
            catch(Exception exp)
            {
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Iriss_Following_error_occurred_approval));
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,exp.getMessage()));
                return null;
            }
            
            return getAssessmentPage();
        }
        return null;
    }
    
    private void updateSubmissionRecord(Id submissionId){
        IRIS_Submission__c oSub = new IRIS_Submission__c(id = submissionId);
        oSub.Assessment_Date__c = System.today();
        try{
            // update the submission record id with the assessment date as today's date
            update oSub;
        }
        catch(Exception exp){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,exp.getMessage()));
        }
    }
    
    /* 
     * Method name : getAssessmentPage
     * Description : This method is used to get the page on which assessment is taken i.e. the submission detail page.
     * Param - No Parameter. 
     * Returns :  The Submission detail page.
    */
    public PageReference getAssessmentPage()
    {
        PageReference assessmentPage;
        if(returnUrl != null)
        {
            assessmentPage = new PageReference(returnUrl);  
        }
        else
        {
            assessmentPage = new PageReference('/'+oSubAssessment.id);
        }
        assessmentPage.setRedirect(true);
        return assessmentPage;
    }
    
    /* 
     * Method name : getPdfPage
     * Description : This method is used to get the page which is rendered as pdf so that the assessment could be sent for printing
     * Param - No Parameter. 
     * Returns :  The Assessment Report page.
    */
    public PageReference getPdfPage()
    {
        PageReference pdfPage = new PageReference('/apex/Iriss_Assessment_Report_Page?id='+oSubAssessment.id);
        pdfPage.setRedirect(true);
        return pdfPage;
    }
    
    /* 
     * Method name : getFields
     * Description : This method is used to get the fields preset in the field set 'FieldsOnAssessmentForm' in the Submission_Iriss__c object.
     * Param - No Parameter. 
     * Returns :  The list of FieldSetMember.
    */
    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.IRIS_Submission__c.FieldSets.FieldsOnAssessmentForm.getFields();
    }
    
    /* 
     * Method name : getRatingPicklistVales
     * Description : This method is used to get the picklist values of the rating field present in the IRIS_Assessment_Data__c object
     * Param - No Parameter. 
     * Returns :  The list of SelectOption representing the picklist values of the rating field
    */
    private List<SelectOption> getRatingPicklistVales()
    {
        List<SelectOption> options = new List<SelectOption>();        
        for( Schema.PicklistEntry picklistVal : IRIS_Assessment_Data__c.Rating__c.getDescribe().getPicklistValues())
        {
            options.add(new SelectOption(picklistVal.getValue(),''));
        }       
        return options;
    }
    
    /* 
     * Method name : doEdit
     * Description : This method is used to redirect to Assessment edit page 
     * Param - No Parameter. 
     * Returns :  null
    */
    
    public PageReference doEdit()
    {
        if(oSubAssessment.id != null)
        {
            PageReference assessmentEditPage = new PageReference('/'+oSubAssessment.id+'/e?retURL=%2F'+oSubAssessment.id);
            assessmentEditPage.setRedirect(true);
            return assessmentEditPage;
        }
        return null;
    }
    
    /* 
     * Method name : getSubmissionPage
     * Description : This method is used to redirect to submission page
     * Param - No Parameter. 
     * Returns :  submissionPage
    */
    
    public PageReference getSubmissionPage()
    {
        PageReference submissionPage = new PageReference('/'+submissionId);
        submissionPage.setRedirect(true);
        return submissionPage;
    }
}