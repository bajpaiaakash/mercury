/*
*  Classname : Iriss_Test_ApprovalHistoryExtnCont 
*   Created By: Deloitte USI    
*   Created Date: 19-Mar-2014
*   Description: This class is the test class for the submission form functionality.
*   Version : 0.1 
*   Change Log
*   Version     Description                         Updated By
*    
*/
@isTest

public with sharing class IRIS_Test_ApprovalHistoryExtnCont {
    private static IRIS_Submission__c oSubmission{set;get;}
    private static IRIS_Assessment__c oAssessment{set;get;}
    
    static void createTestData()
    {
        oSubmission = IRIS_Test_Setup.createSubmission();
        oAssessment = Iris_Test_Setup.createAssessment(oSubmission.Sub_Category__c);
        Iris_Test_Setup.createAssessQuestions(oAssessment,Iris_Test_Setup.createQuestions(5));
        
        Test.setCurrentPage(Page.IRIS_Assessment);
            ApexPages.currentPage().getParameters().put('retURL', '/'+oSubmission.Id);  
            IRIS_Assessment_ExtensionController controller = new IRIS_Assessment_ExtensionController(new ApexPages.StandardController(
                                                        new IRIS_Submission_Assessment__c()));
        if(controller.lstAssessData!=null ){
        for(IRIS_Assessment_Data__c assessData : controller.lstAssessData)
        {
          assessData.Rating__c = '5 - Green';
        }
        }
        //calling the Submit for Approval method to save and submit the Submission Assessment
        controller.doSubmitForApproval();
    
}
    
    static testMethod void testApprovalHistory() {
        system.runas(IRIS_Utility.CreateUserForTestMethods()){
            createTestData();
            Test.startTest();
            Test.setCurrentPage(Page.Iris_Approval_History);
            Apexpages.currentPage().getParameters().put('id',oSubmission.id); 
            IRIS_ApprovalHistory_ControllerExtension controller = new IRIS_ApprovalHistory_ControllerExtension(new ApexPages.StandardController(oSubmission));
            controller.doApprove();
            Test.stopTest();
            IRIS_Submission__c oSub = [Select id, Decision_Taken__c, Status__c From IRIS_Submission__c Where id =: oSubmission.id];
            System.Assertequals(oSub.Status__c, Iris_Constants.SUBMISSION_STATUS_PENDING_DECISION );
        }
    }

}