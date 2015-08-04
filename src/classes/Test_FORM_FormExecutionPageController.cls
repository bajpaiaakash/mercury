/* Test class for FORM_FormExecutingPageController */


@isTest(seeAllData = false)
public with sharing class Test_FORM_FormExecutionPageController {

    public static testmethod void testFormExecutionPage(){
        
        //create form template 
        List<GLBL_Form_Template__c> lstFrmTemplates = FORM_DataFactory.createTemplates(1);
        lstFrmTemplates[0].Approval_Status__c = FORM_Constants.APPROVAL_STATUS ;
        update lstFrmTemplates[0];
        
        // create few questions of various type
        List<GLBL_Form_Template_Question__c> lstFrmCurrencyQuestions = FORM_DataFactory.createCurrencyQuestions(2,lstFrmTemplates[0]);
        List<GLBL_Form_Template_Question__c> lstFrmFreeTextQuestions = FORM_DataFactory.createFreeTextQuestions(2,lstFrmTemplates[0]);
        List<GLBL_Form_Template_Question__c> lstFrmNumberQuestions   = FORM_DataFactory.createNumberQuestions(2,lstFrmTemplates[0]);
        List<GLBL_Form_Template_Question__c> lstFrmPicklistQuestions   = FORM_DataFactory.createPicklistQuestions(1,lstFrmTemplates[0]);
        
        //create options for picklist question
        List<GLBL_Form_Template_Answer_Option__c> lstFrmPicklistQuestionOptions = FORM_DataFactory.createAnswerOptions(4,lstFrmPicklistQuestions[0]);       
        
        //Execute form template as form Executor user
        //User frmExecutor = FORM_DataFactory.createUser('FORM_Form_Executor');
        
        //system.runas(frmExecutor){            
        // TO DO implement runas as the sharing class gets completed as for now templates are private and a from executor will not be able to execute it unless shared to them  
            
            // create form executions
            List<GLBL_Form_Execution__c> lstFrmExecutions = FORM_DataFactory.createExecutions(1,lstFrmTemplates[0]);
            system.debug('====lstFrmExecutions' + lstFrmExecutions);
            
            //create form execution question answers
            List<GLBL_Form_Template_Question__c> masterLstFrmQuestions = new list<GLBL_Form_Template_Question__c>();
            masterLstFrmQuestions.addall(lstFrmCurrencyQuestions);
            masterLstFrmQuestions.addall(lstFrmFreeTextQuestions);
            masterLstFrmQuestions.addall(lstFrmNumberQuestions);
            masterLstFrmQuestions.addall(lstFrmPicklistQuestions);
            
            List<GLBL_Form_Execution_Question_Answer__c> lstFrmExecQuestionAnswer = new List<GLBL_Form_Execution_Question_Answer__c>();
            for(GLBL_Form_Template_Question__c frmQuest : masterLstFrmQuestions){
                GLBL_Form_Execution_Question_Answer__c frmExecQA = FORM_DataFactory.createFormExecutionQuestionAnswer(lstFrmExecutions[0],frmQuest);
                lstFrmExecQuestionAnswer.add(frmExecQA);
            }
            
                        
            PageReference formPage = Page.FORM_FormExecutionPage;
            formPage.getParameters().put('templateId', lstFrmTemplates[0].id);
            formPage.getParameters().put('executionId', lstFrmExecutions[0].Id);
            formPage.getParameters().putAll(ApexPages.currentPage().getParameters());
            test.setCurrentPage(formPage);
            
            FORM_FormExecutionPageController formController = new FORM_FormExecutionPageController();
            
            //Testing Remote Method call
            FORM_FormExecutionPageController.remoteSaveAnswer('Ans',lstFrmExecQuestionAnswer[2].id);
            //testing whether answer is stamped or not
            GLBL_Form_Execution_Question_Answer__c frmQAnswerStamped = [SELECT id, Response_Text__c,Source_Question__c
                                                                        FROM GLBL_Form_Execution_Question_Answer__c
                                                                        WHERE id =: lstFrmExecQuestionAnswer[2].id];
            system.debug('++++ answer' + frmQAnswerStamped.Response_Text__c)  ;
                                                                    
            //system.assertEquals('AnswerFreeText',frmQAnswerStamped.Response_Text__c);
                                                                        
            //Saving the form
            formController.SaveForm();
            system.assertEquals(true,formController.isFormSaved);
            
            //Cancel the form
            formController.cancelForm();
            system.assertEquals(true,formController.isFormcancelled);
            system.assertEquals( FORM_Constants.APPROVAL_STATUS_CANCELLED, formController.formExecution.Execution_Status__c);
            
            //Submit the form
            formController.submitForm();
            system.assertEquals(true,formController.isFormSubmitted);
            system.assertEquals( FORM_Constants.APPROVAL_STATUS_COMPLETE, formController.formExecution.Execution_Status__c);
            
            
        //}
    }
}