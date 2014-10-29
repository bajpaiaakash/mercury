@isTest
private class Test_MICOManageTestScriptStepsController {

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
        
        List<MICO_Test_Template_Steps__c> testScriptStepsList = new List<MICO_Test_Template_Steps__c>();
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
            
        MICO_Test_Template_Steps__c testScriptStep3 = new MICO_Test_Template_Steps__c(
            Test_Script__c     = testScript.Id,
            Action__c          = 'Test 3',
            Expected_Result__c = 'Test 3',
            Tips__c            = 'Test 3');
        
        testScriptStepsList.add(testScriptStep1);
        testScriptStepsList.add(testScriptStep2);
        testScriptStepsList.add(testScriptStep3);
        
        Test.StartTest();
            //Insert the Test Script Steps which will have auto number assigned to them method.
            insert testScriptStepsList;
                        
            //Set the current VF page whose controller is being tested
            PageReference pageRef = Page.MICO_Manage_Test_Script_Steps;
            Test.setCurrentPage(pageRef);          
            //Set the initial page parameter which is passed via URL to the Controller
            ApexPages.currentPage().getParameters().put('testScriptId',testScript.Id);  
            //Invoke the constructor of the controller class by first creating an instance of Standard Controller
            ApexPages.StandardController sc1 = new ApexPages.StandardController(testScriptStep1);
            MICO_Manage_Test_Script_Steps_Controller mtssc = new MICO_Manage_Test_Script_Steps_Controller(sc1);
            
            //Invoke the save method of the Controller without any changes
            mtssc.save();            
            //Invoke the save method of the Controller For Negative Number scenario
            testScriptStepsList[0].Test_Script_Step_Number__c = -1;
            mtssc.testScriptSteps = testScriptStepsList;
            mtssc.save();
            //Invoke the save method of the Controller For 0 scenario
            testScriptStepsList[0].Test_Script_Step_Number__c = 0;
            mtssc.testScriptSteps = testScriptStepsList;
            mtssc.save();
            //Invoke the save method of the Controller For Number larger than steps scenario
            testScriptStepsList[0].Test_Script_Step_Number__c = 4;
            mtssc.testScriptSteps = testScriptStepsList;
            mtssc.save();
            //Invoke the save method of the Controller For Duplicate steps scenario
            testScriptStepsList[0].Test_Script_Step_Number__c = 1;
            testScriptStepsList[1].Test_Script_Step_Number__c = 1;
            testScriptStepsList[2].Test_Script_Step_Number__c = 1;
            mtssc.testScriptSteps = testScriptStepsList;
            mtssc.save();
            //Invoke the save method of the Controller for the Correct data
            testScriptStepsList[0].Test_Script_Step_Number__c = 1;
            testScriptStepsList[1].Test_Script_Step_Number__c = 2;
            testScriptStepsList[2].Test_Script_Step_Number__c = 3;
            mtssc.testScriptSteps = testScriptStepsList;
            mtssc.save();
            
            //Invoke the cancel method
            mtssc.cancel();
        Test.StopTest();
    }
}