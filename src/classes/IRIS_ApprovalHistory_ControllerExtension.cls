/*
*    Classname : Iriss_ApprovalHistoryExtensionController
*    Created By: Deloitte USI    
*    Created Date: 05-Mar-2014
*    Description: This class is used an extension for the Iriss_Approval_History page
*    Version : 0.1 
*    Change Log
*    Version     Description                         Updated By
*    
*/

public with sharing class IRIS_ApprovalHistory_ControllerExtension {

    public list<ProcessInstance> histories{get;set;}
    public IRIS_Submission__c oSubmission;

    public IRIS_ApprovalHistory_ControllerExtension (ApexPages.StandardController controller) {
        oSubmission = (IRIS_Submission__c)controller.getRecord();
        getApprovalHistory();
    }
    
    /* 
         * Method name : getApprovalHistory
         * Description : This method is used to retrive values form ProcessInstance object.
         * Param - No parameter 
         * Returns :  void
    */
    
    public void getApprovalHistory()
    {
        // querying the ProcessInstance object to get the approvals which need decesion.
        histories =  [select status , (select StepStatus,OriginalActor.Name , Actor.Name, CreatedDate 
                                                   from Steps
                                                   order by createdDate desc),
                                        (Select createdDate,OriginalActor.Name , Actor.Name
                                                   From Workitems
                                                   order by createdDate desc) 
                                       from ProcessInstance
                                       where targetobjectId = :oSubmission.id                                            
                                       order by createdDate desc limit :Limits.getLimitQueryRows()];
        
    }
    
    /* 
         * Method name : doApprove
         * Description : This method is used for redirecting to the Assessment page.
         * Param - No parameter 
         * Returns :  void
    */
    
    public PageReference doApprove(){
    
        // querying the submission assessment related to the compliance submission record
        IRIS_Submission_Assessment__c subAsses = [SELECT id FROM IRIS_Submission_Assessment__c 
                                                   WHERE Submission__c =:oSubmission.id and 
                                                        Status__c =: IRIS_Constants.SUBMISSION_ASSESSMENT_STATUS_COMPLETED
                                                   order by createddate desc limit 1];
        if(subAsses != null)
        {
            PageReference conPage = new PageReference('/apex/IRIS_Assessment_Approval?id='+subAsses.id);
            return conPage ;
        }
        return null;    
    }

}