@isTest 
public class Test_SubmitForApproval
{
    public static testMethod void testSendEmailMethod(){
    
        User stakeholderUser = new User(Alias             = 'stkhldr',
                        Email             = 'stakeholderUser@mico-test.com',
                        EmailEncodingKey  = 'UTF-8',
                        LastName          = 'User',
                        FirstName         = 'Stakeholder',
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey      = 'en_US',
                        ProfileId         = [select Id from Profile where Name = 'System Administrator' limit 1].Id,
                        TimeZoneSidKey    = 'America/Chicago',
                        Username          = 'stakeholder@mico-test' + Math.round(Math.random() * 10000) + '.com',
                        UserRoleId        = null,
                        Country           = 'Great Britain');
        insert stakeholderUser;
        MICO_Project__c project = new MICO_Project__c();
        project.Name = 'mico-project';
        insert project;
        MICO_App__c app = new MICO_App__c();
        app.Name = 'mico-app';
        app.System_Custodian__c = stakeholderUser.Id;
        app.System_Owner__c = stakeholderUser.Id;
        app.Business_Quality__c = stakeholderUser.Id;
        app.Computer_Systems_Quality__c = stakeholderUser.Id;
        insert app;
        
        MICO_User_Story__c story = new MICO_User_Story__c();
        story.App__c = app.Id;
        story.Project__c = project.Id;
        story.Submitter__c=UserInfo.getUserId();
        story.approval_status__c='Approved';
        insert story;
        
        MICO_SubmitForApproval.SendEmailMethod(story.id);
        
        MICO_Test_Templates__c testScriptObj=new MICO_Test_Templates__c(Title__c='test',Introduction__c='test',User_Story__c=story.id,Submitter__c=UserInfo.getUserid(),Approval_Status__c='Open');
        insert testScriptObj;
        
        MICO_SubmitForApproval.SendEmailMethodTestScript(testScriptObj.id);
        
        MICO_Test__c testExecObj=new MICO_Test__c(Submitter__c=UserInfo.getUserid(),Approval_Status__c='Open',Project__c=project.id);
        insert testExecObj;
        
        MICO_SubmitForApproval.SendEmailMethodTestExcecution(testExecObj.id);
        
        
    }
    
    
}