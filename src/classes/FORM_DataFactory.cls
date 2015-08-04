/*Class Name :FORM_DataFactory
*Description : Utility class for FormBuilder Project
*Createdby : Goutham
*Created Date : 29-10-2014
*Modification Log:
*--------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                        Modification           ID         Description
*---------------------------------------------------------------------------------------------------------------------------------------

*/

@isTest(seeAllData=False)
public class FORM_DataFactory{
       

   //Creating User(Commented for Now as sharing data model is not yet finalised)
     public static User createUser(String PermissionSetLabel){
   
       Profile pfl = [select id from profile where name='GSO Basic User_Platform'];
       //Declaring the User
       string randomName = string.valueof(Datetime.now()).replace('-','').replace(':','').replace(' ','')+ String.valueof(Math.round(Math.random())); 
       User runAsUser = new User(alias = 'alias', email='appAdmin@testorg.com',
       emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
       localesidkey='en_US', profileid = pfl.Id,  country='United States', CommunityNickname = String.valueof(Math.random())+'u1',
       timezonesidkey='America/Los_Angeles', username=randomName+'@gso_org.com');
    
       Insert runAsUser;     
        
       PermissionSet pSet = [SELECT ID,Label from PermissionSet WHERE Name=:PermissionSetLabel];
       PermissionSetAssignment Asign = New PermissionSetAssignment();
       Asign.AssigneeId=runAsUser.ID;
       Asign.PermissionSetId=pSet.ID;
       Insert Asign;
    
       return runAsUser;
    
   }

   //Inserting Form Templates
   public static List<GLBL_Form_Template__c> createTemplates(Integer count){
       List<GLBL_Form_Template__c> lTemplates  = new List<GLBL_Form_Template__c>();
       for(Integer i = 0 ; i < count ; i++){
           GLBL_Form_Template__c Template = New GLBL_Form_Template__c();
           Template.Name = 'Test Form';
           Template.Data_Criticality__c='Green';
           Template.Description__c='TestDescription';
           Template.End_Date__c=System.today()+30;
           Template.GxP_relevant__c='Yes';
           Template.Notify_User__c=Userinfo.getUserId();
           Template.Approval_Required__c=FALSE;
           Template.Start_Date__c=System.today();
           Template.Status__c='Available';
           Template.Type__c='Standard Form';
           lTemplates.add(Template);
        }
        insert lTemplates;
        return lTemplates;
    }
    
   //Inserting Form Executions
   public static List<GLBL_Form_Execution__c> createExecutions(Integer count, GLBL_Form_Template__c frmTemplate){
       //List<GLBL_Form_Template__c> lTemplates  = createTemplates(count);
       List<GLBL_Form_Execution__c> lExecutions = new List<GLBL_Form_Execution__c>();
       for(Integer i = 0 ; i < count ; i++){
            GLBL_Form_Execution__c Execution = New GLBL_Form_Execution__c();
            Execution.Form_Name__c='Test';
            Execution.Description__c='TestDescription';
            Execution.Source_Form__c=frmTemplate.id;
            Execution.Type__c='Standard Form';
            Execution.Execution_Status__c='Complete';
            lExecutions.add(Execution);
       }
       insert lExecutions;
       return lExecutions;
    }
    
    //Inserting Currency Type Questions
   public static List<GLBL_Form_Template_Question__c> createCurrencyQuestions(Integer count,GLBL_Form_Template__c frmTemplate){
       //List<GLBL_Form_Template__c> lTemplates  = createTemplates(count);
       List<GLBL_Form_Template_Question__c> lQuestions = new List<GLBL_Form_Template_Question__c>();
       for(Integer i = 0 ; i < count ; i++){
            GLBL_Form_Template_Question__c Question = New GLBL_Form_Template_Question__c();
            Question.Active__c=TRUE;
            Question.Attachment_Allowed__c=TRUE;
            Question.Character_Limit__c=3;
            Question.Decimal_Places__c=3;
            Question.Form_Template__c=frmTemplate.ID;
            Question.Helptext__c='Test';
            Question.Question_Text__c='Test';
            Question.Question_Type__c='Currency';
            Question.Sequence__c=1;
            lQuestions.add(Question);
       }
       insert lQuestions;
       return lQuestions;
    }
   
   //Inserting Free Text Type Questions
   public static List<GLBL_Form_Template_Question__c> createFreeTextQuestions(Integer count,GLBL_Form_Template__c frmTemplate){
       //List<GLBL_Form_Template__c> lTemplates  = createTemplates(count);
       List<GLBL_Form_Template_Question__c> lQuestions = new List<GLBL_Form_Template_Question__c>();
       for(Integer i = 0 ; i < count ; i++){
            GLBL_Form_Template_Question__c Question = New GLBL_Form_Template_Question__c();
            Question.Active__c=TRUE;
            Question.Attachment_Allowed__c=TRUE;
            Question.Character_Limit__c=3;                
            Question.Form_Template__c=frmTemplate.ID;
            Question.Helptext__c='Test';
            Question.Question_Text__c='Test';
            Question.Question_Type__c='Free Text';
            Question.Sequence__c=1;
            lQuestions.add(Question);
       }
       insert lQuestions;
       return lQuestions;
   }
   
   
   //Inserting Picklist Type Questions
   public static List<GLBL_Form_Template_Question__c> createPicklistQuestions(Integer count,GLBL_Form_Template__c frmTemplate){
       //List<GLBL_Form_Template__c> lTemplates  = createTemplates(count);
       List<GLBL_Form_Template_Question__c> lQuestions = new List<GLBL_Form_Template_Question__c>();
       for(Integer i = 0 ; i < count ; i++){
           GLBL_Form_Template_Question__c Question = New GLBL_Form_Template_Question__c();
           Question.Active__c=TRUE;
           Question.Attachment_Allowed__c=TRUE;                
           Question.Form_Template__c=frmTemplate.ID;
           Question.Helptext__c='Test';
           Question.Question_Text__c='Test';
           Question.Question_Type__c='Picklist';
           Question.Sequence__c=1;
           lQuestions.add(Question);
       }
       insert lQuestions;
       return lQuestions;
   }
    
   //Inserting Number Type Questions
   public static List<GLBL_Form_Template_Question__c> createNumberQuestions(Integer count,GLBL_Form_Template__c frmTemplate){
       //List<GLBL_Form_Template__c> lTemplates  = createTemplates(count);
       List<GLBL_Form_Template_Question__c> lQuestions = new List<GLBL_Form_Template_Question__c>();
       for(Integer i = 0 ; i < count ; i++){
           GLBL_Form_Template_Question__c Question = New GLBL_Form_Template_Question__c();
           Question.Active__c=TRUE;
           Question.Attachment_Allowed__c=TRUE;
           Question.Character_Limit__c=3;
           Question.Decimal_Places__c=3;
           Question.Form_Template__c=frmTemplate.ID;
           Question.Helptext__c='Test';
           Question.Question_Text__c='Test';
           Question.Question_Type__c='Number';
           Question.Sequence__c=1;
           lQuestions.add(Question);
       }
       insert lQuestions;
       return lQuestions;
   }
    
   // Inserting form Execution Question answer
   public static GLBL_Form_Execution_Question_Answer__c createFormExecutionQuestionAnswer(GLBL_Form_Execution__c frmExecution, GLBL_Form_Template_Question__c frmTemplateQues){
       GLBL_Form_Execution_Question_Answer__c frmExecQA = new GLBL_Form_Execution_Question_Answer__c();
       frmExecQA.Form_Execution__c = frmExecution.id;
       frmExecQA.Helptext__c = 'Sample Text';
       frmExecQA.Sequence__c = 1;
       frmExecQA.Question_Text__c = 'Sample Question Text';
       frmExecQA.Response_Boolean__c=True;
       frmExecQA.Response_Number__c=12;
       frmExecQA.Response_Text__c='Test';
       frmExecQA.Source_Question__c=frmTemplateQues.id;
       
       insert frmExecQA;
       return frmExecQA;
   }
   
   //Inserting Answer options for Picklist type questions
   public static List<GLBL_Form_Template_Answer_Option__c> createAnswerOptions(Integer count,GLBL_Form_Template_Question__c frmTemplateQues){
       //List<GLBL_Form_Template_Question__c> lPicklistTypeQuestions = createPicklistQuestions(count);
       List<GLBL_Form_Template_Answer_Option__c> lAnswers = new List<GLBL_Form_Template_Answer_Option__c>();
       for(Integer i = 0 ; i < count ; i++){
            GLBL_Form_Template_Answer_Option__c Answer = New GLBL_Form_Template_Answer_Option__c();
            Answer.Answer_option__c='TestAnswerOption';
            Answer.Form_Template_Question__c=frmTemplateQues.ID;
            Answer.Helptext__c='Test';
            Answer.Sequence__c=1;
            lAnswers.add(Answer);
       }
       insert lAnswers;
       return lAnswers;
    }
    
    // Inserting Custom Settings Record 
    public static GLBL_AttachmentImageSettings__c createAttachmentSettings(){
        
        GLBL_AttachmentImageSettings__c attachSettings = new GLBL_AttachmentImageSettings__c();
        
        attachSettings.Name = 'Logo Test Settings';
        attachSettings.Field_API_Name__c = 'Logo_Image__c';
        attachSettings.Object_API_Name__c = 'GLBL_Form_Template__c';
        attachSettings.Image_Height__c = 155;
        attachSettings.Image_Size__c =  512000;
        attachSettings.Image_Width__c = 576;
        
        insert attachSettings;
        return attachSettings;
    }
    
    //Inserting Multiple Form Team members for single form template
   public static List<GLBL_Form_Team__c> createFormTeams(list<User> lUsers, GLBL_Form_Template__c frmTemplate){
       //List<GLBL_Form_Template__c> lTemplates = createTemplates(count);
       integer count = lUsers.size();
       List<GLBL_Form_Team__c> lformTeamMembers = new List<GLBL_Form_Team__c>();
       for(Integer i = 0 ; i < count ; i++){
            GLBL_Form_Team__c formTeamMember = New GLBL_Form_Team__c();
            formTeamMember.Follow_Template__c=True;
            formTeamMember.Form_Team_Member__c=lUsers[i].ID;
            formTeamMember.Form_Template__c=frmTemplate.ID;
            formTeamMember.Permission__c=label.FORM_Access_Level_RW; 
            lformTeamMembers.add(formTeamMember);
       }
       insert lformTeamMembers;
       return lformTeamMembers;
    }
    
    //Inserting EntitySubscription record for current user to folow a list of records
   public static List<EntitySubscription> createEntitySubscriptions(list<SObject> lrecords){
       List<EntitySubscription> lentitySubscriptions=New List<EntitySubscription>(); 
       integer count=lrecords.size();
       string UserID=Userinfo.getuserID();
       for(Integer i = 0 ; i < count ; i++){
           String TemplateID = lrecords[i].ID;          
           lentitySubscriptions.add(new EntitySubscription(ParentId = TemplateID, SubscriberID = UserID));
        }
       insert lentitySubscriptions;
       return lentitySubscriptions;
    }
    public static List<GLBL_Form_Team__c> create_Form_Team(List<User> lteamMember, List<GLBL_Form_Template__c> lformTemplate){
        List<GLBL_Form_Team__c> lformTeam = new List<GLBL_Form_Team__c>();
        for(GLBL_Form_Template__c formTempObj : lformTemplate){
        for(User teamMemObj: lteamMember){
        GLBL_Form_TEAM__c teamObj = new GLBL_FORM_TEAM__c();
        teamObj.Form_Team_Member__c = teamMemObj.Id;
        teamObj.Form_Template__c = formTempObj.Id;
        teamObj.Permission__c =  Label.FORM_Access_Level_RW;
        lformteam.add(teamObj);
        }
        }
        insert lformTeam;
        return lformTeam;
    }
    
}