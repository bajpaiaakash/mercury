/*
*@ Class Name                                                    : Test_LPAD_AssessmentPageController
*@ Description                                                   : Test class for Assessment Page 																   
*@ CreatedBy                                                     : Jayalakshmi Mohananpillai
*@ CreatedOn                                                     : 09-10-2014
*@ Modification Log                                              :                                      
*/

@isTest(seeAllData=false)
public with sharing class Test_LPAD_AssessmentPageController {
	
	/* 
          * @Method Name                    :  testAssessmentPage
          * @Description                    :  Method to test assessment page functionality
          * @Return Type                    :  void
          * @Param                          :  
                                            
    */ 
    public static testmethod void testAssessmentPage(){
    	
    	//Create Lpad User
    	User LpadUser1 = GLBL_TestDataUtilityClass.createLPADUser();
    	
    	
        
    	
    	system.runas(LpadUser1){
    		
	    	// Creating Form Template	
			GLBL_Form_Template__c  formTempTest = GLBL_TestDataUtilityClass.createFormTemplateForTest();
			insert formTempTest;
		    
		    // Variable to hold list of Template questions
	        List<GLBL_Form_Template_Question__c> listFormTempQuest = new List<GLBL_Form_Template_Question__c>();
	        
			// Creating form Template Question
	        for (integer i=0; i<10; i++){
	             GLBL_Form_Template_Question__c formTempQst = GLBL_TestDataUtilityClass.createFormTemplateQuestionForTest(formTempTest.id);
	             listFormTempQuest.add(formTempQst);
	        } 
	        insert listFormTempQuest;
	        
	        // Variable to hold list of answer options per question
	        List<GLBL_Form_Template_Answer_Option__c> listformTempAns = new list<GLBL_Form_Template_Answer_Option__c>();
	        //Creating Answer options
	        for(GLBL_Form_Template_Question__c formQuest : listFormTempQuest){
	        	for(integer j=0; j<3; j++){
	        		GLBL_Form_Template_Answer_Option__c formTempAns = GLBL_TestDataUtilityClass.createFormTemplateAnswerOptionForTest(formQuest.id);
	        		formTempAns.Answer_option__c = 'Sample';
	        		formTempAns.Score_A__c = '1';
	        		formTempAns.Score_B__c = '2' ;
	        		formTempAns.Score_C__c = '3';
	        		formTempAns.Score_D__c = '4';
	        		formTempAns.Score_E__c = '5';
	        		listformTempAns.add(formTempAns);
	        	}
	        }        
	        insert listformTempAns;
	        
	        Test.startTest();
	    		LPAD_AssessmentPageController assessCntrl = new LPAD_AssessmentPageController();
	    		List<GLBL_Form_Template_Question__c> listformTempQuestions = assessCntrl.fetchlistFormTemplateQuestion();
	    		//fetches the active questions in the form template that is active in the org
	    		system.assertequals(listformTempQuestions.size(),listFormTempQuest.size());
	    		system.assertequals(assessCntrl.mapSelectOption.size(),listFormTempQuest.size());
	    		
	    		assessCntrl.nameproject = 'ScoreE Project';
	    		
	    		assessCntrl.ans = 'Sample';
	    		assessCntrl.QuestionIDNew = listFormTempQuest[0].id;	    		
	    		assessCntrl.renderHelpAndCalculate();	    		
	    		
	    		// End user chooses answer equal to none
	    		assessCntrl.ans = 'None';
	    		assessCntrl.QuestionIDNew = listFormTempQuest[1].id;
	    		assessCntrl.renderHelpAndCalculate();
	    		
	    		assessCntrl.createProjectonSubmit();
	    		/* assert to check that the max score is for Area E hence its associated assessment 
	    		   results from custom label gets displayed to end user taking the assessment */
	    		system.assertEquals(assessCntrl.assessmentResultMessage,System.Label.LPAD_AssessmentPage_Result_Message_for_non_Force);
	    		system.assertEquals(assessCntrl.assessmentResultHeading,System.Label.LPAD_AssessmentPage_Score_E_Result_Heading);
	    		
	    		/* assert to check whether a project with the name supplied as is created on assessment submission */
	    		MICO_Project__c projectCreated = [Select id,Name FROM MICO_Project__c WHERE Name =: 'ScoreE Project' ];
	    		system.assertEquals(projectCreated.Name,assessCntrl.nameproject);
	    		 
	    	Test.stopTest();
    		
    	}
    	
    	
    } 
    
    
    /* 
          * @Method Name                    :  testAssessmentPageScoreAMax
          * @Description                    :  Method to test assessment page functionality
          * @Return Type                    :  void
          * @Param                          :  
                                            
    */ 
    public static testmethod void testAssessmentPageScoreAMax(){
    	
    	//Create Lpad User
    	User LpadUser1 = GLBL_TestDataUtilityClass.createLPADUser();
    	
    	
        
    	
    	system.runas(LpadUser1){
    		
	    	// Creating Form Template	
			GLBL_Form_Template__c  formTempTest = GLBL_TestDataUtilityClass.createFormTemplateForTest();
			insert formTempTest;
		    
		    // Variable to hold list of Template questions
	        List<GLBL_Form_Template_Question__c> listFormTempQuest = new List<GLBL_Form_Template_Question__c>();
	        
			// Creating form Template Question
	        for (integer i=0; i<10; i++){
	             GLBL_Form_Template_Question__c formTempQst = GLBL_TestDataUtilityClass.createFormTemplateQuestionForTest(formTempTest.id);
	             listFormTempQuest.add(formTempQst);
	        } 
	        insert listFormTempQuest;
	        
	        // Variable to hold list of answer options per question
	        List<GLBL_Form_Template_Answer_Option__c> listformTempAns = new list<GLBL_Form_Template_Answer_Option__c>();
	        //Creating Answer options
	        for(GLBL_Form_Template_Question__c formQuest : listFormTempQuest){
	        	for(integer j=0; j<3; j++){
	        		GLBL_Form_Template_Answer_Option__c formTempAns = GLBL_TestDataUtilityClass.createFormTemplateAnswerOptionForTest(formQuest.id);
	        		formTempAns.Answer_option__c = 'Sample';
	        		formTempAns.Score_A__c = '5';
	        		formTempAns.Score_B__c = '4' ;
	        		formTempAns.Score_C__c = '3';
	        		formTempAns.Score_D__c = '2';
	        		formTempAns.Score_E__c = '1';
	        		listformTempAns.add(formTempAns);
	        	}
	        }        
	        insert listformTempAns;
	        
	        Test.startTest();
	    		LPAD_AssessmentPageController assessCntrl = new LPAD_AssessmentPageController();
	    		List<GLBL_Form_Template_Question__c> listformTempQuestions = assessCntrl.fetchlistFormTemplateQuestion();
	    		/*fetches the active questions in the form template that is active in the org : as many selectoption
	    		  records gets created as many question records supplied from form template */
	    		system.assertequals(listformTempQuestions.size(),listFormTempQuest.size());
	    		system.assertequals(assessCntrl.mapSelectOption.size(),listFormTempQuest.size());
	    		
	    		assessCntrl.nameproject = 'ScoreA Project';
	    		
	    		assessCntrl.ans = 'Sample';
	    		assessCntrl.QuestionIDNew = listFormTempQuest[0].id;	    		
	    		assessCntrl.renderHelpAndCalculate();	    		
	    		
	    		// End user chooses answer equal to none
	    		assessCntrl.ans = 'None';
	    		assessCntrl.QuestionIDNew = listFormTempQuest[1].id;
	    		assessCntrl.formTemplateAnswer = NULL;
	    		assessCntrl.renderHelpAndCalculate();
	    		
	    		assessCntrl.createProjectonSubmit();
	    		/* assert to check that the max score is for Area A hence its associated assessment 
	    		   results from custom label gets displayed to end user taking the assessment */
	    		system.assertEquals(assessCntrl.assessmentResultMessage,System.Label.LPAD_AssessmentPage_Result_Message_for_Force);
	    		system.assertEquals(assessCntrl.assessmentResultHeading,System.Label.LPAD_AssessmentPage_Score_A_Result_Heading);
	    		
	    		/* assert to check whether a project with the name supplied as is created on assessment submission */
	    		MICO_Project__c projectCreated = [Select id,Name FROM MICO_Project__c WHERE Name =: 'ScoreA Project' ];
	    		system.assertEquals(projectCreated.Name,assessCntrl.nameproject);
	    		 
	    	Test.stopTest();
    		
    	}
    }	
    
    /* 
          * @Method Name                    :  testAssessmentPageScoreCMax
          * @Description                    :  Method to test assessment page functionality
          * @Return Type                    :  void
          * @Param                          :  
                                            
    */ 
    public static testmethod void testAssessmentPageScoreCMax(){
    	
    	//Create Lpad User
    	User LpadUser1 = GLBL_TestDataUtilityClass.createLPADUser();
    	
    	
        
    	
    	system.runas(LpadUser1){
    		
	    	// Creating Form Template	
			GLBL_Form_Template__c  formTempTest = GLBL_TestDataUtilityClass.createFormTemplateForTest();
			insert formTempTest;
		    
		    // Variable to hold list of Template questions
	        List<GLBL_Form_Template_Question__c> listFormTempQuest = new List<GLBL_Form_Template_Question__c>();
	        
			// Creating form Template Question
	        for (integer i=0; i<10; i++){
	             GLBL_Form_Template_Question__c formTempQst = GLBL_TestDataUtilityClass.createFormTemplateQuestionForTest(formTempTest.id);
	             listFormTempQuest.add(formTempQst);
	        } 
	        insert listFormTempQuest;
	        
	        // Variable to hold list of answer options per question
	        List<GLBL_Form_Template_Answer_Option__c> listformTempAns = new list<GLBL_Form_Template_Answer_Option__c>();
	        //Creating Answer options
	        for(GLBL_Form_Template_Question__c formQuest : listFormTempQuest){
	        	for(integer j=0; j<3; j++){
	        		GLBL_Form_Template_Answer_Option__c formTempAns = GLBL_TestDataUtilityClass.createFormTemplateAnswerOptionForTest(formQuest.id);
	        		formTempAns.Answer_option__c = 'Sample';
	        		formTempAns.Score_A__c = '3';
	        		formTempAns.Score_B__c = '4' ;
	        		formTempAns.Score_C__c = '5';
	        		formTempAns.Score_D__c = '2';
	        		formTempAns.Score_E__c = '1';
	        		listformTempAns.add(formTempAns);
	        	}
	        }        
	        insert listformTempAns;
	        
	        Test.startTest();
	    		LPAD_AssessmentPageController assessCntrl = new LPAD_AssessmentPageController();
	    		List<GLBL_Form_Template_Question__c> listformTempQuestions = assessCntrl.fetchlistFormTemplateQuestion();
	    		//fetches the active questions in the form template that is active in the org
	    		system.assertequals(listformTempQuestions.size(),listFormTempQuest.size());
	    		system.assertequals(assessCntrl.mapSelectOption.size(),listFormTempQuest.size());
	    		
	    		assessCntrl.nameproject = 'ScoreC Project';
	    		
	    		assessCntrl.ans = 'Sample';
	    		assessCntrl.QuestionIDNew = listFormTempQuest[0].id;	    		
	    		assessCntrl.renderHelpAndCalculate();	    		
	    		
	    		// End user chooses answer equal to none
	    		assessCntrl.ans = 'None';
	    		assessCntrl.QuestionIDNew = listFormTempQuest[1].id;
	    		assessCntrl.formTemplateAnswer = NULL;
	    		assessCntrl.renderHelpAndCalculate();
	    		
	    		assessCntrl.createProjectonSubmit();
	    		/* assert to check that the max score is for Area C hence its associated assessment 
	    		   results from custom label gets displayed to end user taking the assessment */
	    		system.assertEquals(assessCntrl.assessmentResultMessage,System.Label.LPAD_AssessmentPage_Result_Message_for_non_Force);
	    		system.assertEquals(assessCntrl.assessmentResultHeading,System.Label.LPAD_AssessmentPage_Score_C_Result_Heading);
	    		
	    		/* assert to check whether a project with the name supplied as is created on assessment submission */
	    		MICO_Project__c projectCreated = [Select id,Name FROM MICO_Project__c WHERE Name =: 'ScoreC Project' ];
	    		system.assertEquals(projectCreated.Name,assessCntrl.nameproject);
	    		 
	    	Test.stopTest();
    		
    	}
    }	
}