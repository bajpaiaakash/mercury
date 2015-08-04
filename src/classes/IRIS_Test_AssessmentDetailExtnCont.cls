/*
*  Classname : Iriss_Test_AssessmentDetailExtnCont
*   Created By: Deloitte USI    
*   Created Date: 18-Mar-2014
*   Description: This class is the test class for the document approval functionality.
*   Version : 0.1 
*   Change Log
*   Version     Description                         Updated By
*    
*/
@isTest
public with sharing class IRIS_Test_AssessmentDetailExtnCont {
    private static IRIS_Submission__c oSubmission{set;get;}
    private static IRIS_Assessment__c oAssessment{set;get;}
    private static IRIS_Submission_Assessment__c oSubAssess{set;get;}
    
    static void createTestData()
    {
        oSubmission = Iris_Test_Setup.createSubmission();
        oAssessment = Iris_Test_Setup.createAssessment(oSubmission.Sub_Category__c);
        Iris_Test_Setup.createAssessQuestions(oAssessment,Iris_Test_Setup.createQuestions(5));
        
        Test.setCurrentPage(Page.Iris_Assessment);
        ApexPages.currentPage().getParameters().put('retURL', '/'+oSubmission.Id);  
        IRIS_Assessment_ExtensionController controller = new IRIS_Assessment_ExtensionController (new ApexPages.StandardController(
                                                                                                new IRIS_Submission_Assessment__c()));
        if(controller.lstAssessData!=null){
        for(IRIS_Assessment_Data__c assessData : controller.lstAssessData)
        {
            assessData.Rating__c = '5 - Green';
        }
       }
        //calling the Submit for Approval method to save and submit the Submission Assessment
        controller.doSubmitForApproval();
    }
    
    static testMethod void testApprovalOfSubmission() {
        system.runas(IRIS_Utility.CreateUserForTestMethods()){
            // create test data like questions,Assessment, Assessment questions and submission record.
            createTestData();
            Test.startTest();
            Test.setCurrentPage(Page.Iris_AssessmentApprovalResponse);
            ApexPages.currentPage().getParameters().put('id', oSubmission.Id);  
            ApexPages.currentPage().getParameters().put('subAssessId', oAssessment.Id);
            IRIS_AssessmentApproval_ControllerExten controller = new IRIS_AssessmentApproval_ControllerExten(new ApexPages.StandardController(oSubmission));
            
            // approving the approval process
            controller.oIrissSubmission.Decision_Taken__c = Iris_Constants.SUBMISSION_DECISION_APPROVE;
            controller.doSubmit();
            controller.sendMail();
            Test.stopTest();
            IRIS_Submission__c oSub = [Select id, Decision_Taken__c, Status__c From IRIS_Submission__c Where id =: oSubmission.id];
            System.Assertequals(oSub.Decision_Taken__c, Iris_Constants.SUBMISSION_DECISION_APPROVE);
            System.Assertequals(oSub.Status__c, Iris_Constants.SUBMISSION_STATUS_APPROVED);
        }
    }
    
    static testMethod void testRejectionOfSubmission() {
        system.runas(IRIS_Utility.CreateUserForTestMethods()){
            // create test data like questions,Assessment, Assessment questions and submission record.
            createTestData();
            Test.startTest();
            Test.setCurrentPage(Page.Iris_AssessmentApprovalResponse);
            ApexPages.currentPage().getParameters().put('id', oSubmission.Id);  
            ApexPages.currentPage().getParameters().put('subAssessId', oAssessment.Id);
            IRIS_AssessmentApproval_ControllerExten controller = new IRIS_AssessmentApproval_ControllerExten(new ApexPages.StandardController(oSubmission));
            
            // approving the approval process
            controller.oIrissSubmission.Decision_Taken__c = Iris_Constants.SUBMISSION_DECISION_REJECT;
            controller.doSubmit();
            controller.sendMail();
            Test.stopTest();
            IRIS_Submission__c oSub = [Select id, Decision_Taken__c, Status__c From IRIS_Submission__c Where id =: oSubmission.id];
            System.Assertequals(oSub.Decision_Taken__c, Iris_Constants.SUBMISSION_DECISION_REJECT);
            System.Assertequals(oSub.Status__c, Iris_Constants.SUBMISSION_STATUS_REJECTED);
        }
    }
}