/*************************************************************************\
    @ Author        : Nitish Kumar
    @ Date          : 03-Sept-2014
    @ Description   : Test Class for MICO_AttachmentTrigger
****************************************************************************/
@isTest

private class Test_Mico_AttachmentTrigger {
	
	 public static MICO_Project__c project;
     public static MICO_User_Story__c testUserStory;
     public static MICO_Test_Templates__c testScript;
     public static MICO_Test_Template_Steps__c testScriptStep;
     public static MICO_Test__c testExecution;
     public static MICO_Test_Steps__c testExecutionStep;
     public static list<Attachment> insertAttachment;
     
      static testMethod void setupTestData() {
        
        project = new MICO_Project__c();
        project.Name = 'Test Project';
        insert project;
        
        testUserStory = new MICO_User_Story__c();
        testUserStory.Project__c = project.id;
        testUserStory.Acceptance_Criteria__c = 'OldAcceptanceCriteria';
        testUserStory.Compliance_Criteria__c = 'OldCC';
        testUserStory.Approval_Status__c = 'Open';
        insert testUserStory;
        
        insertAttachment = new list<Attachment>();
      	
      	testScript = new MICO_Test_Templates__c();
      	testScript.User_Story__c = testUserStory.Id ;
      	testScript.Introduction__c = 'Test' ;
      	testScript.Title__c = 'Test' ;
      	testScript.Approval_Status__c = 'Approved';
      	insert testScript;
      	
      	Attachment attachScript =new Attachment();   	
    	attachScript.Name='Test Attachment';
    	Blob bodyBlobScript=Blob.valueOf('Unit Test Attachment Body');
    	attachScript.body=bodyBlobScript;
        attachScript.parentId=testScript.id;
        insertAttachment.add(attachScript);
      	
      	testScriptStep = new MICO_Test_Template_Steps__c();
      	testScriptStep.Test_Script__c = testScript.Id ;
      	insert testScriptStep ;
      	
      	Attachment attachScriptStep =new Attachment();   	
    	attachScriptStep.Name='Test Attachment';
    	Blob bodyBlobScriptStep =Blob.valueOf('Unit Test Attachment Body');
    	attachScriptStep.body=bodyBlobScriptStep;
        attachScriptStep.parentId=testScriptStep.id;
        insertAttachment.add(attachScriptStep);
      	
      	testExecution = new MICO_Test__c();
      	testExecution.User_Story__c = testUserStory.Id ;
      	testExecution.Template__c = testScript.Id ;
      	testExecution.Project__c = project.Id ;
      	testExecution.Approval_Status__c = 'Open';
      	insert testExecution ;
      	
      	Attachment attachExecution =new Attachment();   	
    	attachExecution.Name='Test Attachment';
    	Blob bodyBlobExecution =Blob.valueOf('Unit Test Attachment Body');
    	attachExecution.body=bodyBlobExecution;
        attachExecution.parentId=testExecution.id;
        insertAttachment.add(attachExecution);
      	
      	testExecutionStep = new MICO_Test_Steps__c();
      	testExecutionStep.Test__c = testExecution.Id ;
      	testExecutionStep.Template_Step__c = testScriptStep.Id ;
      	insert testExecutionStep ;
      	
      	Attachment attachExecutionStep =new Attachment();   	
    	attachExecutionStep.Name='Test Attachment';
    	Blob bodyBlobExecutionStep =Blob.valueOf('Unit Test Attachment Body');
    	attachExecutionStep.body=bodyBlobExecutionStep;
        attachExecutionStep.parentId=testExecutionStep.id;
        insertAttachment.add(attachExecutionStep);
        
        insert insertAttachment ;
        
        testExecution.Approval_Status__c = 'Approved';
      	update testExecution ;
      	
      }
      
      static testMethod void testAttachmentTrigger() {
      	
      	setupTestData();
      	
      	Test.StartTest();
      	
      	try{
      	delete insertAttachment;
      	}
      	Catch(Exception ex){
      	}
      	
      	testScript.Approval_Status__c = 'Open';
      	update testScript;
      	
      	testExecution.Approval_Status__c = 'Open';
      	update testExecution ;
      	
      	delete insertAttachment;
      	
      	Test.StopTest();
      	
      }

}