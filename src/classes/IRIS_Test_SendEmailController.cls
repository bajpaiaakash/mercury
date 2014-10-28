/*
*  Classname : Iriss_Test_SendEmailController
*   Created By: Deloitte USI    
*   Created Date: 19-Mar-2014
*   Description: This class is the test class for the submission form functionality.
*   Version : 0.1 
*   Change Log
*   Version     Description                         Updated By
*    
*/
@isTest
public with sharing class IRIS_Test_SendEmailController{

    private static IRIS_Submission__c oSubmission{set;get;}
    private static Attachment attach{set;get;}
    
    static void createdata(){
        oSubmission = Iris_Test_Setup.createSubmission();
        attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=oSubmission.id;
        insert attach;
        
    }
    static testMethod void testdoSubmit() {
        system.runas(IRIS_Utility.CreateUserForTestMethods()){
            createdata();
            Apexpages.currentPage().getParameters().put('subId',oSubmission.id); 
            IRIS_SendEmailController econtroller = new IRIS_SendEmailController(new ApexPages.StandardController(oSubmission));
            IRIS_SendEmailController.AttachmentWrapper Attwrap = new IRIS_SendEmailController.AttachmentWrapper(attach);
            //Attwrap.selected = true;
            econtroller.attachWrapList.add(Attwrap);
            Attwrap.selected = true;
            econtroller.allFileList.add(attach);
            econtroller.FileCount = '1';
            econtroller.selectedUserEmail = 'test@test.com';
            econtroller.sCC = 'test@test.com';
            econtroller.sBCC = 'test@test.com';
            econtroller.emailBody = 'Test body';
            econtroller.emailSubject = 'Test subject';
            econtroller.send();
            econtroller.cancel();
            econtroller.ChangeCount();
        }
    }
    
    static testMethod void testEmailNeg() {
        system.runas(IRIS_Utility.CreateUserForTestMethods()){
            createdata();
            Apexpages.currentPage().getParameters().put('subId',oSubmission.id); 
            IRIS_SendEmailController econtroller = new IRIS_SendEmailController(new ApexPages.StandardController(oSubmission));
            IRIS_SendEmailController.AttachmentWrapper Attwrap = new IRIS_SendEmailController.AttachmentWrapper(attach);
            //Attwrap.selected = true;
            econtroller.attachWrapList.add(Attwrap);
            Attwrap.selected = true;
            econtroller.allFileList.add(attach);
            econtroller.FileCount = '1';
            econtroller.sBCC = 'test@test.com';
            econtroller.emailBody = 'Test body';
            econtroller.emailSubject = 'Test subject';
            econtroller.send();
            econtroller.cancel();
            econtroller.ChangeCount();
        }
    }
    
    static testMethod void testSubNeg() {
        system.runas(IRIS_Utility.CreateUserForTestMethods()){
            createdata();
            Apexpages.currentPage().getParameters().put('subId',oSubmission.id); 
            IRIS_SendEmailController econtroller = new IRIS_SendEmailController(new ApexPages.StandardController(oSubmission));
            IRIS_SendEmailController.AttachmentWrapper Attwrap = new IRIS_SendEmailController.AttachmentWrapper(attach);
            //Attwrap.selected = true;
            econtroller.attachWrapList.add(Attwrap);
            Attwrap.selected = true;
            econtroller.allFileList.add(attach);
            econtroller.FileCount = '1';
            econtroller.selectedUserEmail = 'test@test.com';
            econtroller.sCC = 'test@test.com';
            econtroller.sBCC = 'test@test.com';
            econtroller.emailBody = 'Test body';
            econtroller.send();
            econtroller.cancel();
            econtroller.ChangeCount();
        }
    }
    
    static testMethod void testCcNeg() {
        system.runas(IRIS_Utility.CreateUserForTestMethods()){
            createdata();
            Apexpages.currentPage().getParameters().put('subId',oSubmission.id); 
            IRIS_SendEmailController econtroller = new IRIS_SendEmailController(new ApexPages.StandardController(oSubmission));
            IRIS_SendEmailController.AttachmentWrapper Attwrap = new IRIS_SendEmailController.AttachmentWrapper(attach);
            //Attwrap.selected = true;
            econtroller.attachWrapList.add(Attwrap);
            Attwrap.selected = true;
            econtroller.allFileList.add(attach);
            econtroller.FileCount = '1';
            econtroller.sCC = 'test@test.com';
            econtroller.sBCC = 'test@test.com';
            econtroller.emailBody = 'Test body';
            econtroller.emailSubject = 'Test subject';
            econtroller.send();
            econtroller.cancel();
            econtroller.ChangeCount();
        }    
    }
}