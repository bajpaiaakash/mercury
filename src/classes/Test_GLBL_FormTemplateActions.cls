/*
*@ Class Name                                                    : Test_GLBL_FormTemplateActions
*@ Description                                                   : Test Class for form assessments including LaunchPad
*@ CreatedBy                                                     : Deloitte Consulting
*@ CreatedOn                                                     : 08-21-2014
*@ Modification Log                                              :                                      
*/

@istest(seeAllData=false)
public with sharing class Test_GLBL_FormTemplateActions {
    
    /* 
          * @Method Name                    :  testCreateformExecution 
          * @Description                    :  Method to test createformExecution; by asserting the number of formExecutionQuestionAnswer
                                               records created is same as number of template Question and form execution object getting added
          * @Return Type                    :  void
          * @Param                          :  
                                            
    */
    public static testmethod void testPositiveCreateformExecution(){    
         user testuser = GLBL_TestDataUtilityClass.createLPADUser();
         system.runas(testuser){
        // Creating Form Template   
        GLBL_Form_Template__c  formTempTest = GLBL_TestDataUtilityClass.createFormTemplateForTest();
        insert formTempTest;
        
        // Variable to hold list of Template questions
        List<GLBL_Form_Template_Question__c> listFormTempQuest = new List<GLBL_Form_Template_Question__c>();
        
        // Creating form Template Question
        for (integer i=0; i<100; i++){
             GLBL_Form_Template_Question__c formTempQst = GLBL_TestDataUtilityClass.createFormTemplateQuestionForTest(formTempTest.id);
             listFormTempQuest.add(formTempQst);
        } 
        insert listFormTempQuest;
        
        Test.startTest();
            GLBL_FormTemplateActions formTemplateAct = new GLBL_FormTemplateActions();
            formTemplateAct.createFormExecution(formTempTest);      
            system.assertEquals(formTemplateAct.listFormExecQuestionAnswer.size(),100);
            system.assertNotEquals(formTemplateAct.formExecution,null);     
        Test.stopTest();
        
     }
    }
    
    /* 
          * @Method Name                    :  testCreateformExecution 
          * @Description                    :  Method to test createformExecution negative cases like simulating to get Query exception or DML exception
          * @Return Type                    :  void
          * @Param                          :  
                                            
    */
    public static testmethod void testNegativeCreateformExecution(){    
        
        user testuser = GLBL_TestDataUtilityClass.createLPADUser();
        system.runas(testuser){
        // Creating Form Template   
        GLBL_Form_Template__c  formTempTest = GLBL_TestDataUtilityClass.createFormTemplateForTest();
        
        Test.startTest();
            GLBL_FormTemplateActions formTemplateAct = new GLBL_FormTemplateActions();
            formTemplateAct.createFormExecution(formTempTest);      
            system.assertEquals(formTemplateAct.listFormExecQuestionAnswer.size(),0);
            system.assertEquals(formTemplateAct.formExecution.Source_Form__c,null);     
        Test.stopTest();
        }
    }
    

}