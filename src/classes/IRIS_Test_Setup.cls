@isTest
public class IRIS_Test_Setup {
    
    public static IRIS_Region__c createRegion(String regionName)
    {
        IRIS_Region__c testRegion = new IRIS_Region__c(name=regionName);
        insert testRegion;
        return testRegion;
    }
    
    public static List<IRIS_Country__c> createCountries(List<String> lstCountryNames)
    {
        List<IRIS_Country__c> lstCountries = new List<IRIS_Country__c>();
        for(String countryName : lstCountryNames)
        {
            lstCountries.add(new IRIS_Country__c(name=countryName));    
        }
        insert lstCountries;
        return lstCountries;
    }
    
    public static List<IRIS_Region_Country__c> createRegionCountryMapping(IRIS_Region__c region, List<IRIS_Country__c> lstCountries)
    {
        List<IRIS_Region_Country__c> lstCountryRegion = new List<IRIS_Region_Country__c>();
        for(IRIS_Country__c country : lstCountries)
        {
            lstCountryRegion.add(new IRIS_Region_Country__c(Country__c=country.id, Region__c=region.id));
        }
        insert lstCountryRegion;
        return lstCountryRegion;
    }

    public static IRIS_Submission__c createSubmission() {
        IRIS_Submission__c oSubmission = new IRIS_Submission__c();
        oSubmission.COE_Category__c = 'HR Investigations';
        oSubmission.Sub_Category__c = 'General Message';
        oSubmission.Intended_Audience__c = IRIS_Constants.SUBMISSION_INTENDED_AUDIENCE_GLOBAL;
        oSubmission.Document_Owner__c = UserInfo.getUserId();
        oSubmission.Document_Submitter__c = UserInfo.getUserId();
        oSubmission.Status__c = IRIS_Constants.SUBMISSION_STATUS_SUBMITTED;
        insert oSubmission;
        return oSubmission;
    }
    
    public static List<IRIS_Question__c> createQuestions(integer iCount)
    {
        List<IRIS_Question__c> lstQuestions = new List<IRIS_Question__c>();
        for(integer i = 1; i<=iCount; i++)
        {
            lstQuestions.add(new IRIS_Question__c(Active__c=true, Question__c='This is question '+i,
                                                     Question_Number__c='QuesNo.'+i));
        }
        insert lstQuestions;
        return lstQuestions;
    }
    
    public static IRIS_Assessment__c createAssessment(String assessmentName)
    {
        IRIS_Assessment__c assessment = new IRIS_Assessment__c(isActive__c=true, name=assessmentName);
        insert assessment;
        return assessment;
    }
    
    public static List<IRIS_Assessment_Questions__c> createAssessQuestions(IRIS_Assessment__c assess, List<IRIS_Question__c> lstQues)
    {
        List<IRIS_Assessment_Questions__c> lstAssessQues = new List<IRIS_Assessment_Questions__c>();
        IRIS_Assessment_Questions__c assessQues;
        Double iCount = 1.0;
        for(IRIS_Question__c ques : lstQues)
        {
            assessQues = new IRIS_Assessment_Questions__c();
            assessQues.Assessment__c = assess.id;
            assessQues.Question__c = ques.id;
            assessQues.Total_Score__c = 5.0;
            assessQues.Sequence__c = iCount;
            iCount++;
            lstAssessQues.add(assessQues);
        }
        insert lstAssessQues;
        return lstAssessQues;   
    }
    
    public static User newAffiliateUser(){
        Profile oProfile = [SELECT Id FROM Profile WHERE Name=:IRIS_Constants.PROFILE_AFFILIATE_NAME]; 
        User oUser = new User(Alias = 'affuser', Email='testAffiliateUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = oProfile.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='affiliateuser_test@testorg.com');
        insert oUser;
        return oUser;
    }
    
    public static User newAssessorUser(){
        Profile oProfile = [SELECT Id FROM Profile WHERE Name='System administrator'];
        PermissionSet oPerSer = [SELECT Id FROM PermissionSet WHERE Name=: IRIS_Constants.PROFILE_ASSESSOR_NAME];
        system.debug('oProfile '+oProfile );
        User oUser = new User(Alias = 'assuser', Email='testAssessorUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US',  ProfileId =oProfile.id,
        TimeZoneSidKey='America/Los_Angeles', UserName='assessoruser_test@testorg.com', FirstName = 'Assessor');
        insert oUser;
        //List<PermissionSetAssignment> lPermissionSetAssign = [SELECT Assignee.name, PermissionSet.name,PermissionSetId FROM PermissionSetAssignment where PermissionSet.Name=: IRIS_Constants.PROFILE_ASSESSOR_NAME' and AssigneeId =: oUserId Limit 1];
        PermissionSetAssignment pSA=new PermissionSetAssignment(AssigneeId =oUser.id, PermissionSetId=oPerSer.Id );
        return oUser;
    }
}