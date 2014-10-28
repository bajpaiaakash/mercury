@isTest
private class test_createTestsForTester {

    static testMethod void SingleAdd() {
        //create a project
        MICO_Project__c pro = new MICO_Project__c();
        pro.Name = 'Test Project';
        insert pro;
        
        MICO_User_Story__c objRequirement = new MICO_User_Story__c(
                                                    I_Want_To__c            = 'Test-Description-User-Stroy',
                                                    Acceptance_Criteria__c  = 'Test-Acceptance-Criteria',
                                                    Story_Points__c         = '21',
                                                    Story_Points_Other__c   = '21',
                                                    Development_Stage__c    = 'Backlog' ,
                                                    Priority__c             = 0,
                                                    
                                                    Project__c = pro.Id);
        insert objRequirement;
        
        
        User tstuser = [select id from user where isActive=true LIMIT 1];
        //insert template record
        MICO_test_templates__c TT = new MICO_Test_templates__c( user_story__c = objRequirement.Id,
                                                                Title__c = 'My test template title',
                                                                Introduction__c = 'My test template introduction'
                                                                
                                                                );
        insert TT;
        
        MICO_test_template_steps__c TTS = new MICO_test_template_steps__c(
            Test_Script__c = TT.id
        );
        insert TTS;
        
        TT.Approval_Status__c = 'Approved';
        update TT;
         
        MICO_Tester__c tster = new MICO_Tester__c(
            Test_Template__c = tt.id, 
            User__c = tstuser.id, 
            Test_Phase__c = 'Unit');
            
        insert tster;
         
         
    }
      static testMethod void MultiAdd() {
      List<User> tstuser = [select id from user where isActive=true AND Profile.Name = 'System Administrator' LIMIT 2];
        //create a project
        MICO_Project__c pro = new MICO_Project__c();
        pro.Name = 'Test Project';
        insert pro;
        
        MICO_User_Story__c objRequirement = new MICO_User_Story__c( I_Want_To__c            = 'Test-Description-User-Stroy',
                                                                    Acceptance_Criteria__c  = 'Test-Acceptance-Criteria',
                                                                    Story_Points__c         = '21',
                                                                    Story_Points_Other__c   = '21',
                                                                    Development_Stage__c    = 'Backlog' ,
                                                                    Priority__c             = 0,
                                                                    Project__c = pro.Id);
        insert objRequirement;
        
        MICO_test_templates__c TT = new MICO_Test_templates__c( user_story__c = objRequirement.Id,
                                                                Title__c = 'My test template title',
                                                                Introduction__c = 'My test template introduction'
                                                                
                                                                );
        insert TT;
        
        MICO_test_template_steps__c TTS = new MICO_test_template_steps__c(
            Test_Script__c = TT.id
        );
        insert TTS;
        
        TT.Approval_Status__c = 'Approved';
        update TT;
        
        list<MICO_Tester__c> tster = new List<MICO_Tester__c>();
            for(User u : tstuser){
                tster.add(new MICO_Tester__c(
                Test_Template__c = tt.id, 
                User__c = u.id, 
                Test_Phase__c = 'Unit'));
            }
        insert tster;
        
         
    }
}