/*
*@ Class Name                                                    : GLBL_FormTemplateActions
*@ Description                                                   : Class for creation of Test dats for Text class usage ( LaunchPad)
*@ CreatedBy                                                     : Jayalakshmi Mohanan Pillai
*@ CreatedOn                                                     : 08-21-2014
*@ Modification Log                                              : On 12-02-2014, modified the folowing :
                                                                      1) End date to be after start Date due to new custom validation rule in create Form template method 
                                                                      2) Question type cannot be blank  : added Type                                   
*/


@isTest
public class GLBL_TestDataUtilityClass {
    
    // Class level Variable declaration
    public Static Final String TYPE_LAUNCHPAD = 'Launchpad Assessment';
    public static final string LPADUSER = 'LPAD_User';
    public static final string LPADADMIN = 'LPAD_Admin';
    
    
    public static User createLPADAdmin(){
          
        PermissionSet psLpadAdmin = [SELECT ID From PermissionSet WHERE Name =: LPADADMIN];
        Profile p = [SELECT Id FROM Profile WHERE Name='GSO Basic User_Platform'];          
        PermissionSetAssignment PSAssignments = new PermissionSetAssignment();
        
        //Create Lpad Admin
        User LpadAdmin1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',profileId = p.id, 
                          LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='LpadAdmin@testorg.com');
        
        insert LpadAdmin1;
        
        PSAssignments.AssigneeId = LpadAdmin1.id;
        PSAssignments.PermissionSetId = psLpadAdmin.ID;
        
        insert PSAssignments;
        
        return LpadAdmin1;                    
        
    }
    
    public static User createLPADUser(){
        PermissionSet psLpadUser = [SELECT ID From PermissionSet WHERE Name =: LPADUSER];
        Profile p = [SELECT Id FROM Profile WHERE Name='GSO Basic User_Platform'];   
        PermissionSetAssignment PSAssignments = new PermissionSetAssignment();
        
        //Create Lpad User
        User LpadUser1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',profileId = p.id, 
                          LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='LpadUser@testorg.com');
        insert LpadUser1;
        
        PSAssignments.AssigneeId = LpadUser1.id;
        PSAssignments.PermissionSetId = psLpadUser.ID;
        
        insert PSAssignments;                         
        
        return LpadUser1;
    }
     /* 
          * @Method Name                    :  createFormTemplateForTest
          * @Description                    :  This Method will called from the test class with the respective
                                               parameters it will instantiate the object and return it to the 
                                               test class
          * @Return Type                    :  GLBL_Form_Template__c
          * @Param                          :  
                                            
      */
      public static GLBL_Form_Template__c createFormTemplateForTest() {
          GLBL_Form_Template__c sObj = new GLBL_Form_Template__c(Start_Date__c=system.today(),End_Date__c=system.today()+7,Description__c = 'Sample Description',
                                                                  status__c='Available',Type__c = TYPE_LAUNCHPAD);
          return sObj;            
      }
      
      
      /* 
          * @Method Name                    :  createFormTemplateQuestionForTest
          * @Description                    :  This Method will called from the test class with the respective
                                               parameters it will instantiate the object and return it to the 
                                               test class
          * @Return Type                    :  GLBL_Form_Template_Question__c
          * @Param                          :  formTemplateId : form template Id 
                                            
      */
      public static GLBL_Form_Template_Question__c createFormTemplateQuestionForTest(id formTemplateId) {
          GLBL_Form_Template_Question__c sObj = new GLBL_Form_Template_Question__c(Form_Template__c = formTemplateId,Active__c = True,Question_Type__c = 'Picklist',
                                                                                   Helptext__c = 'Sample Text',Question_Text__c = 'Sample Question Text',
                                                                                   Sequence__c = 12);
          return sObj;            
      }
      
      
      /* 
          * @Method Name                    :  createFormTemplateAnswerOptionForTest
          * @Description                    :  This Method will called from the test class with the respective
                                               parameters it will instantiate the object and return it to the 
                                               test class
          * @Return Type                    :  GLBL_Form_Template_Answer_Option__c
          * @Param                          :  formTemplateAnswOptionId : form template Answer Option Id 
                                            
      */
      public static GLBL_Form_Template_Answer_Option__c createFormTemplateAnswerOptionForTest(id formTemplateAnswOptionId) {
          GLBL_Form_Template_Answer_Option__c sObj = new GLBL_Form_Template_Answer_Option__c(Answer_option__c = 'test option', 
                                                                                             Form_Template_Question__c = formTemplateAnswOptionId,
                                                                                             Helptext__c = 'Sample Text',
                                                                                             Sequence__c = 12);
          return sObj;            
      }
      
      
      /* 
          * @Method Name                    :  createFormExecutionForTest
          * @Description                    :  This Method will called from the test class with the respective
                                               parameters it will instantiate the object and return it to the 
                                               test class
          * @Return Type                    :  GLBL_Form_Execution__c
          * @Param                          :  formTemplateId : form template Id
                                            
      */
      public static GLBL_Form_Execution__c createFormExecutionForTest(id formTemplateId) {
          GLBL_Form_Execution__c sObj = new GLBL_Form_Execution__c(Description__c = 'Sample Description', 
                                                                   Source_Form__c = formTemplateId,                     
                                                                   Type__c = TYPE_LAUNCHPAD);
          return sObj;            
      }
      
      /* 
          * @Method Name                    :  createFormExecutionForTest
          * @Description                    :  This Method will called from the test class with the respective
                                               parameters it will instantiate the object and return it to the 
                                               test class
          * @Return Type                    :  GLBL_Form_Execution_Question_Answer__c
          * @Param                          :  formExecId : form execution Id
                                               formTempQuestId : form Template question Id
                                            
      */
      public static GLBL_Form_Execution_Question_Answer__c createFormExecQuestAnsForTest(id formExecId, id formTempQuestId) {
          GLBL_Form_Execution_Question_Answer__c sObj = new GLBL_Form_Execution_Question_Answer__c(Form_Execution__c = formExecId, 
                                                            Helptext__c = 'Sample Text', Sequence__c = 12,Question_Text__c = 'Sample Question Text',
                                                            Response_Boolean__c=True,Response_Number__c=12,Response_Text__c='Test',
                                                            Source_Question__c=formTempQuestId);
          return sObj;            
      }
      
      /* 
          * @Method Name                    :  CreateAttachmentForTest
          * @Description                    :  This Method will be called from the test class with the respective
                                               parameters it will instantiate the object and return it to the 
                                               test class
          * @Return Type                    :  Attachment
          * @Param                          :  
                                            
      */
      public static attachment CreateAttachmentForTest(id parentidparam) {
          Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
          attachment sObj = new attachment(Name='Unit Test Attachment',Body=bodyBlob,ParentId=parentidparam);
          return sObj;            
      }
      
       /* 
          * @Method Name                    :  createGSOContentForTest
          * @Description                    :  This Method will be called from the test class with the respective
                                               parameters it will instantiate the object and return it to the 
                                               test class
          * @Return Type                    :  GLBL_GSO_Content__c
          * @Param                          :  
                                            
      */
      public static GLBL_GSO_Content__c CreateGSOContentForTest() {
          GLBL_GSO_Content__c sObj = new GLBL_GSO_Content__c(Name='Test1',Active__c = True,Description__c = 'Sample Description');
          return sObj;            
      }
      
      public static LPAD_Settings__c createLPADSettingsDataForTest(){
          LPAD_Settings__c  sObj = new LPAD_Settings__c(Name='Default', Chatter_Group__c='test grp', Footer_Email__c='xyz@gso1.lly.com');
          return sObj;      
      } 
      
      
}