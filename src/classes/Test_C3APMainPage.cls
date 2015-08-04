/*
*@ Class Name                                                    : Test_C3APMainPage
*@ Description                                                   : Test Class for C3APMainPage extension 
*@ CreatedBy                                                     : Deloitte Consulting
*@ CreatedOn                                                     : 09-22-2014
*@ Modification Log                                              :                     
*/

@istest(seeAllData=false)
public with sharing class Test_C3APMainPage {

    /* 
            * @Method Name                    :  testSelectAffiliate
            * @Description                    :  Tests the affiliate options picklist population
            									 and home page redirection methods of the C3 Homepage
            * @Return Type                    :  void
            * @Param                          :                                               
    */
    
     public static testMethod void testSelectAffiliate(){
         List<C3AP_Affiliate__c> affiliateList = Test_C3AP_TestData_Utility.createAffiliate(3);
         insert affiliateList;
         List <Attachment> attachLst = Test_C3AP_TestData_Utility.createAffAttachments(affiliateList[0]);
         insert attachLst;
         ApexPages.StandardController C3APHomePage = new ApexPages.standardController(affiliateList[0]);  
         PageReference testPage = Page.C3AP_Home_Page;
         test.setCurrentPage(testPage);
         C3APMainPage aTestHomePage = new C3APMainPage(C3APHomePage);         
         Test.StartTest();      
              System.assertNotEquals(aTestHomePage.getoptionlist().size(),0); 
              List<C3AP_Affiliate__c> affLst= [SELECT id, name from C3AP_Affiliate__c WHERE id=: affiliateList[0].id];
              aTestHomePage.listvalue=affLst[0].id;
              aTestHomePage.homepage();
              PageReference pg2=aTestHomePage.newContract();
              System.assertNotEquals(pg2,null);           
         Test.StopTest();      
     }   
     
     /* 
            * @Method Name                    :  testSearchContracts
            * @Description                    :  Tests the affiliate options picklist population
            									 and new contract page redirection methods of the C3 Homepage
            * @Return Type                    :  void
            * @Param                          :                                               
    */
    
     public static testMethod void testSearchContracts(){
         List<C3AP_Affiliate__c> affiliateList = Test_C3AP_TestData_Utility.createAffiliate(3);
         insert affiliateList;
         List <Attachment> attachLst = Test_C3AP_TestData_Utility.createAffAttachments(affiliateList[0]);
         insert attachLst;
         ApexPages.StandardController C3APHomePage = new ApexPages.standardController(affiliateList[0]);  
         PageReference testPage = Page.C3AP_Home_Page;
         test.setCurrentPage(testPage);
         C3APMainPage aTestHomePage = new C3APMainPage(C3APHomePage);         
         Test.StartTest(); 
              System.assertNotEquals(aTestHomePage.getoptionlist().size(),0);          
              List<C3AP_Affiliate__c> affLst= [SELECT id, name from C3AP_Affiliate__c WHERE id=: affiliateList[0].id];
              aTestHomePage.listvalue=affLst[0].id;
              aTestHomePage.homepage();
              PageReference pg2=aTestHomePage.searchContract();
              System.assertNotEquals(pg2,null);           
         Test.StopTest();      
     }           


}