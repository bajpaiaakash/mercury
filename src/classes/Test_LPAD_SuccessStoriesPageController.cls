/*
*@ Class Name                                                    : Test_LPAD_SuccessStoriesPageController
*@ Description                                                   : Test class for Success Story page
*@ CreatedBy                                                     : Jayalakshmi Mohananpillai    
*@ CreatedOn                                                     : 09-08-2014
*@ Modification Log                                              :                                      
*/

@istest(seeAllData=false)

public with sharing class Test_LPAD_SuccessStoriesPageController {
    
    public static testmethod void testSuccessStories(){
        user testuser = GLBL_TestDataUtilityClass.createLPADUser();
        system.runas(testuser){
        GLBL_GSO_Content__c  GSOContentTempTest = GLBL_TestDataUtilityClass.createGSOContentForTest();
    
        Schema.DescribeSObjectResult GSOContentSchema = Schema.SObjectType.GLBL_GSO_Content__c; 
        Map<String,Schema.RecordTypeInfo> GSOContentRecordTypeInfo = GSOContentSchema.getRecordTypeInfosByName();
        ID recID =  GSOContentRecordTypeInfo.get('Success Story').getRecordTypeId();
        
        GSOContentTempTest.RecordTypeId = recID;
        insert GSOContentTempTest;
        
        LPAD_SuccessStoriesPageController successStoryController = new LPAD_SuccessStoriesPageController();
        List<GLBL_GSO_Content__c> gsoContentList = successStoryController.getSuccessStories();
        system.assertequals(gsoContentList.size(),1);
        }
    }
    
    //Negative test case to cover the exception
    public static testmethod void testSuccessStoriesNegative(){
         Profile p = [SELECT Id FROM Profile WHERE Name='GSO Basic User_Platform'];        
         User testuser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',profileId = p.id, 
                  LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='LpadAdmin@testorg.com');
        insert testuser;
        system.runas(testuser){
        GLBL_GSO_Content__c  GSOContentTempTest = GLBL_TestDataUtilityClass.createGSOContentForTest();
    
        Schema.DescribeSObjectResult GSOContentSchema = Schema.SObjectType.GLBL_GSO_Content__c; 
        Map<String,Schema.RecordTypeInfo> GSOContentRecordTypeInfo = GSOContentSchema.getRecordTypeInfosByName();
        ID recID =  GSOContentRecordTypeInfo.get('Success Story').getRecordTypeId();
        
        GSOContentTempTest.RecordTypeId = recID;
        //insert GSOContentTempTest;
        
        LPAD_SuccessStoriesPageController successStoryController = new LPAD_SuccessStoriesPageController();
        List<GLBL_GSO_Content__c> gsoContentList = successStoryController.getSuccessStories();
        system.assertNotequals(gsoContentList.size(),1);
        }
    }

}