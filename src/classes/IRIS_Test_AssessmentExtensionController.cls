/*
*  Classname : Iriss_Test_AssessmentExtensionController
*   Created By: Deloitte USI    
*   Created Date: 18-Mar-2014
*   Description: This class is the test class for the document assessment functionality.
*   Version : 0.1 
*   Change Log
*   Version     Description                         Updated By
*    
*/
@isTest
private class IRIS_Test_AssessmentExtensionController {
  
  private static IRIS_Submission__c oSubmission{set;get;}
  private static IRIS_Assessment__c oAssessment{set;get;}
  
  static void createTestData()
  {
    oSubmission = Iris_Test_Setup.createSubmission();
    oAssessment = Iris_Test_Setup.createAssessment(oSubmission.Sub_Category__c);
    Iris_Test_Setup.createAssessQuestions(oAssessment,Iris_Test_Setup.createQuestions(5));
  }
  
  static testMethod void negativeTestSubmitForApproval() {
      system.runas(IRIS_Utility.CreateUserForTestMethods()){
        // create test data like questions,Assessment, Assessment questions and submission record.
        createTestData();
        Test.setCurrentPage(Page.Iris_Assessment);
        ApexPages.currentPage().getParameters().put('retURL', '/'+oSubmission.Id);  
        IRIS_Assessment_ExtensionController controller = new IRIS_Assessment_ExtensionController(new ApexPages.StandardController(
                                                    new IRIS_Submission_Assessment__c()));
        //filling the rating
        for(IRIS_Assessment_Data__c assessData : controller.lstAssessData)
        {
        assessData.Rating__c = '5 - Green';
        }
        //Calling the Submit for Approval when the submission record doesn't match the entry criteria.
        oSubmission.Status__c = Iris_Constants.SUBMISSION_STATUS_PENDING_DECISION;
        update oSubmission;
        PageReference returnedPage = controller.doSubmitForApproval();
        System.assertEquals(returnedPage , null);
    }
  }
  
  static testMethod void negativeTestFillAllRatting() {
      system.runas(IRIS_Utility.CreateUserForTestMethods()){
        // create test data like questions,Assessment, Assessment questions and submission record.
            createTestData();
            Test.setCurrentPage(Page.IRIS_Assessment);
            ApexPages.currentPage().getParameters().put('retURL', '/'+oSubmission.Id);  
            IRIS_Assessment_ExtensionController controller = new IRIS_Assessment_ExtensionController(new ApexPages.StandardController(
                                                        new IRIS_Submission_Assessment__c()));
        
        //Calling the Submit for Approval when the ratting is not populated.
        PageReference returnedPage = controller.doSubmitForApproval();
        System.assertEquals(returnedPage , null);
        
        //filling the rating
        for(IRIS_Assessment_Data__c assessData : controller.lstAssessData)
        {
          assessData.Rating__c = '5 - Green';
        }
        
        //purposely delete the Submission record so that when we save Submission Assessment we get an error
        delete oSubmission;
        
        //calling the doSubmitForApproval method to try and save the Submission Assessment
        controller.doSubmitForApproval();
        System.assertEquals(controller.isSaveSuccessful , false);
      }      
  }
  
  static testMethod void negativeTestCreateSubmissionAssessment() {
      system.runas(IRIS_Utility.CreateUserForTestMethods()){
        // create test data like questions,Assessment, Assessment questions and submission record.
            createTestData();
            Test.setCurrentPage(Page.Iris_Assessment);
            ApexPages.currentPage().getParameters().put('retURL', '/'+oSubmission.Id);  
            IRIS_Assessment_ExtensionController controller = new IRIS_Assessment_ExtensionController(new ApexPages.StandardController(
                                                        new IRIS_Submission_Assessment__c()));
        //purposely delete the Submission record so that when we save Submission Assessment we get an error
        delete oSubmission;
        //calling the Save as Draft method to try and save the Submission Assessment
        controller.doSaveAsDraft();
        System.assertEquals(controller.isSaveSuccessful , false);
      }  
  }
  
    static testMethod void testCreateSubmissionAssessment() {
        system.runas(IRIS_Utility.CreateUserForTestMethods()){
            // create test data like questions,Assessment, Assessment questions and submission record.
            createTestData();
            Test.setCurrentPage(Page.Iris_Assessment);
            ApexPages.currentPage().getParameters().put('retURL', '/'+oSubmission.Id);  
            IRIS_Assessment_ExtensionController controller = new IRIS_Assessment_ExtensionController(new ApexPages.StandardController(
                                                        new IRIS_Submission_Assessment__c()));
            System.assert(controller.oSubmission!=null,'Submission Record not found');
            System.assert(controller.lstAssessData!=null && controller.lstAssessData.size()>0, 'Assessment questions not found');
            
            //calling the Save as Draft method to save the Submission Assessment
            controller.doSaveAsDraft();
            
            IRIS_Submission_Assessment__c oAssess = [Select Status__c,Submission__c 
                                  from IRIS_Submission_Assessment__c
                                  where id=: controller.oSubAssessment.id];
            System.assert(oAssess != null , 'Submission Assessment is not created.');
            System.assertEquals(controller.oSubAssessment.Status__c , Iris_Constants.SUBMISSION_ASSESSMENT_STATUS_IN_PROGRESS);
            
            
            // testing the methods which are invoked from the page.
            List<SelectOption> lstSelOpts = controller.lstRatings;
            controller.doEdit();
            controller.getPdfPage();
            controller.getSubmissionPage();
        }    
    }
    
    static testMethod void testSubmitSubmissionAssessment() {
        system.runas(IRIS_Utility.CreateUserForTestMethods()){
            // create test data like questions,Assessment, Assessment questions and submission record.
            createTestData();
            Test.setCurrentPage(Page.Iris_Assessment);
            ApexPages.currentPage().getParameters().put('retURL', '/'+oSubmission.Id);  
            IRIS_Assessment_ExtensionController controller = new IRIS_Assessment_ExtensionController(new ApexPages.StandardController(
                                                            new IRIS_Submission_Assessment__c()));
            System.assert(controller.oSubmission!=null,'Submission Record not found');
            System.assert(controller.lstAssessData!=null && controller.lstAssessData.size()>0, 'Assessment questions not found');
            
            for(IRIS_Assessment_Data__c assessData : controller.lstAssessData)
            {
              assessData.Rating__c = '5 - Green';
            }
            
            //calling the Submit for Approval method to save and submit the Submission Assessment
            controller.doSubmitForApproval();
            
            IRIS_Submission_Assessment__c oAssess = [Select Status__c,Submission__c 
                                  from IRIS_Submission_Assessment__c
                                  where id=: controller.oSubAssessment.id];
            System.assert(oAssess != null , 'Submission Assessment is not created.');
            System.assertEquals(controller.oSubAssessment.Status__c , Iris_Constants.SUBMISSION_ASSESSMENT_STATUS_COMPLETED);
            
        }
    }
    
    static testMethod void checkForApproval() {
        system.runas(IRIS_Utility.CreateUserForTestMethods()){
            // create test data like questions,Assessment, Assessment questions and submission record.
            createTestData();
            Test.setCurrentPage(Page.Iris_Assessment);
            ApexPages.currentPage().getParameters().put('retURL', '/'+oSubmission.Id);  
            IRIS_Assessment_ExtensionController controller = new IRIS_Assessment_ExtensionController(new ApexPages.StandardController(
                                                            new IRIS_Submission_Assessment__c()));
            System.assert(controller.oSubmission!=null,'Submission Record not found');
            System.assert(controller.lstAssessData!=null && controller.lstAssessData.size()>0, 'Assessment questions not found');
            
            for(IRIS_Assessment_Data__c assessData : controller.lstAssessData)
            {
              assessData.Rating__c = '5 - Green';
            }
            
            //calling the Submit for Approval method to save and submit the Submission Assessment
            controller.doSubmitForApproval();
            
            IRIS_Submission_Assessment__c oAssess = [Select Status__c,Submission__c 
                                  from IRIS_Submission_Assessment__c
                                  where id=: controller.oSubAssessment.id];
            System.assert(oAssess != null , 'Submission Assessment is not created.');
            System.assertEquals(controller.oSubAssessment.Status__c , Iris_Constants.SUBMISSION_ASSESSMENT_STATUS_COMPLETED);
            
            // re-initializing the Iriss_AssessmentExtensionController class now with an submission assessment id
            ApexPages.currentPage().getParameters().put('id', '/'+controller.oSubAssessment.Id);
            controller = new IRIS_Assessment_ExtensionController(new ApexPages.StandardController(controller.oSubAssessment));
            
            System.assert(controller.lstAssessData!=null && controller.lstAssessData.size()>0, 'Assessment Data not found');
            System.assertEquals(controller.needsApproval , true);
            
        }
    }
    
    static testMethod void testAssessmentReportPage() {
    system.runas(IRIS_Utility.CreateUserForTestMethods()){
            // create test data like questions,Assessment, Assessment questions and submission record.
            createTestData();
            Test.setCurrentPage(Page.Iris_Assessment);
            ApexPages.currentPage().getParameters().put('retURL', '/'+oSubmission.Id);  
            IRIS_Assessment_ExtensionController controller = new IRIS_Assessment_ExtensionController(new ApexPages.StandardController(
                                                        new IRIS_Submission_Assessment__c()));
        System.assert(controller.oSubmission!=null,'Submission Record not found');
        System.assert(controller.lstAssessData!=null && controller.lstAssessData.size()>0, 'Assessment questions not found');
        
        for(IRIS_Assessment_Data__c assessData : controller.lstAssessData)
        {
          assessData.Rating__c = '5 - Green';
        }
        
        //calling the Submit for Approval method to save and submit the Submission Assessment
        controller.doSubmitForApproval();
        
        IRIS_Submission_Assessment__c oAssess = [Select Status__c,Submission__c 
                              from IRIS_Submission_Assessment__c
                              where id=: controller.oSubAssessment.id];
        System.assert(oAssess != null , 'Submission Assessment is not created.');
        System.assertEquals(controller.oSubAssessment.Status__c , Iris_Constants.SUBMISSION_ASSESSMENT_STATUS_COMPLETED);
        
        // re-initializing the Iriss_AssessmentExtensionController class now with an submission assessment id
        ApexPages.currentPage().getParameters().put('id', '/'+controller.oSubAssessment.Id);
        controller = new IRIS_Assessment_ExtensionController(new ApexPages.StandardController(controller.oSubAssessment));
        
        
        System.assert(controller.lstAssessData!=null && controller.lstAssessData.size()>0, 'Assessment Data not found');
        System.assertEquals(controller.needsApproval , true);
        
        Test.setCurrentPage(Page.Iris_Assessment_Report);
            ApexPages.currentPage().getParameters().put('id', '/'+controller.oSubAssessment.Id); 
            controller = new IRIS_Assessment_ExtensionController(new ApexPages.StandardController(controller.oSubAssessment)); 
            
        }
    }        
}