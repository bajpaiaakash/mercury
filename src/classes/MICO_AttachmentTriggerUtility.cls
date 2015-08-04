/*************************************************************************\
    @ Author        : Nitish Kumar
    @ Date          : 22-Aug-2014
    @ Test Class    : 
    @ Description   : The helper class for MICO_AttachmentTrigger.
****************************************************************************/
public with sharing class MICO_AttachmentTriggerUtility {

    /*********************************************************************************************************************
          Method : checkAttachmentonTSStep
          Input Parameters : Set of Id of Test Script Step and map containing the parent id and attachment
          Description : This method will be used to stop the deletion of attachment if the test script has been approved    
         ********************************************************************************************************************/

    public static void checkAttachmentonTSStep(Set < Id > setTestScriptStep, map < Id, Attachment > mapTestScriptStep) {

        //getting the Test Script Step records
        list < MICO_Test_Template_Steps__c > lstTestScriptStep = [Select id, Test_Script__r.Approval_Status__c from MICO_Test_Template_Steps__c where Id IN: setTestScriptStep];

        for (MICO_Test_Template_Steps__c testScriptStep: lstTestScriptStep) {
            if ((testScriptStep.Test_Script__r.Approval_Status__c == 'Approved' || testScriptStep.Test_Script__r.Approval_Status__c == 'Pending Approval') && mapTestScriptStep.containsKey(testScriptStep.id)) {
                //adding the error message if the Test Script has been approved
                mapTestScriptStep.get(testScriptStep.id).addError(Label.MICO_Error_On_Test_Script);
            }
        }
    }

    /*********************************************************************************************************************
          Method : checkAttachmentonTExecution
          Input Parameters : Set of Id of Test Execution and map containing the parent id and attachment
          Description : This method will be used to stop the deletion of attachment if the test script has been approved    
        ********************************************************************************************************************/

    public static void checkAttachmentonTExecution(Set < Id > setTestExecution, map < Id, Attachment > mapTestExecution) {

        //getting the Test Execution records
        list < MICO_Test__c > lstTestExecution = [Select id, Approval_Status__c from MICO_Test__c where Id IN: setTestExecution];

        for (MICO_Test__c testExecution: lstTestExecution) {
            if ((testExecution.Approval_Status__c == 'Approved' || testExecution.Approval_Status__c == 'Pending Approval' ) && mapTestExecution.containsKey(testExecution.id)) {
                //adding the error message if the Test Script has been approved
                mapTestExecution.get(testExecution.id).addError(Label.MICO_Error_On_Test_Execution);
            }
        }
    }

    /*********************************************************************************************************************
       Method : checkAttachmentonTExecutionStep
       Input Parameters : Set of Id of Test Execution Step and map containing the parent id and attachment
       Description : This method will be used to stop the deletion of attachment if the test script has been approved    
     ********************************************************************************************************************/

    public static void checkAttachmentonTExecutionStep(Set < Id > setTestExecutionStep, map < Id, Attachment > mapTestExecutionStep) {

        //getting the Test Execution Step records
        list < MICO_Test_Steps__c > lstTestExecutionStep = [Select id, Test__r.Approval_Status__c from MICO_Test_Steps__c where Id IN: setTestExecutionStep];

        for (MICO_Test_Steps__c testExecutionStep: lstTestExecutionStep) {
            if ((testExecutionStep.Test__r.Approval_Status__c == 'Approved' || testExecutionStep.Test__r.Approval_Status__c == 'Pending Approval')  && mapTestExecutionStep.containsKey(testExecutionStep.id)) {
                //adding the error message if the Test Script has been approved
                mapTestExecutionStep.get(testExecutionStep.id).addError(Label.MICO_Error_On_Test_Execution_Step);
            }
        }

    }

}