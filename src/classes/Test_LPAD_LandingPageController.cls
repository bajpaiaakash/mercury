/*
*@ Class Name                                                    : Test_LPAD_LandingPageController
*@ Description                                                   : Test class for Landing page that displays chatter feed of the chatter group
																   configured in LPAD custom settings 																   
*@ CreatedBy                                                     : Jayalakshmi Mohananpillai
*@ CreatedOn                                                     : 09-10-2014
*@ Modification Log                                              :                                      
*/

@istest(seeAllData=false)
public with sharing class Test_LPAD_LandingPageController {
	
	/* 
          * @Method Name                    :  testLandingPageFeedPositive 
          * @Description                    :  Method to test chatter feed on landing page which would be the feed of chatter group configured
          * @Return Type                    :  void
          * @Param                          :  
                                            
    */ 
	public static testmethod void testLandingPageFeedPositive(){
		
	    
	    //Create Lpad User
	    User LpadUser1 = GLBL_TestDataUtilityClass.createLPADUser();
	    
	    Test.startTest();
	    
	    system.runAs(LpadUser1){
	    	    LPAD_Settings__c lpadSettings = GLBL_TestDataUtilityClass.createLPADSettingsDataForTest();
	    		insert lpadSettings;
	        	PageReference PageRef = Page.LPAD_LandingPage;
	        	Test.setcurrentPage(PageRef);
	        	LPAD_LandingPageController landingCntrl = new LPAD_LandingPageController();       	
	        	
	       		landingCntrl.init();         
	       		
	       		system.assertEquals(landingCntrl.feedId,'test grp');   
	        }	
	    
	    Test.stopTest();
	}
	
	/* 
          * @Method Name                    :  testLandingPageFeedNegative 
          * @Description                    :  Method to test chatter feed on landing page which would be the feed of logged in user
                                               if the system is unable to find any records in LPAD custom settings
          * @Return Type                    :  void
          * @Param                          :  
                                            
    */ 
	public static testmethod void testLandingPageFeedNegative(){
		LPAD_Settings__c lpadSettings = GLBL_TestDataUtilityClass.createLPADSettingsDataForTest();	    
	    
	    //Create Lpad User
	    User LpadUser1 = GLBL_TestDataUtilityClass.createLPADUser();
	    
	    Test.startTest();
	    
	    system.runAs(LpadUser1){
	        	PageReference PageRef = Page.LPAD_LandingPage;
	        	Test.setcurrentPage(PageRef);
	        	LPAD_LandingPageController landingCntrl = new LPAD_LandingPageController();       	
	        	
	       		landingCntrl.init();         
	       		
	       		system.assertEquals(landingCntrl.feedId, LpadUser1.id);   
	        }	
	    
	    Test.stopTest();
	}
}