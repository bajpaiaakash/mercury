/* Class Name  : Test_FORM_ExecutorSharingPageController 
* Description  : Test Class for FORM_ExecutorSharingPageController
* Created By   : Goutham
* Created Date : 12/11/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

@isTest  (SeeAllData = false)
public class Test_FORM_ExecutorSharingPageController{

    static testMethod void ExecutorSharingPageController() {
           
        Test.startTest();
          
          //Inserting a Form template Record
            List<GLBL_Form_Template__c> lTemplates = FORM_DataFactory.createTemplates(1);
            
             //Initialising the controller and adding attributes to resume form URL
            apexpages.standardcontroller stdCntrlr = new apexpages.standardController(lTemplates[0]);
            PageReference formPage = Page.FORM_FormExecutionPage;
                formPage.getParameters().put('id', lTemplates[0].id);
                formPage.getParameters().putAll(ApexPages.currentPage().getParameters());
            test.setCurrentPage(formPage);
                            
            FORM_ExecutorSharingPageController executorShare = New FORM_ExecutorSharingPageController (stdCntrlr);
            
            //Calling the share method
            executorShare.init();            
            
            //Updating the template record to approval required status
            lTemplates[0].Approval_Required__c=TRUE;
            lTemplates[0].Approval_Status__c=FORM_Constants.APPROVAL_STATUS_NOT_APPROVED ; 
            Update lTemplates;
            PageReference accessDeniedPage = Page.FORM_AccessDeniedPage;
            executorShare.init();
            
            system.assertEquals(executorShare.init().getURl(),accessDeniedPage.getURL(),TRUE);
                                     
        Test.stopTest();       
    }
}