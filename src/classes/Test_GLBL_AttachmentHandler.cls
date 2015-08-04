/* Test class for Attachment handler class */

@isTest(seeAllData = false)
public with sharing class Test_GLBL_AttachmentHandler {
	
	public static testmethod void testUploadLogoImage(){
		
		//Create form template 
        List<GLBL_Form_Template__c> lstFrmTemplates = FORM_DataFactory.createTemplates(1);
        lstFrmTemplates[0].Approval_Status__c = FORM_Constants.APPROVAL_STATUS_IN_PROGRESS ;
        update lstFrmTemplates[0];
        
        //Initially the template's Logo_Image__c is null
        system.assertEquals(null, lstFrmTemplates[0].Logo_Image__c);
        
        //Create attachment settings to simulate presence of custom settings
        GLBL_AttachmentImageSettings__c attachSetting = FORM_DataFactory.createAttachmentSettings();
        
        //Setting URL parameters
        pageReference formPage = Page.GLBL_AttachmentPage;
        formPage.getParameters().put('ParentID', lstFrmTemplates[0].id);
        formPage.getParameters().put('Parentname', lstFrmTemplates[0].name);
        formPage.getParameters().put('ParentType', 'GLBL_Form_Template__c');
        formPage.getParameters().put('ParentURLField', 'Logo_Image__c');
        formPage.getParameters().putAll(ApexPages.currentPage().getParameters());
        test.setCurrentPage(formPage);
        
        //Calling Constructor
        GLBL_AttachmentHandler testHandler = new GLBL_AttachmentHandler();
        testHandler.getAttSettings();
        
        //Attachment to be inserted
        Blob b = Blob.valueOf('Test Data');       
    	Attachment attachment = new Attachment();      
    	attachment.Name = 'Test Attachment for Parent';  
    	attachment.Body = b;  
        testHandler.NewAttach = attachment;
        
        testHandler.saveNewImage();
        testHandler.cancel();
        
               
        GLBL_Form_Template__c updFrmTemplate = [SELECT id,name,Logo_Image__c
                                                FROM GLBL_Form_Template__c
                                                WHERE name =: lstFrmTemplates[0].name ];
        // After the attachment operation the field Logo Image gets updated with the URL i.e. no longer null
        system.assertNotEquals('', lstFrmTemplates[0].Logo_Image__c);
                                                
        system.debug('+++updFrmTemplate' + updFrmTemplate.Logo_Image__c);
        
        
        
	}
    
    public static testmethod void testUploadResponseImage(){
		
		//Create form template 
        List<GLBL_Form_Template__c> lstFrmTemplates = FORM_DataFactory.createTemplates(1);
        lstFrmTemplates[0].Approval_Status__c = FORM_Constants.APPROVAL_STATUS_IN_PROGRESS ;
        update lstFrmTemplates[0];
        
        // create few questions of various type
        List<GLBL_Form_Template_Question__c> lstFrmCurrencyQuestions = FORM_DataFactory.createCurrencyQuestions(2,lstFrmTemplates[0]);
        List<GLBL_Form_Template_Question__c> lstFrmFreeTextQuestions = FORM_DataFactory.createFreeTextQuestions(2,lstFrmTemplates[0]);
        lstFrmFreeTextQuestions[0].Attachment_Allowed__c = True;
        update lstFrmFreeTextQuestions[0]; // Allowing attachments for certain questions
        
        List<GLBL_Form_Template_Question__c> lstFrmNumberQuestions   = FORM_DataFactory.createNumberQuestions(2,lstFrmTemplates[0]);
        List<GLBL_Form_Template_Question__c> lstFrmPicklistQuestions   = FORM_DataFactory.createPicklistQuestions(1,lstFrmTemplates[0]);
        
        //create options for picklist question
        List<GLBL_Form_Template_Answer_Option__c> lstFrmPicklistQuestionOptions = FORM_DataFactory.createAnswerOptions(4,lstFrmPicklistQuestions[0]);       
        
        // create form executions
        List<GLBL_Form_Execution__c> lstFrmExecutions = FORM_DataFactory.createExecutions(1,lstFrmTemplates[0]);        
            
        //create form execution question answers
        List<GLBL_Form_Template_Question__c> masterLstFrmQuestions = new list<GLBL_Form_Template_Question__c>();
        masterLstFrmQuestions.addall(lstFrmCurrencyQuestions);
        masterLstFrmQuestions.addall(lstFrmFreeTextQuestions);
        masterLstFrmQuestions.addall(lstFrmNumberQuestions);
        masterLstFrmQuestions.addall(lstFrmPicklistQuestions);
            
        List<GLBL_Form_Execution_Question_Answer__c> lstFrmExecQuestionAnswer = new List<GLBL_Form_Execution_Question_Answer__c>();
        GLBL_Form_Execution_Question_Answer__c testFrmExecQA = new GLBL_Form_Execution_Question_Answer__c();
        
	    
        for(GLBL_Form_Template_Question__c frmQuest : masterLstFrmQuestions){
            GLBL_Form_Execution_Question_Answer__c frmExecQA = FORM_DataFactory.createFormExecutionQuestionAnswer(lstFrmExecutions[0],frmQuest);
            lstFrmExecQuestionAnswer.add(frmExecQA);
            if(frmExecQA.Attachment_Allowed__c == true){
            	 testFrmExecQA = frmExecQA;
            	 //Setting URL parameters
			     pageReference formPage = Page.GLBL_AttachmentPage;
			     formPage.getParameters().put('ParentID', frmExecQA.id);
			     formPage.getParameters().put('Parentname', frmExecQA.name);
			     formPage.getParameters().put('ParentType', 'GLBL_Form_Execution_Question_Answer__c');
			        
			     //create return URL to return to Form Execution
			     String returnURL = '/apex/FORM_ResumeFormPage?id='+lstFrmExecutions[0].id;
			     formPage.getParameters().put('retURL', returnURL);
			                
			     formPage.getParameters().putAll(ApexPages.currentPage().getParameters());
			     test.setCurrentPage(formPage);
			        
			     //Calling Constructor
	   			 GLBL_AttachmentHandler testHandler = new GLBL_AttachmentHandler();
	   			 
			     testHandler.getAttSettings();
			        
			     //Attachment to be inserted
			     Blob b = Blob.valueOf('Test Data');       
			     Attachment attachment = new Attachment();      
			     attachment.Name = 'Test Attachment for Parent';  
			     attachment.Body = b;  
			     testHandler.NewAttach = attachment;
			        
			     testHandler.saveNewImage();
			        
			     List<Attachment> lattachment = [SELECT id,parentid,name FROM Attachment  WHERE parentid = : frmExecQA.id];
			     System.debug('++++lattachment.size()' + lattachment.size());
			     system.assertequals(lattachment.size(),1);
			     testHandler.cancel();
            }
        }
        
        
        
        
	}
    
}