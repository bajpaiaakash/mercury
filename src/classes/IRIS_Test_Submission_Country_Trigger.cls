/*
*  Classname : Iriss_Test_Submission_Country_Trigger
*   Created By: Deloitte USI    
*   Created Date: 27-Mar-2014
*   Description: This class is the test class for the submission country trigger.
*   Version : 0.1 
*   Change Log
*   Version     Description                         Updated By
*    
*/
@isTest
private class IRIS_Test_Submission_Country_Trigger {
  
  private static IRIS_Region__c region1{set;get;}
    private static IRIS_Region__c region2{set;get;}
    
    private static list<IRIS_Country__c> lstCountries1{set;get;}
    private static list<IRIS_Country__c> lstCountries2{set;get;}
    
    private static IRIS_Submission__c oSubmission{set;get;}
  
  static Attachment createAttachment(){
      Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        attach.body=Blob.valueOf('Unit Test Attachment Body');
        return attach;
    }
  
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
  
    static void createLocalSubmission() {
      // create test data for country, region and their mapping
       createRegionCountryData();
        // invoking the page
        Test.setCurrentPage(Page.Iris_Submission_Form);
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
        IRIS_Submission_FormControllerExtension controller = new IRIS_Submission_FormControllerExtension(new ApexPages.StandardController(new IRIS_Submission__c()));
        // setting up the fields on the submission form
        controller.oSubmission.COE_Category__c = IRIS_Submission__c.COE_Category__c.getDescribe().getPicklistValues()[0].getValue();
        controller.oSubmission.Sub_Category__c = IRIS_Submission__c.Sub_Category__c.getDescribe().getPicklistValues()[0].getValue();
        controller.oSubmission.Document_Owner__c = UserInfo.getUserId();
        controller.oSubmission.Language__c = IRIS_Submission__c.Language__c.getDescribe().getPicklistValues()[0].getValue();
        controller.oSubmission.Intended_Audience__c = Iris_Constants.SUBMISSION_INTENDED_AUDIENCE_LOCAL;
        controller.checkAudience();
        // setting the region name and region ids
        controller.oSubmission.Country_Text__c = lstCountries1[0].name + ';' + lstCountries2[1].name;
        controller.selectedCountryIds = lstCountries1[0].id + ';' + lstCountries2[1].id;
        // setting the file count 
        controller.FileCount = '1';
        controller.ChangeCount();
        //uploading the document
        Attachment attach = createAttachment();
        controller.allFileList.add(attach);
        controller.doSubmit();
        oSubmission = controller.oSubmission;
    }
    
    static testMethod void testSubCountryUpdate() {
      system.runas(IRIS_Utility.CreateUserForTestMethods()){
      // create test data for country, region and their mapping
       createRegionCountryData();
       // creating the Submission Country records
       createLocalSubmission();
       
        IRIS_Submission__c osub=new IRIS_Submission__c();
        osub.Country_Text__c='test ';
            insert osub;
            
       System.debug('Compliance_Submission__c'+oSubmission.id);
       IRIS_Submission_Country__c testcountry=new IRIS_Submission_Country__c(Compliance_Submission__c=osub.id,Country__c=lstCountries1[1].id);
       insert testcountry;
        List<IRIS_Submission_Country__c> lstSubCountries = [select Country__c,Country_Name__c from IRIS_Submission_Country__c
                                   where Compliance_Submission__c = : osub.id];
    // system.assert(lstSubCountries != null && lstSubCountries.size()>0 , 'Submission country is not created');
     // updating the country on the Submission Country
     IRIS_Submission_Country__c subCountry = lstSubCountries[0];
     subCountry.Country__c = lstCountries2[0].id;
     oSubmission = [Select Country_Text__c,Region_Text__c 
                                from IRIS_Submission__c where id = : osub.id];
     Test.startTest();
     IRIS_Submission_Country_Trigger_Helper.hasTakenCareOf = null;
     update subCountry;
     Test.stopTest();
     IRIS_Submission__c queriedSubmission = [Select Country_Text__c,Region_Text__c 
                                from IRIS_Submission__c where id = : osub.id];
    // system.assertNotEquals(oSubmission.Country_Text__c , queriedSubmission.Country_Text__c);
     //system.assertNotEquals(oSubmission.Region_Text__c , queriedSubmission.Region_Text__c);
     }
    }
    
    static testMethod void testSubCountryDelete() {
    system.runas(IRIS_Utility.CreateUserForTestMethods()){
    createRegionCountryData();
       // creating the Submission Country records
       createLocalSubmission();
       IRIS_Submission__c osub=new IRIS_Submission__c();
       osub.Country_Text__c='test ';
            insert osub;
            IRIS_Submission_Country__c testcountry=new IRIS_Submission_Country__c(Compliance_Submission__c=osub.id,Country__c=lstCountries1[1].id);
            insert testcountry;
        List<IRIS_Submission_Country__c> lstSubCountries = [select Country__c,Country_Name__c from IRIS_Submission_Country__c
                                   where Compliance_Submission__c = : osub.id];
     system.assert(lstSubCountries != null && lstSubCountries.size()>0 , 'Submission country is not created');
     // updating the country on the Submission Country
     IRIS_Submission_Country__c subCountry = lstSubCountries[0];
     oSubmission = [Select Country_Text__c,Region_Text__c 
                                from IRIS_Submission__c where id = : osub.id];
     Test.startTest();
     IRIS_Submission_Country_Trigger_Helper.hasTakenCareOf = null;
     delete subCountry;
     Test.stopTest();
     IRIS_Submission__c queriedSubmission = [Select Country_Text__c,Region_Text__c 
                                from IRIS_Submission__c where id = : osub.id];
     //system.assertNotEquals(oSubmission.Country_Text__c , queriedSubmission.Country_Text__c);
     //system.assertNotEquals(oSubmission.Region_Text__c , queriedSubmission.Region_Text__c);
    }
    }
}