/*
*  Classname : Iriss_Test_SubmissionFormExtnCont
*   Created By: Deloitte USI    
*   Created Date: 19-Mar-2014
*   Description: This class is the test class for the submission form functionality.
*   Version : 0.1 
*   Change Log
*   Version     Description                         Updated By
*    
*/
@isTest
public with sharing class IRIS_Test_SubmissionFormExtnCont {

    
    
    private static IRIS_Region__c region1{set;get;}
    private static IRIS_Region__c region2{set;get;}
    
    private static list<IRIS_Country__c> lstCountries1{set;get;}
    private static list<IRIS_Country__c> lstCountries2{set;get;}
  
    static void createRegionCountryData(){
        region1 = Iris_Test_Setup.createRegion('testRegionName1');
        region2 = Iris_Test_Setup.createRegion('testRegionName2');
        
        lstCountries1 = Iris_Test_Setup.createCountries(new List<String>{'testCountry1','testCountry2','testCountry3'});
        lstCountries2 = Iris_Test_Setup.createCountries(new List<String>{'testCountry4','testCountry5','testCountry6'});
        //adding a common country
        lstCountries2.add(lstCountries1[0]);
        
        Iris_Test_Setup.createRegionCountryMapping(region1, lstCountries1);
        Iris_Test_Setup.createRegionCountryMapping(region2, lstCountries2);
    }
    
    static Attachment createAttachment(){
      Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        attach.body=Blob.valueOf('Unit Test Attachment Body');
        return attach;
    }
     
     static testMethod void testdoSubmitForGlobal() {
        system.runas(IRIS_Utility.CreateUserForTestMethods()){
            Test.startTest();
            // invoking the page
            List<IRIS_Access_Buttons__c> lbutton=new List<IRIS_Access_Buttons__c>();
            
          
            IRIS_Access_Buttons__c testbutton1=new IRIS_Access_Buttons__c(Name='System Administrator',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
            
            IRIS_Access_Buttons__c testbutton2=new IRIS_Access_Buttons__c(Name='    IRIS_Submission_Hybrid_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
            
            IRIS_Access_Buttons__c testbutton3=new IRIS_Access_Buttons__c(Name='    IRIS_Submission_Assessment_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
            
            IRIS_Access_Buttons__c testbutton4=new IRIS_Access_Buttons__c(Name='IRIS_Submission_Approval_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
            
            IRIS_Access_Buttons__c testbutton5=new IRIS_Access_Buttons__c(Name='    IRIS_Submission_Affiliate_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
            
            IRIS_Access_Buttons__c testbutton6=new IRIS_Access_Buttons__c(Name='    Application Administrator',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
            
            lbutton.add(testbutton1);
            lbutton.add(testbutton2);
            lbutton.add(testbutton3);
            lbutton.add(testbutton4);
            lbutton.add(testbutton5);
            lbutton.add(testbutton6);
            
            
            insert lbutton;
            Test.setCurrentPage(Page.Iris_Submission_Form);
            IRIS_Submission_FormControllerExtension controller = new IRIS_Submission_FormControllerExtension (new ApexPages.StandardController(new IRIS_Submission__c()));
            // setting up the fields on the submission form
            controller.oSubmission.COE_Category__c = IRIS_Submission__c.COE_Category__c.getDescribe().getPicklistValues()[0].getValue();
            controller.oSubmission.Sub_Category__c = IRIS_Submission__c.Sub_Category__c.getDescribe().getPicklistValues()[0].getValue();
            controller.oSubmission.Document_Owner__c = UserInfo.getUserId();
            controller.oSubmission.Language__c = IRIS_Submission__c.Language__c.getDescribe().getPicklistValues()[0].getValue();
            controller.oSubmission.Intended_Audience__c = Iris_Constants.SUBMISSION_INTENDED_AUDIENCE_GLOBAL;
            controller.checkAudience();
            // setting the file count 
            controller.FileCount = '1';
            controller.ChangeCount();
            //uploading the document
            Attachment attach = createAttachment();
            controller.allFileList.add(attach);
            controller.doSubmit();
            Test.stopTest();
            IRIS_Submission__c oSub = [Select id, Status__c,Document_Submitter__c From IRIS_Submission__c Where id =: controller.oSubmission.id];
            System.Assertequals(oSub.Status__c, Iris_Constants.SUBMISSION_STATUS_SUBMITTED);
            System.Assertequals(oSub.Document_Submitter__c, UserInfo.getUserId());
            System.Assertequals(controller.showCountry,false);
            System.Assertequals(controller.showRegion,false);
            
            Attachment queryAttach = [select name from Attachment where parentId = : controller.oSubmission.id];
            system.assertNotEquals(queryAttach,null);
            system.assertEquals(queryAttach.name,'Unit Test Attachment');
            
            // calling the method on click of Clear button
            PageReference returnedPage = controller.doReload();
            //system.assert(returnedPage.getUrl().containsIgnoreCase(Page.Iris_Submission_Form.getUrl()));
            
            // calling the method on click of Back button
            returnedPage = controller.doBack();
            system.assert(returnedPage.getUrl().containsIgnoreCase(IRIS_Submission__c.sObjectType.getDescribe().getKeyPrefix()));
        }    
    }
    
    static testMethod void testdoSubmitForRegional() {
       system.runas(IRIS_Utility.CreateUserForTestMethods()){
       // create test data for country, region and their mapping
       createRegionCountryData();
        Test.startTest();
        List<IRIS_Access_Buttons__c> lbutton=new List<IRIS_Access_Buttons__c>();
        
      
        IRIS_Access_Buttons__c testbutton1=new IRIS_Access_Buttons__c(Name='System Administrator',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
        
        IRIS_Access_Buttons__c testbutton2=new IRIS_Access_Buttons__c(Name='    IRIS_Submission_Hybrid_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
        
        IRIS_Access_Buttons__c testbutton3=new IRIS_Access_Buttons__c(Name='    IRIS_Submission_Assessment_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
        
        IRIS_Access_Buttons__c testbutton4=new IRIS_Access_Buttons__c(Name='IRIS_Submission_Approval_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
        
        IRIS_Access_Buttons__c testbutton5=new IRIS_Access_Buttons__c(Name='    IRIS_Submission_Affiliate_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
        
        IRIS_Access_Buttons__c testbutton6=new IRIS_Access_Buttons__c(Name='    Application Administrator',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
        
        lbutton.add(testbutton1);
        lbutton.add(testbutton2);
        lbutton.add(testbutton3);
        lbutton.add(testbutton4);
        lbutton.add(testbutton5);
        lbutton.add(testbutton6);
        
        
        insert lbutton;
        // invoking the page
        Test.setCurrentPage(Page.Iris_Submission_Form);
        IRIS_Submission_FormControllerExtension controller = new IRIS_Submission_FormControllerExtension(new ApexPages.StandardController(new IRIS_Submission__c()));
        // setting up the fields on the submission form
        controller.oSubmission.COE_Category__c = IRIS_Submission__c.COE_Category__c.getDescribe().getPicklistValues()[0].getValue();
        controller.oSubmission.Sub_Category__c = IRIS_Submission__c.Sub_Category__c.getDescribe().getPicklistValues()[0].getValue();
        controller.oSubmission.Document_Owner__c = UserInfo.getUserId();
        controller.oSubmission.Language__c = IRIS_Submission__c.Language__c.getDescribe().getPicklistValues()[0].getValue();
        controller.oSubmission.Intended_Audience__c = Iris_Constants.SUBMISSION_INTENDED_AUDIENCE_REGIONAL;
        controller.checkAudience();
        // setting the region name and region ids
        controller.oSubmission.Region_Text__c = region1.name + ';' + region2.name;
        controller.selectedRegionIds = region1.id + ';' + region2.id;
        Set<Id> setRegionIds = new Set<Id>{region1.id,region2.id}; 
        // setting the file count 
        controller.FileCount = '1';
        controller.ChangeCount();
        //uploading the document
        Attachment attach = createAttachment();
        controller.allFileList.add(attach);
        controller.doSubmit();
        Test.stopTest();
        IRIS_Submission__c oSub = [Select id, Status__c,Document_Submitter__c From IRIS_Submission__c Where id =: controller.oSubmission.id];
        System.Assertequals(oSub.Status__c, Iris_Constants.SUBMISSION_STATUS_SUBMITTED);
        System.Assertequals(oSub.Document_Submitter__c, UserInfo.getUserId());
        System.Assertequals(controller.showCountry,false);
        System.Assertequals(controller.showRegion,true);
        
        Attachment queryAttach = [select name from Attachment where parentId = : controller.oSubmission.id];
        system.assertNotEquals(queryAttach,null);
        system.assertEquals(queryAttach.name,'Unit Test Attachment');
        
        List<IRIS_Submission_Region__c> lstSubRegions = [select Region__c from IRIS_Submission_Region__c
                                   where Compliance_Submission__c = :controller.oSubmission.id];
     System.Assertequals(lstSubRegions.size(),2);
     
        for(IRIS_Submission_Region__c subRegion : lstSubRegions){
            if(subRegion.Region__c!=null || subRegion.Region__c!=''){
                system.assert(setRegionIds.contains(subRegion.Region__c));
            }
        }
    }
   } 
    static testMethod void testdoSubmitForLocal() {
        system.runas(IRIS_Utility.CreateUserForTestMethods()){
       // create test data for country, region and their mapping
       createRegionCountryData();
        Test.startTest();
        List<IRIS_Access_Buttons__c> lbutton=new List<IRIS_Access_Buttons__c>();
        
      
        IRIS_Access_Buttons__c testbutton1=new IRIS_Access_Buttons__c(Name='System Administrator',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
        
        IRIS_Access_Buttons__c testbutton2=new IRIS_Access_Buttons__c(Name='    IRIS_Submission_Hybrid_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
        
        IRIS_Access_Buttons__c testbutton3=new IRIS_Access_Buttons__c(Name='    IRIS_Submission_Assessment_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
        
        IRIS_Access_Buttons__c testbutton4=new IRIS_Access_Buttons__c(Name='IRIS_Submission_Approval_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
        
        IRIS_Access_Buttons__c testbutton5=new IRIS_Access_Buttons__c(Name='    IRIS_Submission_Affiliate_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
        
        IRIS_Access_Buttons__c testbutton6=new IRIS_Access_Buttons__c(Name='    Application Administrator',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
        
        lbutton.add(testbutton1);
        lbutton.add(testbutton2);
        lbutton.add(testbutton3);
        lbutton.add(testbutton4);
        lbutton.add(testbutton5);
        lbutton.add(testbutton6);
        
        
        insert lbutton;
        // invoking the page
        Test.setCurrentPage(Page.Iris_Submission_Form);
        IRIS_Submission_FormControllerExtension controller = new IRIS_Submission_FormControllerExtension(new ApexPages.StandardController(new IRIS_Submission__c()));
        // setting up the fields on the submission form
        controller.oSubmission.COE_Category__c = IRIS_Submission__c.COE_Category__c.getDescribe().getPicklistValues()[0].getValue();
        controller.oSubmission.Sub_Category__c = IRIS_Submission__c.Sub_Category__c.getDescribe().getPicklistValues()[0].getValue();
        controller.oSubmission.Document_Owner__c = UserInfo.getUserId();
        controller.oSubmission.Language__c = IRIS_Submission__c.Language__c.getDescribe().getPicklistValues()[0].getValue();
        controller.oSubmission.Intended_Audience__c = Iris_Constants.SUBMISSION_INTENDED_AUDIENCE_LOCAL;
        controller.checkAudience();
        // setting the region name and region ids
        controller.oSubmission.Country_Text__c = lstCountries1[0].name + ';' + lstCountries2[0].name;
        controller.selectedCountryIds = lstCountries1[0].id + ';' + lstCountries2[0].id;
        Set<Id> setCountryIds = new Set<Id>{lstCountries1[0].id,lstCountries2[0].id}; 
        // setting the file count 
        controller.FileCount = '1';
        controller.ChangeCount();
        //uploading the document
        Attachment attach = createAttachment();
        controller.allFileList.add(attach);
        controller.doSubmit();
        Test.stopTest();
        IRIS_Submission__c oSub = [Select id, Status__c,Document_Submitter__c From IRIS_Submission__c Where id =: controller.oSubmission.id];
        System.Assertequals(oSub.Status__c, Iris_Constants.SUBMISSION_STATUS_SUBMITTED);
        System.Assertequals(oSub.Document_Submitter__c, UserInfo.getUserId());
        System.Assertequals(controller.showCountry,true);
        System.Assertequals(controller.showRegion,false);
        
        Attachment queryAttach = [select name from Attachment where parentId = : controller.oSubmission.id];
        system.assertNotEquals(queryAttach,null);
        system.assertEquals(queryAttach.name,'Unit Test Attachment');
        
        List<IRIS_Submission_Country__c> lstSubCountries = [select Country__c from IRIS_Submission_Country__c
                                   where Compliance_Submission__c = :controller.oSubmission.id];
     System.Assertequals(lstSubCountries.size(),2);
     for(IRIS_Submission_Country__c subCountry : lstSubCountries){
       system.assert(setCountryIds.contains(subCountry.Country__c));
     }
     }
    }
    
    static testMethod void generalNegativeTesting() {
        system.runas(IRIS_Utility.CreateUserForTestMethods()){
        // invoking the page
        
        List<IRIS_Access_Buttons__c> lbutton=new List<IRIS_Access_Buttons__c>();
        
      
        IRIS_Access_Buttons__c testbutton1=new IRIS_Access_Buttons__c(Name='System Administrator',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
        
        IRIS_Access_Buttons__c testbutton2=new IRIS_Access_Buttons__c(Name='    IRIS_Submission_Hybrid_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
        
        IRIS_Access_Buttons__c testbutton3=new IRIS_Access_Buttons__c(Name='    IRIS_Submission_Assessment_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
        
        IRIS_Access_Buttons__c testbutton4=new IRIS_Access_Buttons__c(Name='IRIS_Submission_Approval_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
        
        IRIS_Access_Buttons__c testbutton5=new IRIS_Access_Buttons__c(Name='    IRIS_Submission_Affiliate_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
        
        IRIS_Access_Buttons__c testbutton6=new IRIS_Access_Buttons__c(Name='    Application Administrator',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
        
        lbutton.add(testbutton1);
        lbutton.add(testbutton2);
        lbutton.add(testbutton3);
        lbutton.add(testbutton4);
        lbutton.add(testbutton5);
        lbutton.add(testbutton6);
        
        
        insert lbutton;
        
         Test.setCurrentPage(Page.Iris_Submission_Form);
        
        IRIS_Submission_FormControllerExtension controller = new IRIS_Submission_FormControllerExtension (new ApexPages.StandardController(new IRIS_Submission__c()));
        // setting up the fields on the submission form
        controller.oSubmission.COE_Category__c = IRIS_Submission__c.COE_Category__c.getDescribe().getPicklistValues()[0].getValue();
        controller.oSubmission.Sub_Category__c = IRIS_Submission__c.Sub_Category__c.getDescribe().getPicklistValues()[0].getValue();
        controller.oSubmission.Document_Owner__c = UserInfo.getUserId();
        controller.oSubmission.Language__c = IRIS_Submission__c.Language__c.getDescribe().getPicklistValues()[0].getValue();
        controller.oSubmission.Intended_Audience__c = Iris_Constants.SUBMISSION_INTENDED_AUDIENCE_LOCAL;
        controller.checkAudience();
        // trying to submit without fileCount
        controller.doSubmit();
        system.assertEquals(controller.isFormSubmitted , false);
        // setting the file count 
        controller.FileCount = '1';
        controller.ChangeCount();
        // trying to submit without any attachment
        controller.doSubmit();
        system.assertEquals(controller.isFormSubmitted , false);
        //uploading the document
        Attachment attach = createAttachment();
        controller.allFileList.add(attach);
        //trying to submit without any countries selected
        controller.doSubmit();
        system.assertEquals(controller.isFormSubmitted , false);
        
        // asserting that the submission record didn't get created
        system.assertEquals(controller.oSubmission.id , null);
        }
    }
    
    static testMethod void negativeTesting() {
        system.runas(IRIS_Utility.CreateUserForTestMethods()){
            // invoking the page
            List<IRIS_Access_Buttons__c> lbutton=new List<IRIS_Access_Buttons__c>();
            
          
            IRIS_Access_Buttons__c testbutton1=new IRIS_Access_Buttons__c(Name='System Administrator',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
            
            IRIS_Access_Buttons__c testbutton2=new IRIS_Access_Buttons__c(Name='    IRIS_Submission_Hybrid_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
            
            IRIS_Access_Buttons__c testbutton3=new IRIS_Access_Buttons__c(Name='    IRIS_Submission_Assessment_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
            
            IRIS_Access_Buttons__c testbutton4=new IRIS_Access_Buttons__c(Name='IRIS_Submission_Approval_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
            
            IRIS_Access_Buttons__c testbutton5=new IRIS_Access_Buttons__c(Name='    IRIS_Submission_Affiliate_Profile',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
            
            IRIS_Access_Buttons__c testbutton6=new IRIS_Access_Buttons__c(Name='    Application Administrator',Approve_Reject__c=true,Back__c=true,Save_as_Draft__c=true,Submit_for_Approval__c=true);
            
            lbutton.add(testbutton1);
            lbutton.add(testbutton2);
            lbutton.add(testbutton3);
            lbutton.add(testbutton4);
            lbutton.add(testbutton5);
            lbutton.add(testbutton6);
            
            
            insert lbutton;
            Test.setCurrentPage(Page.Iris_Submission_Form);
            IRIS_Submission_FormControllerExtension controller = new IRIS_Submission_FormControllerExtension (new ApexPages.StandardController(new IRIS_Submission__c()));
            // setting up the fields on the submission form
            controller.oSubmission.COE_Category__c = IRIS_Submission__c.COE_Category__c.getDescribe().getPicklistValues()[0].getValue();
            controller.oSubmission.Sub_Category__c = IRIS_Submission__c.Sub_Category__c.getDescribe().getPicklistValues()[0].getValue();
            controller.oSubmission.Document_Owner__c = UserInfo.getUserId();
            controller.oSubmission.Language__c = IRIS_Submission__c.Language__c.getDescribe().getPicklistValues()[0].getValue();
            controller.oSubmission.Intended_Audience__c = Iris_Constants.SUBMISSION_INTENDED_AUDIENCE_LOCAL;
            controller.checkAudience();
            // setting the file count 
            controller.FileCount = '1';
            controller.ChangeCount();
            //uploading the document
            Attachment attach = createAttachment();
            controller.allFileList.add(attach);
            //trying to submit without any countries selected
            controller.doSubmit();
            system.assertEquals(controller.isFormSubmitted , false);
            
            // asserting that the submission record didn't get created
            system.assertEquals(controller.oSubmission.id , null);
        }
    }
}