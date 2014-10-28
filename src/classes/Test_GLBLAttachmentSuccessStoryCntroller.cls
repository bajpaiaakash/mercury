/*
*@ Class Name                                                    : Test_GLBLAttachmentSuccessStoryCntroller
*@ Description                                                   : Test class for attaching Icon Image/ Image on GSO_Content record of type Success story
*@ CreatedBy                                                     : Gaurav Suri
*@ CreatedOn                                                     : 08-25-2014
*@ Modification Log                                              : Added Test method to test type population using Process step Image on 09-10-2014                                      
*/

@istest(seeAllData=false)
public with sharing class Test_GLBLAttachmentSuccessStoryCntroller {
    
    /* 
          * @Method Name                    :  testtypepopulationIconImage
          * @Description                    :  Method to test typePopulation method using icon image.
          * @Return Type                    :  void
          * @Param                          :  
                                            
    */
    public static testmethod void testtypepopulationIconImage(){    
        user testuser = GLBL_TestDataUtilityClass.createLPADAdmin();
        system.runas(testuser){
        GLBL_GSO_Content__c  GSOContentTempTest = GLBL_TestDataUtilityClass.createGSOContentForTest();
        insert GSOContentTempTest;
        Attachment AttachmentTest = GLBL_TestDataUtilityClass.CreateAttachmentForTest(GSOContentTempTest.id);
        insert AttachmentTest;
        string idstring = GSOContentTempTest.id;
        idstring = idstring.substring(0,15)+'IconImage';
        Pagereference p = page.GLBL_AttachmentSuccessStory;
        System.Test.setCurrentPage(p);
        p.getParameters().put('id',idstring);
        GLBL_AttachmentSuccessStory_Controller controller = new GLBL_AttachmentSuccessStory_Controller();                     
        Test.startTest();
            controller.saveContent();      
        Test.stopTest();
        }
    }
    
     /* 
          * @Method Name                    :  testtypepopulationDetailImage
          * @Description                    :  Method to test typePopulation method using detail image
          * @Return Type                    :  void
          * @Param                          :  
                                            
    */
    
     public static testmethod void testtypepopulationDetailImage(){  
        user testuser = GLBL_TestDataUtilityClass.createLPADAdmin();
        system.runas(testuser){  
        GLBL_GSO_Content__c  GSOContentTempTest = GLBL_TestDataUtilityClass.createGSOContentForTest();
        insert GSOContentTempTest;
        Attachment AttachmentTest = GLBL_TestDataUtilityClass.CreateAttachmentForTest(GSOContentTempTest.id);
        insert AttachmentTest;
        string idstring = GSOContentTempTest.id;
        idstring = idstring.substring(0,15)+'DetailImage';
        Pagereference p = page.GLBL_AttachmentSuccessStory;
        System.Test.setCurrentPage(p);
        p.getParameters().put('id',idstring);
        GLBL_AttachmentSuccessStory_Controller controller = new GLBL_AttachmentSuccessStory_Controller();                     
        Test.startTest();
            controller.saveContent();      
        Test.stopTest();
       }
    }
    
    
    /* 
          * @Method Name                    :  testtypepopulationProcessImage
          * @Description                    :  Method to test typePopulation method using Process image.
          * @Return Type                    :  void
          * @Param                          :  
                                            
    */
    public static testmethod void testtypepopulationProcessImage(){   
        user testuser = GLBL_TestDataUtilityClass.createLPADAdmin();
        system.runas(testuser){ 
        GLBL_GSO_Content__c  GSOContentTempTest = GLBL_TestDataUtilityClass.createGSOContentForTest();
        insert GSOContentTempTest;
        Attachment AttachmentTest = GLBL_TestDataUtilityClass.CreateAttachmentForTest(GSOContentTempTest.id);
        insert AttachmentTest;
        string idstring = GSOContentTempTest.id;
        idstring = idstring.substring(0,15)+'ProcessStepImage';
        Pagereference p = page.GLBL_AttachmentSuccessStory;
        System.Test.setCurrentPage(p);
        p.getParameters().put('id',idstring);
        GLBL_AttachmentSuccessStory_Controller controller = new GLBL_AttachmentSuccessStory_Controller();                     
        Test.startTest();
            controller.saveContent();      
        Test.stopTest();
        }
    }
    
     /* 
          * @Method Name                    :  TestQueryException
          * @Description                    :  Method to test generation of query exception
          * @Return Type                    :  void
          * @Param                          :  
    */
    
    public static testmethod void TestQueryException(){    
        user testuser = GLBL_TestDataUtilityClass.createLPADAdmin();
        system.runas(testuser){
        GLBL_Form_Template__c  FormTempTest = GLBL_TestDataUtilityClass.createFormTemplateForTest();
        insert FormTempTest;
        Attachment AttachmentTest = GLBL_TestDataUtilityClass.CreateAttachmentForTest(FormTempTest.id);
        insert AttachmentTest;
        String idstring = FormTempTest.id+'DetailImage';
        Pagereference p = page.GLBL_AttachmentSuccessStory;
        System.Test.setCurrentPage(p);
        p.getParameters().put('id',idstring);
        GLBL_AttachmentSuccessStory_Controller controller = new GLBL_AttachmentSuccessStory_Controller();                     
        Test.startTest();
            controller.saveContent();    
        Test.stopTest();
        }
    }
}