/*
*  Classname : Iriss_Test_Submission_Trigger_Helper
*   Created By: Deloitte USI    
*   Created Date: 19-Mar-2014
*   Description: This class is the test class for the testing that the COE Assessor field is populated when the record has been accepted by the COE Assessor 
*   Version : 0.1 
*   Change Log
*   Version     Description                         Updated By
*    
*/
@isTest
private class IRIS_Test_Submission_TriggerHandler {
  
  private static IRIS_Submission__c oSubmission{set;get;}
  private static IRIS_Assessment__c oAssessment{set;get;}
  private static IRIS_Submission_Assessment__c oSubAssess{set;get;}
  
  static void createTestData(){
    oSubmission = Iris_Test_Setup.createSubmission();
    oAssessment = Iris_Test_Setup.createAssessment(oSubmission.Sub_Category__c);
    Iris_Test_Setup.createAssessQuestions(oAssessment,Iris_Test_Setup.createQuestions(5));
  }
  
    static testMethod void testAssignAssessor() {
    system.runas(IRIS_Utility.CreateUserForTestMethods()){
      createTestData();
        // verify that the submission is assigned to a queue
        IRIS_Submission__c oSub = [Select ownerId, COE_Assessor__c, Status__c from IRIS_Submission__c where id=: oSubmission.id];
        String sOwnerId = oSub.ownerId;
        System.assert(!sOwnerId.startsWith('005'));
        System.assertEquals(osub.COE_Assessor__c , null);
        System.assertNotEquals(oSub.Status__c , Iris_Constants.SUBMISSION_STATUS_IN_PROGRESS);
        
        // now assign the submission to Assessor by updating the owner id
        User assessor = Iris_Test_Setup.newAssessorUser();
        oSub.OwnerId = assessor.id;
        update oSub;
        
        // verify that the owner has changed and the COE Assessor has been assigned
        oSub = [Select ownerId, COE_Assessor__c, Status__c from IRIS_Submission__c where id=: oSubmission.id];
        sOwnerId = oSub.ownerId;
        System.assert(sOwnerId.startsWith('005'));
        System.assertEquals(osub.COE_Assessor__c , assessor.id);
        System.assertEquals(oSub.Status__c , Iris_Constants.SUBMISSION_STATUS_IN_PROGRESS);
    }
    }
}