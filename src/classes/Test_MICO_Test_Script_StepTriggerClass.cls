@isTest
private class Test_MICO_Test_Script_StepTriggerClass {

    static testMethod void Test_theEntireClass() {
        //set up the pre-requisite data
        MICO_App__c app = new MICO_App__c();
        app.Name = 'MICO2';
        insert app;
        
        MICO_Project__c project = new MICO_Project__c();
        project.Name = 'MICOSprints2';
        insert project;
         
        MICO_User_Story__c userstory = new MICO_User_Story__c(
            I_Want_To__c            = 'Test-Description-User-Stroy',
            Acceptance_Criteria__c  = 'Test-Acceptance-Criteria',
            Story_Points__c         = '13',
            Story_Points_Other__c   = '13',
            Development_Stage__c    = 'Backlog' ,
            Priority__c             = 0,
            Project__c              = project.Id);
        insert userstory;
        
        //insert approver
        User approver = new User(
            Alias             = 'aprvr1',
            Email             = 'approver@mico-testscript.com',
            EmailEncodingKey  = 'UTF-8',
            LastName          = 'User',
            FirstName         = 'Approver',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey      = 'en_US',
            ProfileId         = [select Id from Profile where Name = 'GLBL_Chatter Only' limit 1].Id,
            TimeZoneSidKey    = 'America/Chicago',
            Username          = 'stakeholder@mico-test' + Math.round(Math.random() * 10000) + '.com',
            UserRoleId        = null,
            Country           = 'Great Britain');
        insert approver;
        
        MICO_test_templates__c testScript = new MICO_Test_templates__c(
            User_Story__c      = userstory.Id,
            Title__c           = 'My test template title',
            Introduction__c    = 'My test template introduction',
            Approver__c        = approver.Id,
            Approval_Status__c = 'Open');
        insert testScript;
        
        MICO_Test_Template_Steps__c testScriptStep1 = new MICO_Test_Template_Steps__c(
            Test_Script__c     = testScript.Id,
            Action__c          = 'Test 1',
            Expected_Result__c = 'Test 1',
            Tips__c            = 'Test 1');
        
        MICO_Test_Template_Steps__c testScriptStep2 = new MICO_Test_Template_Steps__c(
            Test_Script__c     = testScript.Id,
            Action__c          = 'Test 2',
            Expected_Result__c = 'Test 2',
            Tips__c            = 'Test 2');
        
        Test.StartTest();
            //Test the updateSequenceNumberOnInsert method.
            insert testScriptStep1;
            insert testScriptStep2;
            
            //Test the updateSequenceNumberOnDelete method.
            delete testScriptStep1;
            delete testScriptStep2;
        Test.StopTest();
    }
}