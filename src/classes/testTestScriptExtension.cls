/**
 ************** Modification Log****************************
 
 @Modified By : Nitish Kumar 
 @Date :        July 2014
 Description :  US-35861 (Ensure all Test Executions are fully completed)  
 */
@isTest
private class testTestScriptExtension {

    static testMethod void myUnitTest() {
        
        //create a project
        MICO_Project__c pro = new MICO_Project__c();
        pro.Name = 'Test Project';
        insert pro;
        
        MICO_User_Story__c objRequirement =new MICO_User_Story__c(
                                                    I_Want_To__c            = 'Test-Description-User-Story',
                                                    Acceptance_Criteria__c  = 'Test-Acceptance-Criteria',
                                                    Story_Points__c         = '21',
                                                    Story_Points_Other__c   = '21',
                                                    Development_Stage__c    = 'Backlog' ,
                                                    Priority__c             = 0,
                                                    Project__c = pro.Id);
        insert objRequirement;
        //get user
        User tstuser = [select id from user where isActive=true LIMIT 1];
        
        //insert template record
        MICO_test_templates__c TT = new MICO_Test_templates__c (User_Story__c = objRequirement.Id,
													            Title__c = 'My test template title',
													            Introduction__c = 'My test template introduction'		
													        	);
        insert TT;
        
        MICO_test_template_steps__c TTS = new MICO_test_template_steps__c(
        Test_Script__c = TT.id
        );
        insert TTS;
        //insert test record
        MICO_Test__c TestHead = new MICO_Test__c(
                                    Template__c = TT.id,
                                    Test_Phase__c = 'Unit',
                                    user_story__c = objRequirement.Id,
                                    project__c = pro.Id
                                    );
        
        //insert 
        insert testHead;

        //Build Children
        MICO_test_steps__c testSt = new MICO_test_steps__c(
                                                    Name='1.23.4.1',
                                                    test__c = TestHead.id,
                                                    Template_Step__c = TTS.id
                                                    
        );
        
        //insert children
        insert testSt;
        
  
        PageReference pageRef = Page.runTestScript;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', testHead.id);
        
       
        ApexPages.Standardcontroller controller = New ApexPages.StandardController(testHead);
        runTestScriptExtension ext = new runTestScriptExtension(controller);
        system.assertequals(ext.TestSp.size(), 1);

        System.currentPageReference().getParameters().put('testId', testSt.id);
        System.currentPageReference().getParameters().put('testName', testSt.name);
        System.currentPageReference().getParameters().put('req', '');
        ext.addBug();
        ext.Bugs[0].Problem__c = 'bla bla';
        system.assertequals(ext.Bugs.size(),1);
        system.assert(ext.isnewBugs, true);
        
        testSt.Outcome__c = 'Passsed' ;
        update testSt ;
        ext.SaveStep();
        
        TestHead.Overall_Test_Comments__c = 'Passsed' ;
        TestHead.Test_Outcome__c = 'Passsed' ;
        update TestHead ;
        
        ext.Save() ;
        
        ext.AttachFile();
        
    
    }
}