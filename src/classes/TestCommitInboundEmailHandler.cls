/****************************************************************************************************************************************** 
* Class Name   : TestCommitInboundEmailHandler
* Description  : Test class for class CommitInboundEmailHandler    
* Created By   : Robin Wijnen
* Created Date : 16 November 2012
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                  Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Robin Wijnen         16 November 2012          Initial version

*****************************************************************************************************************************************/

@isTest (seeAlldata=false)

private class TestCommitInboundEmailHandler {
    /*
    * Method name: SendJenkinsEmail
    * @description Method: Create Test Jenkins mail with different formats
    */ 
    static testMethod void SendJenkinsEmail() {
        // Create the Custom Settings 
        JenkinsCommitDetails__c inst = new JenkinsCommitDetails__c();
        inst.Name               = 'Author';
        inst.FieldName__c       = 'Author__c';
        insert(inst);
        
        inst = new JenkinsCommitDetails__c();
        
        inst.Name               = 'Body';
        inst.FieldName__c       = 'Body__c';
        insert(inst);
        
        inst = new JenkinsCommitDetails__c();
        
        inst.Name               = 'Related To';
        inst.FieldName__c       = 'Related_To__c';
        insert(inst);

        inst = new JenkinsCommitDetails__c();
        
        inst.Name               = 'Files';
        inst.FieldName__c       = 'Files__c';
        insert(inst);
        
        inst = new JenkinsCommitDetails__c();
        
        inst.Name = 'Link';
        inst.FieldName__c       = 'Link__c';
        insert(inst);
        
        inst = new JenkinsCommitDetails__c();
        
        inst.Name               = 'Revision';
        inst.FieldName__c       = 'Revision__c';
        insert(inst);

        inst = new JenkinsCommitDetails__c();
        
        inst.Name               = 'DefRef';
        inst.FieldName__c       = 'DEF-[0-9]{6}';
        insert(inst);
        
        inst = new JenkinsCommitDetails__c();
        
        inst.Name               = 'USRef';
        inst.FieldName__c       = 'US-[0-9]{4}';
        insert(inst);
        
        inst = new JenkinsCommitDetails__c();
        
        inst.Name               = 'SeperatorString';
        inst.FieldName__c       = '===';
        insert(inst);
        
        inst = new JenkinsCommitDetails__c();
        
        inst.Name               = 'SeperatorCommits';
        inst.FieldName__c       = '&&&';
        insert(inst);
        
        // Create test objects that are required
        MICO_Project__c project = new MICO_Project__c();
        MICO_User_Story__c USTest = new MICO_User_Story__c();
        MICO_Bug__c DefTest = new MICO_Bug__c();
    
        project.Name = 'Tracker';
        insert project;
        
        USTest.Project__c = project.Id;
        insert USTest;
        
        MICO_User_Story__c instUSTest = [SELECT Name FROM MICO_User_Story__c WHERE Id=:USTest.Id];
        
        DefTest.Status__c = 'Raised';
        DefTest.Technology__c = 'SFDC/Veeva';
        DefTest.Problem__c = 'Problem Summary';  
        DefTest.Problem_Description__c = 'Blablablabla';
        DefTest.User_Story__c = instUSTest.Id; 
        DefTest.Project2__c = project.Id;  
        insert(DefTest);
        
        MICO_Bug__c instDefTest = [SELECT Name FROM MICO_Bug__c WHERE Id=:DefTest.Id];
          
        // Date of today
        Datetime myDate = Datetime.now();
        String testDate = String.valueOf(myDate);
        String sUSRef = '';        
        
        // Create a new email and envelope object for US Mail
        Messaging.Inboundemail emailUS = new Messaging.Inboundemail();
        Messaging.Inboundenvelope envUS = new Messaging.Inboundenvelope();
        
        emailUS.fromAddress                 ='robin.wijnen@gmail.com';
        emailUS.subject                     ='Jenkins Poll ' + testDate;
        emailUS.plainTextBody               ='Author:eu\\rwijnen===Body:' + instUSTest.Name + ' - Test tesding class===Revision:84===Files:TestCommit4.txt;&&&';
        System.Debug('Name from US: ' + instUSTest.Name);
        System.Debug('Full body message:' + emailUS.plainTextBody);
        CommitInboundEmailHandler testHandlerUS = new CommitInboundEmailHandler();
        
       
        // Set up the mail DEF
        Messaging.Inboundemail emailDef = new Messaging.Inboundemail();
        Messaging.Inboundenvelope envDef = new Messaging.Inboundenvelope();
        
        emailDef.fromAddress                ='robin.wijnen@gmail.com';
        emailDef.subject                    ='Jenkins Poll ' + testDate;
        emailDef.plainTextBody              ='Author:rwijnen===Body:' + instDefTest.Name + ' - Test tesding class===Revision:84===Files:TestCommit4.txt;&&&';
        System.Debug('Name from Def: ' + instDefTest.Name);
        CommitInboundEmailHandler testHandlerDEF = new CommitInboundEmailHandler();
        
        
        // Set up the mail US without Author to trigger exception
        Messaging.Inboundemail emailUSNoAuthor = new Messaging.Inboundemail();
        Messaging.Inboundenvelope envUSNoAuthor = new Messaging.Inboundenvelope();
        
        emailUSNoAuthor.fromAddress         ='robin.wijnen@gmail.com';
        emailUSNoAuthor.subject             ='Jenkins Poll ' + testDate;
        emailUSNoAuthor.plainTextBody       ='Body:US-0001 - Test tesgin class with no author===Revision:1===Files:Testcommit1.txt;&&&';
        
        CommitInboundEmailHandler testHandlerUSNoAuthor = new CommitInboundEmailHandler();
        
        // Set up the mail without a body
        Messaging.Inboundemail emailNoBody = new Messaging.Inboundemail();
        Messaging.Inboundenvelope envNoBody = new Messaging.Inboundenvelope();
        
        emailNoBody.fromAddress             ='robin.wijnen@gmail.com';
        emailNoBody.subject                 ='Jenkins Poll ' + testDate;
        emailNoBody.plainTextBody           ='';
        
        CommitInboundEmailHandler testHandlerNoBody = new CommitInboundEmailHandler();
        
        // Set up random text that doens't have the layout from the email body from Jenkins
        Messaging.Inboundemail emailRandomBody = new Messaging.Inboundemail();
        Messaging.Inboundenvelope envRandomBody = new Messaging.Inboundenvelope();
        
        emailRandomBody.fromAddress         ='robin.wijnen@gmail.com';
        emailRandomBody.subject             ='Jenkins Poll ' + testDate;
        emailRandomBody.plainTextBody       ='sqfsfsdfs fsfsd fs &&& efesfsf;dfdsfdsf;dsfsd;fdsfsd;dsf&&&';
        
        CommitInboundEmailHandler testHandlerRandomBody = new CommitInboundEmailHandler();
        
        // Start the testing
        Test.startTest();
        Messaging.InboundEmailResult resultUS = testHandlerUS.handleInboundEmail(emailUS, envUS);
        Messaging.InboundEmailResult resultDef = testHandlerDEF.handleInboundEmail(emailDef, envDef);
        Messaging.InboundEmailResult resultUSNoAuthor = testHandlerUSNoAuthor.handleInboundEmail(emailUSNoAuthor, envUSNoAuthor);
        Messaging.InboundEmailResult restulNoBody = testHandlerNoBody.handleInboundEmail(emailNoBody,envNoBody);
        Messaging.InboundEmailResult resultRandomBody = testHandlerRandomBody.handleInboundEmail(emailRandomBody,envRandomBody);
        Test.stopTest();
    }
    
    static testMethod void sendErrorMail() {
        try {
            list<MICO_SCM_Commit__c> listSCMRecord = new list<MICO_SCM_Commit__c>();
            
            // No author
            MICO_SCM_Commit__c testSCM = new MICO_SCM_Commit__c();
            testSCM.Body__c = 'blblblbl';
            listSCMRecord.add(testSCM);
            
            insert listSCMRecord;           
        }
        catch (DMLException e) {
            CommitInboundEmailHandler testErrorMail = new CommitInboundEmailHandler();
            testErrorMail.sendErrorMail(e, 'test'); 
        }
    }
}