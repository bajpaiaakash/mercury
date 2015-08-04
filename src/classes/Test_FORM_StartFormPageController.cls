/* Class Name  : Test_FORM_StartFormPageController
* Description  : Test Class for FORM_StartFormPageController
* Created By   : Goutham
* Created Date : 4/11/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

@isTest  (SeeAllData = false)
public class Test_FORM_StartFormPageController{

    // Test for successful Form execution creation as template is active and requires no approval
    static testMethod void StartFormPageControllerPositiveTest() {
    
      //System.runAs(FORM_DataFactory.createUser('FORM Form Executor')) {
      Test.startTest();
        
        //Inserting a Form templated Record
        List<GLBL_Form_Template__c> lTemplates = FORM_DataFactory.createTemplates(1);        
        
        //Initialising the controller and adding attributes to resume form URL
        apexpages.standardcontroller stdCntrlr = new apexpages.standardController(lTemplates[0]);
        PageReference formPage = Page.FORM_StartFormPage;
            formPage.getParameters().put('id', lTemplates[0].id);
            formPage.getParameters().putAll(ApexPages.currentPage().getParameters());
        test.setCurrentPage(formPage);
                        
        FORM_StartFormPageController startForm = New FORM_StartFormPageController(stdCntrlr);
        
        //Calling the Resume form method
        PageReference pgRef = startForm.init();
        system.debug('*** PgRef' + pgRef);
        
        // Assert to check if the Page is redirected to Form execution page 
        system.assert(pgRef.getURL().contains('form_formexecutionpage'));
        system.assert(pgRef.getURl().contains(lTemplates[0].id));
        
        
                    
      Test.stopTest();
    }
    
    // Test for redirection to access denied page when template is inactive 
    static testMethod void StartFormPageControllerNegativeTest() {
    
        //System.runAs(FORM_DataFactory.createUser('FORM Form Executor')) { 
        //Inserting a Form templated Record
        List<GLBL_Form_Template__c> lTemplates = FORM_DataFactory.createTemplates(1);
        lTemplates[0].Status__c='Draft';
        update lTemplates;
        
     Test.startTest();           
        //Initialising the controller and adding attributes to resume form URL
        apexpages.standardcontroller stdCntrlr = new apexpages.standardController(lTemplates[0]);
        PageReference formPage = Page.FORM_StartFormPage;
            formPage.getParameters().put('id', lTemplates[0].id);
            formPage.getParameters().putAll(ApexPages.currentPage().getParameters());
        test.setCurrentPage(formPage);
                        
        FORM_StartFormPageController startForm = New FORM_StartFormPageController(stdCntrlr);
        
        //Calling the Resume form method
        PageReference pgRef = startForm.init();
        system.debug('*** PgRef' + pgRef);
        
        // Assert to check if the Page is redirected to Form execution page 
        system.assert(pgRef.getURL().contains('form_accessdeniedpage'));
               
        
                    
      Test.stopTest();
    }
}