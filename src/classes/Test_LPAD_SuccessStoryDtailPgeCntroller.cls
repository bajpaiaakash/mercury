/*
*@ Class Name                                                    : Test_LPAD_SuccessStoryDetailPageController
*@ Description                                                   : Test class for Success Story Detail page
*@ CreatedBy                                                     : Gaurav Suri    
*@ CreatedOn                                                     : 09-10-2014
*@ Modification Log                                              :                                      
*/

@istest(seeAllData=false)

public with sharing class Test_LPAD_SuccessStoryDtailPgeCntroller {
    
    public static testmethod void testSuccessStories(){
        user testuser = GLBL_TestDataUtilityClass.createLPADUser();
        system.runas(testuser){
        GLBL_GSO_Content__c  GSOContentTempTest = GLBL_TestDataUtilityClass.createGSOContentForTest();
        
        Schema.DescribeSObjectResult GSOContentSchema = Schema.SObjectType.GLBL_GSO_Content__c; 
        Map<String,Schema.RecordTypeInfo> GSOContentRecordTypeInfo = GSOContentSchema.getRecordTypeInfosByName();
        ID recID =  GSOContentRecordTypeInfo.get('Success Story').getRecordTypeId();
        
        GSOContentTempTest.RecordTypeId = recID;
        insert GSOContentTempTest;
        Pagereference p = page.LPAD_SuccessStoryDetailPage;
        System.Test.setCurrentPage(p);
        p.getParameters().put('id',GSOContentTempTest.id);
        LPAD_SuccessStoryDetailPageController controller = new LPAD_SuccessStoryDetailPageController();                     
        GLBL_GSO_Content__c testgsoContent = controller.getSuccessStory();
        }
    }
    
   //Negative test case to cover the exception
    public static testmethod void testSuccessStoriesNegative(){
        user testuser = GLBL_TestDataUtilityClass.createLPADUser();
        system.runas(testuser){
        GLBL_GSO_Content__c  GSOContentTempTest = GLBL_TestDataUtilityClass.createGSOContentForTest();
        Schema.DescribeSObjectResult GSOContentSchema = Schema.SObjectType.GLBL_GSO_Content__c; 
        Map<String,Schema.RecordTypeInfo> GSOContentRecordTypeInfo = GSOContentSchema.getRecordTypeInfosByName();
        ID recID =  GSOContentRecordTypeInfo.get('Success Story').getRecordTypeId();
        GSOContentTempTest.RecordTypeId = recID;
        insert GSOContentTempTest;
        LPAD_SuccessStoryDetailPageController controller = new LPAD_SuccessStoryDetailPageController();                     
        GLBL_GSO_Content__c testgsoContent = controller.getSuccessStory();
        
        }
    }

}