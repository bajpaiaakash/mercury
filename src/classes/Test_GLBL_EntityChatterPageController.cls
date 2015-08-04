/*
*@ Class Name                                                    : Test_GLBL_EntityChatterPageController
*@ Description                                                   : Test class for a chatter page that acts like a universal chatter feed
 																   container which fetches out the chatteer feed based upon the object id supplied
*@ CreatedBy                                                     : Jayalakshmi Mohananpillai
*@ CreatedOn                                                     : 09-10-2014
*@ Modification Log                                              :                                      
*/


@istest(seeAllData=false)
public with sharing class Test_GLBL_EntityChatterPageController {
	
	
    
    
    /* 
          * @Method Name                    :  testEntityChatterFeedPositive 
          * @Description                    :  Method to test chatterfeed display by passing the entity Id
          * @Return Type                    :  void
          * @Param                          :  
                                            
    */  
    public static testmethod void testEntityChatterFeedPositive(){
    	
    	//Create Lpad User
    	User LpadUser1 = GLBL_TestDataUtilityClass.createLPADUser(); 
		
        system.runAs(LpadUser1){
        	// Creating Form Template, To avoid mixed DML exception keeping this insert inside runas method	
			GLBL_Form_Template__c  formTempTest = GLBL_TestDataUtilityClass.createFormTemplateForTest();
			insert formTempTest;
			
        	PageReference PageRef = Page.GLBL_EntityChatterPage;
        	Test.setcurrentPage(PageRef);
        	GLBL_EntityChatterPageController entChatterFeedCntrl = new GLBL_EntityChatterPageController();
        	
        	// Add parameters to page URL
       		ApexPages.currentPage().getParameters().put('id', formTempTest.id);
            entChatterFeedCntrl.getEntityId();
        }
    }
    
    /* 
          * @Method Name                    :  testEntityChatterFeedNegative
          * @Description                    :  Method to test chatterfeed display by without passing the entity Id
          * @Return Type                    :  void
          * @Param                          :  
                                            
    */  
    public static testmethod void testEntityChatterFeedNegative(){
    	
    	//Create Lpad User
    	User LpadUser1 = GLBL_TestDataUtilityClass.createLPADUser();
		
        system.runAs(LpadUser1){
        	// Creating Form Template	
			GLBL_Form_Template__c  formTempTest = GLBL_TestDataUtilityClass.createFormTemplateForTest();
			insert formTempTest;
			
        	PageReference PageRef = Page.GLBL_EntityChatterPage;
        	Test.setcurrentPage(PageRef);
        	GLBL_EntityChatterPageController entChatterFeedCntrl = new GLBL_EntityChatterPageController();
        	
        	// Add parameters to page URL
       		//ApexPages.currentPage().getParameters().put('id', formTempTest.id);
            entChatterFeedCntrl.getEntityId();
        }
    }
    
}