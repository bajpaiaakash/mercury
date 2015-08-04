/* Class Name  : Test_FORM_ResumeFormPageController
* Description  : Test Class for FORM_ResumeFormPageController
* Created By   : Goutham
* Created Date : 4/11/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

@isTest  (SeeAllData = false)
public class Test_FORM_ResumeFormPageController{

    static testMethod void ResumeFormPageController() {
    
    //System.runAs(FORM_DataFactory.createUser('FORM Form Executor')) {
      Test.startTest();
        
        //Inserting a Form templated Record
        List<GLBL_Form_Template__c> lTemplates = FORM_DataFactory.createTemplates(1);
        
        //Inserting a Form Execution record with sstatus equals to 'In Progress'
        List<GLBL_Form_Execution__c> lExecutions = FORM_DataFactory.createExecutions(1,lTemplates[0]);
        lExecutions[0].Execution_Status__c=FORM_Constants.APPROVAL_STATUS_IN_PROGRESS; 
        Update lExecutions;
        
        //Initialising the controller and adding attributes to resume form URL
        apexpages.standardcontroller stdCntrlr = new apexpages.standardController(lExecutions[0]);
        PageReference formPage = Page.FORM_FormExecutionPage;
            formPage.getParameters().put('templateId', lTemplates[0].id);
            formPage.getParameters().put('id', lExecutions[0].Id);
            formPage.getParameters().put('executionId', lExecutions[0].Id);
            formPage.getParameters().putAll(ApexPages.currentPage().getParameters());
        test.setCurrentPage(formPage);
                        
        FORM_ResumeFormPageController  resumeForm = New FORM_ResumeFormPageController(stdCntrlr);
        
        //Calling the Resume form method
        resumeForm.init();
        
        //Assert statement to check if the URL returned in resume form contoller and the URL passed is same or not      
        system.assertEquals(resumeForm.init().getURl(),formPage.getURL(),TRUE);
        
        //Updating the execution record to 'complete' to so that user is redirected to Access denied page
        lExecutions[0].Execution_Status__c=FORM_Constants.APPROVAL_STATUS_COMPLETE; 
        Update lExecutions;
        PageReference accessDeniedPage = Page.FORM_AccessDeniedPage;
        resumeForm.init();
        system.assertEquals(resumeForm.init().getURl(),accessDeniedPage.getURL(),TRUE);

        //Updating the execution record to 'Cancelled' to so that user is redirected to Access denied page        
        lExecutions[0].Execution_Status__c=FORM_Constants.APPROVAL_STATUS_CANCELLED; 
        Update lExecutions;
        resumeForm.init();
        system.assertEquals(resumeForm.init().getURl(),accessDeniedPage.getURL(),TRUE);
                    
      Test.stopTest();
    }
}