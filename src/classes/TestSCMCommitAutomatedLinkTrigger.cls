/****************************************************************************************************************************************** 
* Class Name   : TestSCMCommitAutomatedLinkTrigger
* Description  : Test class for trigger SCMCommitAutomatedLink    
* Created By   : Robin Wijnen
* Created Date : 20 November 2012
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                  Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Robin Wijnen         20 November 2012          Initial version

*****************************************************************************************************************************************/
@isTest (seeAllData=false)

private class TestSCMCommitAutomatedLinkTrigger {
    /*
    * Method name: createSCMRecord
    * @description: Create test SCM Record to trigger the trigger   
    */ 
    static testMethod void createSCMRecord() {
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
        
        // Create Project
        MICO_Project__c project = new MICO_Project__c();
        project.Name = 'Tracker';
        insert project;
        
        // Create US Ref
        MICO_User_Story__c USTest = new MICO_User_Story__c();
        USTest.Project__c = project.Id;
        insert USTest;
        
        // Create Def Ref
        MICO_Bug__c DefTest = new MICO_Bug__c();
        
        MICO_User_Story__c instUSTest = [SELECT Name FROM MICO_User_Story__c WHERE Id=:USTest.Id];
        
        DefTest.Status__c = 'Raised';
        DefTest.Technology__c = 'SFDC/Veeva';
        DefTest.Problem__c = 'Problem Summary';  
        DefTest.Problem_Description__c = 'Blablablabla';
        DefTest.User_Story__c = instUSTest.Id;   
        insert(DefTest);
        
        MICO_Bug__c instDefTest = [SELECT Name FROM MICO_Bug__c WHERE Id=:DefTest.Id];
        
        // Create the SCM Commit record for US Ref
        MICO_SCM_Commit__c scmUSRec = new MICO_SCM_Commit__c();
        scmUSRec.Author__c = 'Test';
        scmUSRec.Body__c = 'Test Body';
        scmUSRec.Files__c = 'Test Files.txt';
        scmUSRec.Related_To__c = instUSTest.Name;
        
        System.Debug('Insert scmUSRec: ' + scmUSRec);
        
        // Create the SCM Commit Record for Def Ref
        MICO_SCM_Commit__c scmDefRec = new MICO_SCM_Commit__c();
        scmDefRec.Author__c = 'Test';
        scmDefRec.Body__c = 'Test Body';
        scmDefRec.Files__c = 'Test Files.txt';
        scmDefRec.Related_To__c = instDefTest.Name;
        
        System.Debug('Insert scmDefRec: ' + scmDefRec);
        
        Test.startTest();
        insert scmUSRec;
        insert scmDefRec;
        Test.stopTest();
    }
}